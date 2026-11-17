# TASK 015 — RECORD_BACKUP_AND_PLAN_APP_RESTORE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline, and objective

- **Repository:** `elvinazubairovna/1c-elsi-invoice-upd-automation` (PUBLIC); expected branch `main`.
- **Task:** `015_RECORD_BACKUP_AND_PLAN_APP_RESTORE`.
- **Expected local HEAD and freshly checked remote `main`:** `1ad6a6f5a25996375b53bbb21a7f2319a794be18`. If Git differs, stop; no pull/reset/rebase/merge.
- **Architect and auditor:** ChatGPT. **Executor:** Codex. **Owner:** user operating their Windows machine.
- **Goal:** (A) truthfully reconcile the owner's newly reported SUCCESS of the Task 014 operator-run file backup/restore-copy parity drill; (B) prepare a safe, non-executing operator runbook and safety admission criteria for a *future* application-level recovery smoke test in 1C on the verified restore copy. This task is **documentation and planning only**. No 1C application, file copy, folder creation, database access, backup run, or application restore is authorized in Task 015.

### Exact new evidence from owner (record with provenance)

Following ChatGPT's independent audit of Task 014, the owner manually ran the reviewed script `DEV/tools/Invoke-ELSI-TestBackupDrill.ps1` from an ordinary non-elevated Windows PowerShell 7.7.0 session with `-RunDrill`. The owner shared its on-screen completion result:

```text
DRILL_PHASE=P8_SOURCE_FINAL
LAST_COMPLETED_PHASE=P8_SOURCE_FINAL
FAILED_PHASE=NONE
ERROR_CATEGORY=NONE
TEST_BOUNDARY=PASS
TEST_IDLE_CHECK=PASS
BACKUP_014=PASS
RESTORE_014=PASS
FILE_LEVEL_BACKUP=PASS
FILE_LEVEL_RESTORE=PASS
SOURCE_FINAL=PASS
APPLICATION_RESTORE=NOT_ATTEMPTED
INTEGRATIONS=UNVERIFIED
PRODUCTION_ACCESS=NONE
OPERATOR_RUN=ATTEMPTED
STATUS=SUCCESS
```

The program's reported checks cover two **local** folders `_BACKUP_014` and `_RESTORE_CHECK_014` containing a source-to-backup-to-restored-copy tree and in-memory SHA-256/file inventory parity, and preservation of source within that run. This is `OWNER_REPORTED_PASS`/`OWNER_PROVIDED_TOOL_OUTPUT`: **Codex did not independently inspect the TEST filesystem or source database**, and a screenshot/console result is not a laboratory-independent remeasurement. It is nevertheless strong operator-run evidence, appropriately labeled. No actual 1C application-level opening/recovery test occurred; it must remain `NOT_ATTEMPTED`, not `PASS`. Unknown integrations and unknown pre-existing entries remain `UNVERIFIED`. GitHub CI PASS of Task 014 validates repo checks, not a 1C file recovery.

Do **not** publish or reproduce the user's unredacted screenshots, Windows account names, actual paths, database file hashes, size/contents, financial data, or any other private information. Only the generic status fields above and the generic fixed folder names are permitted.

## 2. Mandatory reading and Git admission

1. Fully read `AGENTS.md` **FIRST**, this entire exact task **SECOND**. Then read `DEV/tasks/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md`, `DEV/reports/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md`, `DEV/tools/Invoke-ELSI-TestBackupDrill.ps1`, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, relevant prior reports, and `README.md`.
2. After reading, verify exact repository origin/branch, local HEAD, fresh remote `main` and tracked working tree against the given SHA. Preserve unrelated tracked/untracked files, especially the previously observed untracked Task 001. If any mismatch, blocked publication or missing expected file: stop and report a factual blocker without destructive Git operations.
3. Confirm from the published source that the reported fields are supported by the script's successful P8 completion path. Do not infer or fabricate telemetry that the owner did not supply. No local TEST access is permitted to validate the owner's report.

## 3. Absolute operational boundaries

