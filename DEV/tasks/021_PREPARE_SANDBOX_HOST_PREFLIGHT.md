# TASK 021 — PREPARE_SANDBOX_HOST_PREFLIGHT

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline, and goal

- Public repository: `elvinazubairovna/1c-elsi-invoice-upd-automation`, branch `main`.
- **Required exact local HEAD and fresh remote `origin/main`:** `bb7ae3ea85bd0830d7107e4c3ba2617f53cd53e0`, independently verified by ChatGPT during Task 020 audit. If local/remote differ, `BLOCKED`; no pull/reset/rebase/merge/force push.
- Task: `021_PREPARE_SANDBOX_HOST_PREFLIGHT`.
- ChatGPT: architecture and independent auditor. Codex: narrowly scoped executor. Owner: operator of their own Windows PC.
- **Goal:** prepare and statically/synthetically validate one read-only, owner-run PowerShell 7 preflight script. It must report *only normalized eligibility categories*, sufficient to decide whether a separately authorized activation of the **Windows Sandbox optional feature** is worth trying. The script must not be run against the actual host by Codex in Task 021.
- **Practical next step after audit:** ChatGPT inspects the exact script in GitHub, then owner runs it once in ordinary PowerShell 7 and returns its fixed-format safe result. Avoid making further planning-only tasks unless a concrete blocker demands one.
- **Not in scope:** enabling optional features, starting a Sandbox or `.wsb`, rebooting Windows, installing software, license validation, importing files or running 1C, accessing TEST/production or changing any host configuration.

## 2. Verified and owner-provided evidence (keep provenance exact)

- Task 020 published `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb` with explicit disabled networking and clipboard, disabled peripheral redirection, enabled protected client, **zero mapped folders/startup commands**; `DEV/tools/Test-ELSI-EmptySandboxConfig.ps1` statically validates it. ChatGPT audited the full config/validator and found exact-SHA successful GitHub Actions run for `bb7ae3ea85bd0830d7107e4c3ba2617f53cd53e0` (Actions URL `https://github.com/elvinazubairovna/1c-elsi-invoice-upd-automation/actions/runs/45170321107`). **This is source/static CI evidence, not effective runtime isolation.**
- From owner-provided Windows screenshots/output: edition `PRO`, virtualization status `SUPPORTED`; Optional Features GUI displayed Windows Sandbox and Hyper-V as present but **unchecked**. These are **owner-reported observations**, not Codex's live machine assessment. The automated optional-feature queries previously returned `QUERY_ERROR`, not proof of absence. Do not request or repeat the unreliable feature query as a prerequisite here.
- Task 014 and 016 owner-provided tool outputs reported backup/restore-file-parity and separate disposable host clone `_APP_SMOKE_016` as PASS; no application-level restore performed. The host clone is NOT an isolated guest and must not be opened.
- Preserve `HOST_SANDBOX_FEATURE=OWNER_GUI_UNCHECKED`, `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`, `GUEST_LAUNCH=NOT_ATTEMPTED`, `GUEST_NETWORK_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `1C_OFFLINE_INSTALL_LICENSE=UNVERIFIED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`.

## 3. Non-negotiable boundaries

1. **Production:** no access, discovery or metadata of actual 1C databases, launcher list, processes, application configuration, credentials, licenses, EDI or network resources. No production fallback.
2. **TEST:** no access (including directory metadata), reading, enumerating, copying, running, hashing or changing `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, previous probe folders or other accounting artifacts.
3. **Host during Task 021:** Codex may not execute the new preflight's entry point on any real machine, query actual Windows version, resources, registry, CIM, CPU, free disk, installed features or processes, or invoke admin APIs. Only PowerShell AST extraction and synthetic, isolated in-memory tests are allowed. No filesystem modifications outside explicitly allowed Git workspace docs/source.
4. **Host when owner later runs audited script:** script must perform only the narrow **read-only** capability queries specified below. No feature installation or change, no elevation prompts, no network, no processes, no external executables, no logs/files written, no Windows settings changes, no Sandbox/1C launch and no TEST access. Never enumerate disk volumes, users, applications or process list.
5. **Public repo/output:** no raw Windows build, exact RAM/disk/CPU sizes, usernames, hostnames, serial numbers, drive letters/paths, environment variables, hardware identifiers, screenshots, error messages/stacks, 1C data, binaries, secrets or license fields. Report only categorical values from fixed allowlists.
6. Preserve existing source, backup and clone files. Do not run `.wsb` or assume an XML static check proves operational isolation. No cleanup.

## 4. Mandatory reading, source requirements

