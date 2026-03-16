#!/usr/bin/env bash
# scan-codebase.sh
# Quick structural scan of the project — run this in Phase 2 Step 3
# Usage: bash skills/implement-feature/scripts/scan-codebase.sh [keyword]
# keyword: optional term to search for related files (e.g. "user", "payment")

KEYWORD="${1:-}"
EXCLUDE="--exclude-dir={node_modules,.git,dist,build,.next,__pycache__,vendor}"

echo "════════════════════════════════════════"
echo "CODEBASE SCAN REPORT"
echo "════════════════════════════════════════"
echo ""

echo "── Project Root ──"
ls -la | head -20
echo ""

echo "── Directory Structure (2 levels) ──"
find . -maxdepth 2 -type d \
  | grep -v node_modules | grep -v .git | grep -v dist | grep -v build \
  | grep -v __pycache__ | grep -v ".next" | grep -v vendor \
  | sort
echo ""

echo "── Stack Detection ──"
[ -f package.json ]     && echo "✓ Node.js/JS" && cat package.json | python3 -c "import json,sys; d=json.load(sys.stdin); deps=list({**d.get('dependencies',{}), **d.get('devDependencies',{})}.keys()); [print(f'  {k}') for k in sorted(deps)[:20]]" 2>/dev/null
[ -f pyproject.toml ]   && echo "✓ Python" && grep -E "^name|^version|\[tool.poetry\]|fastapi|django|flask" pyproject.toml | head -10
[ -f go.mod ]           && echo "✓ Go" && head -10 go.mod
[ -f Cargo.toml ]       && echo "✓ Rust" && head -10 Cargo.toml
[ -f pom.xml ]          && echo "✓ Java/Maven"
[ -f build.gradle ]     && echo "✓ Java/Gradle"
[ -f schema.prisma ]    && echo "✓ Prisma ORM"
[ -f Makefile ]         && echo "✓ Makefile found" && grep "^[a-z].*:" Makefile | head -10
echo ""

echo "── Source Files Count ──"
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" \) \
  | grep -v node_modules | grep -v .git | grep -v dist | grep -v build \
  | grep -v __pycache__ | grep -v vendor \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn
echo ""

echo "── API Entry Points ──"
# Node/Express/Fastify
grep -rn $EXCLUDE \
  -E "(router\.(get|post|put|patch|delete|all)|app\.(get|post|put|patch|delete))\s*\(" \
  --include="*.ts" --include="*.js" . 2>/dev/null | grep -v test | grep -v spec | head -20
# Python FastAPI/Flask/Django
grep -rn $EXCLUDE \
  -E "(@app\.(get|post|put|patch|delete)|@router\.(get|post|put)|url_pattern|path\()" \
  --include="*.py" . 2>/dev/null | grep -v test | grep -v migration | head -20
# Go
grep -rn $EXCLUDE \
  -E "(http\.HandleFunc|r\.(GET|POST|PUT|PATCH|DELETE)|mux\.Handle)" \
  --include="*.go" . 2>/dev/null | grep -v test | head -20
echo ""

echo "── Middleware Files ──"
find . -path "*/middleware*" -type f | grep -v node_modules | grep -v .git | head -15
echo ""

echo "── Test Framework ──"
[ -f jest.config.ts ] || [ -f jest.config.js ] && echo "✓ Jest"
grep -q "pytest" pyproject.toml 2>/dev/null && echo "✓ Pytest"
find . -name "*.test.ts" | head -3 | grep -q "." && echo "✓ .test.ts files found"
find . -name "*_test.go" | head -3 | grep -q "." && echo "✓ Go test files found"
find . -name "*_spec.rb" | head -3 | grep -q "." && echo "✓ RSpec files found"
echo ""

echo "── Database / Schema ──"
find . -name "schema.prisma" -o -name "models.py" -o -name "schema.rb" \
  | grep -v node_modules | head -5
find . -path "*/migrations/*" -type f | grep -v node_modules | tail -5
echo ""

if [ -n "$KEYWORD" ]; then
  echo "── Keyword Search: '$KEYWORD' ──"
  grep -rn $EXCLUDE "$KEYWORD" \
    --include="*.ts" --include="*.js" --include="*.py" --include="*.go" \
    . 2>/dev/null | grep -v test | grep -v spec | head -30
  echo ""
fi

echo "── Environment Variables Used ──"
grep -rn $EXCLUDE \
  -E "(process\.env\.|os\.environ|os\.getenv|viper\.Get)" \
  --include="*.ts" --include="*.js" --include="*.py" --include="*.go" \
  . 2>/dev/null | grep -v test | grep -v node_modules \
  | grep -oE '(process\.env\.[A-Z_]+|os\.environ\[['"'"'"][A-Z_]+['"'"'"\]|getenv\("[A-Z_]+")"' \
  | sort -u | head -20
echo ""

echo "════════════════════════════════════════"
echo "SCAN COMPLETE"
echo "════════════════════════════════════════"
