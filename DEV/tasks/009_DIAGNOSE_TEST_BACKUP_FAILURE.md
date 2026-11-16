# TASK 009 — DIAGNOSE_TEST_BACKUP_FAILURE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline, objective

- **Repository (public):** `elvinazubairovna/1c-elsi-invoice-upd-automation`.
- **Task:** `009_DIAGNOSE_TEST_BACKUP_FAILURE`.
- **Expected branch:** `main`.
- **Expected local and remote base SHA:** `39b26d7bace2aa3e5a77817d1f11334116620087` (independently verified by ChatGPT after Task 008).
- **Architect and auditor:** ChatGPT; **executor:** Codex; **project owner:** user.
- **Goal:** perform a tightly bounded, **read-only diagnostic** of the FAILED file-copy attempt in Task 008. Establish the state of the exact TEST source and the **two exact Task 008 output names** at the metadata level, classify what can/cannot be proven about the failure, and propose the smallest safe next step. **Do not retry the backup in this task.**
- **Known evidence from Report 008:** exact TEST path checks passed, the initial exclusive read-only handle test passed, then a local copy/hash operation returned generic `FILE_LEVEL_OPERATION=FAIL`. The failing sub-step and error cause were **not captured**. Backup completeness, remaining artifacts and source post-operation integrity are **UNVERIFIED**. Restore was not attempted.
- **Important:** This task is a diagnostic, **not** approval to use TEST copies, create new backups, clean up partial copies, run 1C, or access production. The owner has delegated routine technical decisions to ChatGPT; this does **not** relax any access boundary or stop condition.

## 2. Hard safety boundary

**PRODUCTION:** Absolutely no search, enumeration, reads, opens, copies, backups, metadata inspection, process inspection, launcher inspection, path identification, changes or service control, direct or indirect. Never use production as a comparison or fallback.

**TEST scope:** On the current Windows system drive, construct only the fixed `1C_TEST` parent and these **three exact child names**:

1. `ELSI_TEST` — original TEST source, metadata only.
2. `_BACKUP_008` — possible partial Task 008 backup, metadata only.
3. `_RESTORE_CHECK_008` — possible partial Task 008 restored-copy destination, metadata only.

No other sibling, drive root inventory, user profile, screenshots, shell history, 1C registry/launcher lists, arbitrary disk searches, unknown logs, CI artifacts or processes. Do **not** use alternate directories, relative working-directory guessing, environment-supplied base paths or wildcards that could leave this exact boundary.

The contents of any of these folders may contain confidential data. **Never emit absolute local paths, names of user files, original file sizes, hashes, counterparties, license or user details, ACL identities or database content** to console summaries intended for the owner, Git, reports, CI or chat. Only publish sanitized statuses such as `PASS`, `FAIL`, `PRESENT`, `ABSENT`, `UNKNOWN`, and high-level bounded reason categories.

**Read-only in TEST for this task.** Do not create, overwrite, delete, rename, move, restore, repair, open in 1C, register in 1C, edit ACLs, modify settings or run cleanup. Do not run backup-copy/hash operations again. Do not take ownership or request elevation. Do not try to force-close any application. No external transfer or data publication.

## 3. Initial reading and Git preflight

1. Read `AGENTS.md` **first**, this complete task **second**. Then read full Task/Report 006–008, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `README.md` and relevant previous investigations. Do not use memory in place of the actual files.
2. Only then check local `HEAD`, branch, remote URL, fresh read-only remote `main` and worktree. All expected refs must match the SHA above. Preserve unrelated tracked/untracked files (including the previously noted unusual Task 001 filename); do not pull/reset/merge/rebase or rewrite history.
3. Use Windows shell and PowerShell 7, without installation or elevation. If platform mismatch, tool missing or runtime preconditions fail, report `BLOCKED` rather than attempting any alternate source.
4. Existing Task 008 report is the **only** authorized source of prior-failure narrative. It contains no exact exception or step. Do not invent one; no post-hoc cause claim without new bounded evidence.

## 4. Permitted read-only diagnostic procedure

Perform these checks in order, using only TEST-scoped operations and **suppressing raw paths and per-file metadata in final output**:

### A. Boundary and tree conditions

