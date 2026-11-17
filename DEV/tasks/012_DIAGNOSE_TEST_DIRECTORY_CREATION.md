# TASK 012 — DIAGNOSE_TEST_DIRECTORY_CREATION

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Ownership, checked baseline and goal

- Repository: `elvinazubairovna/1c-elsi-invoice-upd-automation` (**public**); branch: `main`.
- Expected exact local and freshly fetched `origin/main` HEAD: `6fff8bf312d041ed9b7bc882b1cf10143acb7854` (independently checked by ChatGPT after Task 011).
- Architect/auditor: ChatGPT. Executor: Codex. Owner: the user.
- Task 011 passed TEST preflight and source digest computation, but stopped at `P2_CREATE_BACKUP_DIR` with `UNCLASSIFIED`. No file-level backup was verified; `_BACKUP_011` status was not examined after the error. Do **not** infer that the folder was created or that NTFS permissions caused the error.
- **Goal:** determine the present **metadata-only** state of exactly the Task 011 backup target and safely test whether the designated TEST parent supports creation of **one new, empty directory**, with reliable, sanitized phase-specific error classification. This is **not** a retry of backup/restore, an exploration of the 1C database or a repair of Task 011.

## 2. Absolute security boundary

- **PRODUCTION: absolute prohibition** on discovery, path/registry/launcher/process enumeration, metadata reads, opening, backup, comparison, copying, launch or modification. Never select an alternative source. Do not inspect unrelated Windows/user paths, 1C settings, profiles, services, screenshots or logs.
- **Only allowed local runtime boundary:** derive the Windows system-drive root and join the exact relative component `1C_TEST` (parent); only inspect the **exact children** `ELSI_TEST` (directory identity only), `_BACKUP_011` (existence/type only) and `_DIR_PROBE_012` (probe only). Do not list the parent contents or recurse inside any child. Do not access `_RESTORE_CHECK_011` or any earlier task folders. Do not follow reparse points/symlinks/junctions.
- **Allowed local write:** if and only if all preconditions pass and `_DIR_PROBE_012` does not exist, make **one** non-overwriting attempt to create that exact empty directory *directly inside* the dedicated TEST parent. It must never be made inside `ELSI_TEST`, the Git worktree, a sync/cloud folder or another location. No files are created inside it. Do not delete, rename, overwrite, move, or clean it up, even after success; a later task must authorize any removal.
- Do not read file contents or hashes, open/run 1C, install packages, request elevation, alter permissions/ACLs, invoke backup/restore, send network traffic outside routine authorized Git operations or change application configuration. Unknown 1C integration settings are irrelevant to this single empty-folder creation; they remain `UNVERIFIED` for application-level tests.
- The entire public Git repo, chat and CI must remain free of local absolute paths, account identifiers, ACL subjects, error strings containing paths, usernames, credentials, license numbers, accounting records, snapshots and source files. Only vetted categorical statuses may be published.

## 3. Required initial reading and Git preflight

