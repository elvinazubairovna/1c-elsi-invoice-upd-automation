# Статус реализации

Этот документ фиксирует подтверждённое состояние проекта; он не является планом реализации.

## Verified baseline

- Последний проверенный опубликованный baseline до Task 006: `main` на `b7c1637ccb67dab6026548166fa3824f9d9cd92c` (Task 005); local/remote совпали при preflight Task 006.
- В отчёте Task 005 CI для итогового SHA подтверждён успешным Actions run; CI для новых commits проверяется отдельно.

## Implemented and verified

- **Project skeleton and initial documentation:** подтверждены [отчётом 001](../reports/001_INIT_PROJECT.md) и опубликованным Task 001.
- **Publication safety tooling:** `Index`, `Tracked`, `Outgoing`, локальные hooks, изолированные тесты и workflow описаны в [отчёте 002](../reports/002_SECURITY_AND_WORKFLOW.md). Task 002 tests завершались 15/15 локально; Actions успешно прошёл для опубликованного baseline Task 002.
- **Environment-file path rule (Task 003):** basename `.env` и `.env.*` запрещён независимо от содержимого; точное имя `.env.example` разрешается к обычным проверкам. В задаче добавлены тесты для `Index`, `Tracked`, `Outgoing` и допустимого шаблона. Итоговый локальный счёт тестов и CI задачи 003 приведён в [отчёте 003](../reports/003_DOCUMENTATION_GOVERNANCE.md); CI — отдельный commit-specific статус.
- **Documentation governance (Task 003):** `AGENTS.md`, workflow, task template, changelog и этот status document задают и отражают сверку документов после каждой завершённой задачи. Архитектурная приёмка остаётся ответственностью ChatGPT.

## Limitations

- Publication scanner использует эвристические текстовые проверки и не гарантирует обнаружение всех персональных данных, секретов, обфускаций и будущих форматов.
- Неизвестные бинарные данные и неподдерживаемые кодировки блокируются до отдельного разрешения. Ручной аудит staged diff и каждого outgoing-коммита обязателен.
- GitHub Actions запускается после публикации и не может отменить первое раскрытие в публичном репозитории.
- Локальные Git hooks можно отключить или обойти; перед commit/push обязательны ручные команды из `AGENTS.md`.
- Успешные локальные тесты не означают, что интеграция production-ready или что GitHub Actions завершился успешно для любого будущего коммита.

## Not implemented / not approved

- Архитектура интеграции с 1С не утверждена.
- Не реализованы генерация счетов/УПД, бизнес-правила, база данных/модель хранения, пользовательский интерфейс, планировщик, доставка документов, интеграции с ЭДО, почтой или мессенджерами.
- Production operation не подтверждена.

## Documentation ownership / workflow

- Подтверждённые требования: [REQUIREMENTS](REQUIREMENTS.md).
- Решения и ограничения архитектуры: [ARCHITECTURE](ARCHITECTURE.md).
- Политика безопасности: [SECURITY](SECURITY.md).
- Процесс разработки и аудита: [DEVELOPMENT_WORKFLOW](DEVELOPMENT_WORKFLOW.md).
- История выполненных задач: [CHANGELOG](CHANGELOG.md).
- Каждая задача сверяет эти документы с реальным diff, тестами, конфигурацией и ограничениями и публикует все затронутые документы вместе с изменением.

## Evidence

