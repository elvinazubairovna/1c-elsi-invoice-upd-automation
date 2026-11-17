# TASK 016 — PREPARE_DISPOSABLE_APP_CLONE_TOOL

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline and goal

- Repository (PUBLIC): `elvinazubairovna/1c-elsi-invoice-upd-automation`, branch `main`.
- Exact expected local `HEAD` **and** freshly checked remote `origin/main`: `99204f657bbe484fdc9fc55beeb634aae90b67af` (independently audited by ChatGPT after Task 015). If either differs, STOP; no pull, reset, rebase, merge or forced push.
- Architect/independent auditor: ChatGPT; constrained executor: Codex; operator: project owner.
- Prior accepted results: Task 014's operator-run tool reported `FILE_LEVEL_BACKUP=PASS`, `FILE_LEVEL_RESTORE=PASS`, `SOURCE_FINAL=PASS`, `STATUS=SUCCESS`; Task 015 documented this as **OWNER_REPORTED_PASS**, not independent Codex inspection. Application restore is **NOT_ATTEMPTED**; outbound integrations and data purity are **UNVERIFIED**.
- **Goal of Task 016:** write, statically validate, synthetically test, document and publish a **future operator-run, offline, non-overwriting PowerShell 7 tool** that will make exactly one separate **disposable staging clone** from the existing verified restore-copy, with file parity checks. **Do NOT run this tool on any real TEST folders in Task 016.** The owner may execute it only **after ChatGPT independently audits the script** and gives a separate explicit command.
- This task is **not** authorization to open 1C, register the clone, change Windows/VM networking, create `.epf`/`.cfe`, or test invoice/UPD workflows.

## 2. Why a disposable clone is necessary

The owner-reported `_BACKUP_014` and `_RESTORE_CHECK_014` are preservation/evidence copies; opening a file-based 1C database can write to it even without deliberate user edits. Thus a third **new** working clone is needed for future application testing. Do not risk or modify the protected originals. A separate future task will establish verifiable **application outbound isolation** and decide where/how to open a working clone (e.g. within an actually isolated VM); no VM assumptions or host-wide firewall changes in this task.

## 3. Absolute boundaries

1. **PRODUCTION is entirely out of scope.** Never discover, enumerate, open, read, inspect, compare, back up, copy, launch or modify the real ELSI database, its path, launcher entry, credentials, settings, processes or files. No production fallback, cross-base comparison or search.
2. **No actual TEST access by Codex in Task 016:** do not read metadata, enumerate, hash, copy, create folders, run the entry point or invoke the new script against `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_DIR_PROBE_013` or any other `1C_TEST` path. All runtime tests MUST use **only synthetic fixtures inside a bounded Git-workspace-local temporary test directory**.
3. Future operator tool fixed input path components: Windows **system fixed local drive** root + `1C_TEST` + `_RESTORE_CHECK_014`. Fixed output: the same `1C_TEST` parent + **`_APP_SMOKE_016`**. Source and output are not configurable. Allow no arbitrary path, current-working-directory derivation, recursive parent scan, drive search, user-supplied override or fallback. The checked-in code may contain the neutral literal segments; **do not publish real absolute paths**.
4. The existing `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_DIR_PROBE_013`, older probe/backup folders, production, and unrelated Git files must remain intact and unmodified. No delete, rename, cleanup, overwrite, ACL/ownership/registry/network changes, elevation or service/process controls.
5. **PUBLIC GITHUB:** never publish any backup or restored files, database bytes, local absolute paths, real data, company details, usernames, hashes/inventories, sizes, customer identities, licensing data, exception messages, screenshots, logs, or credentials. Check in only the **generic script source**, documents and synthetic tests permitted below. Script runtime output must contain only fixed status tokens and safe generic category codes; don't echo file paths, names, counts, metadata, digests or exception strings.
6. No invocation of 1C, Configurator, launcher, external API, EDI, email, sync, network or automatic delivery. Future clone may contain unknown data; do not claim it is fully synthetic. Isolation remains `UNVERIFIED` until separately established.

## 4. Mandatory admission and reading

