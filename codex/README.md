# Codex CLI — Senior Engineer Config Setup
# Complete configuration for coding & debugging

## Directory Structure

Copy these files to `~/.codex/`:

```
~/.codex/
├── config.toml                        ← Main config (copy as-is)
├── AGENTS.md                          ← Global working agreements
├── AGENTS.override.md.template        ← Activate during incidents
└── agents/
    ├── debugger.toml                  ← Deep root-cause analysis
    ├── reviewer.toml                  ← Security & quality audit
    ├── refactor.toml                  ← Safe code improvements
    ├── tester.toml                    ← Test generation
    ├── explorer.toml                  ← Codebase mapping
    └── perf.toml                      ← Performance analysis
```

Per-project (inside each repo):
```
your-repo/
└── .codex/
    └── AGENTS.md                      ← From project-AGENTS.md.template
```

---

## Quick Install

```bash
# 1. Back up existing config if any
mv ~/.codex ~/.codex.bak 2>/dev/null || true

# 2. Copy files
mkdir -p ~/.codex/agents
cp config.toml ~/.codex/
cp AGENTS.md ~/.codex/
cp agents/*.toml ~/.codex/agents/

# 3. Verify
codex mcp list
```

---

## Profiles — When to Use Each

| Profile | Command | Use when |
|---|---|---|
| `dev` (default) | `codex` | Day-to-day coding |
| `debug` | `codex --profile debug` | Investigating hard bugs |
| `review` | `codex --profile review` | PR / security audit |
| `fast` | `codex --profile fast` | Quick lookups, completions |
| `auto` | `codex --profile auto` | Trusted autonomous tasks |
| `ci` | `codex --profile ci` | CI/CD pipelines, headless |

---

## Agent Workflows — Example Prompts

### Debug a bug
```
Spawn a debugger agent to investigate this error:
TypeError: Cannot read properties of undefined (reading 'userId')
  at UserService.getProfile (src/services/user.ts:47)

The error happens only when the request includes an Authorization header
but the session has expired.
```

### Parallel PR review
```
Spawn 4 reviewer agents in parallel, each focused on one dimension:
1. Security vulnerabilities
2. Performance issues
3. Missing error handling
4. Test coverage gaps

Wait for all and give me a consolidated report.
```

### Codebase exploration
```
Spawn an explorer agent to trace all code paths that lead to
the `processPayment` function. Map every caller, every dependency,
and every side effect.
```

### Write tests for changed code
```
Spawn a tester agent to write tests for all functions I changed
in the last commit. Use the existing Jest test setup.
```

### Refactor safely
```
Spawn a refactor agent to:
1. Extract duplicated validation logic in src/api/handlers/
2. Replace magic numbers in src/config/limits.ts with named constants
Run the test suite after each change.
```

---

## TUI Shortcuts Reference

| Key | Action |
|---|---|
| `/agent` | Switch between active agent threads |
| `/review` | Open review presets (branch diff, uncommitted, commit) |
| `/theme` | Live theme picker |
| `/mcp` | Show active MCP servers and tools |
| `/approvals` | Change approval mode for this session |
| `/compact` | Compact context when session gets long |
| `/copy` | Copy last assistant output |
| `/clear` | Clear screen (keep thread) |
| `Ctrl+L` | Clear screen without losing context |
| `Enter` | Inject instructions mid-turn |
| `Tab` | Queue follow-up for next turn |
| `!ls` | Run shell command inline |
| `@filename` | Fuzzy file search and insert path |
| `o` | Open agent thread from approval overlay |

---

## Enabling Bitbucket MCP

1. Generate an Atlassian API token at id.atlassian.com
2. Uncomment the `[mcp_servers.bitbucket]` block in config.toml
3. Fill in your email and token
4. Run `codex` and type `/mcp` to verify

---

## Tips for Long Debugging Sessions

- Use `codex --profile debug` for maximum reasoning effort.
- Use `/compact` when the context gets large to avoid context rot.
- Use `codex resume` to pick up a previous session where you left off.
- Spawn a dedicated debugger agent per hypothesis to parallelize investigation.
- Use `AGENTS.override.md` (from the template) to lock Codex into incident mode.
- Add project-specific gotchas to `.codex/AGENTS.md` in your repo.
