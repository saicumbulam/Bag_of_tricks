---
name: generate-docs
description: >
  Generate or update documentation for code: JSDoc/TSDoc comments, docstrings,
  README sections, or API docs. Use when asked to "document this", "add docs",
  "write docstrings", "update the README", "explain this function",
  or "generate API documentation".
---

# Generate Docs Skill

## Step 1 — Identify what to document
Determine the scope from the request:
- **Function/method**: add inline docstring/JSDoc
- **Module/file**: add module-level overview comment
- **API endpoint**: document parameters, request/response, errors
- **README**: update setup, usage, or API sections
- **Class**: document constructor, properties, methods

## Step 2 — Read the code thoroughly
Before writing a single word of documentation:
1. Read the full function/class/module.
2. Trace all inputs, outputs, and side effects.
3. Identify edge cases and error conditions.
4. Understand the "why" — not just the "what".

## Step 3 — Write documentation

### For TypeScript/JavaScript (JSDoc/TSDoc):
```typescript
/**
 * Brief one-line description of what the function does.
 *
 * Longer description if needed — explain WHY not just WHAT.
 * Describe behavior for edge cases.
 *
 * @param userId - The ID of the user to retrieve
 * @param options - Optional configuration
 * @param options.includeDeleted - Whether to include soft-deleted users
 * @returns The user object, or null if not found
 * @throws {NotFoundError} If user doesn't exist and throwOnMissing is true
 * @throws {DatabaseError} If the database query fails
 * @example
 * const user = await getUser('user-123');
 * const user = await getUser('user-123', { includeDeleted: true });
 */
```

### For Python (Google style docstrings):
```python
def get_user(user_id: str, include_deleted: bool = False) -> Optional[User]:
    """Retrieve a user by their ID.

    Fetches user from the database. Returns None if not found rather
    than raising to allow callers to handle the missing case explicitly.

    Args:
        user_id: The unique identifier for the user.
        include_deleted: Whether to return soft-deleted users.
            Defaults to False.

    Returns:
        User object if found, None otherwise.

    Raises:
        DatabaseError: If the database connection fails.
        ValueError: If user_id is empty or None.

    Example:
        >>> user = get_user("user-123")
        >>> user = get_user("user-123", include_deleted=True)
    """
```

### For Go:
```go
// GetUser retrieves a user by ID from the database.
// Returns (nil, nil) when the user is not found — callers should
// check for nil before using the result.
//
// Parameters:
//   - ctx: Context for cancellation and tracing
//   - userID: The unique identifier for the user
//
// Returns the user and nil error on success.
// Returns nil user and nil error if not found.
// Returns nil user and error if a database error occurs.
func GetUser(ctx context.Context, userID string) (*User, error) {
```

## Step 4 — Quality checks
- Does the doc explain non-obvious behavior?
- Are all parameters documented with types and meaning?
- Are error conditions documented?
- Is there at least one usage example for public functions?
- Does it avoid restating the code (e.g., NOT: "// increments i by 1")?

## Step 5 — Report
List every file modified and what was added.