1. Reconstruct the same fixed TEST parent/source location used in Tasks 007/008 from the Windows **system-drive root** and the two fixed components; no discovery or overrides.
2. Establish that the parent and original child are existing ordinary local directories, not junctions/symlinks/reparse points; confirm canonical ancestry, volume, and that the entire scope is outside the Git worktree and known cloud-sync conventions. If the TEST source is ambiguous, stop before any recursion and report `BOUNDARY_UNVERIFIED`.
3. Confirm the exact original `ELSI_TEST` contains one regular, nonempty `1Cv8.1CD` at the expected level. Inspect only **metadata**. Do not interpret data, open 1C, read database bytes or compute content hashes.
4. Check available disk space **only for the same TEST volume** and whether it is currently below the Task 008 two-copy-plus-reserve rule. Report `SPACE_NOW=SUFFICIENT/INSUFFICIENT/UNVERIFIED`. Current capacity does not prove available space at the historical failure moment.
5. For the two **exact** Task 008 destination names, check existence and ordinary directory/reparse status, including safe handling of absent destinations. If a path is a reparse point, stop and report sanitized `UNSAFE_TARGET`; **never follow it**.

### B. Bounded metadata parity (only if all checked paths are safe)

1. If a destination exists, inspect **metadata only** of entries strictly under that exact child. Do not access file contents, read actual database bytes, calculate file hashes or inspect external targets. Never follow a reparse point. If any reparse/special entry, unexpected inaccessible path or unsupported metadata is encountered, stop this branch with `UNVERIFIED`.
2. Compare in memory the **relative-path keys**, file-type flags, file lengths and ordinary attributes of the source and existing destination trees. The keys are for internal parity checking only; **never print or persist them**. Report only `METADATA_PARITY_WITH_SOURCE=MATCH/MISMATCH/NOT_APPLICABLE/UNVERIFIED` for each exact destination.
3. Report `BACKUP_008=ABSENT/PRESENT/UNVERIFIED` and `RESTORE_008=ABSENT/PRESENT/UNVERIFIED`. Optionally distinguish a present destination as `EMPTY/NONEMPTY/UNVERIFIED` without listing entries. **Metadata parity is not byte integrity, a valid backup or proof of 1C recovery.** Even if parity matches, statuses must remain `FILE_LEVEL_BACKUP=UNVERIFIED`, `FILE_LEVEL_RESTORE=UNVERIFIED` (or `NOT_ATTEMPTED` per earlier task evidence) and `APPLICATION_RESTORE=NOT_ATTEMPTED`.
4. If TEST appears active or metadata changes between snapshots, avoid intrusive access, label `SOURCE_STABILITY=UNVERIFIED`, do not repeat scans in a loop, and stop metadata parity as needed. Do not ask the user to close 1C merely for a read-only diagnostic.

### C. Error provenance and next-step design

1. Review **only** prior task/report text already within Git and any non-sensitive *in-memory error category produced by the checks above*. No broad terminal/log-history scraping. The prior error is documented generically: do not assert that permissions, storage, active sessions or a specific filename caused it unless directly supported by permitted evidence.
2. Classify `ROOT_CAUSE=EVIDENCED_<safe category>/UNDETERMINED`. Explain the basis and confidence. Missing artifacts or partial copies locate *possible progress*, not the historical failure point or root cause.
3. Formulate a concrete safe recovery decision for ChatGPT, **without executing it**. If no root cause is proven, propose a new, separate task for an instrumented and bounded TEST-only attempt with exception categories and sanitized stage markers, **after** a fresh preflight and explicit new destination names, and without modifying/clearing Task 008 artifacts. If TEST source is unsafe or a true permission/space issue is evidenced, propose the narrow correction instead, still without acting.
4. Distinguish original TEST post-copy integrity `SOURCE_INTEGRITY_AFTER_008=UNVERIFIED` unless independent pre/post byte-level evidence from Task 008 is already available (report says it is not). Do not infer integrity from current metadata.

## 5. Allowed repository changes (exhaustive)

Only these paths may be added/edited:

- `DEV/tasks/009_DIAGNOSE_TEST_BACKUP_FAILURE.md` — commit this owner-provided task **verbatim**.
- `DEV/reports/009_DIAGNOSE_TEST_BACKUP_FAILURE.md` — factual sanitized report; include evidence/limitations and documentation reconciliation.
- `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — append diagnostic result and preserve existing FAIL/UNVERIFIED statuses; do not claim valid backup.
- `DEV/docs/IMPLEMENTATION_STATUS.md` — reflect reportable Task 009 findings and remaining blockers.
- `DEV/docs/CHANGELOG.md` — record actual diagnostic work (or a truthful blocked stop).
- `README.md` — only if an existing statement becomes materially inaccurate; otherwise unchanged.

Everything else is **read-only inside repository**. No code, scripts, `.epf`, 1C exports, ACL/config changes, new workflows or security-bypass edits; no additional local file artifacts. Any required change outside the allowlist -> `BLOCKED` and request architect decision through the owner.

## 6. Report, documentation and publication

1. In `DEV/reports/009_DIAGNOSE_TEST_BACKUP_FAILURE.md`, record: `Status`, Git preflight, AGENTS-first, scope/safety boundaries, **exact category-level** observations for original/backup/restore, source health limits, failure diagnostic with evidence confidence, permitted operations actually performed, forbidden operations not performed, `PRODUCTION_ACCESS=NONE`, `ROOT_CAUSE`, reasoned next-step proposal, confidentiality audit, `Documentation reconciliation`, Git/security checks and CI status at report writing time. Do not publish raw paths, filenames beyond `1Cv8.1CD`, original sizes, hashes or identifying details. Do not put the future SHA of the commit containing the report in that report.
2. Compare actual findings with `README.md`, `ARCHITECTURE.md`, `REQUIREMENTS.md`, `SECURITY.md`, `DEVELOPMENT_WORKFLOW.md`, `TEST_ENVIRONMENT_SAFETY.md`, `IMPLEMENTATION_STATUS.md`, `CHANGELOG.md` and other relevant canonical docs. Update **affected allowed** docs. The report must contain a `Documentation reconciliation` matrix (reviewed, modified/no, why, evidence, contradiction/resolution). Truthfully distinguish documentation-task completion from backup success.
3. Check UTF-8 and relative links, full staged diff, allowed filename list, `git diff --cached --check`. Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` immediately before commit. Verify configured hooks. Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` for the **actual** outgoing refs immediately before normal fast-forward push. No `git add .`, `--force`, `--no-verify`, bypasses or user-file deletion. Stop if a gate fails.
4. Commit/push **only sanitized text** and exact allowlisted paths to `origin/main`; confirm remote HEAD, public report and commit-specific GitHub Actions conclusion. Mark CI `PASS` **only** for a completed successful workflow on that exact remote SHA, else `FAIL`, `PENDING` or `UNVERIFIED`. A blocked diagnostic may still publish a truthful blocked report if the publication gates pass.
5. No Task 010 until **independent ChatGPT audit**.

## 7. Acceptance / stop conditions

- `AGENTS.md` read first; task read second; expected Git SHA/branch/remote verified.
- **No actual copy, restore, cleanup, repair or 1C launch.** No read of TEST or partial backup **file contents**. No production contact whatsoever.
- Only exact source and exact 008 target metadata inspected; other siblings not enumerated. Reparse safety enforced.
- Reports describe only supported, sanitized **category-level** evidence. Root cause may remain `UNDETERMINED`; do not make one up.
- No claim that current metadata match proves file-level success or application recovery.
- Documentation and report reconciled, security/CI checks verified. `STATUS=SUCCESS` may mean **diagnostic was completed**, not that backup succeeded.
- Any unrecognized path, boundary/permission problem, privacy risk, unintended changes or required action beyond the task => immediate `BLOCKED`, no workaround.

## 8. Required concise final response

```text
TASK=009_DIAGNOSE_TEST_BACKUP_FAILURE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=39b26d7bace2aa3e5a77817d1f11334116620087
AGENTS_FIRST_READ=PASS/FAIL
TEST_METADATA_BOUNDARY=PASS/FAIL/UNVERIFIED
BACKUP_008=ABSENT/PRESENT/UNVERIFIED
RESTORE_008=ABSENT/PRESENT/UNVERIFIED
BACKUP_008_METADATA_PARITY=MATCH/MISMATCH/NOT_APPLICABLE/UNVERIFIED
SPACE_NOW=SUFFICIENT/INSUFFICIENT/UNVERIFIED
ROOT_CAUSE=UNDETERMINED/EVIDENCED_<category>
SOURCE_INTEGRITY_AFTER_008=UNVERIFIED
FILE_LEVEL_BACKUP=UNVERIFIED
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
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**Stop after this task. Do not retry the file-copy operation, delete partial copies or begin the `.epf` stage.**
