# TASK 022 — RECORD_SANDBOX_SMOKE_AND_PREPARE_SYNTHETIC_INGRESS

> **FIRST ACTION REQUIRED:** Read the root `AGENTS.md` completely FIRST, then this task completely SECOND. If either is inaccessible, stop `BLOCKED`. Do not extrapolate authority beyond this task.

## 1. Authority, exact baseline, objective

- Public repository: `elvinazubairovna/1c-elsi-invoice-upd-automation`, branch `main`.
- Exact expected local HEAD and freshly verified remote `main`: `d633ed144f5b5cda0a758cb9935065f0b50130f0` (ChatGPT independently checked Task 021).
- Owner = Windows operator; ChatGPT = architect and independent GitHub auditor; Codex = bounded implementer.
- Purpose: **record the owner's first real empty Windows Sandbox smoke test with accurate provenance**, then prepare a narrowly bounded, **synthetic-only, one-way read-only ingress** for a future separate guest smoke test. Produce a PowerShell 7 *preparation-only* tool plus documentation/decision gates. The preparation tool will be run by the owner **only after ChatGPT audits it**; Codex shall not invoke its entry point on any actual host in Task 022.
- This is NOT a 1C deployment, 1C license activation, accounting-data import, or guest launch. Do not create an actual `.wsb` with a real host mapping during Task 022. Preserve previously approved empty `.wsb` unchanged.

## 2. Owner-provided observations to record (not independent technical attestation)

The owner supplied the following results after Task 021, dated November 23, 2026. Attribute them explicitly as `OWNER_REPORTED`, **not** Codex host evidence:

1. Ran `Get-ELSI-SandboxHostPreflight.ps1` in ordinary PowerShell 7: screenshot showed `HOST_RUN_GATE=NON_ELEVATED_PASS`, `STATUS=READ_ONLY_REPORT`, and `PASS` for Windows version, architecture, minimum/recommended RAM, minimum/practical disk and physical cores. The preceding Windows edition `PRO` and virtualization `SUPPORTED` were earlier owner-reported; do not claim Task 021 independently rechecked them.
2. Using the Windows Features GUI, the owner checked only **Windows Sandbox**, restarted the laptop, and showed a checked **Windows Sandbox** feature afterward. This is an owner-provided UI observation; no claim of verified policy or Hyper-V internals.
3. Owner ran the exact local Task 020 static validator `Test-ELSI-EmptySandboxConfig.ps1` and shared `STATUS=PASS`, `ERROR_CATEGORY=NONE`. This confirms the *local static config*, not runtime effective isolation.
4. Owner launched `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb` manually as instructed. A separate Windows Sandbox desktop window opened. No 1C, installers, files, mapped folders or TEST data were introduced. Screenshots inside Sandbox were not available.
5. Within the guest, the owner navigated to **Settings → Network & Internet**, which displayed **«Соединение отсутствует»**; could not use an English-command shell due to keyboard layout. This is a **visual no-connection observation only** — no packet-level proof, route/adapter inspection or system policy attestation. `GUEST_NETWORK_ISOLATION=OWNER_REPORTED_UI_NO_CONNECTION_RUNTIME_UNVERIFIED` and `OUTBOUND_ISOLATION=UNVERIFIED`.
6. The owner closed the empty Sandbox. No guest data needed preserving. `GUEST_LAUNCH=OWNER_REPORTED_EMPTY_SUCCESS`, `GUEST_CLOSED=OWNER_REPORTED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE` as scope of owner steps. `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`; the original host-side `_APP_SMOKE_016` remains untouched.

Do not falsely retain outdated `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`, `GUEST_LAUNCH=NOT_ATTEMPTED` in current-state documentation. Preserve them as *historical Task 021 status only* and add dated owner-observed statuses distinctly. Do not claim a technically proven air gap or approval to import an existing TEST database.

## 3. Required sources and admission

