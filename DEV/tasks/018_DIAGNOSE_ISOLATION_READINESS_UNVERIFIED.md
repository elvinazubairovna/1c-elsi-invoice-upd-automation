# TASK 018 — DIAGNOSE_ISOLATION_READINESS_UNVERIFIED

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, verified baseline, objective

- Repository (PUBLIC): `elvinazubairovna/1c-elsi-invoice-upd-automation`; branch `main`.
- Exact expected **local HEAD and freshly checked remote** `origin/main`: `0e96ed6cd260cb7502b1de3a8e0c62b4dfa98d39` (checked by ChatGPT against GitHub after Task 017, 2026-11-17).
- Task: `018_DIAGNOSE_ISOLATION_READINESS_UNVERIFIED`.
- ChatGPT is architect/independent auditor; Codex is bounded implementation executor; user is the Windows operator.
- The owner executed Task 017's reviewed read-only `DEV/tools/Get-ELSI-IsolationReadiness.ps1` once from PowerShell 7.7.0 and supplied these **sanitized status values**, not independent Codex host evidence:

```text
OS_EDITION_CLASS=UNVERIFIED
WINDOWS_SANDBOX_FEATURE=UNVERIFIED
HYPERV_FEATURE=UNVERIFIED
VIRTUALIZATION_SUPPORT=UNVERIFIED
HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED
OUTBOUND_ISOLATION=UNVERIFIED
APPLICATION_RESTORE=NOT_ATTEMPTED
PRODUCTION_ACCESS=NONE
STATUS=UNVERIFIED
```

- **Objective:** correct an observability deficiency in the existing **read-only** capability script: it currently returns all `UNVERIFIED` with no safe indication whether its early run gate skipped the queries or each individual read failed. Make the *next* owner-run report diagnostically useful **without broadening any host/TEST/PRODUCTION access**. This is a script repair + synthetic-only validation task. **Do not run the repaired script entry point on the real Codex/owner host.**
- Do **not** infer that the user is elevated, that Windows Sandbox / Hyper-V are unavailable, that virtualization is disabled, or that any OS fault exists. The observed markers establish none of those claims.

## 2. Absolute boundaries

