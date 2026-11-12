# TASK 003 — DOCUMENTATION GOVERNANCE AND AGENT DISCIPLINE

**Project:** `1c-elsi-invoice-upd-automation`  
**Repository:** `https://github.com/elvinazubairovna/1c-elsi-invoice-upd-automation`  
**Task file:** `DEV/tasks/003_DOCUMENTATION_GOVERNANCE.md`  
**Report file:** `DEV/reports/003_DOCUMENTATION_GOVERNANCE.md`  
**Verified baseline:** `origin/main` at `3221b386398bb65fbce005eef0d7e3cb20fe81f5` (Task 002, GitHub Actions success)  
**Decision authority:** ChatGPT is the architect and auditor; project owner approves material changes. Codex implements this task, does not independently decide architecture.

## 0. MANDATORY FIRST ACTION — READ AGENTS.md

**Before carrying out this task, modifying any files, running setup or build commands, or making technical decisions, read the complete root `AGENTS.md` and then read this complete task file.** Locating the project root and opening these two files are the only permitted preliminary actions. All existing rules in `AGENTS.md` remain mandatory. In case of an unclear or conflicting instruction, **stop (`BLOCKED`)** and report the conflict to the project owner for escalation to ChatGPT. Do not interpret missing requirements as permission to design a solution yourself.

For **every subsequent task**, the architect will also write an explicit mandatory `AGENTS.md` reading instruction in that task. This task must additionally enshrine the rule in the repository itself.

## 1. Goal and authoritative scope

Establish a reliable, auditable process under which **after each implemented task the project's documentation is reviewed and brought into agreement with the actual repository state before publication and task completion**. Prevent claims that features, tests or integrations exist when they have not been implemented or verified. Preserve the workflow: owner → ChatGPT (decisions, tasks, audit) → Codex (implementation, tests, report, safe push) → ChatGPT (acceptance or rework).

Also address one narrowly identified safety gap from Task 002: an explicitly staged `.env` / `.env.*` file must be blocked by the publication scanner regardless of whether its contents match known secret patterns. Only an exactly named, non-sensitive `.env.example` template may be eligible, subject to regular content checks.

This is a **process, documentation and existing publication-safety maintenance task**. **Do not implement any invoicing, UPD generation, 1C integration, UI, scheduler, storage model or business logic.** The architecture of the future 1C solution remains unapproved.

## 2. Baseline and preflight gates

1. Having read `AGENTS.md` and this task, inspect local Git state, current branch, remote `origin`, remote `main` SHA and pre-existing untracked or modified files. Do not discard, reset, rename or commit unrelated user changes.
2. Verify `origin` resolves to the named repository. Verify the expected base SHA above is an ancestor of the working baseline, and reconcile any intervening commits **read-only**. If unrelated remote changes or non-fast-forward conditions require a technical decision, stop and report `BLOCKED`; do not force-push or rewrite history.
3. Read the **current** versions of `README.md`, `.gitignore`, `AGENTS.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/reports/001_INIT_PROJECT.md`, `DEV/reports/002_SECURITY_AND_WORKFLOW.md`, `DEV/tools/Test-Publication.ps1`, `tests/security/Invoke-SecurityTests.ps1` and `.github/workflows/publication-security.yml`. These are the factual basis; do not rely on the previous answer's summary alone.
4. Confirm PowerShell 7 (`pwsh`) and Git are accessible, current hooks configuration remains intact and the existing security tests are operable. Do not reinstall tools or change global Git configuration.
5. Task file `DEV/tasks/003_DOCUMENTATION_GOVERNANCE.md` is user-provided and must remain verbatim. Do not include unrelated local copies of tasks or confidential examples in the commit.

## 3. Allowed paths to change

Modify **only** the following paths, provided they exist, plus create the specified new files:

