# TASK 019 — SANDBOX_OFFLINE_FEASIBILITY_AND_CONFIG

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, exact baseline and objective

- Public repository: `elvinazubairovna/1c-elsi-invoice-upd-automation`; target branch: `main`.
- Exact expected local HEAD and freshly checked remote `origin/main`: `0f896957d60808d2438dd9df55cd7565f5e34f16`.
- Owner/operator: user. Architect and independent auditor: ChatGPT. Constrained executor: Codex.
- New owner-observed evidence after Task 018 (record as `OWNER_REPORTED`, not as independent Codex observation): the revised read-only diagnostic reported `OS_EDITION_CLASS=PRO`, `VIRTUALIZATION_SUPPORT=SUPPORTED`, `RUN_GATE=NON_ELEVATED_PASS`, `EDITION_QUERY=PASS`, `VIRTUALIZATION_QUERY=PASS`, while `WINDOWS_SANDBOX_FEATURE=UNVERIFIED`, `HYPERV_FEATURE=UNVERIFIED`, `SANDBOX_QUERY=QUERY_ERROR`, `HYPERV_QUERY=QUERY_ERROR`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED` and `STATUS=PARTIAL_REPORT`.
- The owner then opened the Windows optional-features GUI and showed **Windows Sandbox** and **Hyper-V** as present in the list and **unchecked**. This is owner-provided GUI evidence of their presently unchecked UI state, not proof of successful installation, activation, entitlement, or effective guest isolation. No boxes were selected or settings changed by that observation.
- Goal: design and review the **shortest safe, concrete Windows Sandbox feasibility path** for a future isolated *test-only* 1C launch. Produce a **non-executable Markdown runbook** containing a minimal, explicitly locked-down sample `.wsb` XML and a practical prerequisite/decision matrix. **Do not enable, install, launch, register, configure or modify Windows, Sandbox, Hyper-V, any VM or 1C in this task.** No `.wsb` file shall be deployed or launched now.
- A successful Task 019 authorizes only reviewed documentation. It is NOT a green light to enable a Windows feature, reboot, create a sandbox, transfer any database or launch 1C. ChatGPT will independently audit the result and determine the next owner step.

## 2. Mandatory reading and Git admission

1. Fully read root `AGENTS.md` first, this task second. Then inspect reports/tasks 017–018, the latest `DEV/tools/Get-ELSI-IsolationReadiness.ps1` source, `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, and `DEV/docs/TASK_TEMPLATE.md`.
2. Only after reading, check exact origin, `main`, clean relevant tracked tree, local HEAD and freshly fetched remote HEAD against the specified SHA. Preserve all unrelated tracked/untracked files, notably historic untracked Task 001. Mismatch => `BLOCKED`; do not pull/reset/rebase/merge/force push.
3. Research **public, official Microsoft Learn documentation only** for Sandbox feature prerequisites, activation/restart, `.wsb` format, default network/clipboard behavior, and available XML controls. Do not use a Microsoft account, inspect local licensing, query host/registry/CIM/Windows features, run the diagnostics, or access any 1C installation. Report official documentation URLs and document date where available. If web access is unavailable, rely only on the official reference URLs supplied below and mark unverified facts rather than invent them:
   - `https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install`
   - `https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file`
   - `https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview`

## 3. Non-negotiable boundaries