- [Task 001](../tasks/001_INIT_PROJECT.md), [report 001](../reports/001_INIT_PROJECT.md).
- [Task 002](../tasks/002_SECURITY_AND_WORKFLOW.md), [report 002](../reports/002_SECURITY_AND_WORKFLOW.md), [successful Task 002 Actions run](https://github.com/elvinazubairovna/1c-elsi-invoice-upd-automation/actions/runs/43248306231).
- [Task 003](../tasks/003_DOCUMENTATION_GOVERNANCE.md), [report 003](../reports/003_DOCUMENTATION_GOVERNANCE.md); exact commands and results are recorded there.

## Task 004 — environment discovery (retrospective)

- Публичное исследование и локальная read-only инвентаризация: [dossier 004](1C_ENVIRONMENT_DISCOVERY.md) и [report 004](../reports/004_1C_ENVIRONMENT_DISCOVERY.md). Общие механизмы вендора изучены; tenant-specific eligibility `UNKNOWN / OWNER_CONFIRMATION_REQUIRED`.
- Implementation status: discovery documentation only. Architecture remains `NOT_APPROVED`; invoice/UPD generation and every 1C integration remain `NOT_IMPLEMENTED`. No tenant access or live verification occurred.
- Published Task 004 commit: `main` at `70e754b8ce61258de370443b0057a6bf2369fc18`; CI status was `UNVERIFIED` in report 004.

## Task 005 — local capability assessment

- Owner-reported only: «Бухгалтерия предприятия» 3.0, configuration `3.0.208.14`, platform `8.5.1.1343`, local file information base, thin client. These details were not independently verified; see [assessment](LOCAL_1C_CAPABILITY_ASSESSMENT.md) and [report 005](../reports/005_LOCAL_1C_CAPABILITY_ASSESSMENT.md).
- This task adds documentation only. Architecture remains `NOT_APPROVED`; invoices/UPD generation and all 1C integration remain `NOT_IMPLEMENTED`. No production database access or 1C session occurred.

## Task 006 — test environment safety baseline

- Владелец сообщает о создании и ручном запуске отдельной TEST-базы и сохранении синтетической организации (`OWNER_REPORTED`); до её справочника ранее существовали записи неизвестного происхождения. См. [safety baseline](TEST_ENVIRONMENT_SAFETY.md) и [report 006](../reports/006_TEST_ENVIRONMENT_SAFETY_BASELINE.md).
- Codex не открывал TEST или PRODUCTION. Права, полная синтетичность, отсутствие нежелательных интеграций и изоляция не проверены. Резервная копия и восстановление `RESTORE_UNVERIFIED`; доступ и `.epf` `NOT_ATTEMPTED`.
- Продуктовая реализация не изменилась: архитектура `NOT_APPROVED`, генерация счетов/УПД и интеграция `NOT_IMPLEMENTED`; live tests не разрешены.

## Task 007 — test backup and restore

- Статический preflight остановлен на эксклюзивной read-only проверке из-за `TEST_SESSION_NOT_CONFIRMED_CLOSED`; работу сеансов и процессов не исследовали.
- Файловые копия и восстановление `NOT_ATTEMPTED`; `APPLICATION_RESTORE=NOT_ATTEMPTED`; `RESTORE_UNVERIFIED`. Архитектура `NOT_APPROVED`, продуктовая реализация `NOT_IMPLEMENTED`. См. [report 007](../reports/007_TEST_BACKUP_AND_RESTORE.md).

## Task 008 — retry test backup and restore

- Точный TEST path preflight и начальный exclusive read-only check прошли. Разрешённая локальная file-copy операция вернула ошибку до проверки инвентарной parity; backup `FAIL` / completion `UNVERIFIED`, restore `NOT_ATTEMPTED`.
- Во время Task 008 возможные частичные локальные артефакты не инспектировались, не изменялись и не удалялись; немедленная post-copy проверка исходника/idle была `NOT_ATTEMPTED`. Task 009 позднее проверила только metadata двух точных target-каталогов и обнаружила их отсутствующими; см. [report 008](../reports/008_RETRY_TEST_BACKUP_RESTORE.md) и [report 009](../reports/009_DIAGNOSE_TEST_BACKUP_FAILURE.md).
- `APPLICATION_RESTORE=NOT_ATTEMPTED`; TEST permissions, `.epf`, integrations и production readiness `UNVERIFIED`; architecture `NOT_APPROVED`, product `NOT_IMPLEMENTED`.

## Task 009 — diagnose TEST backup failure

- Read-only metadata checks found the exact TEST source and standard database file present and stable across two metadata snapshots; the two exact Task 008 destination directories were absent. Metadata parity is `NOT_APPLICABLE`; current free space meets the two-copy-plus-reserve rule.
- These observations do not establish source byte integrity after Task 008 or the historical error cause. `ROOT_CAUSE=UNDETERMINED`; `SOURCE_INTEGRITY_AFTER_008=UNVERIFIED`; no backup/restore or application recovery is validated. See [report 009](../reports/009_DIAGNOSE_TEST_BACKUP_FAILURE.md).
- Status categories for product, architecture and readiness did not change: architecture `NOT_APPROVED`, product `NOT_IMPLEMENTED`, restore `UNVERIFIED`.

## Task 010 — instrumented TEST backup and restore

- Fresh P0 checks passed for the exact TEST boundary, metadata stability, exclusive read-only idle check, absent new target names and capacity. The overall preflight was `BLOCKED` because integration/exchange risk remains `UNVERIFIED`; policy does not allow assuming it away or inspecting prohibited settings/processes.
- No source digests, destination directories, backup or restored copy were created. `LAST_COMPLETED_PHASE=NONE`; `FAILED_PHASE=P0_PREFLIGHT` (safety gate, no runtime exception); file-level backup/restore and final source validation remain `NOT_ATTEMPTED`. See [report 010](../reports/010_INSTRUMENTED_TEST_BACKUP_RESTORE.md).
- Product, architecture and readiness categories did not change: architecture `NOT_APPROVED`, product `NOT_IMPLEMENTED`, integration risk `UNVERIFIED`, restore `UNVERIFIED`.

## Task 011 — offline TEST backup and restore

- The task-specific offline-only exception was applied; integrations remain `UNVERIFIED` and no 1C application operation was authorized. Fresh P0 boundary, source metadata/stability, exclusive idle, target absence and capacity checks passed. P1 computed source digests in memory.
- P2 failed with `FAILURE_CATEGORY=UNCLASSIFIED`. The backup target status is `UNVERIFIED`; it was not inspected or cleaned. Restore target was not created; P3–P8 were not attempted. `FILE_LEVEL_BACKUP=FAIL`, `FILE_LEVEL_RESTORE=NOT_ATTEMPTED`, `SOURCE_FINAL=NOT_ATTEMPTED`; see [report 011](../reports/011_OFFLINE_TEST_BACKUP_RESTORE.md).
- Integration risk remains `UNVERIFIED` for all 1C application/outbound activity; product remains `NOT_IMPLEMENTED`, architecture `NOT_APPROVED`.

## Task 012 — diagnose TEST directory creation

- Read-only exact-item checks confirmed `_BACKUP_011=ABSENT` at Task 012 time. This does not determine whether it existed briefly after Task 011; the historical Task 011 backup state remains `UNVERIFIED` and its `FILE_LEVEL_BACKUP=FAIL` is unchanged.
- D0–D2 boundary and exact probe absence checks passed. The single authorized D3 attempt to create `_DIR_PROBE_012` failed with `ERROR_CATEGORY=UNCLASSIFIED`; the one permitted post-error metadata lookup found the probe `ABSENT`. No retry, cleanup, file access, backup, restore, 1C operation or production access occurred. `DIR_CREATE=FAIL`; file-level backup/restore and application restore are `NOT_ATTEMPTED` in Task 012. See [report 012](../reports/012_DIAGNOSE_TEST_DIRECTORY_CREATION.md).
- No product, architecture or application-readiness status changed: architecture `NOT_APPROVED`, product `NOT_IMPLEMENTED`, integrations `UNVERIFIED`, restore `UNVERIFIED`.

## Task 013 — operator folder write probe

- Добавлен операторский PowerShell-скрипт с отдельным `-RunProbe`; после его независимого аудита владелец сообщил об успешном создании одного пустого каталога (`OWNER_REPORTED_PASS`). Codex не проверял этот runtime результат; он не подтверждает backup, restore или права Codex. См. [report 013](../reports/013_OPERATOR_FOLDER_WRITE_PROBE.md).
- Архитектура остаётся `NOT_APPROVED`, продуктовая функциональность `NOT_IMPLEMENTED`; production readiness не подтверждена.

## Task 014 — operator offline TEST backup tool

- Добавлен операторский PowerShell 7 tool `DEV/tools/Invoke-ELSI-TestBackupDrill.ps1` с явным `-RunDrill`; default mode задуман как фиксированное usage/status сообщение без TEST lookup. AST parsing, статический аудит и synthetic-only проверки помощников (parity, изменение данных, non-overwrite, reparse rejection, containment и категории ошибок) прошли; см. [report 014](../reports/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md).
- Entry point не запускался, TEST filesystem не читалась и не изменялась; `CODEX_BACKUP_RUN=NOT_ATTEMPTED`, `OPERATOR_BACKUP_RUN=NOT_ATTEMPTED`. Tool `CODED` / `STATIC_CHECK=PASS` / `SYNTHETIC_TEST=PASS`, но не runtime-tested на TEST и не принят независимо.
- File-level backup/restore остаются `UNVERIFIED`, application restore `NOT_ATTEMPTED`, integrations `UNVERIFIED`; архитектура `NOT_APPROVED`, продукт `NOT_IMPLEMENTED`.

## Task 015 — post-Task 014 owner-reported file drill and application plan

- Владелец позднее сообщил итог P8 Task 014: `FILE_LEVEL_BACKUP=OWNER_REPORTED_PASS`, `FILE_LEVEL_RESTORE_COPY_PARITY=OWNER_REPORTED_PASS`, `SOURCE_FINAL=OWNER_REPORTED_PASS` в рамках того запуска. Это provenance-qualified output, не независимая проверка Codex; отчёт Task 014 сохранён как историческое состояние до operator run. См. [report 015](../reports/015_RECORD_BACKUP_AND_PLAN_APP_RESTORE.md).
- `APPLICATION_RESTORE=NOT_ATTEMPTED`, `TEST_APP_READINESS=UNVERIFIED`, `OUTBOUND_INTEGRATIONS=UNVERIFIED`, `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`. Подготовлен только план будущей проверки на отдельной disposable clone: [TEST_APPLICATION_RESTORE_PLAN](TEST_APPLICATION_RESTORE_PLAN.md); никакой запуск не разрешён этим планом.
- Текущие архитектура и продуктовые статусы не изменились: `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`.