- **PRODUCTION:** no searching, opening, enumeration, inspection, comparison, copying, launch, ACL changes, settings, process inspection or any access. No fallback to production. Avoid invoking a 1C launcher or listing known bases, which could reveal production information.
- **TEST:** do not touch, list, read or change `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_DIR_PROBE_013` or any prior/other TEST paths. **No execution** of the backup script, 1C, Configurator, APIs, test applications or scripts against these folders. Do not create/deploy `.epf`/`.cfe` or change applications. No network/EDI/email actions.
- **Confidentiality:** public GitHub contains only sanitized Markdown documents and the supplied task; no private Windows paths, usernames, screenshots, raw exception output, 1C licenses, credentials, counterparties, real documents, source byte hashes/inventories, database backups, real filenames, precise database sizes or other private material.
- **No state mutation:** Task 015 is entirely documentation-only within the repository. The two operator-created copies must remain intact and unmodified. A later application smoke test may itself cause writes to a *designated disposable working copy*, so that will need separate operator authorization and an explicit preserve/rollback strategy.

## 4. Deliverables and planning decisions

### 4A. Reconcile the observed operator run honestly

Update `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, and `DEV/docs/CHANGELOG.md` with a separate **post-Task-014 operator result** (do not retroactively overwrite historical Task 014 pre-run statements or rewrite the Task 014 report).

- State `FILE_LEVEL_BACKUP=OWNER_REPORTED_PASS` and `FILE_LEVEL_RESTORE_COPY_PARITY=OWNER_REPORTED_PASS` for `_BACKUP_014` and `_RESTORE_CHECK_014` respectively, based on the owner's manually shared output from the reviewed script.
- State `SOURCE_FINAL=OWNER_REPORTED_PASS` *within this operator run*; don't generalize to any later date.
- Keep `APPLICATION_RESTORE=NOT_ATTEMPTED`, `TEST_APP_READINESS=UNVERIFIED`, `OUTBOUND_INTEGRATIONS=UNVERIFIED`, `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`.
- Distinguish this successful file-level run from the earlier unsuccessful Codex sandbox Tasks 008/011/012. Do not reinterpret or delete their historical evidence.

### 4B. Write a safe operator-oriented recovery smoke-test plan — **NOT executable in Task 015**

Create `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, in plain Russian suitable for a non-programmer, with:

1. **Purpose:** verify a copy from `_RESTORE_CHECK_014` can be registered/opened as a *separate temporary information base* in 1C and basic synthetic-data screens can be viewed without affecting `ELSI_TEST` or production. Explain that file parity and application viability are different checks.
2. **Strong preconditions and owner-visible identification:** a separate disposable working clone of the verified restore copy is preferable to opening/modifying `_RESTORE_CHECK_014` itself; preserve originals `_BACKUP_014`, `_RESTORE_CHECK_014`, `ELSI_TEST` immutable. A separate future task must authorize/prepare that clone, using only exact TEST paths and fresh safety checks. Do not choose a production directory or use launcher history to locate production. Use a conspicuously TEST-only display name for a future registration, with manual cross-check of the *exact* new local directory before launch. If identity cannot be proved, stop.
3. **Outbound safety:** application launch may run initialization/background jobs. Since integrations/EDI/email/recipients are `UNVERIFIED`, **no application launch yet**. First specify a separate, reviewable method to establish isolation or safely disable outbound communication *for the disposable TEST clone only*, without assuming integrations are off, without altering settings/services used by production or blocking a shared workstation's unrelated operations. If an appropriate isolation mechanism cannot be demonstrated, halt rather than launching 1C. An offline filesystem copy alone did not need this check; opening 1C does.
4. **Owner-guided future GUI smoke sequence** as a *proposal only*, with numbered plain-language actions: verify the exact clone identity, isolate outbound channels, add/register only the cloned base manually, launch only that TEST copy, confirm it opens and shows the expected synthetic test organization without viewing unknown counterparty records, perform no data creation/edits or outbound send, then close. Do not give a premature copy-paste command that executes any of these steps now. Do not request unredacted screenshots or copy license details.
5. **Checks/acceptance and failures:** `APP_CLONE_BOUNDARY`, `APP_OUTBOUND_ISOLATION`, `APP_OPEN`, `SYNTHETIC_ORGANIZATION_VISIBLE`, `NO_SEND`, `NO_PRODUCTION_ACCESS`; status of all as `NOT_ATTEMPTED` until evidence is provided. Fail closed on real/unknown records, wrong base identity, login/network activity or any surprising behavior. No credential sharing. Have a recovery/rollback section that preserves the verified two original copies and never deletes or overwrites any database under this task.
6. **Limitations:** a successful app launch verifies basic recoverability only, not correctness of invoice/UPD generator, broad 1C integrity, permission audits, compatibility of `.epf`/`.cfe`, or production readiness. The proposed trial must be separately audited before execution.
7. **Next-stage preview:** after app-level recovery and outbound isolation are proven, plan a *read-only, synthetic* `.epf` hello-world experiment before any creation of invoices, UPD or automation. Architecture remains not approved here; no `.epf` is built in Task 015.

