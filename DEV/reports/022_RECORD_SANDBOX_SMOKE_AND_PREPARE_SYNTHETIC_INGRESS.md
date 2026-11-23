# Task 022 — Record Sandbox smoke and prepare synthetic ingress

**Status: SUCCESS** — preparation tool and documentation are complete; this does not mean host staging preparation, mapped guest launch, or application recovery was performed.

## Scope and provenance

- Task: `022_RECORD_SANDBOX_SMOKE_AND_PREPARE_SYNTHETIC_INGRESS`.
- Base: `d633ed144f5b5cda0a758cb9935065f0b50130f0` (`main` at task admission).
- The owner supplied the Task 021/empty-Sandbox observations recorded here and in the guide. Codex did not inspect the host, source screenshots, local staging paths, or databases.
- Owner-reported: Task 021 preflight showed `HOST_RUN_GATE=NON_ELEVATED_PASS`, `STATUS=READ_ONLY_REPORT`, and PASS categories for OS, architecture, RAM, disk, and physical cores. Previously reported edition/virtualization values were not rechecked by that preflight.
- Owner-reported: only Windows Sandbox was selected in GUI and the computer restarted; the checkbox was subsequently checked. The unchanged Task 020 validator reported `PASS` / `ERROR_CATEGORY=NONE`. The owner opened the unchanged empty `.wsb`, saw a separate guest, transferred no app, installer, files, mapping, or TEST data, and closed it. Guest Settings UI showed “Соединение отсутствует”. This is UI evidence only; network adapters, routes, packets, and policy were not checked.
- No Codex host preflight, preparation entry point, Windows Sandbox, `.wsb`, 1C, TEST/backup/clone, or production resource was accessed. No actual synthetic ingress folder or generated mapping was created. Production access: `NONE`.

## Deliverables

- Added `DEV/tools/New-ELSI-SyntheticSandboxIngress.ps1`, a no-parameter, preparation-only operator tool. It is designed to create a new fixed LocalApplicationData target exclusively, a payload folder with one fixed synthetic marker, and a generated `.wsb` outside the mapped payload. The configuration helper emits exactly the seven locked-down options and one read-only mapping to the fixed guest folder. The tool has no launch action, arbitrary source/path input, cleanup, overwrite, or TEST/production access path. It reports fixed categories only.
- The tool was not executed as a whole. Only pure helper functions extracted from its parsed AST were exercised against invented in-memory paths/XML/statuses.
- Updated Sandbox setup, application restore plan, test safety, implementation status, and changelog. README was inspected and left unchanged because existing navigation already links to the applicable canonical documents and no product behavior changed.

## Checks

- PowerShell 7 complete-file AST parse: `PASS`.
- Static source/API and output-boundary review: `PASS`; entry point and host filesystem APIs were not run. No process/guest/1C launch, Windows feature change, network operation, arbitrary source, delete, recursive enumeration, or existing `.wsb` modification was found in the permitted implementation.
- Extracted pure helpers with in-memory synthetic cases: `PASS`, 20 assertions. Covered eligible and escaped paths, null and existing target, reparse flags, XML escaping and valid output, wrong/extra mapping, writable mapping, networking/clipboard enabled, LogonCommand, malformed XML/DTD, and fixed-category output sanitization.
- Existing Task 020 validator/config and other host tools were not run. No live folder or persistent test fixture was created.
- Documentation status: `GUEST_NETWORK_ISOLATION=UNVERIFIED`; UI “no connection” does not establish effective isolation. `OUTBOUND_ISOLATION=UNVERIFIED`; offline 1C install/license `UNVERIFIED`; application restore `NOT_ATTEMPTED`; architecture `NOT_APPROVED`; invoice/UPD automation `NOT_IMPLEMENTED`; synthetic purity of existing TEST `UNVERIFIED`; production access `NONE`.

## Documentation reconciliation

| Document | Inspected | Updated / reason | Claims checked against |
|---|---|---|---|
| `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` | Yes | Added dated owner-reported empty guest result, three-profile boundary, and 1C licensing/offline decision route; explicitly keeps effective isolation unverified. | Task 022 supplied owner evidence; tool source; official Microsoft Learn and 1C licensing pages linked in the guide. |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` | Yes | Added Task 022 provenance, tool status, and explicit distinction from application restore. | Owner-reported facts and tool execution limits in this report. |
| `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` | Yes | Reconciled current Sandbox row and future admission notes; old statuses remain historical. | Task 022 task scope, owner evidence, tool source/checks. |
| `DEV/docs/IMPLEMENTATION_STATUS.md` | Yes | Added coded/static/not-run status and unchanged runtime/product categories. | Actual changed files and recorded check results. |
| `DEV/docs/CHANGELOG.md` | Yes | Added factual Task 022 entry; relabeled Task 021 as retrospective after a later owner-reported state was recorded. | This report and documentation diff. |
| `README.md` | Yes | No change: existing navigation is adequate; no user-facing product behavior was added. | Link review and unchanged product status. |
| `DEV/docs/ARCHITECTURE.md`, `REQUIREMENTS.md`, `SECURITY.md`, `DEVELOPMENT_WORKFLOW.md`, `TASK_TEMPLATE.md` | Yes | No change: no architecture, requirements, security workflow, publication mechanism, or task template changed. | Allowed task scope and source diff; security workflow/scanner/hooks were untouched. |
| `AGENTS.md`, Task 022 input | Read in full | Unchanged; task input is preserved verbatim. | Admission instructions and exact diff review. |

No task-related contradiction remains: the empty no-share configuration and the future marker-only read-only mapping are explicitly separate profiles; the owner-reported UI observation is not presented as proof of isolation; the new tool is coded/static-tested but unrun. No status category for application restore, TEST data purity, architecture approval, or product implementation changed.

## Publication

Publication checks, commit SHA, remote-head readback, exact-SHA workflow result, and report URL are recorded in the final task response after GitHub verification. The committed report intentionally does not predict its own commit SHA.
