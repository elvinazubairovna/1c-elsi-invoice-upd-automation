# TASK 013 — OPERATOR_FOLDER_WRITE_PROBE

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Authority, baseline, and why this task exists

- Public repo: `elvinazubairovna/1c-elsi-invoice-upd-automation`; branch `main`.
- Exact expected **local and fresh remote** baseline: `95d6a5b4dba2751327b1228e82b02e097288191b` (audited by ChatGPT).
- Task: `013_OPERATOR_FOLDER_WRITE_PROBE`. Owner sets business intent; ChatGPT is architect and independent auditor; Codex executes only this scope.
- In Task 011, the backup failed at `P2_CREATE_BACKUP_DIR` with `UNCLASSIFIED`. Task 012 independently tried to create an empty probe folder in the dedicated TEST parent; `D3_DIRECTORY_CREATE` again failed with `UNCLASSIFIED`, and exact post-error lookup found probe `ABSENT`. The underlying cause is **not established**. One plausible hypothesis is that Codex's command-execution sandbox prevents writing outside the Git workspace; another is insufficient Windows permissions or command/runtime error. **Do not assert either as fact.**
- **Goal:** create, statically validate, and publish a small, reusable **operator-executed** PowerShell 7 diagnostic script for a *single empty folder creation* within the fixed TEST parent. The owner will run it in their normal, non-elevated Windows PowerShell session **after** ChatGPT reviews and accepts this task. The script's runtime result will be assessed in the next task/turn.
- The script must **NOT be executed in probe/write mode by Codex in Task 013**, and Task 013 must not attempt another backup or restore.

## 2. Hard safety and privacy boundaries

- **Never touch PRODUCTION**: no location, lookup, launcher/registry discovery, metadata, file contents, process inspection, backup, connection, launch, or permissions changes for the real ELSI accounting base. No cross-base comparisons.
- Runtime script uses **only** Windows system-drive root, fixed literal child `1C_TEST`, the exact `ELSI_TEST` child for *directory identity only*, and a single fixed probe target `_DIR_PROBE_013` immediately under `1C_TEST`. No arbitrary paths or override parameters, no environment-configurable root beyond normal Windows system drive, no fallback searches or sibling enumeration. Do not examine the database or files in `ELSI_TEST`.
- The **only potential local write** from operator invocation is one attempt to create a new **empty** `_DIR_PROBE_013` directory under the TEST parent. Do not create anything inside it. If the target exists, is inaccessible, reparse-linked, or ambiguously absent, stop without writing. Do not delete/rename/clean up any folders, even if the probe succeeds.
- No scripts, tests or Codex commands may invoke the probe write while executing this task. The owner must explicitly perform the operator command after independent review. No privilege elevation, UAC bypass, `runas`, ACL/ownership changes, service/process stops, local group changes, or sandbox-bypass tricks.
- No 1C application or Configurator execution; no `.epf`, `.cfe`, invoice, UПД, API, internet service, EDI, email or outbound operations.
- **GitHub is public**. Never publish or print absolute paths, account names, SIDs/ACL identities, process names/arguments, DB contents, counterparties, private environment values, exception messages/stack traces, licensing information, screenshots, file names inside the base, hashes or sizes. The script **source code**, containing only generic fixed relative path components, may be published. Runtime output must consist only of controlled status fields and safe error categories.

## 3. Required initial checks

