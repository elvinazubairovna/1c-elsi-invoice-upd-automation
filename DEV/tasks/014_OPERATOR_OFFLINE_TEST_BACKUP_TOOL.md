# TASK 014 — OPERATOR_OFFLINE_TEST_BACKUP_TOOL

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline and objective

- **Public repository:** `elvinazubairovna/1c-elsi-invoice-upd-automation`, expected branch `main`.
- **Task:** `014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL`.
- **Expected local `HEAD` and fresh remote `origin/main`:** `4592a17f42898d21850f6603b99cbab72db2cf1d`, independently checked by ChatGPT following Task 013.
- **Roles:** ChatGPT is architect and independent auditor; Codex is the bounded executor; the user is the Windows operator.
- **Verified context:** Task 013 published `DEV/tools/Test-ELSI-TestFolderWrite.ps1` after static checks. Following ChatGPT's audit, the owner ran it manually from a PowerShell 7.7.0 session without administrator elevation and reported `PROBE_PHASE=PROBE_VERIFY`, `PROBE_PRECHECK=PASS`, `PROBE_RESULT=CREATED_EMPTY_DIRECTORY`, `ERROR_CATEGORY=NONE`, `PRODUCTION_ACCESS=NONE`. This is **OWNER_REPORTED operator execution**, not Codex execution or proof of backup/restore. `_DIR_PROBE_013` now exists by owner report; **leave it untouched**. Task 013 also recorded `CODEX_WRITE_SCOPE=RESTRICTED`; do not change or circumvent that scope.
- **Goal for this task:** author, validate **without running against TEST**, document, and publish a small **operator-executed** PowerShell 7 tool for one offline, non-destructive file-level TEST backup and independent restore-copy parity drill. The owner will run it **only in a later step, after ChatGPT independently audits its complete source code**. Do not execute it against TEST in Task 014, including its read-only mode.
- The purpose is to prove file-copy consistency of an already closed, standalone TEST database. This task does **not** implement invoice/UPD functionality, install a 1C extension, launch 1C, or establish application-level recoverability.

## 2. Absolute access and publication boundaries

1. **PRODUCTION is unconditionally off-limits.** Never search for, enumerate, resolve, read, compare, open, copy, execute or alter the real ELSI database, its path, launcher entry, process, user session, service, settings or metadata. No fallback to production, other 1C installations or other bases.
2. **Codex must not perform any TEST filesystem read/write or invoke the new tool in its actual entry-point mode.** Do not check, create, delete or inspect `_DIR_PROBE_013`, TEST database contents, or any previous backup folder as part of this task. All TEST backup/restore operations belong to the future **operator-run** step, not Codex.
3. The script must be fixed to the Windows system-drive root plus the exact relative components `1C_TEST` (dedicated parent) and `ELSI_TEST` (source), with **new, unique** sibling destinations `_BACKUP_014` and `_RESTORE_CHECK_014`. No caller-supplied source or target paths, environment overrides (other than normal Windows system-drive determination), path discovery, sibling enumeration or wildcard parent traversal.
4. Preserve the existing `_DIR_PROBE_013`, all previous backup/probe folders, the source `ELSI_TEST`, unrelated Git files and worktree changes. **No deletes, cleanup, overwrite, rename, move, mirroring, ACL changes, ownership changes, elevation or forced process termination** are authorized, even on a partial failure.
5. TEST may contain unknown/confidential records. Database files, `.dt`, `.cf`, `.cfe`, `.epf`, copies, hashes, inventories, raw exception messages, actual paths, numeric sizes, file metadata, usernames, licensing information and accounting data must **never enter public Git, CI artifacts, reports, terminal output supplied to the owner or chat**. Only sanitized outcome fields can leave the operator-run script. The new script's **generic source code** may be published.
6. Unknown integration configuration alone does not prohibit **offline filesystem-only copying of a closed TEST base**; it remains `UNVERIFIED`. **No 1C application, Configurator, EDI, email, API, scheduled task, external sync, network transfer or background service is to be launched or operated** by this script. All application-level experiments must later undergo a separate integration/recipient safety assessment.

## 3. AGENTS-first and Git admission

1. Read `AGENTS.md` first, this entire task second, then Task/Report 013, Tasks/Reports 008–012 as relevant, and canonical `README.md`, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, plus pertinent 1C environment assessments.
2. Verify exact repository URL, `main`, local HEAD, **fresh remote** `origin/main` against the SHA above and relevant tracked-worktree cleanliness. Preserve unrelated untracked material, including the historically noted unrelated Task 001. On mismatch, `BLOCKED`: no merge/reset/rebase/pull, no silent conflict resolution.
3. Confirm PowerShell 7 is available for script parse and synthetic testing; do not install, elevate or modify the OS. Do not inspect Codex hidden configuration; use only already reported/explicitly documented write-scope evidence. Any proposed runtime filesystem operation outside Git workspace and an isolated synthetic fixture => `BLOCKED`.

