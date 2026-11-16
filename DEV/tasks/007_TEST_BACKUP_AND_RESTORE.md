# TASK 007 — TEST_BACKUP_AND_RESTORE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Governance and verified baseline

- **Repository:** `elvinazubairovna/1c-elsi-invoice-upd-automation` (PUBLIC).
- **Task ID:** `007_TEST_BACKUP_AND_RESTORE`.
- **Expected branch:** `main`.
- **Expected base / remote HEAD SHA at task issue:** `730096a25c7acfb48d8be2380fd5d17113892bba` (independently checked by ChatGPT against GitHub after Task 006).
- **Architect/auditor:** ChatGPT. **Owner:** user. **Executor:** Codex.
- **Authority:** ChatGPT defines this exact technical procedure. Codex implements it; no independent architecture, security-relaxation, accountancy or product decisions. The owner has requested that routine technical choices not be sent back for approval. **This does not waive stop conditions or authorize production access.**

### Goal

Prove a **local, offline, file-level backup and restore drill** for the **specifically bounded** 1C test information base `ELSI_TEST`, without ever touching or discovering the production database, without publishing any database material, and without changing 1C settings or accounting records.

This is **not** a claim that application-level restore, 1C login, `.epf` execution, external integrations, permission isolation or production readiness have been verified. The only permitted live operation is a strictly scoped, offline **read/copy** of TEST, with two new TEST-only backup/restore destinations. If conditions are not provably safe, stop with `BLOCKED`, do not improvise.

## 2. Explicit owner-reported facts and boundaries

The owner manually created `ELSI_TEST` from the official **ordinary** (not demo) 1C:Accounting 3.0 release `3.0.208.14`; platform `8.5.1.1343`; Windows file-mode base; test organization has synthetic name. The owner used the 1C **About** dialog to verify TEST has a different directory from production. These are `OWNER_REPORTED`; Codex has not independently validated them.

There were pre-existing counterparties of unknown provenance even in the fresh template. **Do not inspect their contents or assume all TEST data is synthetic.** Treat the entire TEST database backup as potentially confidential. It must never be copied into the Git working tree, a cloud-synced directory, online service, Actions artifact, issue, message, or report.

**Production is absolutely off-limits**: do not enumerate, resolve, open, scan, copy, rename, modify, back up, load, launch or attempt to identify the production base or its path. Do not scan a whole drive, the 1C launcher registry/list, process command lines, users' profiles or directories outside the exact TEST boundary. Do not inspect or use the owner's prior screenshots.

### Local TEST boundary — no absolute path in Git