- **PRODUCTION:** absolutely no discovery or access whatsoever: no launcher history, paths, processes, 1C settings, registry keys, documents, backups, secrets, services or network operations specific to production. No fallback to production.
- **TEST:** do not read, list, hash, open, copy, alter, register, run or delete `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, older probe directories or any local TEST files. Owner-reported local clones remain intact and **not** isolated by virtue of copying.
- **HOST:** no changing/checking features on the real machine, no admin/elevation, reboot, Hyper-V changes, VM activation, WSB launch, app installation, network/firewall/adapter modification, OS/1C process or service queries, system inventory, shared folder configuration or credentials/licence checks. Do not advise blindly enabling Hyper-V; a future feature activation may require reboot and compatibility review on the host.
- **PUBLIC GIT:** no unredacted screenshots, local Windows paths, usernames, licence keys, real database files/exports, proprietary installers, identifiers, financial records, exception contents, hardware details, hashes, or actual host inventories.
- Preserve `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED` throughout.

## 4. Deliverable: `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md`

Write a clear, practical Russian-language guide for a nontechnical Windows owner. It must include:

### A. Evidence and feasibility — distinguish known from unknown

- Confirm *owner-reported* Windows Pro, virtualisation support, Sandbox and Hyper-V visible/unchecked in optional-features GUI; note `Get-WindowsOptionalFeature` queries returned `QUERY_ERROR`, not disabled/not-available. The GUI result is evidence that the two checkboxes were unchecked, not proof of sandbox operability.
- Explain prerequisites still needing evidence (Windows version/feature readiness, sufficient RAM/disk for one temporary Windows environment, optional reboot and host impact, offline 1C platform installer and right to use it, offline licensing or activation behavior, actual test-clone transport, 1C client compatibility). **Do not obtain this information by probing the owner's host in this task**; list simple owner-visible checks for a later individually authorized stage.
- State that Windows Sandbox is ephemeral; its contents can disappear on close. Avoid a solution that assumes data persists across sessions or reboot. Include a route to switch to a separately isolated offline VM or offline computer if Sandbox is unsuitable; do not claim one approach is definitely viable yet.

### B. Locked-down candidate `.wsb` XML — **documentation example only**

Place one readable XML code block in Markdown, using only Microsoft-documented tags, with:

- `<Networking>Disable</Networking>` — never rely on the default (which is network-enabled).
- `<ClipboardRedirection>Disable</ClipboardRedirection>` — do not rely on the default clipboard sharing.
- `<vGPU>Disable</vGPU>`, `<AudioInput>Disable</AudioInput>`, `<VideoInput>Disable</VideoInput>`, `<PrinterRedirection>Disable</PrinterRedirection>` and, if officially supported, `<ProtectedClient>Enable</ProtectedClient>`.
- **No `MappedFolders`, no `MappedFolder`, no `HostFolder`, no `LogonCommand`, no script launch, no host file access.** The simplest no-host-sharing configuration is the initial *empty sandbox isolation smoke* candidate only, **not** the eventual 1C test configuration.
- Clearly explain why a sandbox with both clipboard and mapped folders disabled has **no approved data/installer ingress path**: an eventual 1C test needs a separately designed, sharply bounded offline delivery method, proof that it does not expose production, and verification of guest isolation before launching 1C. Do not magically assume offline installer/data transport is solved. If a later plan requires temporary host sharing, it is a separate architectural/security decision and must be limited to a purpose-built non-production staging folder; it may NOT map any existing backup/source or production directory. The current task does not approve it.
- Give a warning **not to double-click any `.wsb`** or launch Sandbox now, because that runs an actual guest and any default-start shortcut can enable networking.

### C. Owner-facing next step and decision gates

Outline a short bounded sequence, with no execution in this task:

1. Independently audit Task 019's sample and host-impact preflight.
2. Only after a separate approval, owner may choose to enable **Windows Sandbox** using GUI; ensure other work is saved and assess/restart implications; **do not require enabling the entire Hyper-V feature just because it appears as a separate unchecked checkbox**. If unexpected warning, admin approval or host risk, stop and escalate; do not alter host security settings to bypass.
3. If feature works and is allowed, first verify an **empty guest with explicit disabled networking/clipboard and zero mapped folders**. No 1C, no TEST data, no installed packages. Verify effective isolation, not just XML syntax. Host state remains untouched except narrowly approved Sandbox feature activation and launch.
4. Before actual 1C app test: separately verify 1C offline platform/install/licence, design restricted test-only ingress and dedicated guest clone; never open `_APP_SMOKE_016` on the host and never map the backup directories into the guest. If not feasible, choose the documented offline VM/offline computer alternative.
5. Future app recovery pass/fail must be separately defined and executed; no real accounting data or recipients.

### D. Explicit no-go table

Clearly mark `CURRENT_SANDBOX_FEATURE=OWNER_GUI_UNCHECKED`, `GUEST_CONFIG=DESIGN_ONLY`, `GUEST_NETWORK_ISOLATION=UNVERIFIED`, `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `1C_OFFLINE_INSTALL_LICENSE=UNVERIFIED` and `PRODUCTION_ACCESS=NONE`. Do not issue a copy/paste enable/install/start command in this task.

