# TASK 011 — OFFLINE_TEST_BACKUP_RESTORE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority and checked baseline

- Repository: `elvinazubairovna/1c-elsi-invoice-upd-automation` (**PUBLIC**).
- Task ID: `011_OFFLINE_TEST_BACKUP_RESTORE`.
- Expected branch: `main`.
- Expected local and freshly checked remote `main` HEAD: `eef99667726ec8119bd44a974ef5025d949dd45c`, independently confirmed by ChatGPT after Task 010.
- Architect, technical decision-maker and auditor: ChatGPT. Executor: Codex. Owner: user.
- Owner has delegated routine technical choices to the architect. This task is specific authorization for one strictly bounded TEST-only filesystem backup and verification; it is **not** authorization to access production or run 1C.

## 2. Reason for Task 011 and narrowly approved architectural decision

Task 010 passed its exact TEST filesystem, initial idle, metadata, target absence and capacity checks, but stopped before copying solely because the status of 1C integrations/exchanges was `UNVERIFIED`. This gate was overbroad for an **offline, local, filesystem-only copy of a closed TEST base**. For this task, the architect explicitly approves this **narrow distinction**:

1. **Offline filesystem-only backup and verification:** an unknown general 1C integration/EDI/notification configuration, by itself, is **not a blocker**, because this task must not run 1C, call an API, open a 1C session, use network/cloud transfer, execute background jobs or send a message. Safeguards are the fixed TEST-only path, proven local non-cloud storage, exclusive read-only idle check before copying, read-only original, fresh targets, sufficient capacity, source baseline/final integrity comparison, and an immediate stop upon *positive evidence* of an active connection, background source modification, unexpected lock, reparse point or any outbound activity. Do **not** inspect 1C settings, processes or production to manufacture such proof. Do **not** claim that any integrations are disabled.
2. **Application-level 1C operations (all future tasks):** before launching an `.epf`, using TEST through 1C, creating documents, running any exchange or allowing automatic access, the state and isolation of outbound integrations and potential real recipients **must** be assessed separately. Nothing in Task 011 approves or waives those conditions.
3. This is a **scope-specific clarification**, not a general weakening of safety policy. Amend only the affected language in `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` to explicitly state the distinction and preserve the existing protective stop conditions for 1C application-level actions.
4. The unexpected counterparty records in the clean TEST template remain of unknown provenance. Do not inspect them or include their contents in any public output. Treat the entire TEST copy as potentially confidential and retain it **locally only**, outside Git and cloud sync.

If any other safety gate fails, stop without retrying, overriding or silently relaxing it. The prior Task 008 failure cause is still unknown, so phase-specific error reporting is required.

## 3. Absolute prohibitions and exact operating boundary

**PRODUCTION is off-limits in every form.** Never locate, enumerate, open, read, inspect, compare, copy, back up, modify or launch the working ELSI information base, its directory, service, process, launcher entry or settings. Never use it as a fallback. Do not inspect general 1C processes, registry, profiles, screenshots or log files that could expose production details. Do not change privileges or Windows/1C configuration, launch 1C, terminate programs, export files or use VSS/live-copy alternatives.

TEST-only paths must be constructed from the **Windows system-drive root** and these **fixed relative names only**:

- dedicated parent: `1C_TEST`;
- original source: `ELSI_TEST`;
- **new** backup destination: `_BACKUP_011`;
- **new** restoration-verification destination: `_RESTORE_CHECK_011`.

No arbitrary paths, environment overrides, wildcards beyond the exact source, alternative search, reparse-following, sibling enumeration or different target names. Do not access earlier Task 007/008/010 backup targets, whether present or absent. Do not print or commit absolute paths.

**GitHub may contain only the allowlisted sanitized text files**. No 1C database (`1Cv8.1CD`), `.dt`, `.cf`, `.cfe`, `.epf`, backup, copied template, local script, confidential documents, real identifiers, screenshot, license information, username, path, raw exception, detailed inventory, numeric file sizes or hashes may be staged, logged or uploaded. Backup/restore remain **only on the local TEST drive outside the repository**.

