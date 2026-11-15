# Статус реализации

Этот документ фиксирует подтверждённое состояние проекта; он не является планом реализации.

## Verified baseline

- Последний проверенный опубликованный baseline до Task 004: `main` на `437226191c6e467f4c43a7134d5431c834709be3` (Task 003); локальный `HEAD` совпал с `origin/main` при preflight Task 004.
- Для Task 003 локальные проверки и публикация зафиксированы в отчёте 003; commit-specific CI там отмечен как `UNVERIFIED`. Не переносить этот статус на другие коммиты.

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

## Task 004 — environment discovery

- Публичное исследование и локальная read-only инвентаризация: [dossier 004](1C_ENVIRONMENT_DISCOVERY.md) и [report 004](../reports/004_1C_ENVIRONMENT_DISCOVERY.md). Общие механизмы вендора изучены; tenant-specific eligibility `UNKNOWN / OWNER_CONFIRMATION_REQUIRED`.
- Implementation status: discovery documentation only. Architecture remains `NOT_APPROVED`; invoice/UPD generation and every 1C integration remain `NOT_IMPLEMENTED`. No tenant access or live verification occurred.
- Task 003 published baseline: `main` at `437226191c6e467f4c43a7134d5431c834709be3`; associated commit status was not reported by available GitHub status endpoint in prior task report.
