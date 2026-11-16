# История изменений по задачам

Это журнал фактически выполненных задач, а не план будущих релизов. Исторические записи помечены ретроспективами и основаны на опубликованных отчётах.

## 2026-11-16 — 011_OFFLINE_TEST_BACKUP_RESTORE — stopped at P2

- Узкое offline-only исключение применено; P0 проверки прошли, P1 baseline рассчитан в памяти. P2 завершился с `FAILURE_CATEGORY=UNCLASSIFIED`.
- Backup target остался `UNVERIFIED` и не исследовался/не очищался; restore не создавался. P3–P8 не выполнялись; интеграции остаются `UNVERIFIED` для application-level операций.
- Факты, ограничения и сверка документации: [report 011](../reports/011_OFFLINE_TEST_BACKUP_RESTORE.md). Архитектура `NOT_APPROVED`, продукт `NOT_IMPLEMENTED`.

## 2026-11-16 — 010_INSTRUMENTED_TEST_BACKUP_RESTORE — blocked at P0

- Свежий read-only preflight прошёл проверки точной TEST boundary, metadata stability, exclusive idle check, отсутствия новых target names и capacity.
- P0 остановлен: риск интеграций/обменов остаётся `UNVERIFIED`; digest, backup и restore не запускались, новые каталоги не создавались.
- Доказательства и ограничения: [report 010](../reports/010_INSTRUMENTED_TEST_BACKUP_RESTORE.md). File-level backup/restore `NOT_ATTEMPTED`; architecture `NOT_APPROVED`, product `NOT_IMPLEMENTED`.

## 2026-11-16 — 009_DIAGNOSE_TEST_BACKUP_FAILURE — bounded metadata diagnostic

- Read-only metadata check found the exact TEST source and standard database file present and stable across two snapshots; both exact Task 008 destinations were absent. Metadata parity is `NOT_APPLICABLE`; current space meets the required threshold.
- Historical Task 008 error cause remains `UNDETERMINED`; source byte integrity after that attempt remains `UNVERIFIED`. No backup or restore was created or validated by Task 009.
- Findings and limitations: [report 009](../reports/009_DIAGNOSE_TEST_BACKUP_FAILURE.md). Architecture remains `NOT_APPROVED`; product remains `NOT_IMPLEMENTED`.

## 2026-11-16 — 008_RETRY_TEST_BACKUP_RESTORE — blocked during file copy

- Точный TEST path preflight и начальный exclusive read-only lock-check прошли; далее разрешённая локальная file-copy операция завершилась ошибкой до инвентарной проверки.
- Проверенный backup отсутствует (`FILE_LEVEL_BACKUP=FAIL` / completion `UNVERIFIED`); restore и post-copy validation `NOT_ATTEMPTED`. Возможные локальные partial artifacts оставлены нетронутыми; база и данные в Git не публиковались.
- Подробности и документационная сверка: [report 008](../reports/008_RETRY_TEST_BACKUP_RESTORE.md). Архитектура `NOT_APPROVED`, продукт `NOT_IMPLEMENTED`.

## 2026-11-16 — 007_TEST_BACKUP_AND_RESTORE — blocked preflight

- Локальный offline preflight точного TEST-кандидата остановился: `TEST_SESSION_NOT_CONFIRMED_CLOSED` при попытке эксклюзивного read-only доступа.
- Копия и восстановление не выполнялись; production и содержимое базы не открывались. Документирован точный stop condition и необходимость повторного допуска отдельным заданием после закрытия владельцем сессий TEST.
- Подробности и сверка документов — в [отчёте 007](../reports/007_TEST_BACKUP_AND_RESTORE.md). `FILE_LEVEL_BACKUP=NOT_ATTEMPTED`, `FILE_LEVEL_RESTORE=NOT_ATTEMPTED`, `RESTORE_UNVERIFIED`.

## 2026-11-16 — 006_TEST_ENVIRONMENT_SAFETY_BASELINE — documentation only

