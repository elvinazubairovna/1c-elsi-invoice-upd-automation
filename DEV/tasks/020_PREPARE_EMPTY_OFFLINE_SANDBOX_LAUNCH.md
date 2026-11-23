# TASK 020 — PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline and purpose

- Public repository: `elvinazubairovna/1c-elsi-invoice-upd-automation`, branch `main`.
- Exact expected **local HEAD and freshly verified remote `origin/main`**: `fbd735876d4679b4007fe26134dc81111c84022d` (the accepted Task 019 head). A mismatch => `BLOCKED`; do not pull, reset, rebase, merge, force push or discard user work.
- Task ID: `020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH`.
- ChatGPT = architecture and independent audit; Codex = strictly scoped executor; owner = Windows operator.
- **Goal:** turn the Task 019 reviewed, documentation-only XML example into an **auditable, fixed-content `.wsb` configuration file** for a FUTURE **empty, offline Windows Sandbox smoke test**, and provide a safe, repository-local **static XML validator** plus owner-facing preflight/decision instructions. This task must NOT enable Windows Sandbox, launch a guest, install 1C, register or access TEST, or reboot the computer.
- **The `.wsb` file is launchable if double-clicked. Its presence in Git does NOT authorize opening it.** Codex must not invoke file associations, Explorer, shell start, `wsb`, Windows Sandbox or any subprocess that launches a guest. The owner must await independent ChatGPT source audit and separate operator instructions.

## 2. Facts, provenance, and outstanding risks

1. Owner-provided observations: Windows Pro; virtualization supported; Sandbox and Hyper-V checkboxes visible and unchecked in the Windows Features GUI. The earlier programmatic feature queries returned `QUERY_ERROR`, not a proven unsupported status. Record only normalized `OWNER_REPORTED`, never host-identifying data.
2. Task 014 operator report: file-level TEST backup and restore-copy parity `OWNER_REPORTED_PASS`. Task 016 operator report: TEST-only disposable host clone `_APP_SMOKE_016` and parity `OWNER_REPORTED_PASS`. These are NOT proofs of application-level restore, database synthetic purity or network isolation.
3. `APPLICATION_RESTORE=NOT_ATTEMPTED`; `OUTBOUND_ISOLATION=UNVERIFIED`; `GUEST_NETWORK_ISOLATION=UNVERIFIED`; `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`; `1C_OFFLINE_INSTALL_LICENSE=UNVERIFIED`; architecture `NOT_APPROVED`; invoice/UPD automation `NOT_IMPLEMENTED`.
4. Official Microsoft Windows Sandbox default networking and clipboard behavior means **never suggest Start-menu/default launch** for this test. A configured, explicitly offline `.wsb` is the only planned launch candidate, and no launch is authorized in this task.
5. **Additional feasibility risk:** 1C licensing in an ephemeral VM/guest may differ from the existing host license, and an offline 1C installer is not yet verified. Never assume installed host 1C or its activation transfers to Sandbox. Never request, inspect, transmit, commit or copy license files, activation PINs, installer binaries, user IDs or secrets. Source for future owner/license consultation: https://v8.1c.ru/priobretenie-i-vnedrenie/otvety-na-tipovye-voprosy-po-litsenzirovaniyu-1s-predpriyatiya-8/ and https://kb.1ci.com/1C_Enterprise_Platform/FAQ/Administration/Licenses/How_to_avoid_constant_software_license_restoration_in_virtual_environment/ . Do not conclude that any specific new license is definitively required without a verified applicable case.

## 3. Non-negotiable safety boundaries

- **PRODUCTION:** no discovery, reading, path/launcher enumeration, processes, services, data, network, registry, installation, licensing or side effects. No production fallback.
- **TEST:** Codex must NOT access (including metadata) or change `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, `_DIR_PROBE_013`, any TEST file/database or its contents; do not copy, register, launch or hash them.
- **HOST:** NO live Windows capability queries, feature installs/activation, elevation, Windows Sandbox/Hyper-V/VM/1C launch, reboot, firewall or network changes, clipboard/policy adjustments, sandbox testing, OS inventory, remote requests to private systems, or files outside repo. No activation commands in a runnable script.
- **PUBLIC GITHUB:** no private absolute paths, actual OS/hardware inventory, local username, screenshots, real accounting/customer data, 1C binaries/installers, license/activation secrets, database files, hashes, or direct host-file mappings.
- Preserve all unrelated tracked/untracked user content, including historic untracked Task 001. No cleanup of any existing local backup/clone artifacts.

## 4. Required reading, Git admission and official docs

1. Read full root `AGENTS.md` FIRST, then entire Task 020 SECOND. Then read Task/Report 019, `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` in full, `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TASK_TEMPLATE.md`, and any directly relevant reports 014–018. No external connectors or local TEST lookup.
2. Verify origin, `main`, expected local SHA, freshly checked remote SHA, `core.hooksPath=DEV/hooks`, and tracked working-tree state before edits. Stop on branch/base mismatch; do not repair by rewriting history.
3. Treat only official Microsoft reference as normative for `.wsb` tags and values:
   - https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file
   - https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install
   - https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview
   If accessing public documentation is unavailable, compare with Task 019 cited official references and mark any extra assertion unverified. No host data collection.

## 5. Implementation: fixed, empty, offline Sandbox configuration

Create **`DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb`** with **exactly** this UTF-8 (no BOM needed) XML structure, seven security options only:

```xml
<Configuration>
  <vGPU>Disable</vGPU>
  <Networking>Disable</Networking>
  <AudioInput>Disable</AudioInput>
  <VideoInput>Disable</VideoInput>
  <PrinterRedirection>Disable</PrinterRedirection>
  <ClipboardRedirection>Disable</ClipboardRedirection>
  <ProtectedClient>Enable</ProtectedClient>
