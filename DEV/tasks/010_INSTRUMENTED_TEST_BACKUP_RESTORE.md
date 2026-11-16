# TASK 010 — INSTRUMENTED_TEST_BACKUP_RESTORE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority and baseline

- Project: `elvinazubairovna/1c-elsi-invoice-upd-automation` (**public** repository).
- Task ID: `010_INSTRUMENTED_TEST_BACKUP_RESTORE`.
- Expected branch: `main`.
- Expected current local HEAD **and** fresh remote `origin/main`: `efd0871e46dba867f1481b5b965d1ff2093e237b` (independently verified by ChatGPT after Task 009).
- Architect and acceptance authority: ChatGPT. Executor: Codex. Project owner: user.
- Owner delegates routine technical choices to ChatGPT; no extra question is required for routine implementation choices **within this explicit task**. This does not authorize crossing stop conditions, visiting production or relaxing privacy boundaries.
- After Task 008, backup operation failed with only `FILE_LEVEL_OPERATION=FAIL`. Task 009 confirmed that **the two exact Task 008 destination names were absent at the time of its metadata inspection**, available disk space then met the required threshold, and the historical failure reason remains `UNDETERMINED`. These facts do **not** prove the source bytes unchanged or identify the failed sub-operation.

## 2. Goal and boundaries

Perform **one** bounded, instrumented, offline, TEST-only attempt to create a fresh backup and independent restored copy. Observe the exact phase and **sanitized class of failure** if something fails; do not repeat blind generic-error execution. If all gates and byte-by-byte tests succeed, establish `FILE_LEVEL_BACKUP=PASS` and `FILE_LEVEL_RESTORE=PASS`; **do not claim the restored copy works inside 1C**.

**This task does not authorize:** 1C launch or Configurator access; `.epf`/`.cfe` creation or execution; registering any copied base; changes to accounting records; network integrations, EDI or email; testing/copying/identifying the production base; any cleanup, repair, process/service termination, configuration changes, privilege elevation, software installs or destructive action.

**Absolute PRODUCTION exclusion:** do not enumerate, locate, open, read, write, launch, copy, inspect metadata of, compare with, scan, or otherwise touch production. Do not inspect the 1C launcher list/registry, users' profiles, screenshots, processes or logs to discover production. No fallback to production or any alternate base.

**Exact TEST-only scope** (derive dynamically from Windows system-drive root and these exact fixed relative names; never commit/display the resulting absolute path):

- Fixed parent: `1C_TEST`.
- Source child: `ELSI_TEST`.
- NEW backup destination: `_BACKUP_010`.
- NEW independent restore destination: `_RESTORE_CHECK_010`.

Only these entries may be inspected inside the fixed parent. **Do not list or read any sibling** (`_BACKUP_007`, `_BACKUP_008`, etc.), even if present. The source may contain unknown or confidential records, so treat its entire byte content as confidential. Every copy and any temporary in-memory digest must remain local; absolutely no upload of 1C binaries, files, dumps, credentials, account/user/license information, internal filenames, file sizes, content hashes, exceptions containing paths, or screenshots to GitHub, logs or chat. Avoid outputting full local paths to the interactive terminal; print only sanitized stage markers.

## 3. Preconditions and AGENTS-first procedure

1. **Before anything else:** fully read the root `AGENTS.md`, then this task. Read prior Task/Report 007–009 and canonical `README.md`, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, and relevant 1C assessment docs.
2. Verify exact `main`, local HEAD, `origin` target and **fresh** remote HEAD. Expected SHA above. Preserve all unrelated tracked/untracked files, including previously observed unrelated Task 001. Any mismatch, unapproved tracked change or diverged remote -> `BLOCKED` with no pull/reset/merge/rebase.
3. Verify Windows host and PowerShell 7. No installation, elevation, registry scan or process inventory.
4. Construct *only* the known TEST parent and child on the system-drive root. Check canonical path/drive ancestry, that source is not inside Git/cloud-sync, no junction/symlink/reparse/special file in any path component or within the exact source tree. No path overrides, no wildcard source discovery. Source must be an ordinary directory with one nonempty regular `1Cv8.1CD` at the expected level. Do not decode/interrogate database or metadata objects inside 1C; only file-system checks.
5. Perform a **short exclusive read-only file-handle check** on this exact TEST database file and close it immediately; fail closed if not provably idle. Do not inspect or kill processes, enumerate sessions or use live-copy/Volume Shadow Copy workarounds. If user left TEST open, stop with `TEST_SESSION_NOT_CONFIRMED_CLOSED`.
6. Snapshot file-tree metadata in-memory, strictly inside `ELSI_TEST`, with relative paths and types only; require regular ordinary files, stable metadata across two snapshots and no reparse/unsupported entries. Never print/store inventory paths or values. Confirm source has no unexpected mutation during preflight.
7. Ensure **both** NEW destination folders `_BACKUP_010` and `_RESTORE_CHECK_010` do not exist (also reject inaccessible/reparse items). No overwrites, even of empty directories, and no automatic alternative destination names.
8. Verify capacity for two complete new copies **plus** the stricter of at least 1 GiB and 15% free disk reserve after copies. Report only `SPACE=PASS/FAIL`; do not publish bytes/volume details. Any uncertainty -> stop before creating destinations.
9. No copy attempt without **all** gates above. If source isolation, ownership, privacy, integration risk or stable source is uncertain, halt safely rather than assuming the issue away.