## 4. Before operating: AGENTS-first, Git and local safety preflight

1. Completely read `AGENTS.md` first and this exact task second. Next read full Tasks/Reports 007–010, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, related assessment documents and `README.md`.
2. Check the current Git branch, local HEAD, origin URL and **fresh** remote `main` match the expected repo and SHA. Preserve unrelated tracked/untracked changes, especially the previously reported unrelated Task 001. Do not pull/reset/rebase/merge or rewrite history. Uncertainty -> `BLOCKED`.
3. Confirm Windows and PowerShell 7 using normal shell facts. No installation, elevation, process scan or permission modification. If not on the intended Windows host, stop.
4. Construct the exact TEST paths using the fixed components. Confirm their canonical location, correct local system volume, ordinary directories, no reparse points/junctions/symlinks in path ancestry, source not in Git or known sync folder and no escape outside dedicated parent. Do not enumerate other siblings. If unable to rule out cloud-sync, stop. Do not compare or inspect production.
5. Strictly within original `ELSI_TEST`, verify that the expected `1Cv8.1CD` is a single regular, nonempty file at the proper level; only ordinary safe files/dirs exist, no reparse/special entries. Take two stable in-memory metadata inventories, with no output of names, values or contents.
6. Confirm TEST idle by **one** short exclusive **read-only** handle open on the exact standard database file, then close it. If not provable, stop `TEST_SESSION_NOT_CONFIRMED_CLOSED` without process investigation, retries or forced termination. The owner should have exited TEST normally before submitting the task.
7. Confirm `_BACKUP_011` and `_RESTORE_CHECK_011` are **absent** by exact item lookup. Do not overwrite or delete any existing item, including an empty directory, and do not silently choose alternatives.
8. Verify local free capacity for **two full copies plus a reserve at least the greater of 1 GiB or 15% of the volume size after copying**, using only TEST source metadata. If not provable, stop.
9. If there is **positive evidence** of active TEST modification, actual unsafe outgoing transfer, a conflicting lock, unexpected unsafe filesystem entry, or unbounded scope, stop before copying. The mere `UNVERIFIED` state of application integrations, in the absence of such evidence, **does not block this strictly offline task**. Do not inspect unknown integration configuration; retain `INTEGRATIONS=UNVERIFIED` in docs and report.
10. Before any write, reconcile the scope-specific offline clarification with `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` in working memory/planned diff. No need to publish prematurely; change the canonical text within the permitted allowlist by the end of the task, preserving the prohibition for future application-level testing.

## 5. Exactly one instrumented, non-destructive, local attempt

Use built-in Windows/PowerShell 7/.NET APIs only. No external modules or executable tools from the TEST tree. You may use a transient in-memory script, but **do not persist implementation scripts or sensitive outputs in Git or filesystem logs**. Separate phase-level exception boundaries; do not swallow failures into a generic result. Do not print raw exceptions, stack traces, paths, raw filenames, file contents, hashes, sizes or private metadata.

Run each phase **at most once**, in this order:

- `P0_PREFLIGHT`: all section 4 gates passed; integrations recorded as `UNVERIFIED` but accepted only under the narrow **offline-only** exception above.
- `P1_SOURCE_BASELINE`: build an in-memory relative file inventory and calculate per-file SHA-256 digests of original TEST only. Keep keys/digests private in memory; no logging. Stop before creating destinations if any read fails.
- `P2_CREATE_BACKUP_DIR`: create exactly `_BACKUP_011` (must have been absent), with no overwrites.
- `P3_COPY_SOURCE_TO_BACKUP`: copy the complete regular TEST directory tree non-destructively into the new backup directory. Never follow a link, never modify original TEST, and prevent overwriting.
- `P4_VERIFY_BACKUP`: verify all relative entries, counts, lengths and per-file SHA-256 agree with source baseline. If not exactly equal, stop; no restore attempt.
- `P5_CREATE_RESTORE_DIR`: create exactly new `_RESTORE_CHECK_011` only after P4 passes.
- `P6_COPY_BACKUP_TO_RESTORE`: independently copy from backup into new restore directory with no overwrite.
- `P7_VERIFY_RESTORE`: compare original, backup and restore structure, lengths and per-file digests; require exact parity.
- `P8_SOURCE_FINAL`: recompute source inventory and digests against P1 and repeat one short exclusive read-only idle check on the exact original database. `PASS` only if source demonstrably unchanged within the operation.