## 5. Safe tests and documentary reconciliation

- Validate the XML sample **statically only** from the Markdown snippet or a synthetic in-memory string, with no WSB app association / shell execution. Parse XML using a secure XML parser (no DTD/external entity resolution). Assert exact no-network, no-clipboard, no-mapped-folder and no-autostart tags; correct root and documented option values. Do not create a runnable `.wsb` on disk.
- Verify official documentation grounding for the tags and the fact that default Sandbox has networking and clipboard redirection enabled. Note limitations of static XML checks: they do not prove the guest's effective isolation, availability, file transfer, 1C licensing, or OS feature state.
- Check no private host data, real paths, identifying screenshots, installers or 1C binaries in staged changes. Do not run any host capability probe, executable script, Sandbox, Hyper-V, 1C, or Windows optional-feature changes.
- Reconcile affected canonical docs: `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, and task template. Update allowed affected docs within the same task. Add factual changelog entry and report table `Documentation reconciliation` (reviewed / changed / reason / evidence / contradictions). Mark claims according to provenance.

## 6. Exact Git allowlist

Only these paths may be staged/committed:

1. `DEV/tasks/019_SANDBOX_OFFLINE_FEASIBILITY_AND_CONFIG.md` — supplied task **verbatim**.
2. `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` — new Russian document, non-executable XML example only.
3. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — link/prerequisites/status update if needed.
4. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — owner GUI evidence / remaining gates.
5. `DEV/docs/IMPLEMENTATION_STATUS.md` — plan-only status.
6. `DEV/docs/CHANGELOG.md` — factual task entry.
7. `DEV/reports/019_SANDBOX_OFFLINE_FEASIBILITY_AND_CONFIG.md` — sanitized report.
8. `README.md` — only if material link/status correction is needed.

No actual `.wsb` file, PowerShell or other code/script/feature changes; other tracked paths read-only. Preserve unrelated untracked files, including Task 001.

## 7. Publication and report protocol

1. After writing documentation, review exact allowlist, staged diff, UTF-8, links and secrets; `git diff --cached --check`. No `git add .`, no force, bypass, merge/reset/rebase/history rewrite.
2. Immediately before commit: manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`, ensure `core.hooksPath=DEV/hooks`, and allow hooks. Before push: `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Outgoing` with the actual outgoing refs and allow pre-push hook. If any gate fails, stop without bypass.
3. Commit only allowlisted safe documents, normal fast-forward push. Confirm final remote SHA, published task/report/guide, and exact-SHA CI status; CI `PASS` only if completed successful. No report self-reference to future containing SHA; write report before final commit.
4. `DEV/reports/019_SANDBOX_OFFLINE_FEASIBILITY_AND_CONFIG.md` must include AGENTS-first, baseline, detailed scope/changed files, static XML check results, references, owner evidence provenance, restrictions/unknowns, documentation reconciliation, publication/security results as known before report commit, CI result separately in final owner message, and `NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`.
5. **Do not start Task 020, enable Sandbox/Hyper-V, restart Windows, execute `.wsb`, register/test 1C, operate TEST, or modify production.**

## 8. Required final response

```text
TASK=019_SANDBOX_OFFLINE_FEASIBILITY_AND_CONFIG
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=0f896957d60808d2438dd9df55cd7565f5e34f16
AGENTS_FIRST_READ=PASS/FAIL
OWNER_WINDOWS_PRO=OWNER_REPORTED
OWNER_VIRTUALIZATION=OWNER_REPORTED_SUPPORTED
OWNER_GUI_SANDBOX=VISIBLE_UNCHECKED
OWNER_GUI_HYPERV=VISIBLE_UNCHECKED
SAFE_SANDBOX_RUNBOOK=CREATED/NOT_CREATED
XML_STATIC_CHECK=PASS/FAIL/UNVERIFIED
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

The task prepares a safe design only. It must not turn a review of Windows features into permission to operate the host or 1C.