## 4. One instrumented local operation — no retry

Do **not** re-use the Task 008 all-in-one opaque operation. Implement small explicit, sequential TEST-only phases with separate error boundaries. Perform all steps in a **single** authorized run; **do not repeat** on error. Use built-in Windows/PowerShell/.NET file operations only; no external modules or tools, no `robocopy /MIR`, `/MOVE`, `/PURGE`, shell wildcard traversal into adjacent directories, `git add .`, network sync or logging of private data. No permanent helper script in the public repository. In-memory script execution is acceptable.

### Exact phase markers (only sanitized markers may leave memory)

- `P0_PREFLIGHT`: completed all prerequisites.
- `P1_SOURCE_BASELINE`: compute local SHA-256 for **every** source file, retaining only in-memory relative-name-to-digest mapping; do not emit hashes, names, sizes or counts.
- `P2_CREATE_BACKUP_DIR`: create exactly the new `_BACKUP_010` directory (only after all preflight checks passed).
- `P3_COPY_SOURCE_TO_BACKUP`: create matching child dirs and non-overwriting copies of each source file; always reject reparse/special entries. Preserve content and supported attributes. Do not modify the source.
- `P4_VERIFY_BACKUP`: compare source and backup structure, lengths and per-file SHA-256; require exact parity, report just `PASS/FAIL`. If mismatched, stop; **do not** proceed to restore.
- `P5_CREATE_RESTORE_DIR`: create exactly new `_RESTORE_CHECK_010`, only after the backup has passed verification.
- `P6_COPY_BACKUP_TO_RESTORE`: independently copy backup to the new restore directory without overwrite.
- `P7_VERIFY_RESTORE`: compare original, backup and restored structure, lengths and per-file SHA-256; require exact match. Report only `PASS/FAIL`.
- `P8_SOURCE_FINAL`: recompute original source digests and in-memory metadata inventory and confirm agreement with P1; repeat an exclusive read-only lock check and close it. If anything is unstable -> `SOURCE_FINAL=FAIL/UNVERIFIED`, and do not declare backup/restore successful.

**Diagnostics contract:** print the last completed phase and (on error) the **failed** phase with one safe category only: `ACCESS_DENIED`, `SHARING_OR_LOCK`, `PATH_OR_TARGET`, `CAPACITY`, `UNSUPPORTED_ENTRY`, `SOURCE_CHANGED`, `PARITY_MISMATCH`, `RESOURCE_LIMIT`, `OTHER_IO`, or `UNCLASSIFIED`. Classify by the captured .NET exception *type* and known structured error code where unambiguous (not by guessing from a text message). Never print raw exception messages, stack traces, nested error records, file names, absolute paths, volume sizes, identifiers, hashes or personal data. For unrecognized exceptions, say `UNCLASSIFIED`, preserve evidence privately in memory only, and stop. Capture failures **at individual phases** rather than hide them under generic `FILE_LEVEL_OPERATION=FAIL`.

- If the **first** source baseline cannot be computed safely, stop before making any new destination.
- After **any** failure, stop. Leave whatever new local TEST-only directories exist **untouched**; never delete, retry, rename, repair, clean up or overwrite. Report which allowed destination is `NOT_CREATED/CREATED/UNVERIFIED` only if independently established within this attempt. Do not inspect directories from previous tasks.
- Success at file-level parity is not evidence that the restored database can be opened in 1C. `APPLICATION_RESTORE=NOT_ATTEMPTED` in **all** outcomes.
- Backups may include unknown personal/accounting data. They remain on the local, non-synced TEST drive; no Git staging, no messages or network transfer of their bytes.

## 5. Allowlisted Git changes

Only the following paths may be **added or edited**:

1. `DEV/tasks/010_INSTRUMENTED_TEST_BACKUP_RESTORE.md` — the supplied task file, **verbatim**, never rewrite it.
2. `DEV/reports/010_INSTRUMENTED_TEST_BACKUP_RESTORE.md` — create a sanitized factual report.
3. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — reconcile exact current TEST backup/restore, integrity and readiness status.
4. `DEV/docs/IMPLEMENTATION_STATUS.md` — reconcile tested vs unverified scope, linking report.
5. `DEV/docs/CHANGELOG.md` — factual Task 010 entry, including `BLOCKED` if applicable.
6. `README.md` — only if a current claim is materially inaccurate; otherwise unchanged.

