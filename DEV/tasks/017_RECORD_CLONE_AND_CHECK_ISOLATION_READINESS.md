# TASK 017 — RECORD_CLONE_AND_CHECK_ISOLATION_READINESS

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, checked baseline, and goal

- Public repository: `elvinazubairovna/1c-elsi-invoice-upd-automation`; branch: `main`.
- **Required exact local HEAD and freshly verified remote `origin/main`:** `d1b731673b71a318209b3e412d7d02966b6486b0` (verified by ChatGPT during audit of Task 016). No automatic pull/reset/rebase/merge/force push if different.
- Task ID: `017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS`.
- Roles: ChatGPT = architect/independent acceptance authority; Codex = bounded executor; owner = Windows operator.
- **Goal A:** record the owner's successful offline disposable-clone result accurately, as owner-provided evidence, not as an independent filesystem observation.
- **Goal B:** author, statically inspect and synthetically validate a **read-only, operator-run** PowerShell 7 capability-reporting script that will help select an actually isolated way to run a future 1C TEST copy. The script must not be run on the owner's real host in Task 017; the owner will run it only after ChatGPT independently audits the exact source.
- **No 1C launch, no VM creation, no host setting changes, no cloned-base access, no network disablement, no `.epf` execution and no invoice/UPD implementation in this task.**

## 2. New evidence supplied by the owner — precise provenance

After ChatGPT's independent audit of Task 016, the owner executed the audited `DEV/tools/New-ELSI-DisposableAppClone.ps1` **once** in ordinary non-elevated Windows PowerShell 7.7.0 with `-RunClone` and supplied a screenshot of sanitized output:

```text
CLONE_PHASE=P5_SOURCE_FINAL
LAST_COMPLETED_PHASE=P5_SOURCE_FINAL
FAILED_PHASE=NONE
ERROR_CATEGORY=NONE
CLONE_016=PASS
FILE_LEVEL_CLONE_PARITY=PASS
SOURCE_FINAL=PASS
APPLICATION_RESTORE=NOT_ATTEMPTED
OUTBOUND_ISOLATION=UNVERIFIED
PRODUCTION_ACCESS=NONE
STATUS=SUCCESS
```

Record the result as `OWNER_REPORTED_PASS` / `OWNER_PROVIDED_TOOL_OUTPUT` for the **one operator run**, namely:

- `CLONE_016=OWNER_REPORTED_PASS`: a disposable file-level working copy was reported at the tool's fixed TEST-only target `_APP_SMOKE_016`, sourced from `_RESTORE_CHECK_014`.
- `FILE_LEVEL_CLONE_PARITY=OWNER_REPORTED_PASS` and `SOURCE_FINAL_AT_OPERATOR_RUN=OWNER_REPORTED_PASS`.
- `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`.

**Do not assert** Codex independently examined TEST files, that the copy is safe to open, that integrations are disabled, or that the copy is already placed inside an isolated environment. Do not alter historic reports (Task 016 recorded the situation *before* owner execution). Do not publish the screenshot, user name, terminal prompt, absolute paths, hashes, inventories, license information, account details, file sizes or any other private environmental data.

## 3. Non-negotiable safety boundary

1. **PRODUCTION absolutely forbidden** — no discovery, path or launcher listing, inspection, launch, reading, copying, network/service/process or registry inspection specific to 1C/production, settings change, or fallback.
2. **TEST absolutely untouched by Codex in Task 017** — no metadata lookup, enumeration, copy, open, hash, registration, launch, deletion, rename or change to `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, earlier artifacts or any other TEST directory.
3. Do not change Windows settings, Hyper-V or Sandbox features, services, adapters, firewall, network, virtualization configuration, shared folders, cloud settings, or 1C application settings. Do not install any software, request elevation, use remote systems or collect machine secrets.
4. Existing `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, and `_DIR_PROBE_013` are to remain intact. No cleanup or retries.
5. No database/backup files or host-derived data in public GitHub. Only sanitized Markdown, generic PowerShell script source and synthetic-only test source if explicitly allowlisted.
6. A reported successful clone is **not** permission to launch 1C or proof of network isolation. The capability probe must never claim `OUTBOUND_ISOLATION=PASS` or `APPLICATION_RESTORE=PASS`.

## 4. Mandatory reading and Git admission

1. Read `AGENTS.md` in full **FIRST**, then this complete task **SECOND**. Read Task/Report 016, `DEV/tools/New-ELSI-DisposableAppClone.ps1`, Task/Report 015 and `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, plus `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, and earlier related evidence as needed.
2. Only after reading, verify the exact origin, branch, local SHA and **fresh** remote `main` against the baseline above. Preserve unrelated tracked/untracked files (including historical unusual Task 001). No `git add .`, reset, rewrite, merge, rebase, pull, or force push.
3. Confirm from published Task 016 source code that its success path prints the status fields recorded above after its P0–P5 checks. Record this as a code-output consistency audit only, not independent runtime proof.