1. Read full `AGENTS.md`, full Task 022 in that order. Then inspect Tasks/Reports 019–021, `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb`, `DEV/tools/Test-ELSI-EmptySandboxConfig.ps1`, `DEV/tools/Get-ELSI-SandboxHostPreflight.ps1`, `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md`, `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, and `DEV/docs/TASK_TEMPLATE.md`.
2. Verify expected Git branch/origin, local HEAD, fresh remote `main`, tracked status and `core.hooksPath=DEV/hooks`. Preserve historic untracked Task 001 and unrelated work. Mismatch means `BLOCKED`, no pull/reset/rebase/merge/force-push or user-data deletion.
3. Ground Windows Sandbox mapped-folder configuration **only in official Microsoft Learn**: `https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file` and `https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-sample-configuration`. Explicit `ReadOnly=true`, disabled networking and clipboard remain required.
4. For 1C choices consult **official 1C sources only**: `https://v8.1c.ru/priobretenie-i-vnedrenie/otvety-na-tipovye-voprosy-po-litsenzirovaniyu-1s-predpriyatiya-8/`, `https://v8.1c.ru/podderzhka-i-obuchenie/uchebnye-versii/`, `https://v8.1c.ru/platforma/litsenziya-dlya-razrabotchikov/`, and `https://kb.1ci.com/1C_Enterprise_Platform/FAQ/Administration/Licenses/How_to_avoid_constant_software_license_restoration_in_virtual_environment/`. Explain training/developer/commercial limits and offline activation **only when verified by source**. Do not assert that a specific training build can open the owner's configuration 3.0.208.14 or that an existing commercial license automatically transfers to a disposable VM. Do not access user account/license/installers.

## 4. Non-negotiable boundaries

- **Production:** zero discovery or access: no 1C launcher, history, paths, running processes, services, registry, accounts, credentials, EDI, email, bank data, network or any production file/metadata. Never use real data as an example.
- **TEST:** zero access (even metadata) or copying, hashing, opening, transferring, mapping or modifying `ELSI_TEST`, `_BACKUP_014`, `_RESTORE_CHECK_014`, `_APP_SMOKE_016`, `_DIR_PROBE_013` or any other actual 1C data. Existing backup/clone originals must remain untouched; synthetic purity of existing TEST is `UNVERIFIED`.
- **Host:** Codex runs **no** actual host inspector, no synthetic-ingress entry point, and no feature/guest/1C/installer/VM launches, no elevation, reboot, drive enumeration, Windows/TEST directory traversal, firewall/network changes, OS configuration, local account/licensing inspection. No real local staging folder creation or user-file reads in Task 022.
- **GitHub:** public repo must contain no absolute user path, actual generated `.wsb` with a real mapping, Windows account info, real OS inventory, screenshots, production/test data, installers/binaries, activation/license files or keys, test database copies, filenames from private directories, raw exceptions, hashes of private files, or any host identifier.
- No shell association or action that starts a `.wsb`. No change to `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb` or its validator. A read-only mapping still **exposes** the mapped staging folder's contents to a guest; this future test must be strictly synthetic and non-sensitive only, and is not permission to map 1C/backup directories.

## 5. Concrete deliverable A: owner-only synthetic-ingress preparation tool

Create `DEV/tools/New-ELSI-SyntheticSandboxIngress.ps1`, PowerShell 7 **without parameters**, with a narrow, auditable implementation and zero auto-launch behavior:

