# TASK NNN — TASK_NAME

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

The architect (ChatGPT) prepares this task file for the project owner. The owner places it at `DEV/tasks/NNN_TASK_NAME.md`. For every future task, the architect must copy the mandatory opening instruction above verbatim. This template is guidance, not authority to make new technical decisions.

## Task identifier and ownership

- Task: `NNN_TASK_NAME`
- Project/repository: `...`
- Decision authority: ChatGPT (architect/auditor); owner approves material changes.
- Executor: Codex.

## Checked base SHA and branch

- Expected branch: `main`
- Expected base SHA: `...`
- Baseline verification date/source: `...`

## Goal

`...`

## Confirmed requirements

- `...`
- Do not infer missing business, data, security, or architecture decisions.

## Allowed files

- `...`

Any additional path requires a task amendment/explicit written authorization from ChatGPT via the owner.

## Forbidden actions

- No work outside the allowed paths.
- No unapproved architecture, business logic, schema, or security relaxation.
- No real accounting or personal data in code, tests, logs, or documentation.
- No destructive Git operations or `git push --force`.
- No next task after this task.

## Implementation steps

1. Read `AGENTS.md` and this complete task; inspect local/remote Git state and preserve unrelated user files.
2. Implement only the approved changes.
3. Run the checks below and inspect actual results.
4. Complete the mandatory documentation reconciliation.
5. Create the task report before the final commit; do not include the SHA of the commit that contains the report.
6. Review staged files/diff and run required security gates before commit and push.

## Privacy and security requirements

- Use synthetic test data only.
- List prohibited data and required scanning/handling rules for this task: `...`.
- State known limits; automatic checks do not replace manual review.

## Testing

- Commands: `...`
- Positive and negative cases: `...`
- Required expected results: `...`

## Mandatory documentation reconciliation

After implementation and tests, but before report and commit:

- Compare the actual diff and evidence with `README.md`, architecture, requirements, security policy, development workflow, changelog, implementation status, and other affected canonical docs.
- Update all affected docs in the same task. Add a factual task entry to `DEV/docs/CHANGELOG.md` and synchronize `DEV/docs/IMPLEMENTATION_STATUS.md` with evidence.
- Trace `task → implementation → tests → documentation → report`; mark unsupported claims `UNVERIFIED` or `NOT_IMPLEMENTED`.
- In the report, include a `Documentation reconciliation` matrix: document, reviewed, changed and reason, factual verification, discrepancy/resolution.
- If a contradiction needs an architectural decision, stop `BLOCKED`. A task blocked before changes may report the blocker without inventing a changelog success entry.

## Acceptance gates

- `...`
- Documentation and implementation agree; no unresolved task-related contradiction.
- Security/index/outgoing checks pass and only allowed files are committed.
- Remote SHA is confirmed; CI status is reported only with evidence (`PASS`, `FAIL`, `PENDING`, or `UNVERIFIED`).
- `SUCCESS` means task checks/publication completed, not architect acceptance.

## Report format

Create `DEV/reports/NNN_TASK_NAME.md` with status, base state, changed files, commands/results, security model and limits, `Documentation reconciliation` matrix, Git/publication/CI status, deviations, unresolved issues, and report URL. Do not self-reference the containing commit SHA.

## Git publication and stop conditions

- Target: ordinary fast-forward push to `origin/main`; never force-push or rewrite history.
- Preserve unrelated work and task source files unless explicitly included in allowed paths.
- Stop and report `BLOCKED` for an unexpected remote/history, missing tools, conflict, sensitive data, required check failure, or missing technical decision.
- Final owner message includes the exact remote HEAD SHA, report link, CI status, and `NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`.