## 5. Deliverable: read-only Windows isolation-capability inventory

Create **`DEV/tools/Get-ELSI-IsolationReadiness.ps1`**. It is an **operator-only, read-only** PowerShell 7 script to be manually run later from an ordinary, non-admin Windows PowerShell 7 session, after independent ChatGPT audit. It must **never need or offer an administrator/elevation option**.

### Allowed local reads by the future owner-run script

- Only standard non-sensitive **OS capability facts** directly relevant to isolated-app feasibility, such as Windows edition class (e.g. `HOME`, `PRO`, `ENTERPRISE`, `EDUCATION`, `SERVER`, `OTHER`, `UNVERIFIED`), recognized Microsoft Windows Sandbox / Hyper-V **optional feature states**, and processor virtualization capability flags *if safely and read-only retrievable without escalation*.
- All statuses must be **normalized** to fixed allowlisted values: `ENABLED`, `DISABLED`, `NOT_AVAILABLE`, `UNVERIFIED` for features; `SUPPORTED`, `UNSUPPORTED`, `UNVERIFIED` for virtualization; and the edition classes above. If query APIs are absent or access is denied, report `UNVERIFIED`; **never guess**.
- Do not enumerate or print installed applications, installed 1C software, licensed users/keys, devices, network adapters, services, processes, drives, folders, environment variables, interfaces, DNS, credentials, serial numbers, hostnames, user names, domain, raw OS build string, RAM size or other host identifiers. No broad registry traversal, process inventory, log inspection or WMI collection beyond the exact class/property needed for listed safe indicators.
- If checking Windows features requires elevated privileges on the target machine, **do not elevate**: mark the feature `UNVERIFIED`. Do not call `Enable-WindowsOptionalFeature`, `Disable-WindowsOptionalFeature`, DISM installation commands, `Set-*`, adapters/firewall commands, or virtualization creation/configuration APIs.
- Do not perform any network request, localhost probe, remote lookup, filesystem write, log/transcript, `Start-Process`, installer, VM launch, 1C launch, or local TEST access.
- The script must safely handle PowerShell errors, absent CIM providers/features, missing APIs and unknown edition values. Print only the following schema (fixed keys and normalized values, no raw errors):

```text
OS_EDITION_CLASS=HOME/PRO/ENTERPRISE/EDUCATION/SERVER/OTHER/UNVERIFIED
WINDOWS_SANDBOX_FEATURE=ENABLED/DISABLED/NOT_AVAILABLE/UNVERIFIED
HYPERV_FEATURE=ENABLED/DISABLED/NOT_AVAILABLE/UNVERIFIED
VIRTUALIZATION_SUPPORT=SUPPORTED/UNSUPPORTED/UNVERIFIED
HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED
OUTBOUND_ISOLATION=UNVERIFIED
APPLICATION_RESTORE=NOT_ATTEMPTED
PRODUCTION_ACCESS=NONE
STATUS=READ_ONLY_REPORT/UNVERIFIED
```

The host isolation line is **not a live test** and must not imply that a VM/sandbox is deployed or isolated. Be especially conservative: optional-feature state or virtualization capability alone is **never** sufficient evidence of a secure, networkless 1C environment. No raw `Get-ComputerInfo`, `systeminfo`, detailed CIM objects or registry values may be printed.

### Validation in Task 017 (synthetic / static only)

- Parse full script as PowerShell AST and review all commands/APIs for side effects, enumeration, raw output leaks, privileged operations and accidental exceptions printed by PowerShell. `Get-WindowsOptionalFeature` may be used only for exact known feature names and caught errors; avoid querying all features. If the API cannot be called safely without privilege, mark `UNVERIFIED`.
- Exercise only pure normalization/status-mapping helper functions using **synthetic** OS/feature/virtualization objects and simulated failures; ensure unknown values sanitize to `UNVERIFIED`/`OTHER` and cannot leak arbitrary text.
- Codex **must not execute the script entry point on the real host even in read-only mode** during Task 017 and must not collect host capability facts. If isolated synthetic validation is not possible, state `SYNTHETIC_TEST=PARTIAL/UNVERIFIED`, not `PASS`.
- Documentation must plainly state that the script only *surveys eligibility* and that the owner is not yet authorized to run 1C or the cloned database.

## 6. Isolation-options decision note — planning only

Update `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` with a short, plain-Russian decision section, without assuming Windows edition, hypervisor availability, OS license, 1C installation/license access or guest network state:

- Compare only **candidate** approaches, such as a separately configured offline VM, Windows Sandbox if supported and legally/operationally viable, or a separate offline test computer. Record prerequisites/unknowns, that the selected environment must be proven isolated *before* 1C starts, and that the 1C license and platform may need separate owner-handled installation.
- The existing `_APP_SMOKE_016` was reportedly created on the **host**. It is not automatically isolated. If a VM is selected later, the procedure must separately design transferring a **distinct disposable copy** into the guest without live host shares or persistent integrations, and verify no host or production resources are exposed. **Do not** mount/open the existing clone into a live 1C session now.
- Explicitly rule out disabling all host network adapters, changing host-wide firewall rules affecting the production 1C executable, or attaching host production data as a convenience. No networking changes or VM actions in this task.
- Avoid a cycle of endless design-only tasks: describe the **shortest viable next concrete operator action**, dependent on the script's future sanitized feature report. Do not choose a VM product merely based on convenience; explain the evidence needed.

## 7. Strict allowlist (all other tracked files read-only)

1. `DEV/tasks/017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS.md` — owner's task file verbatim.
2. `DEV/tools/Get-ELSI-IsolationReadiness.ps1` — new generic read-only source only.
3. `DEV/reports/017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS.md` — factual sanitized report.
4. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — record reported clone creation and safe isolation-options decision path.
5. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — owner-provided clone outcome and remaining application/connection risks.
6. `DEV/docs/IMPLEMENTATION_STATUS.md` — coded vs owner-reported vs not-attempted states.
7. `DEV/docs/CHANGELOG.md` — factual Task 017 entry.
8. `README.md` — only if demonstrably outdated or a concise canonical link is warranted.

No modifications to `AGENTS.md`, historical tasks/reports, existing tools including the clone/backup script, scanners, hooks, workflows, 1C binaries, `.gitignore` or unrelated files. No VM config artifacts in Git at this stage.

## 8. Verification, documentation reconciliation, publication

1. Reconcile the actual task, script, synthetic results and owner-provided clone status with `README.md`, architecture, requirements, security, workflow, task template, safety, implementation status, recovery plan and changelog. Update affected allowlisted documents and add the new factual Task 017 changelog record.
2. Report includes status, `AGENTS_FIRST_READ`, base SHA and Git checks, owner-result provenance, complete review of what the script reads and cannot do, AST/synthetic outcomes, full `Documentation reconciliation` matrix (document/reviewed/changed/reason/evidence/discrepancy), changed files, privacy gates, Index/Outgoing/hooks, remote SHA, CI status as knowable before final publication, blockers and next action. Never invent the SHA of the report's containing commit.
3. Manually inspect **entire** staged diff, exact allowed paths, Unicode/UTF-8, relative Markdown links, `git diff --cached --check`, private data leaks, unexpected runtime or API effects. Do not stage the unrelated Task 001 or generated fixtures.
4. Immediately before `git commit` manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`, confirm `core.hooksPath=DEV/hooks` and allow commit hook. Before normal `git push`, manually run `-Mode Outgoing` with the actual outgoing refs and allow pre-push hook. **No** `--no-verify`, `--force`, reset, rebase, silent workaround or history rewriting. Security gate failure => stop, never bypass.
5. Normal fast-forward push to `origin/main` only. Verify exact remote SHA, published task/report/script, and completed commit-specific CI if available. `CI=PASS` only for completed successful exact-SHA run, else `PENDING/FAIL/UNVERIFIED`.
6. Do not perform operator host capability probe, register/open the clone in 1C, set up a VM, access any TEST/PRODUCTION filesystem, configure network, or start Task 018. Await ChatGPT independent GitHub audit.

## 9. Required final response

```text
TASK=017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=d1b731673b71a318209b3e412d7d02966b6486b0
AGENTS_FIRST_READ=PASS/FAIL
OWNER_CLONE_016=OWNER_REPORTED_PASS/UNVERIFIED
OWNER_CLONE_PARITY=OWNER_REPORTED_PASS/UNVERIFIED
OWNER_SOURCE_FINAL=OWNER_REPORTED_PASS/UNVERIFIED
ISOLATION_READINESS_TOOL=CREATED/NOT_CREATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_TEST=PASS/PARTIAL/FAIL/UNVERIFIED
CODEX_HOST_PROBE=NOT_ATTEMPTED
OWNER_HOST_PROBE=NOT_ATTEMPTED
APPLICATION_RESTORE=NOT_ATTEMPTED
OUTBOUND_ISOLATION=UNVERIFIED
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

**Never turn a read-only Windows capability query into an installation, VM activation, network change, production inspection or permission to launch 1C.**