1. **When later explicitly run by the owner only**, create one dedicated **new**, disposable directory under `LocalApplicationData` (from the documented .NET special folder, not a user-supplied path), with a stable distinctive name such as `ELSI-Sandbox-Synthetic-Ingress-022`. Use fail-if-exists semantics: **do not** delete, empty, overwrite, reuse, traverse or repair any existing directory/file, and fail closed if path is a reparse point or the directory's safety cannot be established. No recursive enumeration or cleanup. Do not change ACLs, system policies, firewall, Windows Features, or 1C.
2. Write inside it exactly one **synthetic** `payload` folder containing one harmless fixed UTF-8 marker `ELSI_SANDBOX_SYNTHETIC_INGRESS_ONLY` (no accounting values, no real data); the directory also contains the generated `.wsb` *outside the payload*, not mapped into the guest. Do not read or copy any other host file, especially no 1C, downloads, documents, backups or app binaries. Do not let a user specify another path or file source. If preparation cannot be atomic/safe, return a fixed `FAIL` category; do not delete any uncertain partial directory automatically.
3. Build one local-only `.wsb` via secure XML APIs (encode/escape any path automatically; no raw string insertion). **HostFolder** is only the newly created exact `payload` folder path; **SandboxFolder** a fixed guest-only path, e.g. `C:\SandboxSyntheticIngress`; **ReadOnly** `true`. The security options of Task 020 remain exact: networking/clipboard/vGPU/audio/video/printer disabled, ProtectedClient enabled. `MappedFolders` contains exactly one `MappedFolder`; no `LogonCommand`, commands, startup, extra mappings, external source or config parameters. Do not create a `.wsb` in the repository, do not launch it, and do not change the original empty `.wsb`.
4. Do not print, log, commit or send actual absolute paths/usernames/identifiers; return only fixed normalized fields, such as `STATUS=PREPARED|BLOCKED|FAIL`, `PAYLOAD=SYNTHETIC_MARKER_ONLY`, `MAPPING=READ_ONLY_ONE_FOLDER`, `NETWORKING=DISABLED_IN_CONFIG`, `GUEST_LAUNCH=NOT_ATTEMPTED`, `TEST_ACCESS=NONE`, `PRODUCTION_ACCESS=NONE`, `NEXT=WAIT_FOR_SEPARATE_AUDIT_AND_OPERATOR_LAUNCH`. If an error occurs, print fixed category (`TARGET_EXISTS`, `PATH_UNVERIFIED`, `CREATE_ERROR`, `XML_INVALID`, etc.), never raw exception or path.
5. The generation tool is **preparation only**; it cannot start Sandbox, trigger shell file associations, install 1C, read TEST or production, transfer other files, or invoke admin commands. It must be runnable without administrator rights. A later *separate, audited owner step* determines if/how to open the locally generated `.wsb`. If the design cannot meet all conditions safely, stop with `BLOCKED` and a factual sanitized report rather than implementing a dangerous fallback.
6. If existing Windows security policy might override `.wsb` settings, clearly mark runtime isolation as `UNVERIFIED`; one mapped synthetic folder explicitly changes the original no-host-sharing profile, and this boundary must be documented honestly.

## 6. Tests — static and synthetic only, **no real staging writes**

- Parse the complete PowerShell 7 AST and manually inventory all commands/.NET operations, filesystem read/write boundaries and output paths. Reject any process/guest/1C/Windows activation, network, arbitrary `-Path`/source, broad directory enumeration, or file deletion.
- Refactor pure XML generation/validation and path-eligibility checks into injectable helpers for synthetic tests; execute **only pure helpers** with invented paths and data in memory. Do not dot-source or execute the full entry point against host; never create/delete a real staging folder during Task 022.
- Assert all seven security controls, exact single `MappedFolders`/`MappedFolder`, `ReadOnly=true`, fixed `SandboxFolder`, no startup, no extra tags and correct XML escaping. Synthetic negative cases: wrong host mapping, second mapping, read-write mapping, enabled network/clipboard, `LogonCommand`, malformed XML, path escape, already-existing target, reparse/symlink input, null path. Verify fixed-category safe output; no raw host fields or exceptions.
- Do not modify or rerun the existing empty `.wsb` or actual Sandbox. Do not create persistent synthetic test fixtures (pure in-memory tests only).
- CI and existing repo publication scanner may not simulate OS local runtime; do **not** claim an actual owner staging smoke succeeded.

## 7. Deliverable B: reconcile docs and 1C route decision

1. In `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md`, add a dated **owner-reported Task 021/empty guest outcome** and detailed boundary between (a) the prior **empty no-share WSB**, (b) new **future synthetic-marker-only read-only mapping** and (c) later **1C installer or TEST import — NOT APPROVED**. Document that owner already activated Sandbox and rebooted and that guest was closed. Remove misleading current-tense statements claiming feature is still unchecked or launch not attempted, while preserving historical attribution.
2. Explain that a newly generated read-only mapping will intentionally share **one harmless synthetic marker** with the guest and thus must be treated as a different isolation profile. No approval for real accounting data, real TEST, existing backups or 1C installers.
3. Add a concise **decision tree for 1C feasibility** based on official 1C sources: determine whether a compatible offline platform distribution can legally be used; assess commercial VM licensing versus developer/training variant; whether separate credentials/online activation would be required; if not feasible for ephemeral offline Sandbox, choose a separately assessed offline durable VM or standalone lab computer. Do not ask the owner to submit keys, installed path, license files, installer binaries or private records. Do not claim a commercial production-ready test on a learning license. Keep the next practical operator step simple after audit.
4. Update `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, and `DEV/docs/CHANGELOG.md` with accurate provenance/status. Review `README.md`, `ARCHITECTURE.md`, `REQUIREMENTS.md`, `SECURITY.md`, `DEVELOPMENT_WORKFLOW.md`, `TASK_TEMPLATE.md` and update README only if materially necessary. Add a full `Documentation reconciliation` matrix to the Task 022 report.
5. Suggested status taxonomy: `OWNER_PREFLIGHT=OWNER_REPORTED_PASS`, `HOST_SANDBOX_FEATURE=OWNER_GUI_CHECKED_POST_REBOOT`, `EMPTY_GUEST_LAUNCH=OWNER_REPORTED_SUCCESS_CLOSED`, `GUEST_UI_NETWORK=OWNER_REPORTED_NO_CONNECTION`, `GUEST_NETWORK_ISOLATION=RUNTIME_UNVERIFIED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `SYNTHETIC_INGRESS_TOOL=CODED_STATIC_TESTED_NOT_RUN`, `SYNTHETIC_INGRESS_OWNER_RUN=NOT_ATTEMPTED`, `OFFLINE_1C_INSTALL_LICENSE=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`, `PRODUCTION_ACCESS=NONE`.

