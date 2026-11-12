# Статус реализации

Этот документ фиксирует подтверждённое состояние проекта; он не является планом реализации.

## Verified baseline

- Последний проверенный опубликованный baseline перед задачей 003: `main` на `3221b386398bb65fbce005eef0d7e3cb20fe81f5` (Task 002). Удалённый `origin/main` совпадал; соответствующий GitHub Actions run завершился `success`.
- Документация и `.env` path guard задачи 003 проверяются и публикуются в одном изменении. SHA содержащего этот документ коммита здесь не указывается; итоговый remote HEAD передаётся отдельно владельцу.

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