</Configuration>
```

- No comments, attributes, namespace declarations, DTD/external entities, extra nodes, or dynamic interpolation.
- Strictly no `MappedFolders`, `MappedFolder`, `HostFolder`, `SandboxFolder`, `ReadOnly`, `LogonCommand`, startup applications/scripts, credentials, network mounts, drive mappings, file paths or configurable arguments.
- This configuration is for an **empty smoke test** only. It has **no approved pathway to import 1C installers or database data**. Do not claim or design an implicit transfer mechanism.
- Do not open this `.wsb` file through any shell/application/file association, including as a “test” or “preview”.

## 6. Repository-only static validation

Create **`DEV/tools/Test-ELSI-EmptySandboxConfig.ps1`** as a small PowerShell 7 **read-only validation script** which:

- Resolves the exact fixed config path **relative to the repository** (not through a user-provided `-Path` parameter; no arbitrary host paths or filesystem traversal); only reads this one file in the workspace.
- Opens the XML with DTD prohibited and XML resolver disabled. Rejects unexpected root, child tags, attributes, duplicate tags, text other than whitespace, nonexact values, extra nodes/comments/processing instructions, or any disallowed network/clipboard/folder/startup element.
- Asserts exactly the seven fields and values above. Returns only `STATUS=PASS` or `STATUS=FAIL` and a fixed non-sensitive category like `ERROR_CATEGORY=XML_INVALID/UNSAFE_ELEMENTS/MISSING_FIELD/READ_ERROR/NONE`. No raw parser exceptions, paths, XML content or source dumps in operator output.
- Includes **no** API that creates/starts a Windows Sandbox, launches a program except PowerShell itself, runs OS/feature queries, changes files/permissions/configuration, or accesses TEST/PRODUCTION, network, Windows registry or processes. A read of the one static repository `.wsb` is its **only** runtime file access.
- Tests may execute **only this static validator**, not the `.wsb` file; include bounded synthetic in-memory negative cases (e.g., enabled network, enabled clipboard, added mapped folder, added `LogonCommand`, unknown node, duplicate, DTD, malformed XML). Keep synthetic fixtures ephemeral in memory; do not create persistent test data or other source files beyond allowlist. If a negative-case harness would require broad host effects, omit and report `UNVERIFIED`, never simulate success.
- Confirm the static validator does NOT accidentally start Sandbox, execute `.wsb` association, or call PowerShell `Start-Process`, `Invoke-Item`, `& <wsb>` or any installer. The `.wsb` shall NOT be run at all in Task 020.

## 7. Owner-facing runbook: separate approval gates

Update **`DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md`** with a short, plain-Russian **next-operator-phase section**:

1. Task 020 publishes a **potentially launchable** `.wsb`; it is **NOT yet approved for opening**. The owner should not double-click it or open Windows Sandbox by default.
2. **Future host preflight, owner only:** verify Windows version eligibility, available RAM/disk, and that important host work (including 1C) is saved/closed before any feature change. **Do not ask for private/system identifiers to be published.** If any prerequisite is unverified, do not enable Sandbox.
3. **Future Windows feature activation, only after a separate explicit owner go-ahead:** enable **only** Windows Sandbox checkbox by the GUI if prerequisites and host-impact conditions are satisfied; do not independently enable whole Hyper-V, change BIOS, network, host-wide firewall or production settings. Feature activation may request elevation/restart and can affect running work; stop for unexpected prompts or impacts. **Task 020 does not perform or authorize activation**.
4. **Future empty guest smoke, only after a separate independent code review and operator go-ahead:** start solely via the audited `.wsb`, never via generic Start-menu/default launcher, and verify *effective* isolation before introducing 1C. Be candid that XML syntax and settings are configuration evidence, not absolute runtime attestation. No data/imports/1C are authorized yet.
5. **License/install gate before actual 1C testing:** obtain a confirmed legal and technically feasible offline 1C installation/licensing route for an ephemeral guest. Existing host activation should not be assumed usable in a virtual guest. No sensitive details, keys or license artifacts go into public docs/chat. If unsuitable, stop and recommend a stable isolated offline VM or dedicated test computer as a separately evaluated alternative; never silently reuse host license data.
6. Existing host-side `_APP_SMOKE_016` stays untouched and unlaunched. New, separate nonproduction copy for a guest requires a future audited transfer method, **not host or backup folder mapping**.
7. Keep explicit status table: `WSB_CONFIG=STATIC_VALIDATED/UNVERIFIED`, `HOST_SANDBOX_FEATURE=OWNER_GUI_UNCHECKED`, `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`, `GUEST_LAUNCH=NOT_ATTEMPTED`, `GUEST_NETWORK_ISOLATION=UNVERIFIED`, `1C_OFFLINE_INSTALL_LICENSE=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE`.

Do not turn the runbook into an owner script that executes or installs the feature; do not include a copy-paste Windows optional-feature enable command.

## 8. Strict Git write allowlist

1. `DEV/tasks/020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH.md` — owner task file verbatim.
2. `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb` — fixed XML configuration above.
3. `DEV/tools/Test-ELSI-EmptySandboxConfig.ps1` — static checker only.
4. `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` — owner-facing gates and file reference.
5. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — precise status/link reconciliation only if affected.
6. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — updated static-only status and unchanged safety gates.
7. `DEV/docs/IMPLEMENTATION_STATUS.md` — coded/static-validated vs unrun host state.
8. `DEV/docs/CHANGELOG.md` — factual Task 020 entry.
9. `DEV/reports/020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH.md` — sanitized report including documentation reconciliation.
10. `README.md` — only if an already published statement would otherwise be materially misleading.

No other changes. No modifications to `AGENTS.md`, previous tasks/reports, existing tools, scanners, hooks or workflows. If publication/security gates reject `.wsb` or any other new path, **STOP**; never bypass or rename to evade checks. Report the blocker for independent audit.

## 9. Verification, report, publication

1. Read and compare all canonical documentation affected by the change: README, architecture, requirements, security, workflow, task template, safety, implementation status, changelog, restoration plan and Sandbox guide. Update affected allowlisted files. In report include a `Documentation reconciliation` matrix with reviewed/changed/why/evidence/discrepancies; no unsupported `PASS` claims.
2. PowerShell 7 AST parse of the complete validator; review entire source for allowed commands, implicit execution, errors and side effects. Validate exact XML and negative synthetic variants. Do not launch Sandbox, virtual machine, 1C, test database or host capability probe. If .wsb XML is syntactically correct but the published validator fails, stop and correct it before publishing.
3. Before commit: inspect complete staged diff, exact allowlist, UTF-8, link correctness, `git diff --cached --check`, secrets and accidental private identifiers. Do not stage unrelated untracked Task 001, and do not use `git add .`.
4. Immediately before commit run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` manually; verify `core.hooksPath=DEV/hooks`; allow normal commit hook. Before push run `-Mode Outgoing` with actual outgoing refs and allow normal push hook. No bypass, force, reset, rebase, merge or history rewriting.
5. Commit only allowlisted files and normal fast-forward push; verify remote `main` SHA, published task, config, validator and report, plus commit-specific CI status. Only report `CI=PASS` for completed successful exact SHA run; else PENDING/UNVERIFIED/FAIL. Do not put a fabricated future containing SHA in the report.
6. The report must clearly differentiate `CONFIG_CREATED` and `XML_STATIC_CHECK=PASS` from **feature installed**, **guest launched**, **effective network isolation**, **1C licensing** or **application restore**, which all remain not attempted/unverified.
7. Stop. Await independent ChatGPT GitHub audit; do not begin Task 021 or send operator a launch command.

## 10. Required final response

```text
TASK=020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=fbd735876d4679b4007fe26134dc81111c84022d
AGENTS_FIRST_READ=PASS/FAIL
WSB_CONFIG=CREATED/NOT_CREATED
XML_STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_NEGATIVE_TESTS=PASS/PARTIAL/FAIL/UNVERIFIED
VALIDATOR_STATIC_CHECK=PASS/FAIL/UNVERIFIED
HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED
GUEST_LAUNCH=NOT_ATTEMPTED
GUEST_NETWORK_ISOLATION=UNVERIFIED
1C_OFFLINE_INSTALL_LICENSE=UNVERIFIED
APPLICATION_RESTORE=NOT_ATTEMPTED
PRODUCTION_ACCESS=NONE
DOCS_SYNC=PASS/FAIL
INDEX_CHECK=PASS/FAIL
OUTGOING_CHECK=PASS/FAIL
HOOKS=PASS/FAIL
CI=PASS/PENDING/FAIL/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=NONE/<non-sensitive reason>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**Strict prohibition:** neither this task nor an `XML_STATIC_CHECK=PASS` result authorizes enabling Windows Sandbox, launching the `.wsb`, installing 1C, copying test files or touching production.