Classify exception at the **exact failed phase** using a safe, supported category only: `ACCESS_DENIED`, `SHARING_OR_LOCK`, `PATH_OR_TARGET`, `CAPACITY`, `UNSUPPORTED_ENTRY`, `SOURCE_CHANGED`, `PARITY_MISMATCH`, `RESOURCE_LIMIT`, `OTHER_IO`, `UNCLASSIFIED`. Derive from structured exception type/code when safe; do not parse secret-bearing raw messages or guess. Report only `LAST_COMPLETED_PHASE`, `FAILED_PHASE`, `FAILURE_CATEGORY`, and `BACKUP_011` / `RESTORE_011` state as `CREATED`, `NOT_CREATED` or `UNVERIFIED` if established safely within this run.

After **any** failure stop immediately; never retry a phase, clean up or remove partially created copies, change ACLs, adjust settings, change destination names or access production. Record only sanitized statuses in task report. Do not declare file-level success unless P0–P8 all pass. Do not call a successful file copy an **application-level** restore: the copied database is not launched or registered in 1C in this task.

If a credible integrity or active-write risk becomes apparent during the run, stop at once and mark source final status `UNVERIFIED`/`FAIL` as justified. File-copy parity does not prove the base contains only synthetic data or that future network integrations are safe.

## 6. Exact allowed Git changes

Only these paths may be added/modified:

1. `DEV/tasks/011_OFFLINE_TEST_BACKUP_RESTORE.md` — include the owner's copy **verbatim**.
2. `DEV/reports/011_OFFLINE_TEST_BACKUP_RESTORE.md` — sanitized factual report.
3. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — **required**: add narrow distinction between local offline file copying vs future 1C application/automated integrations; record exact outcomes and remaining risks.
4. `DEV/docs/IMPLEMENTATION_STATUS.md` — update evidence and verified/unverified statuses, preserve product `NOT_IMPLEMENTED` and architecture `NOT_APPROVED`.
5. `DEV/docs/CHANGELOG.md` — add factual Task 011 record, even on a blocked preflight, without claiming backup success.
6. `README.md` — **only if** an existing statement would otherwise become inaccurate.

Read and reconcile, but **do not modify** without separate authorization: `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TASK_TEMPLATE.md`, `AGENTS.md`, prior tasks/reports, tooling, hooks, workflows and `.gitignore`. If a task-related contradiction actually requires changing a non-allowlisted file, stop `BLOCKED`, report the conflict; no unilateral scope expansion.

## 7. Mandatory verification, documentation reconciliation and publication

