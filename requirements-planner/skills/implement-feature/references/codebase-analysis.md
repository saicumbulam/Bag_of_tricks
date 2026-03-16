# Codebase Analysis Guide

Read this when analyzing how the codebase relates to the feature being planned.
Follow each scan in order. Use shell commands to explore — don't guess file locations.

---

## Step 1: Understand project structure

```bash
# Overall layout
find . -maxdepth 2 -type d | grep -v node_modules | grep -v .git | grep -v dist | sort

# Identify the stack
cat package.json 2>/dev/null | grep -E '"(name|version|dependencies|devDependencies)"' | head -20
cat pyproject.toml 2>/dev/null | head -30
cat go.mod 2>/dev/null | head -10
cat Cargo.toml 2>/dev/null | head -10
cat pom.xml 2>/dev/null | grep -E '<groupId>|<artifactId>' | head -10
```

Identify:
- Language and major framework (Express, FastAPI, Django, Gin, Rails, etc.)
- ORM / query builder (Prisma, TypeORM, SQLAlchemy, GORM, ActiveRecord)
- Testing framework (Jest, Pytest, Go test, RSpec)
- Monolith vs microservices

---

## Step 2: Find the relevant entry points

For web APIs:
```bash
# Node/Express
grep -rn "router\.\|app\.get\|app\.post\|app\.put\|app\.delete\|app\.patch" \
  --include="*.ts" --include="*.js" src/ | grep -v test | grep -v spec | head -30

# Python/FastAPI/Django
grep -rn "@app\.\|@router\.\|urlpatterns\|path(" \
  --include="*.py" . | grep -v test | grep -v migration | head -30

# Go
grep -rn "http\.HandleFunc\|r\.GET\|r\.POST\|mux\." \
  --include="*.go" . | grep -v test | head -20
```

For the specific feature area:
```bash
# Search for related keywords in route files
grep -rn "<feature_keyword>" --include="*.ts" --include="*.js" --include="*.py" \
  src/ app/ | grep -v test | grep -v node_modules | head -20
```

---

## Step 3: Trace the full request stack

For each relevant endpoint, trace:
```
Route/Handler → Service → Repository/DAO → DB schema
```

```bash
# Find service layer
find . -path "*/services/*" -name "*.ts" | grep -v test | head -20
find . -path "*/service*" -name "*.py" | grep -v test | head -20

# Find data layer
find . -path "*/repositories/*" -o -path "*/models/*" -o -path "*/dao/*" | \
  grep -v node_modules | grep -v .git | head -20

# Find schema/migrations
find . -path "*/migrations/*" -name "*.sql" -o \
       -path "*/migrations/*" -name "*.ts" -o \
       -name "schema.prisma" -o \
       -name "models.py" | grep -v node_modules | head -20
```

---

## Step 4: Find existing patterns to reuse

```bash
# Auth/middleware patterns
find . -path "*/middleware/*" | grep -v node_modules | grep -v test | head -10
grep -rn "authenticate\|authorize\|requireAuth\|@require_auth\|middleware" \
  --include="*.ts" --include="*.py" --include="*.go" src/ | head -20

# Validation patterns
grep -rn "validate\|schema\|zod\|joi\|pydantic\|yup" \
  --include="*.ts" --include="*.py" src/ | grep -v test | head -20

# Error handling patterns
grep -rn "throw new\|ApiError\|HTTPException\|errors\." \
  --include="*.ts" --include="*.py" src/ | grep -v test | head -20

# Response patterns
grep -rn "res\.json\|return.*Response\|jsonify\|c\.JSON" \
  --include="*.ts" --include="*.py" --include="*.go" src/ | grep -v test | head -20
```

---

## Step 5: Find related tests

```bash
# Test files for the relevant feature area
find . -path "*/test*" -o -path "*/__tests__/*" -o -path "*/spec/*" | \
  grep -v node_modules | xargs grep -l "<feature_keyword>" 2>/dev/null | head -10

# Test helper utilities
find . -name "test-utils.*" -o -name "helpers.*" -o -name "factories.*" | \
  grep -v node_modules | head -10
```

---

## Step 6: Check for configuration and environment dependencies

```bash
# What environment variables does the app use?
grep -rn "process\.env\|os\.environ\|os\.getenv\|viper\." \
  --include="*.ts" --include="*.py" --include="*.go" src/ | \
  grep -v test | grep -v node_modules | head -30

# External service integrations
grep -rn "axios\|fetch\|requests\.\|http\.Get\|grpc" \
  --include="*.ts" --include="*.py" --include="*.go" src/ | \
  grep -v test | head -20
```

---

## Output Format

Produce this inventory after scanning:

```
CODEBASE INVENTORY FOR: <feature name>
═══════════════════════════════════════

Stack: <language> + <framework> + <ORM> + <test framework>

Entry Points:
  - src/api/routes/users.ts:42 — GET /users/:id (getUserById)
  - src/api/routes/users.ts:78 — POST /users (createUser)

Service Layer (to modify):
  - src/services/UserService.ts — getUser(), createUser(), updateUser()

Data Layer (to modify):
  - src/repositories/UserRepository.ts — DB queries
  - prisma/schema.prisma — User model (need to add fields: X, Y)

Existing Utilities to Reuse:
  - src/utils/validate.ts — Zod validation helper
  - src/middleware/auth.ts — JWT auth middleware
  - src/errors/ApiError.ts — Standard error class

Related Tests:
  - tests/unit/UserService.test.ts — Unit tests to update
  - tests/integration/users.test.ts — Integration tests to add

New Files Needed:
  - src/api/routes/export.ts (new)
  - src/services/ExportService.ts (new)
  - src/jobs/ExportJob.ts (new)
  - migrations/xxx_add_export_table.sql (new)

Integration Points:
  - S3 for file storage (see src/lib/storage.ts)
  - SendGrid for email delivery (see src/lib/email.ts)
```
