# Mermaid Diagrams — Codex CLI Skill

Create professional software diagrams using Mermaid's text-based syntax. Mermaid renders diagrams from simple text definitions, making diagrams version-controllable and easy to update alongside code.

## What's Inside

```
mermaid-diagrams/
├── SKILL.md                          # Entry point — Codex loads this first
└── references/
    ├── class-diagrams.md             # OOP, domain modeling
    ├── sequence-diagrams.md          # API flows, interactions
    ├── flowcharts.md                 # Processes, decision trees
    ├── erd-diagrams.md               # Database schemas
    ├── c4-diagrams.md                # System architecture
    └── advanced-features.md          # Themes, styling, layout
```

## Installation (Codex CLI)

**Global (recommended):**

```bash
mkdir -p ~/.codex/skills
cp -r mermaid-diagrams ~/.codex/skills/
```

**Project-local:**

```bash
mkdir -p ./.codex/skills
cp -r mermaid-diagrams ./.codex/skills/
```

Restart your Codex session (or start a new one) so it picks up the new skill. Codex will read `SKILL.md` when the description matches the user's request and lazy-load reference files as needed.

## When It Triggers

Requests to **diagram**, **visualize**, **model**, **map out**, or **show the flow** of a system — class diagrams, sequence diagrams, flowcharts, ERDs, C4 architecture diagrams, state diagrams, git graphs, Gantt charts.

## Security Notes

This skill is documentation-only. It contains no executable code, no network calls, no shell commands, and no credential handling. It provides Mermaid syntax references that Codex uses to generate diagram text. The Mermaid diagrams themselves are rendered client-side by whatever tool displays them (GitHub, VS Code, Mermaid Live, etc.) — not by this skill.
