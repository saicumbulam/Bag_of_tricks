# Code Patterns Reference — Python Edition

Patterns that `ralph-implementer` reads during each iteration before writing
code. Consistent patterns reduce iteration time, prevent duplicate utilities,
and keep the codebase coherent across sessions.

**Rule:** Before writing any new utility, check `src/lib/` (or `src/core/`,
`src/shared/`) for an existing one. If a pattern below doesn't exist in your
project yet, the first iteration that needs it should create it.

---

## Project Layout

```
src/
├── __init__.py
├── main.py                 # app entry point (FastAPI app / script runner)
├── config.py               # settings (Pydantic BaseSettings)
├── lib/                    # shared utilities — check here before writing anything new
│   ├── __init__.py
│   ├── database.py         # DB pool / session factory
│   ├── errors.py           # custom exception hierarchy
│   ├── logging.py          # structured logger factory
│   └── security.py         # auth helpers (token verify, hash password)
├── models/                 # Pydantic schemas (request/response shapes)
│   └── __init__.py
├── services/               # business logic (pure functions / service classes)
│   └── __init__.py
├── api/                    # FastAPI routers (thin — delegate to services)
│   ├── __init__.py
│   └── deps.py             # FastAPI dependency functions
├── db/                     # SQLAlchemy ORM models and migrations
│   ├── __init__.py
│   └── models.py
└── workers/                # background tasks / Celery / ARQ workers
    └── __init__.py

tests/
├── conftest.py             # shared fixtures (test db, test client, factories)
├── unit/                   # pure logic tests — no I/O
└── integration/            # tests with real DB / HTTP client
```

---

## Configuration — Pydantic BaseSettings

**Never** scatter `os.environ.get()` calls through the codebase.
Centralise all config in `src/config.py`.

```python
# src/config.py
from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    # Database
    database_url: str
    db_pool_size: int = 10
    db_max_overflow: int = 20

    # Auth
    secret_key: str
    access_token_expire_minutes: int = 30
    algorithm: str = "HS256"

    # App
    debug: bool = False
    log_level: str = "INFO"


@lru_cache
def get_settings() -> Settings:
    return Settings()
```

**Usage:**
```python
from src.config import get_settings

settings = get_settings()
conn_str = settings.database_url
```

---

## Database Access — SQLAlchemy Async

**Never** create engine or sessions outside `src/lib/database.py`.

```python
# src/lib/database.py
from collections.abc import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from src.config import get_settings

settings = get_settings()

engine = create_async_engine(
    settings.database_url,
    pool_size=settings.db_pool_size,
    max_overflow=settings.db_max_overflow,
    echo=settings.debug,
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    expire_on_commit=False,
    autoflush=False,
)


async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

**Usage in FastAPI route:**
```python
from fastapi import Depends
from sqlalchemy.ext.asyncio import AsyncSession
from src.lib.database import get_db

@router.get("/users/{user_id}")
async def get_user(user_id: int, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()
```

**Usage in service:**
```python
# Pass session in, don't import it directly — makes testing easy
async def get_user_by_email(db: AsyncSession, email: str) -> User | None:
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()
```

---

## Error Handling — Custom Exception Hierarchy

**Never** raise raw `Exception` or `ValueError` from business logic.
Use typed exceptions from `src/lib/errors.py`.

```python
# src/lib/errors.py
from http import HTTPStatus


class AppError(Exception):
    """Base for all application errors."""
    status_code: int = HTTPStatus.INTERNAL_SERVER_ERROR
    detail: str = "An unexpected error occurred"

    def __init__(self, detail: str | None = None) -> None:
        self.detail = detail or self.__class__.detail
        super().__init__(self.detail)


class NotFoundError(AppError):
    status_code = HTTPStatus.NOT_FOUND
    detail = "Resource not found"


class ValidationError(AppError):
    status_code = HTTPStatus.UNPROCESSABLE_ENTITY
    detail = "Validation failed"


class AuthError(AppError):
    status_code = HTTPStatus.UNAUTHORIZED
    detail = "Authentication required"


class ForbiddenError(AppError):
    status_code = HTTPStatus.FORBIDDEN
    detail = "Insufficient permissions"


class ConflictError(AppError):
    status_code = HTTPStatus.CONFLICT
    detail = "Resource already exists"
```

**Wire into FastAPI:**
```python
# src/main.py
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from src.lib.errors import AppError

app = FastAPI()

@app.exception_handler(AppError)
async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})
```

**Usage:**
```python
from src.lib.errors import NotFoundError, ConflictError