No other tracked path may be modified; if necessary -> `BLOCKED`. Do not create or publish a PowerShell implementation script, binary artifacts, 1C database/backup files, `.epf`/`.cfe`, scripts with local paths, raw diagnostics, raw metadata, screenshots or copied product code. Confine copies/digests to the approved local TEST folders or memory.

## 6. Reconciliation, gates and publication

1. Before report/commit, inspect actual work and compare with `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, the task template and previous reports. Update every **affected allowed** document; unresolved task-related contradictions requiring broader changes -> `BLOCKED`.
2. Report: `Status`, `AGENTS-first`, `Git baseline`, `Scope and production boundary`, `Preflight`, `Phase outcomes`, `Failure category if any`, `Backup/restore parity and source integrity`, `Application-level limitations`, `Confidentiality review`, `Documentation reconciliation` **matrix** (document, reviewed, changed/reason, evidence, discrepancies), `Changed files`, `Publication gates`, `Git/CI`, `Blockers`, `Next action`. Never write source names beyond generic `1Cv8.1CD`, local absolute paths, sizes, hashes or raw exceptions. Write the report **before** commit; no invented self-commit SHA.
3. Stage only allowlisted files; inspect filenames and the full staged diff; check UTF-8, Markdown relative links and `git diff --cached --check`. Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` just before commit; preserve established `core.hooksPath=DEV/hooks`, do not bypass hooks.
4. Before push, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` with actual pushed ref mapping. Pre-push hook must pass. No `--force`, `--no-verify`, or history rewriting. Fast-forward push only to `origin/main`.
5. Confirm remote HEAD and public report. Report GitHub Actions `CI=PASS` only with successful **commit-specific** completed run; otherwise `PENDING/FAIL/UNVERIFIED`. The final owner message contains the verified remote SHA/report URL and `NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`.
6. A failed/blocked file-copy operation can still yield a **safely published factual report**, but the task must remain `BLOCKED`/`FAILED` for backup purposes. Do not self-accept or begin next task.

## 7. Acceptance and stopping conditions

- AGENTS read before task and any other work; baseline as specified.
- Production never discovered/touched; TEST scope never expanded.
- All TEST preflight gates pass before any new folder creation.
- Each operational step is individually identified; **no generic-only failure** if a specific phase can be captured. Errors are sanitized.
- On `PASS`, original TEST, backup and restore content and structure agree by local per-file SHA-256 and source is verified stable in this attempt. Mark `FILE_LEVEL_BACKUP=PASS`, `FILE_LEVEL_RESTORE=PASS` **only** if these conditions are proven.
- On failure, stop without cleanup/retry, report last phase and category; keep failed or partial copies untouched and unpublished.
- 1C and application restore never launched. No `.epf` or invoice/UPD implementation.
- Canonical docs/reports accurately represent results; Git publication gates pass, independent ChatGPT audit is awaited.

## 8. Required compact final message to owner

```text
TASK=010_INSTRUMENTED_TEST_BACKUP_RESTORE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=efd0871e46dba867f1481b5b965d1ff2093e237b
AGENTS_FIRST_READ=PASS/FAIL
TEST_BOUNDARY=PASS/FAIL/UNVERIFIED
TEST_IDLE_CHECK=PASS/FAIL/UNVERIFIED
PREFLIGHT=PASS/FAIL/UNVERIFIED
LAST_COMPLETED_PHASE=P0_PREFLIGHT/P1_SOURCE_BASELINE/P2_CREATE_BACKUP_DIR/P3_COPY_SOURCE_TO_BACKUP/P4_VERIFY_BACKUP/P5_CREATE_RESTORE_DIR/P6_COPY_BACKUP_TO_RESTORE/P7_VERIFY_RESTORE/P8_SOURCE_FINAL/NONE
FAILED_PHASE=<phase or NONE>
FAILURE_CATEGORY=<safe category or NONE>
FILE_LEVEL_BACKUP=PASS/FAIL/NOT_ATTEMPTED/UNVERIFIED
FILE_LEVEL_RESTORE=PASS/FAIL/NOT_ATTEMPTED/UNVERIFIED
SOURCE_FINAL=PASS/FAIL/UNVERIFIED/NOT_ATTEMPTED
APPLICATION_RESTORE=NOT_ATTEMPTED
PRODUCTION_ACCESS=NONE
DOCS_SYNC=PASS/FAIL
INDEX_CHECK=PASS/FAIL
OUTGOING_CHECK=PASS/FAIL
HOOKS=PASS/FAIL
CI=PASS/FAIL/PENDING/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=NONE/<sanitized status>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**Never continue to a new task on your own. Never treat an ordinary GitHub CI PASS as confirmation of 1C database integrity or a successful application-level restore.**
