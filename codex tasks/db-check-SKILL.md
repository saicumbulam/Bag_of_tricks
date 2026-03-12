---
name: db-check
description: >
  Audit database usage: find N+1 queries, missing indexes, unparameterized queries,
  missing migrations, or schema issues. Use when asked to "check database queries",
  "find N+1 queries", "audit DB usage", "check for SQL injection",
  "review migrations", or "find slow queries".
---

# Database Check Skill

You operate READ-ONLY for inspection. You do NOT run migrations or modify schemas
without explicit confirmation.

## Scan 1 — N+1 query detection
Look for database calls inside loops:
```
# Patterns to find
- for/forEach/map containing .findOne(), .findById(), query(), SELECT
- .find().then(results => results.map(r => db.query(...)))
- Lazy loading in ORM loops (Sequelize, TypeORM, Prisma, SQLAlchemy)
```
For each N+1 found, suggest the eager-load or JOIN fix.

## Scan 2 — Missing index detection
Read schema/migration files. For each table, check:
- Foreign key columns: should always be indexed
- Columns used in WHERE clauses in frequent queries
- Columns used in ORDER BY on large tables
- Compound index needs for multi-column WHERE

```bash
# Find migration files
find . -path "*/migrations/*" -name "*.sql" -o \
       -path "*/migrations/*" -name "*.ts" -o \
       -path "*/migrations/*" -name "*.py" | head -20

# Find schema definition
find . -name "schema.prisma" -o -name "models.py" -o \
       -name "schema.rb" -o -name "*.sql" | grep -v node_modules | head -10
```

## Scan 3 — SQL injection risk
```bash
grep -rn --include="*.{js,ts,py,go,rb}" \
  -E "(query|execute|raw)\s*\(.*\+" \
  --exclude-dir={node_modules,.git} .
```
Flag any query built with string concatenation or f-string/template literals
with non-constant values.

## Scan 4 — Migration hygiene
- Are migrations sequential and numbered?
- Are there any DOWN migrations / rollback scripts?
- Any migrations modifying existing data without a backup strategy?
- Any irreversible operations (DROP COLUMN, DROP TABLE) without caution?

## Scan 5 — Connection management
- Are connections properly pooled?
- Are connections released in finally/defer blocks?
- Is there a connection limit configured?
- Are transactions properly committed/rolled back?

## Output
```
DATABASE AUDIT REPORT
=====================

N+1 QUERIES:
  [HIGH] src/services/user.ts:45
  Pattern: findById() inside forEach loop
  Impact:  N queries per request (N = number of users)
  Fix:     Replace with findByIds(ids) or JOIN query

MISSING INDEXES:
  [MEDIUM] Table: orders — column: user_id (foreign key, unindexed)
  Fix: CREATE INDEX idx_orders_user_id ON orders(user_id);

SQL INJECTION RISKS:
  [CRITICAL] ...

MIGRATION ISSUES:
  ...

SUMMARY:
  Critical: <N>  High: <N>  Medium: <N>
```