1. **PRODUCTION:** zero discovery or interaction — no 1C launcher enumeration, base paths, processes, programs, network, registry, files, logs, credentials, EDI/email or production services.
2. **TEST:** zero discovery or interaction — do not read/list/hash/open/alter any of `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, `_DIR_PROBE_013` or other TEST folders.
3. **Host:** no live capability queries in Task 018, even if nominally read-only. Do not open any actual registry keys, invoke `Get-CimInstance`, query Windows optional features or check Windows identity/elevation except via synthetic/mocked objects during pure-function tests. No installs, elevation, `Start-Process`, settings/feature changes, network changes, VM creation, services/process listing, OS inventory or 1C launch.
4. **PUBLIC GITHUB:** no screenshots, absolute local paths, account names, IDs, private configuration, real registry values, actual feature results, raw exceptions, hardware IDs, 1C files, database backups, hashes or raw OS fields. Code may use neutral fixed API/property names; reports show only owner-supplied sanitized values and synthetic-test statuses.
5. Preserve prior backup and clone output; do not delete, modify, overwrite, repeat a prior runtime action, or begin a future 1C app test. All application/integration isolation remains `UNVERIFIED`.

## 3. Mandatory admission

1. Read `AGENTS.md` in full **FIRST**, then this task in full **SECOND**. Then read Task/Report 017 and its entire script; the application recovery plan; `README.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/TASK_TEMPLATE.md`; Task/Report 016 as needed.
2. Verify origin, `main`, clean relevant tracked tree, exact local HEAD and fresh remote `main` against the SHA above. Preserve all unrelated files, including the historical untracked Task 001. Mismatch => `BLOCKED`; do not pull, reset, rebase, merge or force push.
3. Use PowerShell 7 only for **AST/static analysis and synthetic helper tests** inside the repository. No actual host/TEST capability or filesystem probing.

## 4. Precisely bounded implementation

Modify **only** `DEV/tools/Get-ELSI-IsolationReadiness.ps1` to add safe, fixed-category diagnostic output. Maintain existing semantics and nine existing status lines (same keys, compatible allowed values); append a small number of fixed keys that distinguish the stage which prevented trustworthy results:

- `RUN_GATE=NON_ELEVATED_PASS/ELEVATED_BLOCKED/NON_WINDOWS/IDENTITY_CHECK_FAILED/UNVERIFIED`. A failed identity/elevation check must not silently resemble missing virtualization support. Running elevated is **not permitted** as a workaround: skip remaining queries and report `ELEVATED_BLOCKED`.
- `EDITION_QUERY=PASS/NO_VALUE/ACCESS_DENIED/QUERY_ERROR/SKIPPED`.
- `SANDBOX_QUERY=PASS/API_UNAVAILABLE/ACCESS_DENIED/QUERY_ERROR/SKIPPED`.
- `HYPERV_QUERY=PASS/API_UNAVAILABLE/ACCESS_DENIED/QUERY_ERROR/SKIPPED`.
- `VIRTUALIZATION_QUERY=PASS/API_UNAVAILABLE/ACCESS_DENIED/QUERY_ERROR/SKIPPED`.
- `STATUS=READ_ONLY_REPORT/PARTIAL_REPORT/BLOCKED_BY_RUN_GATE/UNVERIFIED`. Use `READ_ONLY_REPORT` only when the run gate passed and useful normalized values were actually obtained; `PARTIAL_REPORT` when the run gate passed but some requested capability values could not be verified; `BLOCKED_BY_RUN_GATE` for a positively established gate; and `UNVERIFIED` when even gate status is unknown. Do not label all-unknown findings successful.

**Technical constraints:**

- Do not print a raw exception type, exception text, stack, raw registry value, CIM object, username, path, process/adapter/service information, or any other host-derived free text.
- A `PASS` *query label* means the specific read completed and its value was normalized, **not** that the relevant Windows feature is enabled or a VM is isolated. `API_UNAVAILABLE` requires positive evidence of missing API; unknown runtime errors become `QUERY_ERROR`. `ACCESS_DENIED` requires reliable structured exception evidence, not text matching. If classification is ambiguous choose `QUERY_ERROR` or `UNVERIFIED` instead of guessing.
- Preserve the exact narrow read allowlist already in Task 017: read-only `EditionID` at one known Windows registry key, two exact optional-feature names (`Containers-DisposableClientVM` and `Microsoft-Hyper-V-All`) and the three specified `Win32_Processor` virtualization flags. Do not broaden to installed programs, services, `Get-ComputerInfo`, broad CIM/registry enumeration or additional environment details. No new read path, external process, network call or privilege requirement.
- Fix only the error-reporting/control-flow issue. Refactor existing logic into side-effect-free, injectable classification/report-building helpers as needed so gate and query outcomes can be reliably tested **without executing host APIs**. Make all error paths fail closed and leave the nine original status lines truthful.
- Do not add a “force”, administrator, diagnostic raw dump, alternate path or skip-safety mode.
- Output should remain single fixed-schema text report suitable to paste into chat. A user who sees all `UNVERIFIED` again must be able to distinguish an early gate skip from separate query failures based on **fixed categories alone**.

## 5. Validation — no real host probe

- PowerShell 7 AST parse of the entire revised script, review all commands and output points, and verify the exact read allowlist / absence of write, elevation, VM, process/1C, network and sensitive-output APIs.
- Synthetic-only tests of run gate classification: non-elevated Windows; positively elevated Windows; identity-check exception; non-Windows; unsupported/unknown value. Confirm that elevated/non-Windows/identity failures **do not** reach simulated host query functions.
- Synthetic-only tests of each query: normalized success with HOME/PRO and other representative values; API missing; permission denied; unexpected exception; null/unknown value; mixed outcomes. Confirm all printed fields remain in their allowlists and status semantics hold (e.g., all unknown never `READ_ONLY_REPORT`).
- Verify nine legacy fields remain and remain conservative: `HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE`. Never claim an isolated environment exists.
- Do **not** execute the script entry point (`pwsh -File ...`) on an actual host in any mode. Pure-functions-only AST extraction or fully mocked calls are permitted if demonstrably incapable of querying live OS state. If this cannot be ensured, stop or mark validation `UNVERIFIED`, never claim test success.
- No new persistent test fixture artifacts except explicitly allowlisted source/documentation. The synthetic harness may be ephemeral and workspace-local, not committed unless explicitly included in the allowlist (it is not).

## 6. Strict allowlist of Git changes

1. `DEV/tasks/018_DIAGNOSE_ISOLATION_READINESS_UNVERIFIED.md` — owner-provided task file verbatim.
2. `DEV/tools/Get-ELSI-IsolationReadiness.ps1` — bounded correction of existing read-only tool.
3. `DEV/reports/018_DIAGNOSE_ISOLATION_READINESS_UNVERIFIED.md` — factual, sanitized report.
4. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — add owner-reported all-unknown result and revised gate; no app launch permission.
5. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — explain `RUN_GATE` diagnostic and outstanding isolation risk.
6. `DEV/docs/IMPLEMENTATION_STATUS.md` — distinguish repaired tool/static-synthetic test from still-unperformed host rerun.
7. `DEV/docs/CHANGELOG.md` — factual Task 018 entry.
8. `README.md` — only if an existing statement is materially wrong.

All other paths read-only, including `AGENTS.md`, prior tasks/reports, backup and clone scripts, Git hooks, scanner, CI workflow, `.gitignore`, and any 1C/TEST files.

## 7. Documentation reconciliation, publication and report

1. Reconcile the exact implementation and tests with README, architecture, requirements, security, workflow, canonical TEST safety, application recovery plan, implementation status, changelog and task template. Update affected allowed documents in the **same task**. Include a detailed `Documentation reconciliation` matrix (inspected/changed/why/evidence/discrepancy) in report.
2. Report `OWNER_HOST_PROBE_017=OWNER_REPORTED_ALL_UNVERIFIED`, explicitly separate it from test results. No independent diagnosis of owner's Windows. For Task 018, `CODEX_HOST_PROBE=NOT_ATTEMPTED`, `OWNER_REVISED_PROBE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE`, architecture `NOT_APPROVED`, invoice/UPD automation `NOT_IMPLEMENTED`.
3. Do pre-commit exact staged allowlist/full diff, `git diff --cached --check`, UTF-8, links and sensitive-content review. Immediately before commit manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`, keep `core.hooksPath=DEV/hooks`, do not bypass normal hooks. Before push run `-Mode Outgoing` with the exact refs and allow normal pre-push hook.
4. Normal fast-forward push to `origin/main` only, no `--force`, `--no-verify`, reset/rebase/merge. Verify final remote SHA, published task/script/report, commit-specific Actions run; `CI=PASS` only when an exact-SHA run is complete and successful. No future commit SHA hardcoded in the report written before final commit.
5. `SUCCESS` means script fix, static/synthetic tests, docs and Git publication; **NOT** real owner host capability validation or isolation approval. Await ChatGPT audit before suggesting the owner rerun the repaired tool. Do not start Task 019.

## 8. Final response to owner

```text
TASK=018_DIAGNOSE_ISOLATION_READINESS_UNVERIFIED
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=0e96ed6cd260cb7502b1de3a8e0c62b4dfa98d39
AGENTS_FIRST_READ=PASS/FAIL
OWNER_HOST_PROBE_017=OWNER_REPORTED_ALL_UNVERIFIED
READINESS_DIAGNOSTICS=UPDATED/NOT_UPDATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_TEST=PASS/PARTIAL/FAIL/UNVERIFIED
CODEX_HOST_PROBE=NOT_ATTEMPTED
OWNER_REVISED_PROBE=NOT_ATTEMPTED
OUTBOUND_ISOLATION=UNVERIFIED
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

**Stop conditions:** any unexpected filesystem/OS read, requirement to run as administrator, request for raw host details, scope conflict, inaccessible `AGENTS.md`, Git mismatch, security gate failure, or inability to validate safely => stop without changing Windows or touching TEST/PRODUCTION.
