# TASK 004 — 1C_ENVIRONMENT_DISCOVERY

> **MANDATORY FIRST ACTION:** Before doing any work for this task, fully read the repository root `AGENTS.md`, then read this task file. If either is inaccessible or conflicts with this task, stop and report `BLOCKED`; do not implement based on assumptions.

## 1. Ownership and verified baseline

- **Task ID:** `004_1C_ENVIRONMENT_DISCOVERY`
- **Repository:** `elvinazubairovna/1c-elsi-invoice-upd-automation`
- **Target branch:** `main`
- **Expected base HEAD:** `437226191c6e467f4c43a7134d5431c834709be3`
- **Baseline:** checked against remote `origin/main` by ChatGPT before issuing this task. Confirm again using Git before making changes.
- **Decision authority:** ChatGPT as architect and auditor; owner approves material actions.
- **Executor:** Codex. Do not independently select an architecture or integration technology.
- **Status of previous task:** Task 003 accepted by architect. Do not reinterpret or change its implementation.

## 2. Goal and boundaries

Produce a safe **read-only technical feasibility inventory** for future automation of monthly invoices and universal transfer documents (UPD) in 1C:Accounting. Establish which facts about the **actual deployment** are confirmed versus unknown; research **official publicly accessible vendor documentation** describing potential integration mechanisms and their access restrictions. Produce a concise decision dossier for ChatGPT to select the architecture in a **later task**.

This is **discovery and documentation only**. **Do not implement any 1C functionality**, create prototype connections, install tools, deploy extensions, call 1C APIs, access production accounting data, or change application settings.

The owner has previously discussed using cloud-hosted 1C (1C:Fresh). Treat that as an **owner-stated lead, not verified fact about this computer or organization**. The true product, delivery model, configuration, version, privileges and eligibility for any integration remain `UNVERIFIED` until supported by explicit non-sensitive evidence. A lack of local 1C executables does **not** imply cloud access is unavailable.

## 3. Allowed and prohibited paths

**Allowed to create/modify:**

- `DEV/tasks/004_1C_ENVIRONMENT_DISCOVERY.md` — user-supplied task; preserve the entire original text verbatim.
- `DEV/reports/004_1C_ENVIRONMENT_DISCOVERY.md` — exact report for Task 004.
- `DEV/docs/1C_ENVIRONMENT_DISCOVERY.md` — new, canonical, sanitized discovery dossier.
- `DEV/docs/CHANGELOG.md` — factual Task 004 entry if work is completed.
- `DEV/docs/IMPLEMENTATION_STATUS.md` — evidence-based discovery status; no claim that architecture or integration is implemented.
- `README.md` — only a short link to the new discovery dossier, if needed to keep documentation navigable.