## 4. Create one operator-only tool (do not execute against TEST)

Create **`DEV/tools/Invoke-ELSI-TestBackupDrill.ps1`**, a self-contained, readable PowerShell 7 script. It has **two mutually exclusive modes**:

- **Default (no switch):** print a brief, fixed, non-sensitive usage/status message; perform **no TEST lookup, no file enumeration, no creation, no content read and no network operation**. This may be syntax-tested, but do not invoke the entry point against TEST even in default mode during Task 014.
- **Explicit `-RunDrill`:** only for a subsequent human/operator PowerShell session after independent ChatGPT review. One attempt to back up the fixed TEST source to `_BACKUP_014` and create a verified independent restored copy at `_RESTORE_CHECK_014`. The switch must not accept arbitrary path values. Do not add a separate cleanup or unsafe override switch.

### 4A. Preflight in `-RunDrill` (operator invocation only)

1. Require Windows/PowerShell 7, the Windows **system-drive** fixed local volume, canonical fixed TEST parent/source/destination identity, ordinary directories, no reparse/junction/symlink components, and strict containment outside the project/Git tree and known sync-folder conventions. Fail closed on uncertain path or volume. No scanning other directories. Do not inspect production or the 1C launcher.
2. Exactly and recursively inspect **only** `ELSI_TEST` source for filesystem inventory, using APIs that do not follow reparse links. Check **one** ordinary, nonempty `1Cv8.1CD` at the expected level, regular ordinary file/dir entries, no unsupported special files, and two stable metadata inventories. Reject unexpected changed/unsupported entries. Do not interpret any record or extract 1C metadata.
3. Check TEST idleness with **one brief exclusive read-only handle open** for the exact standard database file, immediately close it. If inaccessible or not provably idle, stop without a retry, process lookup or live-copy workaround. This is not a guarantee all 1C writers are absent; a later source-final byte comparison is still required.
4. Use exact non-recursive lookup on `_BACKUP_014` and `_RESTORE_CHECK_014`, requiring **both absent** and rejecting inaccessible/reparse/ambiguous items. Do not enumerate or alter any older sibling, including `_DIR_PROBE_013`. Repeat exact target and parent checks just before creation. If a race produces a preexisting target, fail closed; never copy into an existing nonempty/unknown directory or overwrite any file.
5. Verify free space for **two full TEST copies plus a remaining reserve** equal to the greater of **1 GiB and 15% of the fixed volume capacity**, using local metadata only. Do not print source size, capacity or the numerical result. Reject unknown disk-space state.
6. Source backup and restored copy must remain on the same fixed local non-cloud drive, outside Git and outside known sync folders; no external upload, network or launch of 1C. If any positive evidence of active modification or unsafe external transfer appears, stop.

### 4B. Exactly one phase-by-phase attempt

Keep original TEST read-only. Use built-in PowerShell/.NET streaming operations, no external binaries/modules or unsafe `robocopy` flags. Use exact fixed destination names and non-overwriting file-create/copy semantics; preserve byte content and supported ordinary metadata without changing TEST. Do not copy reparse points. Never use `Copy-Item -Force`, `/MIR`, `/MOVE`, `/PURGE`, recursive delete or broad wildcards. The procedure has **at most one attempt per phase**:

- `P0_PREFLIGHT`: all §4A checks pass.
- `P1_SOURCE_BASELINE`: compute an in-memory relative-tree inventory and per-file SHA-256 of original TEST; suppress all names, sizes and digest output. If it fails, create no destination.
- `P2_CREATE_BACKUP_DIR`: create exactly `_BACKUP_014` after checking absent again. The API's success alone is insufficient: verify the exact item is an ordinary directory, not a link, and belongs to the fixed parent. Never overwrite or use a preexisting item.
- `P3_COPY_SOURCE_TO_BACKUP`: create subordinate ordinary directories and make a complete non-overwriting copy of every ordinary source file with original relative structure, rejecting reparse/special entries. Recheck key boundary conditions while traversing.
- `P4_VERIFY_BACKUP`: independently enumerate and compare relative structure, file counts, lengths and per-file SHA-256 of source and backup. If mismatched, stop before restore.
- `P5_CREATE_RESTORE_DIR`: create exactly `_RESTORE_CHECK_014`, after fresh absence check and only if P4 passed.
- `P6_COPY_BACKUP_TO_RESTORE`: copy the complete backup to the restored directory with non-overwriting operations, without reading from or modifying production or original TEST beyond already authorized checks.
- `P7_VERIFY_RESTORE`: independently verify all three trees have identical paths, counts, lengths and SHA-256 digests.
- `P8_SOURCE_FINAL`: recompute original TEST inventory and SHA-256 and compare with P1; repeat a single brief exclusive read-only database-file check. If original source changed, do not declare success.