1. Read `AGENTS.md` fully **first**, then this task fully **second**. Review Task/Report 011 and 012, earlier Task/Report 007–010 as needed, plus `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/TEST_ENVIRONMENT_SAFETY.md`, `DEV/docs/IMPLEMENTATION_STATUS.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, and `README.md`.
2. Confirm clean relevant tracked tree, `main`, exact local HEAD, correct `origin` URL and fresh `origin/main` SHA. Preserve any unrelated tracked/untracked files (including previously observed unusual Task 001). On mismatch, stop `BLOCKED` with no pull/reset/rebase/merge.
3. Check Windows and PowerShell 7 through ordinary shell metadata. Do not inventory programs, profiles, users, drives, 1C paths or processes.
4. If available directly through Codex's documented execution interface, **read only the stated sandbox/write-scope policy** (for example, workspace-write vs full filesystem). Do not inspect secret config files, hidden harness internals, environment dumps, or logs. Report `CODEX_WRITE_SCOPE=RESTRICTED/UNRESTRICTED/UNVERIFIED` only when supported; never infer from previous error alone. No attempt to elevate Codex's scope.

## 4. Deliverable: operator-run diagnostic script

Create `DEV/tools/Test-ELSI-TestFolderWrite.ps1` as a minimal readable, maintainable PowerShell 7 script. Require explicit `-RunProbe` switch for the only write; without it, perform only safe read-only boundary/target checks (or display a fixed usage message). The script must be self-contained, no dependency installation, no network access, no external programs, no PowerShell transcription/logs, no elevation, and no user-supplied path parameters.

### Fixed boundaries and fail-closed conditions

1. Use Windows-only behavior. Obtain system-drive root from OS-supported standard runtime facts; require it to be an ordinary local filesystem volume. Join **only** fixed `1C_TEST`, `ELSI_TEST`, and `_DIR_PROBE_013` segments. Do not accept alternative path inputs, current directory inference or any fallback.
2. Before write, verify parent and `ELSI_TEST` identity using metadata only (no traversal inside ELSI_TEST); reject wrong/missing path, symlink/junction/reparse in relevant components, known cloud-sync folder or Git-working-tree containment, and ambiguous paths. Never enumerate siblings. Never query PRODUCTION.
3. Check the exact probe item with a non-recursive filesystem-item lookup that distinguishes absent, present and inaccessible/reparse. If not strictly absent, stop with `PROBE_PRECHECK=BLOCKED` and do not attempt creation.
4. `-RunProbe` performs **exactly one** built-in .NET/PowerShell directory-create API attempt for the fixed target, with explicit `try/catch`. No retries, loops or silent fallback. Validate afterward via a single direct metadata lookup of that exact target. If create fails, one direct post-failure lookup is allowed; do not clean up.
5. Do **not** use a blanket catch that converts every failure into `UNCLASSIFIED`. Explicitly unwrap common PowerShell invocation wrappers via `InnerException` / `GetBaseException()` in memory; classify **only from well-understood .NET exception types and numeric HRESULT** (and distinguish `POWER_SHELL_RUNTIME`, `SANDBOX_OR_POLICY`, `ACCESS_DENIED`, `PATH_OR_TARGET`, `OTHER_IO`, `UNCLASSIFIED`). Do not over-interpret an unknown HRESULT. A platform/policy denial category requires reliable structured evidence, not guesswork. It is permitted to print a **safe allowlisted exception type name and hexadecimal numeric HRESULT** for the actual failure after filtering against a fixed whitelist; otherwise print `UNCLASSIFIED`, not raw exception text. No absolute path or user identity in output.
6. Always emit machine-readable, sanitized outcome fields, for example: `PROBE_PHASE=...`, `PROBE_RESULT=CREATED_EMPTY_DIRECTORY/ABSENT/ALREADY_EXISTS/UNVERIFIED`, `ERROR_CATEGORY=...`, `EXCEPTION_TYPE=...` (allowlisted or `UNVERIFIED`), `HRESULT=...` (only safe hex code or `UNVERIFIED`), `PRODUCTION_ACCESS=NONE`. Exit nonzero on error; never claim success merely from a successful API return if target identity was not checked.
7. Include prominent comments that this is an operator-run **empty-folder diagnostic**, not a backup or proof that a 1C database is safe to modify. Running PowerShell as administrator is neither needed nor approved; if access is denied, stop and report the result rather than attempting permission changes.
8. Keep source code free of values identifying the owner or installed database paths. Use no external logging or `Start-Transcript`.

### Validation during Task 013 — static only

- Codex **must not invoke `-RunProbe`** or any other TEST directory write. It may parse the script with PowerShell's AST parser and exercise pure, side-effect-free category mapping against synthetic exceptions only. No test may touch an actual TEST destination. If this cannot be verified safely, report `STATIC_CHECK=UNVERIFIED` and do not claim executable validation.
- Review the script manually for every filesystem write, potential path-escape, accidental output of secrets, and error-handler behavior. Check script encoding/line endings appropriate for PowerShell 7.
- Do not launch the test database or run application-level tests.

## 5. Exact Git allowlist

The only tracked paths that may be added/changed:

1. `DEV/tasks/013_OPERATOR_FOLDER_WRITE_PROBE.md` — user-supplied task verbatim.
2. `DEV/tools/Test-ELSI-TestFolderWrite.ps1` — new script **source only**, not execution output.
3. `DEV/reports/013_OPERATOR_FOLDER_WRITE_PROBE.md` — factual report.
4. `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — note planned owner-run probe (not yet performed) and unresolved boundary.
5. `DEV/docs/IMPLEMENTATION_STATUS.md` — distinguish created/tested script from operator probe not yet performed; backup and restore unverified.
6. `DEV/docs/CHANGELOG.md` — factual Task 013 entry.
7. `README.md` — only if needed to point to usage instructions or correct an inaccurate claim; avoid duplicating instructions otherwise.