async def get_user(db: AsyncSession, user_id: int) -> User:
    user = await db.get(User, user_id)
    if not user:
        raise NotFoundError(f"User {user_id} not found")
    return user
```

---

## Pydantic Models — Request/Response Schemas

**Never** return ORM models directly from routes. Always use Pydantic schemas.

```python
# src/models/user.py
from datetime import datetime
from pydantic import BaseModel, EmailStr, ConfigDict


class UserBase(BaseModel):
    email: EmailStr
    full_name: str


class UserCreate(UserBase):
    password: str


class UserUpdate(BaseModel):
    email: EmailStr | None = None
    full_name: str | None = None


class UserResponse(UserBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    created_at: datetime
    is_active: bool
```

**Usage:**
```python
@router.post("/users", response_model=UserResponse, status_code=201)
async def create_user(payload: UserCreate, db: AsyncSession = Depends(get_db)):
    user = await user_service.create(db, payload)
    return user  # Pydantic converts ORM → response schema via from_attributes
```

---

## API Response Shape — Consistent Envelope

For list endpoints and paginated results, use a consistent envelope:

```python
# src/models/common.py
from typing import Generic, TypeVar
from pydantic import BaseModel

T = TypeVar("T")


class PageResponse(BaseModel, Generic[T]):
    items: list[T]
    total: int
    page: int
    page_size: int
    has_next: bool


class MessageResponse(BaseModel):
    message: str
```

**Usage:**
```python
@router.get("/users", response_model=PageResponse[UserResponse])
async def list_users(page: int = 1, page_size: int = 20, db: AsyncSession = Depends(get_db)):
    return await user_service.list_paginated(db, page=page, page_size=page_size)
```

---

## Authentication — JWT

Centralise all token logic in `src/lib/security.py`.

```python
# src/lib/security.py
from datetime import UTC, datetime, timedelta
import jwt
from passlib.context import CryptContext
from src.config import get_settings
from src.lib.errors import AuthError

settings = get_settings()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(subject: str | int) -> str:
    expire = datetime.now(UTC) + timedelta(minutes=settings.access_token_expire_minutes)
    payload = {"sub": str(subject), "exp": expire}
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)


def decode_access_token(token: str) -> str:
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
        return payload["sub"]
    except jwt.ExpiredSignatureError:
        raise AuthError("Token expired")
    except jwt.InvalidTokenError:
        raise AuthError("Invalid token")
```

**FastAPI dependency:**
```python
# src/api/deps.py
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.ext.asyncio import AsyncSession
from src.lib.database import get_db
from src.lib.security import decode_access_token
from src.db.models import User

bearer = HTTPBearer()

async def current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer),
    db: AsyncSession = Depends(get_db),
) -> User:
    user_id = decode_access_token(credentials.credentials)
    user = await db.get(User, int(user_id))
    if not user:
        raise AuthError("User not found")
    return user
```

---

## Structured Logging

**Never** use `print()` or bare `logging.info()` in application code.
Use the structured logger from `src/lib/logging.py`.

```python
# src/lib/logging.py
import logging
import sys
from typing import Any
import structlog
from src.config import get_settings

settings = get_settings()


def configure_logging() -> None:
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.dev.ConsoleRenderer() if settings.debug
            else structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(
            getattr(logging, settings.log_level.upper())
        ),
        logger_factory=structlog.PrintLoggerFactory(sys.stdout),
    )


def get_logger(name: str) -> Any:
    return structlog.get_logger(name)
```

**Usage:**
```python
from src.lib.logging import get_logger

log = get_logger(__name__)

