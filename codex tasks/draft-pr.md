---
description: Create a pull request description from current branch changes
argument-hint: [BASE=main] [TITLE="your PR title"]
---

You are writing a pull request description.

1. Run: `git log $BASE..HEAD --oneline --no-merges` to see commits
2. Run: `git diff $BASE...HEAD --stat` to see changed files
3. Run: `git diff $BASE...HEAD` to read the actual changes

Write a PR description using this template:

## What changed
<!-- 2-4 bullet points summarizing the key changes -->

## Why
<!-- The motivation / business reason for this change -->

## How it works
<!-- Brief technical explanation for reviewers -->

## Testing
<!-- What tests were added/updated, how to test manually -->

## Screenshots / Output
<!-- Add if there are UI changes or CLI output changes -->

## Checklist
- [ ] Tests added/updated
- [ ] No secrets or credentials committed
- [ ] Breaking changes documented
- [ ] Relevant docs updated

Use "$TITLE" as the PR title if provided, otherwise derive one from the commits.
Base branch: $BASE (default: main)