1. Read `AGENTS.md` **in full FIRST**, then this task **in full SECOND**. Inspect Tasks/Reports 019–020, exact `.wsb` and XML validator, `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md`, `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, plus `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TASK_TEMPLATE.md` and relevant previous reports.
2. After reading, verify branch, origin, exact local HEAD, freshly verified remote HEAD, `core.hooksPath=DEV/hooks`, tracked and unrelated untracked worktree state. Preserve historic untracked Task 001 and all other unrelated work. If mismatch, stop; don't silently repair.
3. Use only official Microsoft Learn public documentation to confirm resource prerequisites; no live host queries. Relevant references:
   - https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install
   - https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file
4. From Microsoft Learn: Windows 10 1903+ or Windows 11; AMD64, or ARM64 on Windows 11 22H2+; at least **4 GB RAM** (8 GB recommended), **1 GB free disk** (SSD recommended), **two CPU cores**; hardware virtualization enabled. Thresholds are general documentation, **not** host-specific facts. For a practical 1C-related guest use higher disk headroom as a *conservative recommendation*, not an official minimum.

## 5. Deliverable: narrow owner-run read-only preflight

Create `DEV/tools/Get-ELSI-SandboxHostPreflight.ps1` as a PowerShell 7 script with **no parameters**, no `-Force` or administrator mode, running ordinarily (non-elevated). Avoid per-user paths; outputs contain only these fixed keys and enumerated values:

```text
HOST_RUN_GATE=NON_ELEVATED_PASS/ELEVATED_BLOCKED/NON_WINDOWS/UNVERIFIED
OS_VERSION_ELIGIBILITY=PASS/FAIL/UNVERIFIED
OS_ARCH_ELIGIBILITY=PASS/FAIL/UNVERIFIED
RAM_MIN_4GB=PASS/FAIL/UNVERIFIED
RAM_RECOMMENDED_8GB=PASS/BELOW_RECOMMENDED/UNVERIFIED
DISK_MIN_1GB=PASS/FAIL/UNVERIFIED
DISK_PRACTICAL_5GB=PASS/BELOW_RECOMMENDED/UNVERIFIED
CPU_CORE_MIN_2=PASS/FAIL/UNVERIFIED
HOST_FEATURE_STATE=OWNER_GUI_UNCHECKED_NOT_REVERIFIED
VIRTUALIZATION_SUPPORT=OWNER_REPORTED_SUPPORTED_NOT_REVERIFIED
HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED
GUEST_LAUNCH=NOT_ATTEMPTED
GUEST_NETWORK_ISOLATION=UNVERIFIED
APPLICATION_RESTORE=NOT_ATTEMPTED
PRODUCTION_ACCESS=NONE
STATUS=READ_ONLY_REPORT/PARTIAL_REPORT/BLOCKED_BY_RUN_GATE/UNVERIFIED
```

The categorical prior owner observations must be clearly identified as such — do **not** claim they were rechecked during this run. If prior evidence should not appear in a live-report script, instead use conservative `NOT_REVERIFIED` category and explain it in the guide; do not read the optional-features state.

### Narrow permitted host reads at the FUTURE owner run only

- Read-only OS platform (`RuntimeInformation.IsOSPlatform`) and whether session is elevated (`WindowsIdentity` + `WindowsPrincipal`). If not Windows, positively elevated, or identity cannot be verified, **skip the rest** and emit only conservative allowed statuses, no elevation request.
- Windows OS build from one narrowly defined read-only source, e.g. `Environment.OSVersion.Version.Build` or **one exact** read-only Windows registry value if required; classify `Windows 10 build >=18362` or Windows 11 as eligible. If the build is unknown, nonnumeric, below minimum or cannot be reliably interpreted, fail closed (`UNVERIFIED`/`FAIL` only with affirmative proof). Do not print the build number.
- OS architecture via `RuntimeInformation.OSArchitecture`. `X64` qualifies on supported Windows; `Arm64` requires Windows 11 22H2+; anything else unsupported/unknown. Do not print raw architecture.
- Total installed RAM from exactly `Win32_ComputerSystem.TotalPhysicalMemory` (single CIM class/property), or an equivalent small read-only documented API. Classify only against 4/8 GiB thresholds, without exposing the value.
- CPU *physical core count*, not merely threads/logical processors, from `Win32_Processor.NumberOfCores` (only this class/property) or equivalent reliable read-only API. Classify against two physical cores. Unknown => `UNVERIFIED`, not optimistic PASS.
- Free space ONLY on the Windows OS system volume, obtained without enumerating other drives, e.g. derive OS drive internally from the Windows directory using `.NET` and query that one `DriveInfo.AvailableFreeSpace`. **Never emit drive name or path**. Classify at official 1 GiB and conservative 5 GiB practical thresholds; do not list volumes, inspect TEST directory or reveal exact bytes.
- Do not call `Get-WindowsOptionalFeature`, host network commands, generic `Get-ComputerInfo`, list drives, installed programs, processes, services or identities beyond the narrow elevation test.
- Treat errors independently: one failed RAM query must not erase successfully verified OS information. Distinguish positive `FAIL` from unknown (`UNVERIFIED`). No raw exception/error output; catch expected errors and produce fixed categorical output only.
- `STATUS=READ_ONLY_REPORT` only when all four minimum requirements (OS version/arch, 4GB RAM, 1GB disk, two cores) are verified; `PARTIAL_REPORT` when any component is unknown; `BLOCKED_BY_RUN_GATE` on positively established non-Windows/elevated state; `UNVERIFIED` for unknown gate. A report's success is **not** permission to enable feature; `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED` remains true. If a minimum clearly fails, report the corresponding `FAIL` without upgrading it to a claim of readiness.
- Pure testable normalization/decision helpers should accept synthetic values; isolate host-API callbacks such that AST extraction/tests cannot invoke the real host queries.

## 6. Validation — strictly static and synthetic only in Task 021

- Parse the complete PowerShell file using PowerShell 7 AST; enumerate every cmdlet, .NET call, data source, output stream and entry-point side effect. Require read-only bounded APIs, no extra reads, no process launch, feature activation, network, registry discovery, drive enumeration, Windows UI, TEST or 1C access.
- Extract ONLY the pure helper functions for synthetic tests; do not dot-source or execute full entry point on the actual host. Simulate a full pass, each requirement below threshold, failures/nulls/non-numeric inputs, Windows 10 below build threshold, Windows 11, x64 vs ARM64 edge cases, elevated/non-Windows/identity-failure short-circuits, mixed unknown results; ensure no query callback runs after a blocked gate. Assert fixed output format and allowlist values; no raw error data.
- In-memory tests only; no persistent fixture source outside the allowlist, no installed components and no guest start. If validation cannot safely isolate host API calls, report `SYNTHETIC_TEST=UNVERIFIED` and stop before publication.
- Re-run the previously published static `.wsb` validator ONLY if needed for documentation consistency; NEVER execute the `.wsb` file or its shell association.

## 7. Documentation, strict Git allowlist, publication

### Allowed files only

1. `DEV/tasks/021_PREPARE_SANDBOX_HOST_PREFLIGHT.md` — supplied owner task verbatim.
2. `DEV/tools/Get-ELSI-SandboxHostPreflight.ps1` — new read-only source.
3. `DEV/reports/021_PREPARE_SANDBOX_HOST_PREFLIGHT.md` — factual, sanitized report.
4. `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` — concise future operator command only **after ChatGPT audit**, host-risk and privacy guidance; maintain no activation permission in Task 021.
5. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — only if affected by this exact new tool.
6. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — distinction between code/static tests and actual host preflight, no app launch.
7. `DEV/docs/IMPLEMENTATION_STATUS.md` — coded/static tested versus not attempted.
8. `DEV/docs/CHANGELOG.md` — factual entry for Task 021.
9. `README.md` — only if demonstrably necessary to correct an inaccurate claim.

Everything else read-only, especially `AGENTS.md`, `.wsb` config, Task 020 validator, security workflows/hooks/scanners, prior tasks/reports and production/test files. No private inventory, paths, binary files or screenshots in GitHub.

### Reporting and gates

- Reconcile actual changes/status with README, architecture, requirements, security, workflow, task template, existing restoration plan, Sandbox guide, safety baseline, implementation status and changelog. Update every impacted allowlisted canonical doc in the same task. Report a full `Documentation reconciliation` matrix (reviewed, changed, why, evidence, remaining gaps).
- Preserve prior evidence levels (`OWNER_REPORTED` and `STATIC_VALIDATED`) without upgrading them to successful host isolation; `PRODUCTION_ACCESS=NONE`, `GUEST_NETWORK_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, product/architecture not implemented/approved.
- Before commit inspect entire staged diff, exact allowlist, secret/private-data leaks, UTF-8/links, and `git diff --cached --check`. Do not stage unrelated untracked Task 001 or use `git add .`.
- Immediately before **every** commit manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`, verify `core.hooksPath=DEV/hooks`, let hooks run. Before push manually run `-Mode Outgoing` with actual outgoing refs and let pre-push hook run. No bypass, force, reset, merge, rebase, history rewrite.
- Fast-forward push only to `origin/main`. Verify exact remote SHA, published task/tool/report and exact-SHA GitHub Actions if available. Note that GitHub **commit combined statuses and GitHub Actions workflow runs are distinct**; a blank combined-status list is NOT evidence of no CI. To declare `CI=PASS`, require completed/success Actions run on exact SHA; otherwise `PENDING/UNVERIFIED/FAIL`.
- Codex must **not run the new tool's entry point on a real host**, enable Windows features, reboot, open `.wsb`, start Sandbox or 1C, copy files or start Task 022. Stop for independent ChatGPT source audit.

## 8. Final Codex response

```text
TASK=021_PREPARE_SANDBOX_HOST_PREFLIGHT
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=bb7ae3ea85bd0830d7107e4c3ba2617f53cd53e0
AGENTS_FIRST_READ=PASS/FAIL
OWNER_PROVENANCE=PRO_VIRT_SUPPORTED_GUI_UNCHECKED
HOST_PREFLIGHT_TOOL=CREATED/NOT_CREATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_TEST=PASS/PARTIAL/FAIL/UNVERIFIED
CODEX_HOST_PREFLIGHT=NOT_ATTEMPTED
OWNER_HOST_PREFLIGHT=NOT_ATTEMPTED
HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED
GUEST_LAUNCH=NOT_ATTEMPTED
GUEST_NETWORK_ISOLATION=UNVERIFIED
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

**Important:** A correct static `.wsb` and a passing host prerequisites report still do **not** establish effective guest isolation or 1C licensing. Actual feature activation is a separate owner action after host-impact review; no unconditional enable command in this task.