1. Read `AGENTS.md` **fully and first**, then this exact file **fully**; read Task/Report 011 and Reports 008–010, plus `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `README.md` and relevant 1C assessments. Do not work from memory or the task summary alone.
2. Verify `main`, local HEAD, clean relevant tracked tree, expected `origin` URL and freshly fetched remote `main` at the SHA above. Preserve every unrelated tracked/untracked file (notably the previously observed unrelated Task 001). Do not pull/reset/merge/rebase or force push. Git mismatch => `BLOCKED` before local probe.
3. Confirm Windows and PowerShell 7 from ordinary shell facts without privilege elevation or system enumeration. Construct the exact fixed TEST parent. Check only the dedicated parent path components and known `ELSI_TEST` child: local system volume, ordinary directory, canonical containment, absence of reparse/special links, not inside the repo or known cloud-sync convention. If these cannot be verified **without scanning outside the allowed boundary**, stop `BLOCKED`.
4. Inspect `_BACKUP_011` via one direct exact-path filesystem-item lookup, **not** recursive listing: report `ABSENT`, `PRESENT_DIRECTORY`, `PRESENT_OTHER` or `UNVERIFIED`. Treat a symlink/reparse item as `PRESENT_OTHER` and do not follow. Never edit or enumerate it.
5. Check that `_DIR_PROBE_012` is truly `ABSENT` using a direct filesystem-item lookup that distinguishes inaccessible items from missing items (do not rely solely on `Test-Path`). If present, inaccessible, reparse, or ambiguous, stop `BLOCKED` with `PROBE_TARGET_NOT_EMPTY_OR_UNVERIFIED`; do not select a new name. No requirement for TEST to be idle because this task does **not** open its database and changes only the dedicated parent; nevertheless, any unexpected unsafe or boundary condition is a hard stop.

## 4. One controlled directory-creation diagnostic

**Do not write a permanent helper script or logs.** Use built-in PowerShell 7/.NET APIs in-memory, with explicit `try/catch` and `$ErrorActionPreference = 'Stop'` where applicable. A directory-creation API call may be made **once only**, using the exact prevalidated `_DIR_PROBE_012` path. Prefer a non-overwriting path/target guard immediately before the call; a time-of-check/time-of-use race, ambiguous target, or unexpected preexistence => stop, not overwrite. Do not write contents in the new directory.

Phase markers to collect:

- `D0_BOUNDARY`: Git/Windows/fixed TEST parent and source identity preflight complete.
- `D1_PRIOR_TARGET`: exact `_BACKUP_011` state determined without reading its contents.
- `D2_PROBE_ABSENCE`: exact `_DIR_PROBE_012` absence confirmed.
- `D3_DIRECTORY_CREATE`: one attempt to create the exact new empty directory, using a single specific built-in API. Keep the actual script/command and private paths **out of public Git and logs**.
- `D4_PROBE_VERIFY`: only after D3, obtain direct, nonrecursive metadata for `_DIR_PROBE_012` to determine `CREATED_EMPTY_DIRECTORY`, `ABSENT`, `OTHER`, or `UNVERIFIED`. Do not enumerate its children. A successful creation call without verified directory identity must **not** be reported as `PASS`.

For a failure, capture the **structured** exception data locally in memory at the phase that failed: PowerShell ErrorRecord's `Exception.GetType().FullName`, `.HResult`, and (if applicable) the structured `InnerException` type/HResult. Do not use `.Message`, raw ErrorRecord rendering, stack trace, target-object string or filesystem path in reports/terminal output. Classify from exception type and well-understood HRESULT only (e.g. `UnauthorizedAccessException`/`SecurityException` => `ACCESS_DENIED`; documented directory/path issues => `PATH_OR_TARGET`; recognized I/O or sharing failures => `OTHER_IO`/`SHARING_OR_LOCK`; unknown => `UNCLASSIFIED`). If the exception class is one of the standard public .NET types and the HResult contains no private data, you **may** publish only a fixed allowlisted category plus sanitized numeric HRESULT code; otherwise say `UNCLASSIFIED`. Do not invent an error category when evidence is ambiguous.

After D3 fails, **one** extra direct metadata check of the exact `_DIR_PROBE_012` item is permitted solely to learn whether the directory may have been created despite the error. No retry, overwrite or cleanup. Record `LAST_COMPLETED_PHASE`, `FAILED_PHASE`, `ERROR_CATEGORY`, `PROBE_RESULT`, `PRIOR_BACKUP_011`; never print raw exceptions. If D3 succeeds and D4 confirms an ordinary empty probe directory, report `DIR_CREATE=PASS`, but **do not** claim backup works; source reading/copying/restore are not part of this task.

## 5. Git allowlist (exhaustive)

Add/modify **only**:

1. `DEV/tasks/012_DIAGNOSE_TEST_DIRECTORY_CREATION.md` — owner-provided source **verbatim**.
2. `DEV/reports/012_DIAGNOSE_TEST_DIRECTORY_CREATION.md` — sanitized factual report.
3. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — narrow Task 012 outcome, current exact `_BACKUP_011` state and limitations.
4. `DEV/docs/IMPLEMENTATION_STATUS.md` — exact verified/unverified statuses and link to report.
5. `DEV/docs/CHANGELOG.md` — factual new Task 012 entry at top, including a blocked result if applicable.
6. `README.md` — **only** if a current statement is demonstrably inaccurate; otherwise untouched.

Everything else is read-only, including root `AGENTS.md`, prior tasks/reports, PowerShell security tools, CI, hooks and `.gitignore`. Do not add code/PowerShell helper files to Git, binaries, screenshots, or any 1C material. If corrections require files outside allowlist, stop and report the conflict instead of expanding scope.

## 6. Required documentation, checks and publication

1. Report must separate `DIR_CREATE` from `FILE_LEVEL_BACKUP`, `FILE_LEVEL_RESTORE`, `APPLICATION_RESTORE`. The latter remain `NOT_ATTEMPTED` in Task 012, and no previous backup may be reclassified without actual evidence. Record whether a probe directory now exists, **not** its full path.
2. Reconcile actual actions and evidence against README, architecture, requirements, security, workflow, canonical TEST safety, implementation status, changelog, task template and historical reports. Update every *affected allowed* document and include a `Documentation reconciliation` matrix with reviewed/changed/reason/evidence/discrepancies. Preserve `NOT_APPROVED` integration architecture and `NOT_IMPLEMENTED` invoice/UPD generator.
3. Before committing, create the report (without its own future commit SHA), inspect exact staged filenames and complete staged diff, verify UTF-8/links and `git diff --cached --check`, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` immediately before commit; preserve `core.hooksPath=DEV/hooks`. No bypass of hooks.
4. Before push manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` with actual remote ref update, ensure pre-push hook runs. Ordinary fast-forward push to `origin/main` only, without `--force`, `--no-verify`, reset or history rewriting. Do not stage any unrelated task.
5. Confirm actual remote HEAD SHA, public report and commit-specific GitHub Actions status. CI `PASS` only with a completed successful run for that exact SHA; else `PENDING/FAIL/UNVERIFIED`. A correctly blocked probe may still publish a truthful report. `SUCCESS` for Task 012 means a verified, tightly scoped diagnostic and documentation/publication, **not** a successful backup, restore or 1C application test.
6. Stop after this task and await independent ChatGPT audit; do not start Task 013 automatically.

## 7. Stop conditions

Unexpected Git baseline/remote, unknown or reparse path, inability to verify TEST parent or target absence, unsupported Windows/tooling, possible production access, unclear write target, need for elevation/ACL changes, unexpected existing probe item, leak of private data, failure of publication security gates, or required out-of-scope edits => `BLOCKED` and **no workaround**. If a directory-creation attempt errors, stop and preserve its state with no retry/deletion; only the single direct probe existence check explicitly authorized above is allowed.

## 8. Required final response

```text
TASK=012_DIAGNOSE_TEST_DIRECTORY_CREATION
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=6fff8bf312d041ed9b7bc882b1cf10143acb7854
AGENTS_FIRST_READ=PASS/FAIL
TEST_PARENT_BOUNDARY=PASS/FAIL/UNVERIFIED
PRIOR_BACKUP_011=ABSENT/PRESENT_DIRECTORY/PRESENT_OTHER/UNVERIFIED
PROBE_PREEXISTING=ABSENT/PRESENT/UNVERIFIED
LAST_COMPLETED_PHASE=D0_BOUNDARY/D1_PRIOR_TARGET/D2_PROBE_ABSENCE/D3_DIRECTORY_CREATE/D4_PROBE_VERIFY/NONE
FAILED_PHASE=NONE/D0_BOUNDARY/D1_PRIOR_TARGET/D2_PROBE_ABSENCE/D3_DIRECTORY_CREATE/D4_PROBE_VERIFY
ERROR_CATEGORY=NONE/ACCESS_DENIED/PATH_OR_TARGET/SHARING_OR_LOCK/OTHER_IO/UNCLASSIFIED
DIR_CREATE=PASS/FAIL/NOT_ATTEMPTED/UNVERIFIED
PROBE_RESULT=CREATED_EMPTY_DIRECTORY/ABSENT/OTHER/UNVERIFIED
FILE_LEVEL_BACKUP=NOT_ATTEMPTED
FILE_LEVEL_RESTORE=NOT_ATTEMPTED
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
BLOCKERS=NONE/<sanitized reason>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**No 1C launch, no accounting-data write, no file-level backup retry, no cleanup. Diagnose only the ability to create an empty directory in the dedicated TEST parent.**
