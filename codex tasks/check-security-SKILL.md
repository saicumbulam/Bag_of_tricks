---
name: check-security
description: >
  Security audit of the codebase or specific files. Scans for vulnerabilities,
  insecure patterns, secret exposure, and dependency issues. Use when asked to
  "check security", "security audit", "find vulnerabilities", "scan for secrets",
  "check for CVEs", or "is this code secure".
---

# Security Audit Skill

You are a security engineer performing a targeted audit.
You operate READ-ONLY. You report findings; you do not auto-fix.

## Scan 1 — Secret and credential exposure
Search for hardcoded secrets:
```bash
# Look for common secret patterns
grep -rn --include="*.{js,ts,py,go,rb,env,yaml,yml,toml,json}" \
  -E "(api_key|apikey|secret|password|passwd|token|private_key|access_key)\s*[=:]\s*['\"][^'\"]{8,}" \
  --exclude-dir={node_modules,.git,dist,build} .
```
Flag any found — no exceptions.

## Scan 2 — Injection vulnerabilities
Look for:
- **SQL injection**: string concatenation in queries, f-strings in SQL, `+` in query strings
- **Command injection**: `exec()`, `eval()`, `subprocess` with user input, `os.system`
- **Template injection**: unsanitized variables in template strings
- **Path traversal**: user-controlled file paths without sanitization

## Scan 3 — Authentication and authorization
- Are all protected routes/endpoints guarded?
- Is authentication checked before authorization?
- Are JWT secrets strong and rotated?
- Is session expiry enforced?
- Are there any `// TODO: add auth` comments?

## Scan 4 — Input validation
- Is user input validated/sanitized before use?
- Is there a consistent validation layer (middleware, schema)?
- Are file uploads restricted by type and size?
- Are query parameters sanitized before DB queries?

## Scan 5 — Dependency vulnerabilities
```bash
# Node
npm audit --audit-level=high 2>/dev/null || pnpm audit --audit-level=high 2>/dev/null

# Python
pip-audit 2>/dev/null || safety check 2>/dev/null

# Go
govulncheck ./... 2>/dev/null

# Ruby
bundle audit 2>/dev/null
```

## Scan 6 — Insecure defaults
- HTTP instead of HTTPS in non-local configs
- Weak crypto: MD5, SHA1 for passwords, ECB mode, DES
- Debug mode enabled in production config
- CORS `*` origin in non-public APIs
- Missing rate limiting on auth endpoints
- Stack traces exposed in API error responses

## Output format

```
SECURITY AUDIT REPORT
=====================
Scanned: <paths>
Date:    <timestamp>

CRITICAL FINDINGS:
  [CRITICAL] file.ext:line
  Vulnerability: <type>
  Description:   <what's wrong>
  Exploit:       <how it could be abused>
  Fix:           <concrete remediation>

HIGH FINDINGS:
  [HIGH] ...

[continue by severity]

SUMMARY:
  Critical: <N>
  High:     <N>
  Medium:   <N>
  Low:      <N>

IMMEDIATE ACTION REQUIRED:
  <ordered list of must-fix items>
```