The owner designated a dedicated TEST root on the Windows system drive named `1C_TEST`, containing the exact child `ELSI_TEST` (the location was confirmed through the test application's About window). **The local absolute path itself must not be written into a tracked file.** For any runtime check, construct ONLY the candidate path by joining the Windows system-drive root with the two fixed **relative** components `1C_TEST` and `ELSI_TEST`; do not search for it or fall back to another path. Do not accept an arbitrary directory parameter, environment override or alternate base name. If absent/ambiguous, stop `BLOCKED`.

If the repository is on a non-Windows host, the machine identity is uncertain, or no exact TEST candidate can be established from this rule, stop `BLOCKED`. Never use or inspect production as a fallback.

## 3. Mandatory AGENTS-first and read-only preflight

1. Fully read `AGENTS.md`, then this task, then `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md` and relevant previous reports.
2. Check current Git working tree, branch, origin URL and `origin/main` **before** implementation. Expected HEAD exactly `730096a25c7acfb48d8be2380fd5d17113892bba`. Preserve ALL unrelated tracked/untracked files, especially the previously reported unusual Task 001 file. Conflict or divergent history => `BLOCKED`.
3. Check Windows and PowerShell 7 availability through normal shell metadata only. No installation, elevation or permissions change.
4. Check only the explicitly constructed TEST candidate, its dedicated parent directory, and candidate contents. Resolve its canonical location, reject missing directories, reparse points/junctions/symlinks in every applicable path component, unexpected alternate volumes, and a path outside the dedicated TEST root. Do not read any sibling's contents. **The only accepted TEST data directory is the exact child `ELSI_TEST`; no other source candidates.**
5. Verify TEST contains an ordinary regular `1Cv8.1CD` file, not a symlink/reparse point or a zero-length placeholder. This proves presence of a database file, **not** its health or complete synthetic character. Do not read its content into reports or logs.
6. Determine whether TEST is idle **without reading any 1C user/account/process/production details**: obtain a temporary exclusive *read-only* file handle to the exact TEST `1Cv8.1CD` and close it immediately. If it cannot be exclusively opened, or lock semantics cannot be established safely, stop `BLOCKED` and report only `TEST_SESSION_NOT_CONFIRMED_CLOSED`; **never kill or disconnect any process**. No copy with active/uncertain users.
7. Ensure sufficient free space on the TEST volume to accommodate **two additional complete TEST copies plus a safety reserve** (minimum additional 1 GiB; also require projected free space after copies to be at least 15% of volume size, whichever reserve is larger). Only enumerate files strictly under the TEST child. If the test tree has reparse points, unsupported/special files, unrecognized attributes, inaccessible paths, multiple candidate DB files or unstable changes, stop `BLOCKED`. Do not dump filenames to Git/report.
8. Check the local backup and restore target names selected below do not exist before any write. Never delete, overwrite, recycle, rename, compact, optimize, repair or alter existing databases or previous backups. If any target already exists, stop `BLOCKED` (do not add a timestamp fallback without architect instruction).

## 4. Exactly permitted local operations (TEST only)

**After all section 3 checks pass**, create these two entirely new sibling directories **inside the dedicated TEST root**:

- `_BACKUP_007` — file-for-file local backup of `ELSI_TEST`.
- `_RESTORE_CHECK_007` — independent file-for-file local restoration **from the newly created `_BACKUP_007`**, not from the original.

Technical rules:

1. The two destination paths must be constructed from the same dedicated TEST parent as the source, using only these exact folder names. They must not exist before the operation. Never create them inside the Git repository or OneDrive/Dropbox/sync folders (if sync location cannot be excluded from known path semantics, stop).
2. The source remains read-only; no modifications, locking changes, application launch or configuration changes are permitted. This task **does not** perform 1C GUI/API/Configurator operations.
3. Copy the **complete directory tree** with original relative structure, from source TEST to `_BACKUP_007`, then from `_BACKUP_007` to `_RESTORE_CHECK_007`. Do not follow any reparse point; on detecting any, stop before copying. Do not execute external programs from TEST and do not upload any file.
4. Prohibit destructive copy flags and mirrored sync (e.g. no `/MIR`, `/MOVE`, `/PURGE`, `/EFSRAW`), shell globbing into unknown paths, and `git add .`. Use only explicitly scoped and non-destructive file copy methods. Preserve bytes and relevant file attributes; if metadata cannot be preserved, note the limitation, do not claim full fidelity.
5. Verify all three inventories — original TEST, backup and restored TEST copy — for identical relative paths, file counts, file lengths and per-file SHA-256 **computed locally**. No hashes, absolute paths or file contents in a committed file, terminal summary intended for the owner, GitHub Actions, or report. The only permitted published results are `PASS/FAIL/UNVERIFIED`, non-identifying categorical evidence and limitations.
6. Repeat the independent exclusive-read check on the original exact TEST database file after copy; if source changed or the checksum comparison fails, return `FAILED`/`BLOCKED` with safe reason. No automatic retry against an active base.
7. **Do not register or launch the restored copy in 1C in this task.** Hence distinguish `FILE_LEVEL_RESTORE=PASS` from `APPLICATION_RESTORE=NOT_ATTEMPTED`. A checksum pass is not a proof of operational recovery.
8. Do not remove the created backup or restored copy during Task 007. If the copy fails partially, do not try to clean up destructively. Leave artifacts local, record sanitized failure and ask the architect for a separate remediation task. No access to production in remediation.
9. **No debug dumps or verbose file listings in chat/CI/Git**. Locally generated outputs containing path, account, data, hashes or filenames remain outside the repository and should be suppressed where possible.

### If data safety or source integrity is uncertain

Even if earlier sections pass, any indication of an external exchange, inter-base link, active client, unexpected read/write changes or unclear ownership => stop and report `BLOCKED`. Lack of a proven 1C runtime check means `APPLICATION_RESTORE=NOT_ATTEMPTED`, not `PASS`.

## 5. Required Git deliverables and strict allowlist

The only Git-tracked paths allowed to change:

1. `DEV/tasks/007_TEST_BACKUP_AND_RESTORE.md` — owner's downloaded task file; include **verbatim**.
2. `DEV/reports/007_TEST_BACKUP_AND_RESTORE.md` — factual, sanitized report.
3. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — update readiness matrix with exact independently verified statuses, no paths or hash values.
4. `DEV/docs/IMPLEMENTATION_STATUS.md` — reflect verified/unverified distinction and remaining blockers.
5. `DEV/docs/CHANGELOG.md` — add new task record at top if task genuinely made documented progress, even if test stayed blocked after a reportable preflight; avoid claiming success if blocked.
6. `README.md` — change only if a minimal existing link or statement is now materially inaccurate; otherwise leave unchanged.

All other tracked files **read-only**. For any required change outside the allowlist, stop with `BLOCKED` and describe the conflict without making unapproved edits.

Do **not** write or commit PowerShell source tools, `.epf`, `.cfe`, `.dt`, `.cf`, `1Cv8.1CD`, backup archives, reports with private paths, new GitHub workflows, screenshots, license information or any real accounting data. Source/backup/restored database files must exist **only outside the repository**.

## 6. Implementation procedure and mandatory documentation reconciliation

1. Preflight per sections 2–3; no 1C access or TEST directory mutation until all read-only gates pass.
2. Carry out only the offline file-level copy/restore verification of section 4. Stop on any failed gate without trying alternative paths or moving to production.
3. Compare the result with `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, and `DEV/docs/CHANGELOG.md`. Update all **affected allowed** canonical docs in the same task. Do not describe the 1C environment as ready for interactive/API tests merely because file restoration worked.
4. In `DEV/docs/CHANGELOG.md` record truthful task outcome; in `DEV/docs/IMPLEMENTATION_STATUS.md` distinguish `FILE_LEVEL_BACKUP` and `FILE_LEVEL_RESTORE`, and explicitly keep `APPLICATION_RESTORE`, TEST permission review, `.epf` and integrations as `UNVERIFIED`/`NOT_ATTEMPTED`, and architecture as `NOT_APPROVED`, product implementation as `NOT_IMPLEMENTED`.
5. Create `DEV/reports/007_TEST_BACKUP_AND_RESTORE.md` containing: `Status`, `AGENTS-first confirmation`, `Expected/observed Git base`, `Preflight result`, `Operations actually performed`, `File-level validation`, `Application-level limitations`, `PRODUCTION_ACCESS=NONE`, `Confidentiality review`, `Documentation reconciliation` matrix (all canonical docs checked, changed/unchanged and why, evidence), `Changed files`, `Index/Outgoing/Hooks/CI`, `Git publication`, `Blockers`, `Next action`. **No absolute local paths, personal identifiers, secrets, document records, filenames beyond the generic standard 1C database filename, numeric hashes, licensing or screenshots.**
6. Do not claim `SUCCESS` for backup/restore if a copy did not complete or any digest/file parity check failed. `SUCCESS` for task execution means all applicable actual gates and publication pass, not production readiness.

## 7. Mandatory static and publication checks

- Review `git status`, exact `git diff --cached --name-only`, entire staged diff and `git diff --cached --check`; check markdown UTF-8 and relative links.
- Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` **immediately before each commit**; verify `core.hooksPath=DEV/hooks`; do not bypass hooks.
- Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` **with the exact refs being pushed** before any push; do not bypass pre-push hook.
- Run existing security tests if changes to security tooling are proposed; such changes are **not permitted** here, so stop for separate task rather than implementing them.
- Commit only the allowlisted sanitized text documents and task file; ordinary fast-forward push to `origin/main`, never `--force`/`--no-verify`.
- Confirm remote HEAD and publicly accessible task/report/docs, and query the commit-specific GitHub Actions run for the **final remote HEAD**. `CI=PASS` only when a completed successful run for that SHA is confirmed; otherwise `PENDING`/`FAIL`/`UNVERIFIED` honestly.
- The report is written before final commit and must not pretend to contain its own future SHA; put final remote SHA in the response to owner.
- No Task 008 or `.epf` tests until ChatGPT independently audits 007.

## 8. Acceptance criteria

- `AGENTS.md` read **first**, then this task. Git base matches expected SHA.
- No discovery, reads, process introspection, copy, modifications, or connections to production.
- Every local read/write is explicitly bounded to the designated TEST child and its two dedicated local sibling directories; reparse point/path ambiguity handled by fail-closed behavior.
- TEST proved idle for backup; TEST original unchanged; two new copies made outside Git; byte-for-byte inventories and hashes match if full file-level verification is claimed.
- No 1C execution, no application-level restore, no `.epf` and no accounting document creation.
- Canonical documentation fully reconciled; no unsupported claims; published documentation contains no local absolute paths, unknown counterparty details or database material.
- Allowed files only; Index/Outgoing hooks and GitHub publication checks properly recorded.
- Stop safely with `BLOCKED` if required preconditions fail. This is preferable to a speculative `SUCCESS`.

## 9. Required final status (to owner)

```text
TASK=007_TEST_BACKUP_AND_RESTORE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=730096a25c7acfb48d8be2380fd5d17113892bba
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

## 10. Hard stop conditions

Stop without improvisation on any of the following: missing/mismatching repo or SHA; forbidden/prod path required; cannot uniquely validate the exact TEST source; active/uncertain TEST session; symlink/junction/reparse or unsupported files; missing space; destination exists; corrupted/inconsistent copy; required permissions absent; an external exchange risk is suspected; unrelated files at risk; confidentiality scanner fails; documentation would require unapproved edits; or Git push would rewrite history.

**Do not ask the owner to decide routine implementation details. Do not interpret the owner's general instruction as permission to cross any hard safety boundary. Where physical owner action is unavoidable (e.g. closing a TEST application), report the precise required action and stop.**
