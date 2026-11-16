# TASK 008 — RETRY_TEST_BACKUP_RESTORE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Task authority, baseline and purpose

- Repository: `elvinazubairovna/1c-elsi-invoice-upd-automation` (PUBLIC).
- Task ID: `008_RETRY_TEST_BACKUP_RESTORE`.
- Expected branch: `main`.
- Expected baseline `HEAD` and `origin/main`: `b215a5098882234bf575ee80a9bca33a185728f7` (checked by ChatGPT at task authoring).
- ChatGPT is the architect and independent auditor; Codex is the executor; user is owner of the Windows host.
- Task 007 was blocked because an exclusive read-only handle to the exact TEST database file could not be obtained (`TEST_SESSION_NOT_CONFIRMED_CLOSED`). No backup or restore was created in Task 007.
- Goal: **repeat one conservative offline file-level backup and restore verification for TEST only**, after the owner manually closes the `ELSI_TEST` application. If test idleness or another precondition cannot be verified, stop. Do not work around the blocker.
- Task 008 is not permission to open 1C, test `.epf`, run a 1C application-level restoration, develop invoice/UPD functionality, access production or create financial documents.

## 2. Prerequisite supplied by owner, not by Codex

Before the owner sends this task to Codex, they must close any visible **ELSI_TEST** windows using normal application **Exit / X** and let the client finish exiting. They must not select, inspect, alter or terminate any production base, process or service. The owner's manual closure is a preparation step; **Codex must still independently verify TEST file idleness**. Do not assume that the user's closure proves the lock is released.

If the prerequisite is not satisfied or cannot be established by the specified lock gate, report `BLOCKED`. Do not ask the owner for routine technical decisions; give a concrete safe action and stop.

## 3. Read-only preflight — mandatory and fail closed

1. Fully read `AGENTS.md` FIRST, then this complete task, the exact published Task 007 and Report 007, and canonical `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/SECURITY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/ARCHITECTURE.md`, and `DEV/docs/REQUIREMENTS.md`.
2. After first reads, check local branch, `HEAD`, `origin` URL and fresh remote `main` exactly match the expected SHA. Preserve all unrelated tracked and untracked items, particularly the previously identified Task 001 file; do not stage unrelated material. A mismatch -> `BLOCKED`, no reset/pull/merge/rebase.
3. Confirm Windows host, PowerShell 7 availability and expected repository without enumerating installed programs, 1C installations, production files, launcher lists or processes. Never elevate permissions or change ACLs.
4. Construct the **only** TEST source from the Windows system-drive root plus fixed relative path segments `1C_TEST` and `ELSI_TEST`. No arbitrary override, alternate path discovery or recursion beyond that exact source. Never print/commit the absolute path. Its dedicated parent must not be the Git working tree or cloud-sync location. Verify fixed local drive, canonical exact path, safe ancestry and absence of reparse points/junctions/symlinks. Do not enumerate sibling contents.
5. Only within exact TEST child: verify a regular, nonempty `1Cv8.1CD` exists, no reparse points or special/unsupported file types, sufficient access/metadata and the tree can be inventoried without disclosure. Existing unknown counterparty records remain uninspected; the entire copied dataset is potentially confidential.
6. Perform **one** short exclusive **read-only** open of the exact TEST `1Cv8.1CD` to establish no conflicting file handles. Close handle immediately. If the result is any failure, unknown, or misleading locking semantics, stop with `TEST_SESSION_NOT_CONFIRMED_CLOSED`; no process/service inspection, no attempts to terminate clients, no retry loop, no Volume Shadow Copy or live-copy fallback. Do not read the database contents through this check.
7. Check target directories `_BACKUP_008` and `_RESTORE_CHECK_008` **do not exist** under the same dedicated TEST parent. Existing backup/restore directories from any other task are never modified, enumerated, overwritten or removed. If either target exists, stop `BLOCKED` without choosing an alternative.
8. Check free space on the TEST volume for two **full** additional copies plus reserve **at least 1 GiB and 15% of volume capacity**, using the stricter reserve. Use only metadata of TEST source; on unsupported files, unstable contents, insufficient space or privilege ambiguity stop. Do not export inventory, file names, hashes or sizes to GitHub, report or chat.
9. If any outbound connection, interbase exchange or real-data contamination risk becomes apparent, stop. Do not try to disable services, change networking or inspect production.

## 4. Exactly approved TEST-only operations after all gates PASS

- Create brand-new sibling folders `_BACKUP_008` and `_RESTORE_CHECK_008` inside the dedicated local `1C_TEST` parent **only** after every read-only preflight passes.
- Copy the complete TEST directory tree from exact `ELSI_TEST` into `_BACKUP_008`, then independently copy the backup tree into `_RESTORE_CHECK_008`.
- Use only non-destructive file-copy techniques, no moving, no mirror/purge flags, no globbing into adjacent directories, no process controls, no external sync tools. Preserve bytes and file attributes as supported; explicitly distinguish attributes that cannot be fully verified.
- Do not follow any symlink/junction/reparse point. Recheck source unchanged and TEST file idle after copying; fail and stop if modified/locked.
- Locally compare source, backup, restored tree: same relative file structure, file count, lengths and **SHA-256 per file**; do not publish any actual paths, filenames beyond generic `1Cv8.1CD`, raw sizes, file hashes, source data or contents. State only `PASS/FAIL/UNVERIFIED` and categorical limits.
- On partial failure do not delete, overwrite, retry, rename or clean up backup artifacts. Leave them outside Git and report a sanitized blocker.
- **No invocation of 1C**: do not launch or register backup/restored base, do not access a Configurator, cannot claim application-level recovery. Application restore remains `NOT_ATTEMPTED` regardless of file-level results.
- Never touch, discover, enumerate, resolve, open, read, copy, scan, export, stop or modify the production ELSI base or its directory. Do not obtain launcher registry entries, logs, user data, license information or screenshots.