**Error handling:** Each phase needs its own `try/catch`. Never collapse all failures into one generic `FAIL`. Classify from safe structured .NET exception type/HRESULT, unwrap common PowerShell wrappers in memory without exposing messages; categories `ACCESS_DENIED`, `SHARING_OR_LOCK`, `PATH_OR_TARGET`, `CAPACITY`, `UNSUPPORTED_ENTRY`, `SOURCE_CHANGED`, `PARITY_MISMATCH`, `RESOURCE_LIMIT`, `OTHER_IO`, `POWER_SHELL_RUNTIME`, `UNCLASSIFIED`. Unknown => `UNCLASSIFIED`. Do not print source paths, raw messages, stack traces, filenames, digests, inventory, numerical sizes, owner or machine details. On any failure stop immediately and leave all possible partial folders untouched; **no retry and no cleanup**. Where an operation itself failed, an explicitly fixed, direct metadata-only post-error lookup of the *current* target may be allowed to classify `CREATED/ABSENT/UNVERIFIED` without reading or changing contents.

**Output:** Emit only fixed machine-readable fields, e.g. `DRILL_PHASE`, `LAST_COMPLETED_PHASE`, `FAILED_PHASE`, `ERROR_CATEGORY`, `TEST_BOUNDARY`, `TEST_IDLE_CHECK`, `BACKUP_014`, `RESTORE_014`, `FILE_LEVEL_BACKUP`, `FILE_LEVEL_RESTORE`, `SOURCE_FINAL`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `INTEGRATIONS=UNVERIFIED`, `PRODUCTION_ACCESS=NONE`, `OPERATOR_RUN=...`, `STATUS=...`. Exit nonzero on failure. `FILE_LEVEL_BACKUP=PASS` and `FILE_LEVEL_RESTORE=PASS` are allowed **only after all P0–P8 succeed**; otherwise report partial status honestly. A file-level verified copy **does not prove** the copied base opens in 1C, that all records are synthetic, or that production is isolated technically. No 1C application-level restore in this task.

## 5. Validation within Task 014 — static and synthetic only

**Codex must not run the new script's actual entry point or read/modify the TEST filesystem.**

- Run PowerShell 7 AST parser and manually review entire new source: fixed path derivation, non-reparse traversal, target check-before-create, exactly authorized writes, safe non-overwriting copy semantics, output privacy, exception unwrapping and no hidden destructive action.
- Pure helper functions may be extracted/tested against **small, explicitly synthetic files** in an isolated, newly created **workspace-local test fixture** (not `1C_TEST`, not any real 1C DB, not any system/user path or public artifact). Fixture names and content must be fictional. No actual 1C files, production/test metadata or user identities. Tests must not accidentally invoke the main entry point or discover the fixed TEST path.
- At least exercise safe exception-category mapping, boundary containment and synthetic per-file hash/parity and changed-source failure behavior if those helpers can be isolated. Verify negative cases for reparse points and existing target using pure/mocked metadata if safe. If dynamic fixture testing is not safely achievable, clearly state `SYNTHETIC_TEST=NOT_ATTEMPTED` and why; do not fabricate success or quietly run against TEST.
- Verify PowerShell AST parsing and check there is no default-mode write, no external network, no 1C launch, no recursion outside the fixed source and new targets, and no broad deletes. A syntax/static pass **is not proof of a runtime-successful backup**.
- Do not execute `-RunDrill` during Task 014, even if automatic scripts indicate it is possible.

## 6. Exact Git-tracked allowlist

1. `DEV/tasks/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md` — the owner's copy included **verbatim**.
2. `DEV/tools/Invoke-ELSI-TestBackupDrill.ps1` — generic script source only.
3. `DEV/reports/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md` — sanitized actual report.
4. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — explicitly record Task 013 **owner-reported successful operator probe**, the existence of a newly coded but **not executed** backup tool, and continued `RESTORE_UNVERIFIED`. Keep future 1C application gates unchanged.
5. `DEV/docs/IMPLEMENTATION_STATUS.md` — coded vs statically/synthetically tested vs never operated distinction; product `NOT_IMPLEMENTED`, architecture `NOT_APPROVED`.
6. `DEV/docs/CHANGELOG.md` — factual Task 014 history.
7. `README.md` — only if needed for a minimal reference to the operator tool or to correct inaccurate text; do not claim runtime success.

