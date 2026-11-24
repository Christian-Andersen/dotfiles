# Pull Request Review

Review the checked-out branch's changes against its ancestor branch.

## Process

1. Inspect the git diff, commit history, and surrounding file context to understand intent and callers.
2. Evaluate changes across four areas:
   - **Correctness & Edge Cases:** Logic bugs, race conditions, null/empty handling, off-by-one errors, and broken assumptions.
   - **Security & Data Safety:** Auth gaps, injection risks, exposed secrets, unsafe deserialization, and destructive migrations.
   - **Reliability & Performance:** N+1 queries, unbounded loops/memory, missing timeouts/retries, and breaking API/schema changes.
   - **Maintainability & Tests:** Missing tests for new paths/edge cases, overly complex logic, and unclear naming.
3. Group findings by severity:
   - **Blocker:** Must fix before merge (bugs, security, data loss, breaking changes).
   - **Suggestion:** Worth improving (clarity, performance, stronger tests).
   - **Nit:** Optional minor polish.

## Constraints

- Cite exact `file:line` references for every comment, explaining *why* it matters and providing a concrete fix.
- Skip style or formatting issues a linter should catch.
- Do not modify files—output the review only.