1. Review `README.md`, architecture, requirements, security, workflow, task template, prior assessments and reports. Ensure the changed TEST safety document explains **why unknown integration configuration does not block only offline local file copying**, while explicitly preserving `UNVERIFIED` status and gates for **all application-level or outbound trials**.
2. Update `DEV/docs/CHANGELOG.md` and `DEV/docs/IMPLEMENTATION_STATUS.md` based solely on actual results. Do not imply 1C/application restoration, configured integrations, validated permissions, or working invoice/UPD automation.
3. Before commit create `DEV/reports/011_OFFLINE_TEST_BACKUP_RESTORE.md` including: Status; AGENTS-first; Git base; exact safety boundary (without absolute paths); architect-authorized offline-only distinction; preflight statuses; P0–P8 marker results; safe failure category if any; backup and restore statuses; source final integrity; untouched production statement; confidentiality; **Documentation reconciliation** matrix (reviewed/changed/reason/evidence/discrepancy for each canonical doc); changed files; Index/Outgoing/hooks/CI; Git publication; blockers; next action. Do not invent your own future commit SHA.
4. Confirm the exact staged file allowlist, examine the **entire staged diff**, check UTF-8 and relative Markdown links, `git diff --cached --check`, and scan manually for all private material. Never stage copies or executables.
5. Immediately before each `git commit`, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`. Verify `core.hooksPath=DEV/hooks`; do not bypass hooks. Before push, manually run the same tool `-Mode Outgoing` with the **actual** refs being sent; let pre-push hook run. Run security tests only if required by established `AGENTS.md` for changes (security tooling changes are forbidden here). No `--force`, `--no-verify`, destructive Git commands or implicit `git add .`.
6. Ordinary fast-forward push to `origin/main`; independently verify remote SHA and public files. Report `CI=PASS` only for a completed successful workflow of that exact final SHA; otherwise `PENDING`, `UNVERIFIED` or `FAIL`. Task `SUCCESS` requires genuinely completed file-level backup+restore+source checks **and** documentation/publication success. On a safe stop report `BLOCKED`, even if Git publication passes.
7. No next task, `.epf` execution, Configurator operation, restored-base registration, cleanup or permission change. Stop for ChatGPT's independent audit.

## 8. Final concise response to owner

```text
TASK=011_OFFLINE_TEST_BACKUP_RESTORE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=eef99667726ec8119bd44a974ef5025d949dd45c
AGENTS_FIRST_READ=PASS/FAIL
TEST_BOUNDARY=PASS/FAIL/UNVERIFIED
TEST_IDLE_CHECK=PASS/FAIL/UNVERIFIED
INTEGRATIONS=UNVERIFIED
OFFLINE_ONLY_EXCEPTION=APPLIED/NOT_APPLICABLE
PREFLIGHT=PASS/FAIL/UNVERIFIED
LAST_COMPLETED_PHASE=P0_PREFLIGHT/P1_SOURCE_BASELINE/P2_CREATE_BACKUP_DIR/P3_COPY_SOURCE_TO_BACKUP/P4_VERIFY_BACKUP/P5_CREATE_RESTORE_DIR/P6_COPY_BACKUP_TO_RESTORE/P7_VERIFY_RESTORE/P8_SOURCE_FINAL/NONE
FAILED_PHASE=P0_PREFLIGHT/P1_SOURCE_BASELINE/P2_CREATE_BACKUP_DIR/P3_COPY_SOURCE_TO_BACKUP/P4_VERIFY_BACKUP/P5_CREATE_RESTORE_DIR/P6_COPY_BACKUP_TO_RESTORE/P7_VERIFY_RESTORE/P8_SOURCE_FINAL/NONE
FAILURE_CATEGORY=NONE/ACCESS_DENIED/SHARING_OR_LOCK/PATH_OR_TARGET/CAPACITY/UNSUPPORTED_ENTRY/SOURCE_CHANGED/PARITY_MISMATCH/RESOURCE_LIMIT/OTHER_IO/UNCLASSIFIED
BACKUP_011=CREATED/NOT_CREATED/UNVERIFIED
RESTORE_011=CREATED/NOT_CREATED/UNVERIFIED
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
BLOCKERS=NONE/<safe blocker>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

## 9. Non-negotiable stopping conditions

Stop without retry/cleanup for a wrong Git baseline, unsafe/unproven exact TEST boundary, active/unknown TEST file lock, positive evidence of actual TEST source writes or unsafe outbound operations, special/reparse source entry, missing capacity, an existing Task 011 destination, inability to preserve original read-only, unclassified runtime exception, any risk of touching production, any risk of placing DB bytes in Git/cloud sync, publication-security failure or unresolved required documentation changes outside allowlist. **Do not stop solely because general 1C integration settings are unknown for this strictly offline, local file-copy operation.** Keep them `UNVERIFIED` for later 1C application-level tests.