All other tracked files read-only, including Task/Report 013, prior files, `AGENTS.md`, `DEV/tools/Test-ELSI-TestFolderWrite.ps1`, scanner, hooks, CI workflows, `.gitignore` and actual 1C files. Do not publish fixture output, logs, backup data, personal paths or binaries. Preserve unrelated untracked Task 001. If any needed code/test/document change exceeds the allowlist, stop `BLOCKED` and explain rather than expanding scope.

## 7. Documentation, security and publication

1. Reconcile against `README.md`, architecture, requirements, security, development workflow, TEST safety, implementation status, changelog, task template and prior relevant task/reports. Update all **affected allowlisted** docs. In particular, do not mistake the owner-reported Task 013 empty-folder success for file-level backup success. Preserve unknown integration status and strict no-production rules.
2. Write `DEV/reports/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md` with `Status`, `AGENTS-first`, `Git baseline`, `Script design and exact limitations`, `No TEST execution`, `Static and synthetic validations`, `Confidentiality / production boundary`, `Changed files`, a full `Documentation reconciliation` matrix (read/changed/why/evidence/unresolved), staged/index/outgoing/hooks/CI status at time of writing, `Operator next step`, and `Next action`. Never include actual local paths or any test data; do not invent future self-commit SHA.
3. Before commit, inspect `git status`, the exact staged file list and **entire staged diff**, `git diff --cached --check`, Markdown relative links and UTF-8. Do manual review for secrets, local paths, accidental accounting identifiers and test artifacts. Stage explicit allowlisted paths only; never `git add .`.
4. Immediately before each commit, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`, confirm `core.hooksPath=DEV/hooks` and do not bypass hooks. Before an ordinary fast-forward push, manually run `-Mode Outgoing` with the **exact actual pushed refs**, and allow pre-push hook to run. Do not `--force`, reset, merge/rebase or bypass security checks. If publication scanner rejects the script, stop; do not weaken scanner or publish around it.
5. After push, verify remote `main` SHA, public report and script presence, and completed **commit-specific** GitHub Actions status. Report `CI=PASS` only if actually confirmed; else `PENDING/FAIL/UNVERIFIED`. Report `STATUS=SUCCESS` only for script implementation/static testing/documentation/publication — **never for actual backup or restore** in this task.
6. **Do not ask owner to run the new script yet.** Finish with `NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`. After independent ChatGPT code audit, the owner will be given one explicit non-administrator command for the `-RunDrill` operator run in a later turn. Do not begin Task 015.

## 8. Required final concise report to owner

```text
TASK=014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=4592a17f42898d21850f6603b99cbab72db2cf1d
AGENTS_FIRST_READ=PASS/FAIL
OWNER_PROBE_013=OWNER_REPORTED_PASS
BACKUP_TOOL=CREATED/NOT_CREATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_TEST=PASS/PARTIAL/FAIL/NOT_ATTEMPTED
CODEX_TEST_ACCESS=NONE
CODEX_BACKUP_RUN=NOT_ATTEMPTED
OPERATOR_BACKUP_RUN=NOT_ATTEMPTED
FILE_LEVEL_BACKUP=UNVERIFIED
FILE_LEVEL_RESTORE=UNVERIFIED
APPLICATION_RESTORE=NOT_ATTEMPTED
INTEGRATIONS=UNVERIFIED
PRODUCTION_ACCESS=NONE
DOCS_SYNC=PASS/FAIL
INDEX_CHECK=PASS/FAIL
OUTGOING_CHECK=PASS/FAIL
HOOKS=PASS/FAIL
CI=PASS/FAIL/PENDING/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED/NOT_ATTEMPTED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=NONE/<safe blocker>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

## 9. Stop rules

Stop safely if the Git base does not match; the exact TEST source/destination safety rules cannot be expressed without reading production or widening scope; the operator script would require elevation, remote network access, deleting/overwriting, processing previous backup folders or opening 1C; code would expose data in outputs; synthetic tests would read actual TEST; any allowed path conflict requires unapproved modifications; or a security/publication gate fails. There is no permission in this task to access TEST, run the backup, restore a database, build `.epf` or start application-level tests.