- Добавлен канонический safety baseline с разделением PRODUCTION / TEST / PUBLIC GIT, readiness-статусами, stop conditions и будущей процедурой допуска.
- Наличие и ручной запуск отдельной тестовой базы записаны только как `OWNER_REPORTED`; ранее существовавшие записи неизвестного происхождения исключают утверждение о полностью синтетическом составе.
- Доступ Codex, `.epf`, интеграции, резервное копирование и восстановление не проверялись; `RESTORE_UNVERIFIED`. Архитектура `NOT_APPROVED`, продукт `NOT_IMPLEMENTED`.
- Матрица документации и проверки приведены в [отчёте 006](../reports/006_TEST_ENVIRONMENT_SAFETY_BASELINE.md).

## 2026-11-15 — 005_LOCAL_1C_CAPABILITY_ASSESSMENT — discovery only

- Создана сравнительная матрица по штатной работе, `.epf`, `.cfe` и обмену; технические варианты не ранжированы и архитектура не выбрана.
- Обновлён Task 004 dossier безопасными характеристиками, сообщёнными владельцем как `OWNER_REPORTED`; независимой проверки, подключения к 1С, открытия конфигуратора, доступа к базе или тестирования совместимости не было.
- Официальные материалы 1С подтверждают общие механизмы и ограничения, но не подтверждают права/совместимость данной среды. Зафиксированы ограничения публикации типовых фрагментов в GitHub и требования synthetic-only стенда.
- Доказательства и документационная матрица: [отчёт 005](../reports/005_LOCAL_1C_CAPABILITY_ASSESSMENT.md). Архитектура `NOT_APPROVED`, функциональность `NOT_IMPLEMENTED`.

## 2026-11-15 — 004_1C_ENVIRONMENT_DISCOVERY — ретроспектива

- Создан [санитизированный dossier среды](1C_ENVIRONMENT_DISCOVERY.md) на основе публичных страниц и безопасных локальных индикаторов; никаких tenant-доступов не выполнялось.
- Tenant readiness оставалась неизвестной на момент Task 004; позже владелец сообщил локальную файловую среду в Task 005 как `OWNER_REPORTED` (независимо не проверено).
- Подробные свидетельства и ограничения: [отчёт 004](../reports/004_1C_ENVIRONMENT_DISCOVERY.md). Архитектура осталась неутверждённой, интеграция и формирование документов не реализованы.

## 2026-11-12 — 003_DOCUMENTATION_GOVERNANCE — ретроспектива

- Установлены обязательные правила чтения `AGENTS.md`, сверки документации, ведения отчёта и не-самоаудита.
- Добавлены шаблон задания, changelog и источник статуса реализации; workflow и README связывают документацию и процесс сверки.
- Publication scanner блокирует индексированные `.env` и `.env.*` имена в `Index`, `Tracked`, `Outgoing`, кроме точного basename `.env.example`; добавлены синтетические изолированные проверки.
- Проверки и ограничения: [отчёт 003](../reports/003_DOCUMENTATION_GOVERNANCE.md). Автоматические проверки остаются эвристическими и не гарантируют обнаружение всех секретов.

## 2026-11-12 — 002_SECURITY_AND_WORKFLOW — ретроспектива

- По [отчёту 002](../reports/002_SECURITY_AND_WORKFLOW.md) добавлены публикационный scanner, локальные hooks, изолированные тесты, GitHub Actions и рабочие инструкции.
- Отчёт зафиксировал 15/15 локальных тестов и первоначальную ошибку проверки temp-пути на Ubuntu. Эта ошибка была исправлена; Actions run для опубликованного состояния Task 002 завершился успешно.
- Scanner остаётся эвристическим, hooks можно обойти, Actions запускается после push; ручная проверка содержимого обязательна. Это не гарантия абсолютной защиты.

## 2026-11-12 — 001_INIT_PROJECT — ретроспектива

- По [отчёту 001](../reports/001_INIT_PROJECT.md) создана стартовая структура и документы требований, архитектуры и безопасности.
- Бухгалтерская функциональность и интеграция с 1С не реализованы; архитектура остаётся неутверждённой.