All other files read-only. No modification of `AGENTS.md`, `.gitignore`, security tooling, hooks, workflows, prior tasks/reports, 1C files or operator's TEST folders. Never stage any runtime-generated data or binary files. Unrelated files stay untouched.

## 6. Required checks, documentation and publication

1. Reconcile actual script implementation and status with `README.md`, architecture, requirements, security, workflow, TEST safety, implementation status and changelog. Update affected allowed docs **in the same task**. Add a factual `CHANGELOG` entry. **Explicitly preserve** `FILE_LEVEL_BACKUP=UNVERIFIED`, `FILE_LEVEL_RESTORE=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, architecture `NOT_APPROVED`, product `NOT_IMPLEMENTED`, and `OPERATOR_PROBE=NOT_ATTEMPTED`.
2. Report must include `Status`, `AGENTS-first`, baseline and scope, sandbox scope evidence (or `UNVERIFIED`), script threat model, exact allowed files, parse/static test outcome, absence of any probe write by Codex, documentation reconciliation **matrix** (every canonical doc reviewed/changed/why/evidence/discrepancy), privacy review, publication gates, remote HEAD and CI state as knowable at report creation, limitations and next action. Report written before final commit; do not self-reference the future SHA.
3. Check script code statically and synthetically, `git diff --check`, `git diff --cached --check`, full staged diff, exact staged path list, UTF-8, local Markdown links, secrets/data/privacy manually.
4. Immediately before commit explicitly run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`; verify hooks path and allow hook to run. Before normal fast-forward push run `-Mode Outgoing` with the exact ref mapping; preserve pre-push hook. Never use `--no-verify`, `--force`, reset or rewrite history. If security checker rejects script, **stop BLOCKED**; do not bypass it or modify scanner to permit the artifact.
5. Verify remote `main`, published files and commit-specific CI. Mark CI `PASS` only for completed successful run for the final SHA; if pending/unavailable, report exact status. This task can be `SUCCESS` **for code delivery and static checks only**, not for the operator probe or backup.
6. No actual TEST backup/restore or application launch in Task 013. Do not start Task 014 automatically. Await independent ChatGPT audit, after which owner will run the one explicit `-RunProbe` command.

## 7. Final response format

```text
TASK=013_OPERATOR_FOLDER_WRITE_PROBE
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=95d6a5b4dba2751327b1228e82b02e097288191b
AGENTS_FIRST_READ=PASS/FAIL
CODEX_WRITE_SCOPE=RESTRICTED/UNRESTRICTED/UNVERIFIED
PROBE_SCRIPT=CREATED/NOT_CREATED
STATIC_CHECK=PASS/FAIL/UNVERIFIED
CODEX_PROBE_WRITE=NOT_ATTEMPTED
OPERATOR_PROBE=NOT_ATTEMPTED
FILE_LEVEL_BACKUP=UNVERIFIED
FILE_LEVEL_RESTORE=UNVERIFIED
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
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

**Stop safely if any requirement conflicts with the real execution environment. Never escalate access or attempt a TEST write in this task.**