## 8. Exact Git change allowlist

Only these files may be staged and published:

1. `DEV/tasks/022_RECORD_SANDBOX_SMOKE_AND_PREPARE_SYNTHETIC_INGRESS.md` — supplied task verbatim.
2. `DEV/tools/New-ELSI-SyntheticSandboxIngress.ps1` — strictly bounded preparation-only tool.
3. `DEV/reports/022_RECORD_SANDBOX_SMOKE_AND_PREPARE_SYNTHETIC_INGRESS.md` — sanitized, factual report.
4. `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` — operator guidance and provenance.
5. `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — status/gate update.
6. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — current owner status and future synthetic boundary.
7. `DEV/docs/IMPLEMENTATION_STATUS.md` — coded/static/runtime distinctions.
8. `DEV/docs/CHANGELOG.md` — dated factual Task 022 entry.
9. `README.md` — only if materially needed.

Do not edit `AGENTS.md`, existing scripts/config, security scanner, CI/workflows/hooks, prior tasks/reports, TEST files, or anything else. No runnable `.wsb` with a real mapping in public Git. Preserve unrelated untracked files including Task 001.

## 9. Publication and final reporting

1. Inspect exact staged allowlist/full diff, UTF-8, links, accidental paths, personal data/secrets and `git diff --cached --check`. No `git add .`, force push, bypass, reset, rebase or merging unrelated work.
2. Before **every** commit manually execute `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`; leave `core.hooksPath=DEV/hooks`, let hooks run. Before push manually run same scanner `-Mode Outgoing` with the exact refs, let pre-push hook run; stop on any failure.
3. Commit and normal fast-forward push to `origin/main`; confirm exact remote HEAD, published task/source/report and commit-specific GitHub Actions **workflow run** status (not merely combined commit statuses). Report `CI=PASS` only for completed/success exact-SHA run; otherwise `PENDING/UNVERIFIED/FAIL`. Do not hardcode future self-containing SHA in the committed report.
4. `SUCCESS` means: accurate owner observation recorded, safe synthetic-only preparation tool written, static/in-memory tests passed, public docs reconciled, GitHub changes published. It **does not** mean local staging folder created, guest opened with new mapping, 1C installed/licensed, or app-level restore validated.
5. Do not begin Task 023. Await independent ChatGPT review and a later explicit owner-run instruction.

### Codex final output format

```text
TASK=022_RECORD_SANDBOX_SMOKE_AND_PREPARE_SYNTHETIC_INGRESS
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=d633ed144f5b5cda0a758cb9935065f0b50130f0
AGENTS_FIRST_READ=PASS/FAIL
OWNER_EMPTY_SANDBOX=OWNER_REPORTED_OPENED_CLOSED_UI_NO_CONNECTION
SYNTHETIC_INGRESS_TOOL=CREATED/NOT_CREATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
SYNTHETIC_TEST=PASS/PARTIAL/FAIL/UNVERIFIED
CODEX_HOST_PREPARATION=NOT_ATTEMPTED
OWNER_HOST_PREPARATION=NOT_ATTEMPTED
GUEST_NEW_MAPPING_LAUNCH=NOT_ATTEMPTED
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
BLOCKERS=NONE/<sanitized reason>
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```
