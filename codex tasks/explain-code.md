---
description: Explain how a piece of code works — deeply and clearly
argument-hint: [FILE=<path>] [FUNCTION=<name>]
---

Read and explain the code at $FILE or the function named $FUNCTION.

Your explanation should cover:

1. **What it does** — in plain English, one paragraph
2. **How it works** — step-by-step walkthrough of the logic
3. **Inputs and outputs** — what goes in, what comes out, what side effects exist
4. **Edge cases handled** — what special conditions are accounted for
5. **Edge cases NOT handled** — potential failure modes
6. **Dependencies** — what external things does it rely on
7. **Where it's used** — find the callers if FILE or FUNCTION is provided

Assume I understand code but I'm new to this specific part of the codebase.
Be specific and concrete — reference actual variable names and line numbers.