async def create_user(db: AsyncSession, payload: UserCreate) -> User:
    log.info("creating_user", email=payload.email)
    user = User(**payload.model_dump(exclude={"password"}))
    db.add(user)
    await db.flush()
    log.info("user_created", user_id=user.id)
    return user
```

---

## Service Layer Pattern

Business logic lives in `src/services/`, not in routes.
Routes are thin: validate input → call service → return response.

```python
# src/services/user_service.py
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from src.db.models import User
from src.lib.errors import ConflictError, NotFoundError
from src.lib.logging import get_logger
from src.lib.security import hash_password
from src.models.user import UserCreate, UserUpdate

log = get_logger(__name__)


async def create(db: AsyncSession, payload: UserCreate) -> User:
    existing = await db.execute(select(User).where(User.email == payload.email))
    if existing.scalar_one_or_none():
        raise ConflictError(f"Email {payload.email} already registered")

    user = User(
        email=payload.email,
        full_name=payload.full_name,
        hashed_password=hash_password(payload.password),
    )
    db.add(user)
    await db.flush()
    log.info("user_created", user_id=user.id, email=user.email)
    return user


async def get_by_id(db: AsyncSession, user_id: int) -> User:
    user = await db.get(User, user_id)
    if not user:
        raise NotFoundError(f"User {user_id} not found")
    return user
```

**Route (thin):**
```python
# src/api/users.py
from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from src.lib.database import get_db
from src.models.user import UserCreate, UserResponse
from src.services import user_service

router = APIRouter(prefix="/users", tags=["users"])

@router.post("", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(payload: UserCreate, db: AsyncSession = Depends(get_db)):
    return await user_service.create(db, payload)
```

---

## Testing Patterns

### conftest.py — Shared fixtures

```python
# tests/conftest.py
import asyncio
import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from src.main import app
from src.lib.database import get_db
from src.db.models import Base

TEST_DATABASE_URL = "sqlite+aiosqlite:///:memory:"

@pytest.fixture(scope="session")
def event_loop():
    loop = asyncio.get_event_loop_policy().new_event_loop()
    yield loop
    loop.close()

@pytest_asyncio.fixture(scope="function")
async def db():
    engine = create_async_engine(TEST_DATABASE_URL)
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    session_factory = async_sessionmaker(engine, expire_on_commit=False)
    async with session_factory() as session:
        yield session
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)

@pytest_asyncio.fixture(scope="function")
async def client(db: AsyncSession):
    app.dependency_overrides[get_db] = lambda: db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()
```

### Unit test — service layer

```python
# tests/unit/test_user_service.py
import pytest
from src.lib.errors import ConflictError
from src.services import user_service
from src.models.user import UserCreate

@pytest.mark.asyncio
async def test_create_user(db):
    payload = UserCreate(email="a@example.com", full_name="Alice", password="secret")
    user = await user_service.create(db, payload)
    assert user.id is not None
    assert user.email == "a@example.com"

@pytest.mark.asyncio
async def test_create_user_duplicate_email(db):
    payload = UserCreate(email="a@example.com", full_name="Alice", password="secret")
    await user_service.create(db, payload)
    with pytest.raises(ConflictError):
        await user_service.create(db, payload)
```

### Integration test — API layer

```python
# tests/integration/test_users_api.py
import pytest

@pytest.mark.asyncio
async def test_create_user_endpoint(client):
    response = await client.post("/users", json={
        "email": "b@example.com",
        "full_name": "Bob",
        "password": "secret123",
    })
    assert response.status_code == 201
    data = response.json()
    assert data["email"] == "b@example.com"
    assert "id" in data
    assert "password" not in data   # never leak password in response
```

---

## Discovering New Patterns

When `ralph-implementer` finds a reusable pattern during an iteration, it
should add it here under this section with the date:

```markdown
## [YYYY-MM-DD] — [Pattern Name]

**Problem:** [what this pattern solves]
**Location:** src/lib/[file].py
**Example:**
\`\`\`python
# minimal example
\`\`\`
**Why:** [benefit over the naive approach]
```

The next iteration will read this file and pick up the pattern automatically.
