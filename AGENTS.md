# Project instructions

- Before each task, read this file and the corresponding file in `DEV/tasks/`.
- Perform only the assigned task. Do not make independent architecture, business logic, requirements, data structure, or security decisions.
- Do not edit files outside the task's permitted scope or delete user data.
- Do not run dangerous commands without authorization. Never use `git push --force`.
- Do not publish confidential information. Use fictional data for tests.
- Run the checks required by the task and record results in `DEV/reports/`.
- Before committing, inspect the exact file list, staged diff, secrets, real accounting data, and accidental documents.
- Before every `git commit`, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`; before every `git push`, manually run it with `-Mode Outgoing` and the same refs that will be pushed. Hooks are an extra guard and can be bypassed.
- Run `pwsh -NoProfile -File tests/security/Invoke-SecurityTests.ps1` for security workflow changes. If PowerShell 7 or a required check fails, stop the operation and report it.
- Publish only when every security condition is met. If publication is blocked, preserve local changes and report why.
- Do not call a task complete without evidence from its required checks.
- Request new technical decisions from ChatGPT through the project owner.

## Documentation maintenance — mandatory after every task

- Before starting any task, fully read this root `AGENTS.md` and the exact `DEV/tasks/NNN_TASK_NAME.md` file. Only then inspect the active repository state and confirm scope. Do not implement from a chat message, stale context, or memory alone.
- After every completed task, compare documentation with the actual changed files, behavior, tests, configuration, and limitations. Update every affected canonical document in the same task, before the final commit and push. Do not defer required documentation without explicit written authorization from ChatGPT.
- For every completed task, update `DEV/docs/CHANGELOG.md`, including documentation-only and process-only work. Record the task ID, factual changes, relevant checks, and limitations. Historical entries must be labeled retrospectives and based only on published reports. A blocked task that changes nothing must not invent a successful changelog entry; document the blocker truthfully in its report.
- Keep `DEV/docs/IMPLEMENTATION_STATUS.md` as the source of truth for implemented and validated, not implemented/not approved, unverified, and blocked scope, with evidence links. Distinguish planned, coded, locally tested, CI-passed, and production-ready. Recheck status on every task and say in the report when no status category changed.
- Review affected canonical documentation: `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, and other applicable canonical docs. Resolve contradictions against implementation and evidence; do not make an unapproved technical decision to resolve one. Link to canonical sources instead of maintaining competing descriptions.
- Every task report must include a `Documentation reconciliation` section listing inspected documents, updates and reasons, documents left unchanged and why, contradictions and their resolution (or `BLOCKED`), and how claims were verified. A report cannot claim `SUCCESS` while task-related contradictions remain.
- Declare `SUCCESS` only after approved implementation, tests, documentation reconciliation, security checks, and publication verification are complete. `SUCCESS` is not architect acceptance. On `PARTIAL`, record what is true and what remains. If blocked before changes, do not invent successful documentation updates.
- Keep documentation and reports free of real counterparties, contract details, invoices, tax identifiers, private paths, and secrets. Use only non-sensitive filenames, test results, and synthetic examples.
- Preserve the established audit process: only ChatGPT assigns `ACCEPTED`, `REWORK_REQUIRED`, or `BLOCKED`; do not accept your own work or start the next task.