## 5. Allowed Git files — exhaustive

1. `DEV/tasks/008_RETRY_TEST_BACKUP_RESTORE.md` — include the owner-supplied task **verbatim**.
2. `DEV/reports/008_RETRY_TEST_BACKUP_RESTORE.md` — sanitized factual report (create).
3. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — update exactly the backup/readiness statuses and Task 008 result.
4. `DEV/docs/IMPLEMENTATION_STATUS.md` — reconcile latest verification statuses and limitations.
5. `DEV/docs/CHANGELOG.md` — factual Task 008 entry at top; if blocked, document stop without fictitious backup success.
6. `README.md` — only if an existing statement has become materially inaccurate; otherwise leave unchanged.

Every other file is read-only. No changes to `AGENTS.md`, security tools, hooks, CI, `.gitignore`, 1C source code, runtime configuration, or prior report/task. A necessary change outside scope -> stop and report `BLOCKED`.

**Hard publication exclusion:** all `1Cv8.1CD`, `.dt`, `.cf`, `.cfe`, `.epf`, backups, archives, actual configuration, personal data, IDs, contract/invoice data, license information, secrets, local paths, screenshots, hash dumps and unreviewed binaries. Only the allowlisted text task, docs, report go to public GitHub.

## 6. Documentation, checks and publication

1. Reconcile actual outcomes against `README.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, and other relevant canonical docs. Update affected **allowed** docs in the same task. Distinguish file-level verification from 1C application-level recovery and production readiness.
2. Add a `Documentation reconciliation` table to the report showing documents read, changed or unchanged, evidence and contradictions. Do not assert `SUCCESS` while task-related contradictions remain. If blocked after preflight, describe exactly what was safely checked without claiming backup/restore success.
3. Create `DEV/reports/008_RETRY_TEST_BACKUP_RESTORE.md` **before** final commit (do not write its future commit SHA into itself): base, AGENTS-first, allowed operations, checks/evidence statuses, privacy review, docs reconciliation, blockers, Git and CI state at time of writing, and next action.
4. Inspect `git status`, staged filenames and **full** staged diff, check UTF-8, Markdown relative links and `git diff --cached --check`. Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` immediately before commit; verify `core.hooksPath=DEV/hooks`; do not bypass hooks.
5. Before ordinary fast-forward push, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` with matching real ref update. Pre-push hook must pass. Do not use `--no-verify`, `git add .`, force push, reset or rewrite history.
6. Confirm remote `main` HEAD and accessible task/report/docs after push. Commit-specific Actions CI `PASS` only if a completed successful run for final SHA; otherwise `PENDING`, `FAIL` or `UNVERIFIED` honestly. If a blocker occurs, a sanitized blocked-task report and documentation may still be committed if all publication gates pass; report task itself as `BLOCKED`, never `SUCCESS`.
7. No next task automatically. Stop for independent ChatGPT audit.

## 7. Acceptance and clear stop conditions

- `AGENTS.md` fully read FIRST; Task 008 executed only after the full task file is read.
- Exact checked branch and baseline, no unrelated edits; absolute production isolation.
- TEST exact source passes all preflight checks including exclusive read-only handle. If not, stop without backup.
- If proceeded, source→backup→restored file inventories and per-file SHA-256 match, originals unchanged; backups never enter Git.
- Application restore remains `NOT_ATTEMPTED`; 1C not launched; invoice/UPD generator remains `NOT_IMPLEMENTED` and integration architecture `NOT_APPROVED`.
- Complete, truthful documentation/report; manual security checks, hooks, Git publication and CI reported honestly.
- Do not make new architecture/business decisions, do not silently relax any failed safety gate, and do not investigate production or user processes to fix a failure.

## 8. Required final response to owner

```text
TASK=008_RETRY_TEST_BACKUP_RESTORE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=b215a5098882234bf575ee80a9bca33a185728f7
AGENTS_FIRST_READ=PASS/FAIL
TEST_SOURCE_ISOLATION=PASS/UNVERIFIED/BLOCKED
TEST_IDLE_CHECK=PASS/FAIL/UNVERIFIED
FILE_LEVEL_BACKUP=PASS/FAIL/NOT_ATTEMPTED
FILE_LEVEL_RESTORE=PASS/FAIL/NOT_ATTEMPTED
APPLICATION_RESTORE=NOT_ATTEMPTED
PRODUCTION_ACCESS=NONE
DOCS_SYNC=PASS/FAIL/NOT_APPLICABLE
INDEX_CHECK=PASS/FAIL/NOT_ATTEMPTED
OUTGOING_CHECK=PASS/FAIL/NOT_ATTEMPTED
HOOKS=PASS/FAIL/NOT_ATTEMPTED
CI=PASS/FAIL/PENDING/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED/NOT_ATTEMPTED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=...
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**Stop on any ambiguity. A blocked file-level exercise is preferable to opening or damaging the production accounting system.**