- `AGENTS.md` — add binding documentation/governance requirements; preserve existing security rules.
- `README.md` — add concise pointers to the canonical documentation and the review rules.
- `DEV/docs/DEVELOPMENT_WORKFLOW.md` — define an enforceable documentation review phase in every task.
- `DEV/docs/CHANGELOG.md` — **new**, cumulative record of implementation/doc/process changes by task.
- `DEV/docs/IMPLEMENTATION_STATUS.md` — **new**, verified implementation status and explicit pending/unverified scope.
- `DEV/docs/TASK_TEMPLATE.md` — **new**, future task structure, with the `AGENTS.md`-first instruction and documentation acceptance gate.
- `DEV/tools/Test-Publication.ps1` — change only what is required for `.env` / `.env.*` path blocking.
- `tests/security/Invoke-SecurityTests.ps1` — add minimal isolated tests for the `.env` rule, including the allowed `.env.example` case.
- `DEV/tasks/003_DOCUMENTATION_GOVERNANCE.md` — this supplied task; copy/move to canonical location if needed **without editing its contents**.
- `DEV/reports/003_DOCUMENTATION_GOVERNANCE.md` — **new**, exact execution evidence.

Do **not** modify `DEV/tasks/001_*`, `DEV/tasks/002_*`, previous reports, 1C/user documents, `.github/workflows/`, hooks, `src/`, unrelated tests, or other files. If fulfilling the task safely requires an additional path or a larger design change, report it as `BLOCKED` instead of expanding scope.

## 4. Mandatory changes to AGENTS.md

Append an unambiguous, permanent section (e.g. `## Documentation maintenance — mandatory after every task`). It must include all the following **binding** rules; do not weaken existing clauses:

1. **Before starting any task:** fully read root `AGENTS.md` and the exact task file `DEV/tasks/NNN_TASK_NAME.md`. Check active repository state and scope after reading. Do not start with implementation based only on a chat message or old memory.
2. **Every completed task:** review documentation against the **actual changed files, behavior, tests, configuration and limitations**; update all affected canonical documents in the same task, before final commit and push. Do not defer documentation to another task without explicit written authorization from ChatGPT.
3. **Always update `DEV/docs/CHANGELOG.md`** with a concise entry for a completed task (including process/docs-only tasks) that names its task ID, factual changes, relevant checks and any current limitation. Historical entries for Tasks 001 and 002 may be added based only on their actual published reports; clearly label these as retrospectives.
4. **Maintain `DEV/docs/IMPLEMENTATION_STATUS.md` as the current source of truth:** what has been implemented and validated, what is not implemented, what is still unverified or blocked, and the authoritative evidence/task references. Do not confuse “planned”, “coded”, “locally tested”, “CI passed” and “production-ready”. Update after each task to reflect actual status; if no status category changed, re-check it and say so explicitly in the task report.
5. **Review all affected documentation** (`README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, plus future canonical docs) and correct contradictions between text and implementation. Do not make undocumented technical decisions while resolving a discrepancy: ask the architect. Avoid redundant competing descriptions; use links to canonical source documents.
6. Every report in `DEV/reports/NNN_TASK_NAME.md` must contain a **`Documentation reconciliation`** section listing: docs inspected; docs updated with the reason; docs deliberately left unchanged with reason; any discovered contradiction and its resolution (or `BLOCKED`); how claims were verified. A report cannot declare `SUCCESS` with outstanding contradictions related to that task.
7. A task may be declared `SUCCESS` only when approved implementation/tests **and** mandatory docs updates/checks are complete, security gates pass and publication is confirmed; `SUCCESS` is still *not* architect acceptance. On `PARTIAL`, record what is actually true and what remains; on `BLOCKED` before changes, do not invent changelog entries or claim docs were updated.
8. Reconciliation must use **non-sensitive** file names, test results and pseudodata only; do not leak real counterparties, actual contract data, invoices, tax IDs, private paths, or secrets into documentation/reports.
9. Preserve the established final-result and audit process from Task 002. Codex must not assign `ACCEPTED` to itself or start another task.

## 5. DEV/docs/DEVELOPMENT_WORKFLOW.md

Extend the existing workflow rather than replacing it. Define an explicit stage **after implementation/testing but before report/commit**:

1. Compare the task requirements and actual diff to the canonical documentation.
2. Update docs that describe changed behavior, configuration, safety limits and user-facing procedures.
3. Update `CHANGELOG.md` for the current completed task and synchronize `IMPLEMENTATION_STATUS.md` with verified evidence.
4. Check for contradictions: require a traceable chain `task → implementation → tests → documentation → report`. If a claim lacks evidence, label it `UNVERIFIED`/`NOT_IMPLEMENTED` rather than asserting success.
5. Include the `Documentation reconciliation` matrix in the report.
6. If required documentation is inconsistent, do not `push` or claim `SUCCESS` until fixed. If correction needs an architectural decision, stop and raise `BLOCKED`.

Explain that a blocked task that changes nothing may need only a truthful report, rather than inventing a successful changelog entry. The latest docs are published together with the applicable changes, not later as a separate untracked promise.

## 6. DEV/docs/CHANGELOG.md

Create a lightweight Markdown task-based history, not a generic product release history. Required entries:

- `001_INIT_PROJECT` — retrospective, based on the published Task 001 report; project skeleton and initial docs only.
- `002_SECURITY_AND_WORKFLOW` — retrospective, based on the published Task 002 report and successful CI; local hooks, publication scanner, tests, GitHub Actions, documented limitations. Do not claim absolute security.
- `003_DOCUMENTATION_GOVERNANCE` — current task's *actual* changes and validation, with an explicit indication if any part is unverified.

For new tasks, prepend a dated (if reliably available) entry. Include task ID, concise factual outcome, evidence reference (`DEV/reports/NNN_...md`), affected core documents and known limitations. Do not write future tasks as though completed. A retrospective entry must be distinguishable from live implementation facts.

## 7. DEV/docs/IMPLEMENTATION_STATUS.md

Create a small, durable source of truth with at least these sections:

- **Verified baseline** — latest task and Git reference known when authoring (do not fabricate self-referential commit SHA).
- **Implemented and verified** — Git repository initialization, documentation structure, publication safety scanner, hooks, tests and CI *only to the extent evidenced in published Task 001/002 and any actually run Task 003 tests*.
- **Limitations** — heuristics of publication scanning; GitHub Actions checks run after push, so cannot undo initial disclosure; manual review remains necessary; local hooks are bypassable.
- **Not implemented / not approved** — 1C integration architecture, invoice/UPD generation, business rule engine, database, delivery channels, production operation.
- **Documentation ownership / workflow** — where to find canonical requirements, architecture, security, workflow and changelog; each task is responsible for keeping them accurate.
- **Evidence** — links to project-local reports, tasks and test commands, avoiding claims beyond actual verification.

Use stable relative links. Never put actual accounting amounts/partners/contracts from private sample data into this public file.

## 8. DEV/docs/TASK_TEMPLATE.md

Create a reusable Markdown template for the architect (ChatGPT) and owner. It must include the following explicit opening instruction, not just a link:

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

Template sections: task identifier, checked base SHA and branch, goal, confirmed requirements, allowed files, forbidden actions, implementation steps, privacy/security requirements, testing, **mandatory documentation reconciliation**, acceptance gates, report format, Git publication and stop conditions. State that the architect is responsible for preparing each future task file and must copy the explicit AGENTS-first instruction verbatim. The template is guidance, not authority to make new technical decisions.

## 9. Narrow security correction for `.env`

Strengthen `Test-PathPolicy` in `DEV/tools/Test-Publication.ps1`:

- Reject files with the basename `.env` or `.env.*`, **case-insensitively and at any nesting depth**, in Index, Tracked and Outgoing modes, even if force-added and even if contents are harmless-looking.
- **Sole allowed name exception:** basename is exactly `.env.example` (case-insensitive); the file must still pass all existing content/encoding/path checks. Do not allow `.env.example.local` or other derived names.
- Do not change global scanning decisions, relax any current rules, print secret content or silently add arbitrary allowlists.
- Extend isolated security tests with deterministic synthetically named cases: force-added `.env`, a nested `.ENV.production`, `.env.example.local` must FAIL; safe `.env.example` must PASS. Test each without modifying the real project's Git index. Preserve the existing 15 tests and existing safety outcomes.
- If a safe `.env.example` content is accidentally rejected by an unrelated existing high-confidence secret rule, document it and stop rather than weakening that rule without architectural approval.

This correction **does not claim comprehensive secret detection**. Keep SECURITY documentation consistent if any documented behavior changes: `DEV/docs/SECURITY.md` is **not** in the permitted write set for this task, because the current description already warns about scanner limitations and does not promise `.env` scanning specifically. If that assumption proves false, stop and ask for expanded scope; do not silently edit it.

## 10. Required tests and independent checks

1. PowerShell AST parse: `DEV/tools/Test-Publication.ps1` and `tests/security/Invoke-SecurityTests.ps1` — PASS.
2. Full isolated suite: `pwsh -NoProfile -File tests/security/Invoke-SecurityTests.ps1` — PASS, baseline 15 tests plus the newly mandated cases. Report exact total, not a guessed number.
3. Security scan: `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` — PASS before commit. Execute existing pre-push/Outgoing security check with correct Git ref input before publication; hooks must remain active.
4. Confirm no unapproved paths are staged. Run `git diff --cached --name-only` and inspect `git diff --cached` for confidential data and inadvertent text changes. `git diff --cached --check` must pass on newly authored files; if an untouched user-provided task has inherited formatting issues, identify them honestly rather than editing the task.
5. Documentation review: manually verify `AGENTS.md`, workflow, template, changelog, implementation status and README agree with one another and with evidence from the actual source/test results. In the report present a table with document, reviewed, changed, reason, factual verification, discrepancies.
6. Run the repository's existing hook checks; do not alter `core.hooksPath` or reinstall hooks unless diagnostics show missing expected settings and the owner explicitly approves a repair.
7. Confirm the published GitHub Actions workflow for the final task commit, if observable. Treat `PENDING` as `PENDING`; do not report `CI=PASS` without a completed successful run.

No external package installation, new dependencies, internet upload outside GitHub, live 1C access or real-doc processing is permitted.

## 11. Report and publication

Create `DEV/reports/003_DOCUMENTATION_GOVERNANCE.md` **before the final commit**, with sections:

- `Status` (`SUCCESS` / `PARTIAL` / `BLOCKED` / `FAILED`), base SHA and worktree baseline.
- `Changed files`, including verification that no unrelated changes were staged.
- `Agent rules` — which specific mandatory clauses were added to `AGENTS.md`.
- `Documentation reconciliation` — the detailed reviewed/changed/evidence/discrepancy matrix; verify docs describe only implemented realities.
- `Security correction` — `.env` behavior and tests, including allowed template.
- `Checks and tests` — exact commands, PASS/FAIL counts, limitations.
- `Git` and `CI` — known pre-report commit SHAs, final publication verification, CI status if known, report URL.
- `Deviations`, `unresolved questions`, `blockers`.

**Never put a not-yet-existing SHA of the commit containing the report into the report.** Report final remote `HEAD` SHA separately in the response to the owner; do not introduce extra commits solely to amend a self-referential report SHA.

Commit and push only after review/security checks pass; preserve the existing history, use `origin/main`, no force push. Then verify remote SHA and that the final report and docs are accessible in GitHub. If anything cannot be safely confirmed, report `BLOCKED`/`PARTIAL` rather than inventing success. Do not execute Task 004.

Final message to project owner should be:

```text
TASK=003_DOCUMENTATION_GOVERNANCE
STATUS=...
BASE_SHA=...
AGENTS_FIRST_READ=PASS/FAIL
DOCS_SYNC=PASS/FAIL
CHANGELOG=PASS/FAIL
IMPLEMENTATION_STATUS=PASS/FAIL
ENV_GUARD_TESTS=PASS/FAIL
SECURITY_TESTS=PASS (N/N) / FAIL
INDEX_CHECK=PASS/FAIL
OUTGOING_CHECK=PASS/FAIL
HOOKS=PASS/FAIL
CI=PASS/FAIL/PENDING/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=...
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

## 12. Hard stop conditions

- Missing, unreadable or conflicting `AGENTS.md` or task file.
- Unexpected Git history, unsafe remote state, unreviewed changes, unapproved paths.
- Any need to choose an unapproved architecture or weaken existing security.
- Any evidence of real financial/personal data, secret material or private content entering a commit.
- Any required check fails, docs contradict actual behavior, or CI result is asserted without evidence.

**Do not start another task. Do not change the 1C application. Do not publish real business data.**