Choose safe technical details within this planning scope. If necessary, consult vendor/public documentation *without using any account or production environment*. Do not convert suggestions into verified claims or assume tool availability. This is a **plan**, not permission to launch 1C or set OS firewall rules.

## 5. Strict Git allowlist

Only these tracked paths may be added or changed:

1. `DEV/tasks/015_RECORD_BACKUP_AND_PLAN_APP_RESTORE.md` — publish the user's task file **verbatim**.
2. `DEV/reports/015_RECORD_BACKUP_AND_PLAN_APP_RESTORE.md` — factual sanitized task report.
3. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — **new** plain-language, non-executing plan.
4. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — provenance-qualified operator result and future gates.
5. `DEV/docs/IMPLEMENTATION_STATUS.md` — separate evidence levels and outstanding risks.
6. `DEV/docs/CHANGELOG.md` — new factual Task 015 entry, not a revision of Task 014 history.
7. `README.md` — only if an existing claim is now materially wrong or a small canonical link is warranted.

Everything else is **read-only**, including `AGENTS.md`, prior tasks/reports, `DEV/tools/*.ps1`, hooks, security scanner, workflows, `.gitignore`, 1C files and all TEST data. Do not modify code to make this task work. If a real task-related contradiction requires editing a path outside this allowlist, stop `BLOCKED` and report it.

## 6. Validation, publication and reporting

1. Manually compare allowed edits with the complete Task 014 tool source and the exact owner-provided success markers above. Verify that the report says `OWNER_REPORTED_PASS` and that there are **no assertions of independent Codex TEST access** or application-level recovery.
2. Reconcile `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/TASK_TEMPLATE.md`, previous reports and the new recovery plan. Update **all affected allowed** docs in the same task. Include a `Documentation reconciliation` matrix (reviewed, changed, why, evidence, discrepancies) in the report.
3. Before committing, check staged exact paths, full staged diff, `git diff --cached --check`, UTF-8, Markdown relative links, and confidentiality. Do not stage unrelated Task 001 or any database material, screenshot, backup or diagnostic output. Do not use `git add .`.
4. Manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` immediately before commit; verify `core.hooksPath=DEV/hooks` and allow the hook. Before push, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` with the exact outgoing ref update, and let pre-push hook run. No bypass/force push/reset/rebase/history rewriting.
5. Commit only the allowlisted sanitized Markdown files; normal fast-forward push to `origin/main`. Confirm remote HEAD and publicly readable Task 015/report/plan. Confirm commit-specific GitHub Actions **completed successful** run before `CI=PASS`; otherwise report `PENDING`, `UNVERIFIED` or `FAIL` accurately.
6. Create the report **before** its containing commit: no impossible future self-SHA. Report status, AGENTS-first, exact Git baseline, owner-provided markers/provenance, no runtime operations, current statuses, new plan and safety limitations, documentation reconciliation, changed files, checks, security/privacy review, Git/CI, blockers, next action. No source screenshots or local absolute paths.
7. Do **not** begin Task 016. Await ChatGPT's independent GitHub audit and separate operator instructions for any future application testing.

## 7. Required final response

```text
TASK=015_RECORD_BACKUP_AND_PLAN_APP_RESTORE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=1ad6a6f5a25996375b53bbb21a7f2319a794be18
AGENTS_FIRST_READ=PASS/FAIL
OPERATOR_FILE_BACKUP=OWNER_REPORTED_PASS/UNVERIFIED
OPERATOR_RESTORE_COPY_PARITY=OWNER_REPORTED_PASS/UNVERIFIED
SOURCE_FINAL_AT_OPERATOR_RUN=OWNER_REPORTED_PASS/UNVERIFIED
APPLICATION_RESTORE=NOT_ATTEMPTED
INTEGRATIONS=UNVERIFIED
APP_RESTORE_PLAN=CREATED/NOT_CREATED
CODEX_TEST_ACCESS=NONE
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

**No production access, no TEST data modification, no 1C launch, no operator action in Task 015. This task records the verified *reported* backup evidence and designs the next safe stage; it does not perform an application recovery.**