1. Fully read root `AGENTS.md` **first**, this entire task **second**. Then inspect `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, Task/Report 015, Task/Report 014, `DEV/tools/Invoke-ELSI-TestBackupDrill.ps1` (read-only reference), `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/TASK_TEMPLATE.md`, `README.md`, and any directly relevant past reports.
2. Verify origin URL, branch `main`, local HEAD and fresh remote HEAD match expected SHA; worktree has no unexpected tracked modifications. Preserve the unrelated historical untracked Task 001 and all other user files. STOP if Git admission fails; do not change branch/history.
3. Confirm PowerShell 7 available for **static-only and synthetic-only** tests. Do not install or elevate software and do not change Codex sandbox permissions.

## 5. Implement one operator-only script

Create `DEV/tools/New-ELSI-DisposableAppClone.ps1` as a self-contained PowerShell 7 script with the **only** opt-in write switch `-RunClone`.

**Default invocation (without switch):** emit fixed `USAGE=...`, `STATUS=READY_FOR_AUDIT` and exit. No filesystem lookup except script self-location if essential, no TEST file interaction, no writes, no network.

**Future `-RunClone` invocation — design only, NOT run here:**

### P0 — fail-closed preflight

- Windows PowerShell 7, standard Windows `SystemDrive` local fixed ready filesystem; construct fixed literal parent/source/target only; canonicalize with `GetFullPath` and ensure exact containment. No `Resolve-Path` or fallback searches.
- Metadata-only inspect **exact** system-root, `1C_TEST` parent and `_RESTORE_CHECK_014` source identities. Require ordinary directories, reject reparse points/junctions/symlinks (including recursive source entries later), cloud-synced or Git tree containment, inaccessible/ambiguous results, or unusual filesystem entries. Never inspect production. No parent sibling enumeration.
- Require `_APP_SMOKE_016` strictly **ABSENT** by exact, non-recursive metadata check before any creation; if present/inaccessible/ambiguous, stop, never write into it. Do not read unrelated prior targets. Do not operate on `_BACKUP_014` or `ELSI_TEST`.
- Require a **single ordinary nonempty** top-level `1Cv8.1CD` under source; reject unsupported file/link types, named streams and unexpected path escapes when safely detectable; do not parse 1C contents. Snapshot source tree's ordinary metadata twice and verify unchanged. Use source open/share checks suitable for offline copied data; never assume source safe if unstable. Require free space for another full copy PLUS a conservative reserve (at least 1 GiB or 15% of volume, whichever greater). Fail closed on arithmetic overflow/unknown values.

### P1 — source baseline

- Stream SHA-256 for source regular files and construct in-memory relative-path/size/type inventories; include empty directories in parity. Do not print or persist filenames, sizes, digest values or inventory. Stop if source metadata changes during reading. Reject any reparse/junction or path escape on traversal and again before opening files.

### P2–P3 — non-overwriting clone

- Reconfirm target is absent and exact parent/source identity immediately before the only top-level folder creation. Create **only** `_APP_SMOKE_016` and its children (if source contains ordinary nested directories) with non-overwrite behavior. If race, partial failure, or preexisting destination: stop; **never delete, retry, rename, overwrite, merge or clean up**. For files use `FileMode.CreateNew` (or equivalent proven no-overwrite atomic mode); source files read-only and streams disposed reliably; flush destination streams and preserve timestamps where practical. Refuse links and unsupported entries rather than following them.

### P4–P5 — verify and finalize

- Independently compute inventory+SHA-256 over the clone; compare to source in-memory baseline (relative paths, regular file bytes/digests, lengths, and directories). Re-read/verify source baseline and stable metadata at end so it was not changed during copy. Report `CLONE_016=PASS` **only** after both parity and source-final checks succeed. Never modify any source file.
- In any error, report sanitized exact phase, last completed phase, `ERROR_CATEGORY` (allowlisted .NET type/HRESULT interpretation or controlled category; otherwise `UNCLASSIFIED`), `CLONE_016=ABSENT/CREATED_UNVERIFIED/PREEXISTING_UNTOUCHED/UNVERIFIED`, `SOURCE_FINAL=PASS/UNVERIFIED`, `STATUS=FAIL`. On success report `CLONE_016=PASS`, `FILE_LEVEL_CLONE_PARITY=PASS`, `SOURCE_FINAL=PASS`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `PRODUCTION_ACCESS=NONE`, `STATUS=SUCCESS`.
- Catch exceptions without printing unsafe `Exception.Message`, stack, paths, environment/user information or type names containing private text. Do not write logs or external files beyond the clone target. No `Write-Verbose` of sensitive values.
- Critically: status `CLONE_016=PASS` is only **file-level staging proof**. It is NOT evidence that 1C opens, VM network isolation works, integrations are disabled, TEST data is synthetic, or `.epf` can be executed.

## 6. Tests allowed during this task (NO TEST access)

- PowerShell AST parse; verify `-RunClone` is the only opt-in path; identify **all** filesystem write APIs and forbidden operations; inspect for path escape, reparse, races, no-overwrite, sanitized outputs and error paths.
- Synthetic-only tests inside a workspace-local fixture (known invented names and bytes): success with ordinary files and nested/empty directories; byte-level parity; altered source before/after; hash mismatch; source file missing/empty; preexisting target remains unchanged; link/reparse rejection; read/write permission failure classifier; non-Windows/unsupported entry handling where feasible using mock metadata; target never deleted/overwritten.
- Do not run script entry point in any mode against real TEST in Task 016. Prefer extracting pure functions for synthetic tests to avoid any accidental system-path reads. Keep only approved, non-sensitive test SOURCE (if any) in Git; never commit generated fixture outputs.
- If any security-critical behavior cannot be verified synthetically or by static review, record `STATIC_CHECK=UNVERIFIED` or `SYNTHETIC_TEST=PARTIAL`, **not** `PASS`; do not declare tool ready for operator.

## 7. Exact tracked Git allowlist

1. `DEV/tasks/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md` — task file verbatim.
2. `DEV/tools/New-ELSI-DisposableAppClone.ps1` — new operator-only script SOURCE.
3. `DEV/reports/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md` — factual audit-ready report.
4. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — clarify that clone preparation is staged separately, not an application launch.
5. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — describe coded/unrun tool and unverified isolation.
6. `DEV/docs/IMPLEMENTATION_STATUS.md` — code/static/synthetic vs actual runtime statuses; app restore remains not attempted.
7. `DEV/docs/CHANGELOG.md` — factual Task 016 record.
8. `README.md` — only if necessary to correct a now-wrong status or add canonical link.

All other tracked paths **read-only**, including existing `DEV/tools/Invoke-ELSI-TestBackupDrill.ps1`, scripts, security checks, hooks, CI workflows, prior tasks/reports, `AGENTS.md`, `.gitignore`, 1C files. Do not include any binary data or generated fixtures in Git. Do not stage unrelated untracked Task 001.

## 8. Documentation, publication and report

1. Compare script and test evidence to canonical docs. Perform mandatory documentation reconciliation (README, architecture, requirements, security, workflow, Task Template, safety, status, plan and changelog); update all affected **allowed** docs in same task; record a factual changelog. Report a matrix (reviewed / changed / reason / evidence / discrepancy). Preserve `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `DATA_PURITY=UNVERIFIED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`, and `OPERATOR_CLONE_RUN=NOT_ATTEMPTED`.
2. In report: exact baseline & AGENTS-first, threat boundaries, allowed paths, code/test scope, synthetic cases/results, lack of TEST execution, no production access, publication/privacy checks, docs matrix, CI/remote checks and explicit next step. Report must be written before final commit (no impossible self-SHA).
3. Check `git diff --check`, staged exact allowlist, full staged diff, UTF-8 and relative links, no secrets/data/private paths. Immediately before commit manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`; use `core.hooksPath=DEV/hooks`, no hook bypass. Before normal push manually run `-Mode Outgoing` with actual ref update and normal pre-push hook. No force, `--no-verify`, reset/rebase/history rewriting.
4. Push only approved sanitized source/docs through normal fast-forward commit/push. Verify remote `main`, report, task/script and commit-specific GitHub Actions final SHA; only label CI `PASS` for a **completed successful** run, else `PENDING`/`UNVERIFIED`/`FAIL`. If checks fail, STOP, retain local state, report accurately.
5. Do not run the owner clone tool, do not register or launch 1C, do not create a VM or change network settings, and do not begin Task 017. Await independent ChatGPT audit.

## 9. Required final response

```text
TASK=016_PREPARE_DISPOSABLE_APP_CLONE_TOOL
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=99204f657bbe484fdc9fc55beeb634aae90b67af
AGENTS_FIRST_READ=PASS/FAIL
OPERATOR_FILE_BACKUP=OWNER_REPORTED_PASS
OPERATOR_RESTORE_COPY_PARITY=OWNER_REPORTED_PASS
CLONE_TOOL=CREATED/NOT_CREATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_TEST=PASS/PARTIAL/FAIL/UNVERIFIED
CODEX_TEST_ACCESS=NONE
CODEX_CLONE_RUN=NOT_ATTEMPTED
OPERATOR_CLONE_RUN=NOT_ATTEMPTED
APPLICATION_RESTORE=NOT_ATTEMPTED
OUTBOUND_ISOLATION=UNVERIFIED
PRODUCTION_ACCESS=NONE
DOCS_SYNC=PASS/FAIL
INDEX_CHECK=PASS/FAIL
OUTGOING_CHECK=PASS/FAIL
HOOKS=PASS/FAIL
CI=PASS/FAIL/PENDING/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=NONE/<safe reason>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**Safety stop:** if a required gate cannot be satisfied, stop without widening permissions or touching TEST or PRODUCTION. This task only prepares code for a future operator action after independent audit.