**Read-only review:** `AGENTS.md`, `DEV/docs/TASK_TEMPLATE.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, earlier tasks/reports, Git metadata, approved public vendor documentation and non-sensitive local command outputs.

**Forbidden:** modifications to `AGENTS.md`, scanners, hooks, workflows, `src/`, `tests/`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, configuration files or any files outside the allowed list. If a contradiction requires modification outside this list, **stop `BLOCKED` and request an authorized task amendment**; do not quietly widen scope.

## 4. Mandatory privacy and production isolation

1. This is a **public GitHub repository**. Never add real invoices, UPDs, contract terms, actual amounts, counterparties, addresses, identifying account/user data, real database names, tenant URLs, application URLs with identifiers, screenshots from accounting systems, real configuration exports, or credentials. Do not include local full paths, usernames, server addresses, environment variable contents, installation IDs, organization identifiers, licence/registration numbers, or authentication artifacts in any published report.
2. Only inspect **known files in the repository** and **minimal harmless local capability indicators** (operating-system family, PowerShell version, availability/version of `git`, and whether documented 1C tooling is discoverable by its command name). Do not recursively search the user's disk, registry, profile, browsers, credential stores, system services, or unrelated projects. No process inventory, no screen capture, no installation changes.
3. Never attempt login, launch a 1C session, connect to the organization's 1C tenant, contact its API/OData endpoints, read an information base, or open company accounting records — even for a purported read-only probe. Do not request or process credentials, database exports, screenshots, sample invoices or URLs containing tenant identifiers.
4. If product version, platform, subscription, or role information is unavailable, label it `UNKNOWN / OWNER_CONFIRMATION_REQUIRED` and list the minimal **safe, manually answerable** questions for the owner. Never infer privileges or availability from marketing material.
5. Public documentation retrieval is permitted solely for general vendor references. Do not send project files, environment details, business names, or user information to search services. When network access to public sources is unavailable, mark `PUBLIC_DOCS_UNVERIFIED` and do not substitute speculation.
6. All records and examples must be synthetic; no factual claims about real tenant capabilities without evidence. Avoid accidentally publishing secrets through tool output, command failures, errors, or redirections.

## 5. Required execution stages

### Stage A — repository and capability preflight (read-only)

1. Fully read `AGENTS.md`, then this task. Inspect `git status --short`, `git branch --show-current`, `git rev-parse HEAD`, configured remote (report only whether it matches, **do not copy credential-bearing URLs**), and `git ls-remote` or a similarly safe remote HEAD check.
2. Ensure expected branch and base SHA. Preserve every unrelated local/untracked file (including any older long-named Task 001 file); never add it to the index. If HEAD diverged, histories conflict or unrelated work cannot be protected, `BLOCKED`.
3. Report only sanitized local environment facts: OS family (Windows/other), availability of PowerShell 7, Git, and local 1C development commands **if discoverable without wider scanning**. No installation or upgrades. Be explicit that missing local tooling is not proof that a cloud deployment cannot be automated.
4. Read current canonical project docs and confirm no actual 1C technical implementation or integration mechanism has been approved.

### Stage B — official vendor documentation research (no tenant access)

Review these **public** official references, if accessible, recording the **actual page title/URL and access date**. Distinguish publicly documented possibilities from eligibility in this specific deployment:

- `https://www.1cfresh.com/articles/faq_app` — application FAQ; includes discussion of standardized integration interface (OData). Verify the exact conditions from the source, not assumptions.
- `https://www.1cfresh.com/articles/faq_dev` — adaptation, extension and external processing developer guidance; read restrictions and publication/audit process.
- `https://www.1cfresh.com/articles/so_addprocess` — authorization model for developers/service organizations for adding client extensions and processing.
- `https://www.1cfresh.com/articles/work_addprocess` — how a subscriber requests adaptation through its servicing organization.
- `https://its.1c.ru/db/content/fresh/src/index.html` — vendor overview of cloud integration mechanisms; some details may require access.
- `https://dev.1cfresh.com/` — extension catalog; do not mistake a commercial catalog entry for ability to publish a custom extension.

For each technically relevant option, make a **neutral evidence table** with columns:

`Option | Vendor reference | Publicly documented capability | Preconditions/restrictions | Evidence for THIS tenant | Unknowns | Security/operational concerns`

At minimum distinguish:

A. Standard built-in 1C document functionality / manual or semi-manual operations.

B. Approved additional processing or configuration extensions for 1C:Fresh, subject to publisher authorization and review when applicable.

C. Standard data interface such as OData, subject to publication/permissions/authentication and applicable account restrictions.

D. Local client/information-base automation **only if a local 1C deployment is confirmed**. Do not assume a local installation exists.

E. External automation or import/export as a *potential* mechanism, with no assumption that endpoints, permissions, files, or external access exist.

These are **comparison categories, not approved solutions**. Do **not** select or rank a preferred architecture, invent endpoints or credentials, claim an integration is available, or suggest bypassing cloud restrictions.

### Stage C — factual gap analysis

Create a short table separating:

- `CONFIRMED_FROM_REPOSITORY`
- `CONFIRMED_FROM_OFFICIAL_PUBLIC_DOCS`
- `OWNER_STATED_BUT_NOT_INDEPENDENTLY_VERIFIED`
- `UNKNOWN / REQUIRES_OWNER_CONFIRMATION`
- `NOT_PERMITTED_TO_PROBE`

Draft a **minimal, non-sensitive owner checklist** for ChatGPT to ask **after the task**. Include, only as appropriate:

- Exact commercial product name: 1C:Accounting and edition/version, as displayed in the application's About window (text only; avoid tenant identifiers).
- Deployment: 1C:Fresh cloud, another cloud host, or local information base.
- Platform/configuration version numbers (without server/database identifiers).
- Type of access/role relevant to adding reports/extensions or integrations (generic privilege category, no login).
- Whether the serving organization supports uploading audited custom add-ons; `UNKNOWN` until confirmed.
- Whether any test information base exists with only synthetic data. Never ask to export a real database.
- Whether the user can manually inspect the presence of relevant built-in integrations; do not send them on a risky settings tour or require credential disclosure.

Describe exactly **what remains impossible to decide** without these owner inputs. No business requirement or architectural decision is authorized at this point.

### Stage D — sanitized canonical discovery file

Create `DEV/docs/1C_ENVIRONMENT_DISCOVERY.md` containing:

1. `Purpose and scope` (read-only, no account access).
2. `Evidence register` with stable identifiers (`E01`, `E02`, ...), source type, official URL (public only), observed date, claim and confidence.
3. `Environment facts and unknowns` (no actual tenant/company identifiers).
4. `Possible integration paths — NOT APPROVED` with the evidence table from Stage B.
5. `Privacy and access boundaries`.
6. `Owner confirmation checklist` (non-sensitive and small).
7. `Decision gate for architect` (what evidence ChatGPT needs before any design/prototype task).
8. `Not implemented and not verified` statement; explicit prohibition on interpreting this report as production authorization.

Where public source access is denied or outdated, mark `UNVERIFIED` and note it. Do not imply Codex tested anything in 1C.

### Stage E — documentation reconciliation

After the discovery work, and **before** preparing the report/commit:

1. Compare the actual diff and findings with `README.md`, `DEV/docs/ARCHITECTURE.md`, `DEV/docs/REQUIREMENTS.md`, `DEV/docs/SECURITY.md`, `DEV/docs/DEVELOPMENT_WORKFLOW.md`, `DEV/docs/CHANGELOG.md`, `DEV/docs/IMPLEMENTATION_STATUS.md` and other relevant canonical files.
2. Keep the architectural status as `NOT_APPROVED` and functionality as `NOT_IMPLEMENTED`. **Discovery is not implementation.** Correct only allowed documentation files, and do not invent confirmations.
3. Add a factual Task 004 entry to `CHANGELOG.md` with evidence/unknowns; update `IMPLEMENTATION_STATUS.md` to reflect completed discovery only and cite the new dossier/report. If status of application implementation did not change, say explicitly so in the report.
4. Review links and avoid competing or contradictory statements. If a contradiction needs an edit outside allowed scope or an architectural decision, stop `BLOCKED`.
5. In the Task 004 report include a **`Documentation reconciliation`** matrix: document, reviewed, modified or unchanged with reason, evidence, discrepancy and resolution.

## 6. Checks and acceptance gates

Require all applicable checks, providing commands/results without sensitive output:

- [ ] Correct `AGENTS.md`-first read and exact task read before any work.
- [ ] Branch and base SHA verified; no unrelated user files altered or staged.
- [ ] Public sources correctly attributed; inaccessible pages marked `UNVERIFIED`; tenant-specific claims not inferred.
- [ ] Discovery document created with confirmed/unknown separation and no actual company data.
- [ ] Zero 1C sessions, API requests, application changes, extension uploads, deployments, source-code changes or real business data processing.
- [ ] Changelog/status/README reconciled; architecture remains unapproved; implementation remains unimplemented.
- [ ] Markdown links/relative paths reviewed, UTF-8 and formatting checked.
- [ ] `git diff --check` for **authored changes**; if verbatim user-supplied task formatting alone triggers whitespace warnings, preserve the source, isolate and report honestly. Do not weaken checks.
- [ ] Inspect staged path list and staged diff **manually**; `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index` returns PASS.
- [ ] Ensure local hooks remain configured and their status is recorded without changing configuration.
- [ ] Before push, perform the manual `Outgoing` check with the exact pre-push ref pair(s); ensure pre-push hook runs. Do not bypass hooks.
- [ ] Commit only allowed files; ordinary fast-forward push to `origin/main`; confirm remote HEAD and published task/report/docs. **No force push**.
- [ ] Look up commit-specific GitHub Actions status. Report `CI=PASS` **only** if the run is confirmed completed and successful; otherwise `PENDING`, `FAIL` or `UNVERIFIED` as justified.
- [ ] Do not start Task 005.

If the owner has not yet confirmed details of their actual 1C installation, task may still be `SUCCESS` **for its narrow public-research and inventory deliverables**, but mark tenant readiness `UNKNOWN` and list the blockers to **future architecture selection**. Do not confuse documentation success with production readiness.

## 7. Report

Create `DEV/reports/004_1C_ENVIRONMENT_DISCOVERY.md` **before the final commit** with:

- `Status`: `SUCCESS`, `PARTIAL`, `BLOCKED` or `FAILED` and meaning.
- `Initial state`: expected/observed SHA, branch, untracked user files treated safely.
- `Public source verification`: each public URL checked, accessed or inaccessible, date, evidence notes; no tenant data.
- `Environment and capability findings`: factual results, safe unknowns, reasons probing was not attempted.
- `Integration comparison`: neutral options with explicit unapproved/unverified state.
- `Documentation reconciliation`: detailed matrix.
- `Security and tests`: safety checks, path lists, success/failure, no secrets or actual data.
- `Git publication`: known SHA(s) as of report creation, remote verification and CI to be confirmed after publish; **do not invent the SHA of the commit containing this report**.
- `Open questions for owner and architect` and `Next permitted action`.

After the final push, respond to the owner in exactly this compact status schema (one line per field):

```text
TASK=004_1C_ENVIRONMENT_DISCOVERY
STATUS=SUCCESS/PARTIAL/BLOCKED/FAILED
BASE_SHA=...
AGENTS_FIRST_READ=PASS/FAIL
ENVIRONMENT_INVENTORY=PASS/PARTIAL/BLOCKED
PUBLIC_VENDOR_RESEARCH=PASS/PARTIAL/UNVERIFIED
TENANT_ACCESS=NOT_ATTEMPTED
TENANT_DETAILS=UNKNOWN/OWNER_CONFIRMED
DOCS_SYNC=PASS/FAIL
SECURITY_CHECK=PASS/FAIL
INDEX_CHECK=PASS/FAIL
OUTGOING_CHECK=PASS/FAIL
HOOKS=PASS/FAIL
CI=PASS/FAIL/PENDING/UNVERIFIED
GITHUB_PUSH=SUCCESS/BLOCKED
REMOTE_HEAD_SHA=...
REPORT_URL=...
BLOCKERS=...
OWNER_QUESTIONS=...
NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT
```

## 8. Hard stop conditions

Stop and report `BLOCKED` rather than improvising if any of these occurs:

- `AGENTS.md` or task cannot be read or conflicts; Git branch/base/remote unexpected; unrelated state at risk.
- Any proposal requires accessing real 1C data, logging into a tenant, reading local secrets, installing tools, changing settings or using live APIs.
- Real customer/accounting information would enter a tracked file or report.
- Required modification extends beyond authorized paths, or an architectural decision is needed.
- Local security gate or outgoing check fails; Git publication cannot be confirmed safely.

**Do not touch the 1C application. Do not develop business functionality. Do not begin Task 005. Await ChatGPT audit.**
