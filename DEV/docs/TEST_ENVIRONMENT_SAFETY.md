# Безопасность тестового контура 1С

## Tasks 019–021 — Sandbox evidence and preflight boundaries

Владелец сообщил по исправленному readiness report `OS_EDITION_CLASS=PRO`, `VIRTUALIZATION_SUPPORT=SUPPORTED`, `RUN_GATE=NON_ELEVATED_PASS`; edition/virtualization query были `PASS`, но Sandbox/Hyper-V queries были `QUERY_ERROR`, feature states `UNVERIFIED`, итог `STATUS=PARTIAL_REPORT`. Владелец также сообщил, что Windows Sandbox и Hyper-V были видны, но unchecked в Optional Features GUI. Все это только `OWNER_REPORTED`: Codex не проверял Windows, а unchecked UI не доказывает возможность включения или безопасную работу. Task 019 добавила плановый guide, Task 020 — фиксированный XML и валидатор с `WSB_CONFIG=STATIC_VALIDATED`; эта статика не подтверждает runtime isolation. Task 021 добавляет owner-run host preflight script, проверенный только AST/static/synthetic; entry point Codex и владельцем в рамках Task 021 не запускался. Скрипт предназначен для однократного запуска владельцем после независимого аудита ChatGPT; он не читает Optional Features и не меняет host. `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`, `HOST_PREFLIGHT_TOOL=CODED_STATIC_TESTED_NOT_RUN`, `OWNER_HOST_PREFLIGHT=NOT_ATTEMPTED`, `GUEST_NETWORK_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE`. Никаких изменений host, запусков Sandbox/1С или доступа к TEST/PRODUCTION этот статус не разрешает.

## Task 018 — статус диагностики readiness

Владелец сообщил по Task 017 все capability-значения `UNVERIFIED` и `STATUS=UNVERIFIED` (`OWNER_REPORTED_ALL_UNVERIFIED`). Это не устанавливает причину и не подтверждает elevation, отсутствие Windows features или неисправность ОС. Capability report исправлен: фиксированные поля `RUN_GATE` и статусы отдельных разрешённых чтений показывают этап пропуска или ошибку. Task 018 проверила только AST/static анализ и synthetic callbacks; исправленный entry point на компьютере не запускался. Результат повторного owner-run отсутствует до независимого аудита ChatGPT. Изоляция, outbound controls и приложение остаются непроверенными (`OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`). См. [отчёт 018](../reports/018_DIAGNOSE_ISOLATION_READINESS_UNVERIFIED.md) и [план](TEST_APPLICATION_RESTORE_PLAN.md).

## Назначение и статус

Этот документ фиксирует безопасные границы и условия допуска к будущим локальным проверкам. По сообщению владельца тестовый контур создан штатным мастером и запускался вручную (`OWNER_REPORTED`). В Task 007 проверка остановилась до копирования; Tasks 008 и 011 не подтвердили backup; Task 012 диагностировала directory creation. Эти исторические результаты не переписываются последующим запуском владельца. После независимого аудита Task 013 владелец сообщил об успешном создании одного пустого `_DIR_PROBE_013` (`OWNER_REPORTED_PASS`), что не доказывает backup или restore. В Task 014 Codex создал и статически/синтетически проверил операторский инструмент, но не запускал его и не обращался к TEST. Позднее, уже после отдельного аудита Task 014, владелец сообщил об операторском результате P8: `FILE_LEVEL_BACKUP=PASS`, `FILE_LEVEL_RESTORE=PASS`, `SOURCE_FINAL=PASS`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `INTEGRATIONS=UNVERIFIED`, `PRODUCTION_ACCESS=NONE`, `STATUS=SUCCESS`. Это `OWNER_REPORTED_PASS`/`OWNER_PROVIDED_TOOL_OUTPUT` только для одного запуска; Codex не осматривал TEST или копии и не проводил независимого повторного измерения. В Task 016 подготовлен отдельный операторский clone tool и выполнены статические/синтетические проверки на вымышленных файлах; на момент отчёта 016 он не запускался с TEST. Позднее владелец сообщил об одном запуске с `_RESTORE_CHECK_014` → `_APP_SMOKE_016` и итогами clone parity/source-final `PASS`; этот статус остаётся только `OWNER_REPORTED_PASS`, без осмотра TEST/clone со стороны Codex. Файловая копия на host не является изолированной и не является проверкой запуска/восстановления в 1С. В Task 017 подготовлен новый capability-report tool, но его entry point и host facts не проверялись. `APPLICATION_RESTORE=NOT_ATTEMPTED`, готовность приложения `UNVERIFIED`; план кандидатов и следующий safe step описаны в [плане проверки восстановления](TEST_APPLICATION_RESTORE_PLAN.md). Полная синтетичность данных, интеграции и outbound isolation остаются `UNVERIFIED`.

Архитектура интеграции `NOT_APPROVED`; генерация счетов/УПД и интеграция `NOT_IMPLEMENTED`. Наличие тестового контура не означает доступ Codex, готовность к программному доступу или разрешение на операции в рабочей базе.

## Post-Task 014 operator-run result — owner reported

После отдельного аудита владелец сообщил, что вручную запустил проверенный Task 014 tool в обычной не повышенной PowerShell 7.7.0 сессии. Предоставленные маркеры достигли `P8_SOURCE_FINAL`; фиксируем результат только как `OWNER_REPORTED_PASS` / `OWNER_PROVIDED_TOOL_OUTPUT` одного операторского запуска:

- `FILE_LEVEL_BACKUP=OWNER_REPORTED_PASS` для `_BACKUP_014`.
- `FILE_LEVEL_RESTORE_COPY_PARITY=OWNER_REPORTED_PASS` для `_RESTORE_CHECK_014`.
- `SOURCE_FINAL=OWNER_REPORTED_PASS` в рамках именно этого запуска.
- `APPLICATION_RESTORE=NOT_ATTEMPTED`; `TEST_APP_READINESS=UNVERIFIED`.
- `OUTBOUND_INTEGRATIONS=UNVERIFIED`; `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`.
- `ARCHITECTURE=NOT_APPROVED`; `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`; `PRODUCTION_ACCESS=NONE` по сообщённому результату.

Это не независимая повторная проверка: Codex не читал, не копировал и не сверял TEST, `_BACKUP_014` или `_RESTORE_CHECK_014`. Отчёт Task 014 остаётся историческим свидетельством состояния до owner-run. Проверка открытия в 1С и безопасного application restore описана как будущий, неисполняемый план в [TEST_APPLICATION_RESTORE_PLAN.md](TEST_APPLICATION_RESTORE_PLAN.md).

## Task 016 owner-reported clone and Task 017 capability report

После отдельного аудита Task 016 владелец сообщил один обычный PowerShell 7.7.0 запуск clone tool с результатами `CLONE_016=PASS`, `FILE_LEVEL_CLONE_PARITY=PASS`, `SOURCE_FINAL=PASS`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `PRODUCTION_ACCESS=NONE`, `STATUS=SUCCESS`. Источник и целевой каталог отражены только generic именами `_RESTORE_CHECK_014` и `_APP_SMOKE_016`; точный экранный вывод, скриншот и локальные сведения не опубликованы. Это owner-provided output; code-output consistency проверена по опубликованной success ветке Task 016, но Codex не обращался к TEST и не устанавливал наличие, содержимое или безопасность каталога клона.

В Task 017 создан `DEV/tools/Get-ELSI-IsolationReadiness.ps1`. Допустимые будущие reads ограничены одним registry value для edition class, exact Windows optional feature names и `Win32_Processor` тремя virtualization capability flags. Вывод нормализован и не содержит raw errors/host identifiers. Tool не меняет систему, не обращается к TEST/PRODUCTION, не запускает VM/1С, не проверяет фактическую сеть и всегда сохраняет `HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`. В Task 017 сделан только AST/static review и синтетический вызов pure normalization functions; сам script и machine capability API не запускались в этой задаче.

Сообщённый clone сделан на host и не считается изолированным. Любая будущая VM требует отдельной передачи distinct disposable clone внутрь guest без live host share и подтверждения отсутствия host/production resources. До отдельного задания и доказательства effective outbound isolation запуск приложения не разрешён; см. [план восстановления](TEST_APPLICATION_RESTORE_PLAN.md).

## Owner-reported facts

Только безопасные сведения, сообщённые владельцем после Task 005; независимо Codex не проверены:

- Новая файловая информационная база создана владельцем вручную из официального полного дистрибутива и обычного шаблона «Бухгалтерия предприятия», редакция 3.0, конфигурация `3.0.208.14`; владелец сообщает, что она не создана из выгрузки рабочей базы или демонстрационного шаблона.
- База отображается в окне запуска под коротким названием `ELSI_TEST`. Владелец сообщает, что её каталог отличается от каталога рабочей бухгалтерии; абсолютные пути не фиксируются.
- Сообщены платформа `8.5.1.1343`, файловый режим и тонкий клиент. Владелец вручную запускал базу в режиме «1С:Предприятие».
- Владелец сообщает об успешном сохранении организации с вымышленным названием и без реальных налоговых/банковских реквизитов.
- До добавления владельцем своих тестовых контрагентов в справочнике уже отображались записи неизвестного происхождения. Их содержимое, объём и происхождение не исследуются и не публикуются. Нельзя характеризовать базу как полностью пустую или полностью синтетическую.
- Первоначальный запуск и настройка выполнялись владельцем вручную.

Эти сведения основаны только на сообщении владельца. Скриншоты, приложение, база и её каталог Codex не открывал и не проверял. См. также [задание 006](../tasks/006_TEST_ENVIRONMENT_SAFETY_BASELINE.md), [оценку возможностей](LOCAL_1C_CAPABILITY_ASSESSMENT.md) и [предыдущее исследование среды](1C_ENVIRONMENT_DISCOVERY.md).

## Границы сред

| Контур | Граница |
|---|---|
| PRODUCTION | Безусловно запрещены поиск, перечисление, запуск, подключение, чтение, копирование, экспорт, архивирование, изменение и сканирование. Никакой прямой или косвенный перенос его данных в TEST или GitHub. Этот документ и обычный `AGENTS.md` не создают техническую песочницу. |
| TEST (`ELSI_TEST`, по сообщению владельца) | В Task 006 не открывать и не читать базу, файлы, метаданные, журналы или настройки; не делать backup/restore; не запускать 1С; не тестировать права и `.epf`. В будущем — только действие из отдельного задания, с ручной идентификацией владельцем и явным разрешением на конкретную операцию и категорию данных. Неизвестные ранее существовавшие записи запрещены для тестовых сценариев. |
| PUBLIC GIT | Только безопасные текстовые документы проекта и синтетические примеры. Запрещены файлы баз/выгрузок/типовой конфигурации, реальные документы и данные, идентификаторы, реквизиты, скриншоты, лицензии и локальные пути. Любая публикация проходит ручной просмотр и обязательные проверки репозитория. |

## Разграничение offline backup и application tests

По узкому решению архитектора в Task 011 неизвестная общая конфигурация интеграций сама по себе не блокирует только строго локальное offline filesystem-копирование закрытой TEST-базы, если прошли точные path/reparse, idle, metadata, destination и capacity gates и нет положительных признаков активной записи или исходящего действия. Такое исключение не подтверждает, что обмены выключены: `INTEGRATIONS=UNVERIFIED` сохраняется, а копии остаются потенциально конфиденциальными и только локальными.

До любых будущих действий через 1С — запуска приложения, `.epf`, создания документов, обмена либо автоматического доступа — отдельно требуется подтвердить состояние интеграций, получателей и изоляции. Offline-разрешение Task 011 не распространяется на эти сценарии. Production остаётся безусловно запрещённой.

## Readiness matrix

Статусы разделяют сведения владельца, отсутствие попыток и то, что всё ещё требует подтверждения. Ни один статус не является разрешением на выполнение.

| Проверка/свойство | Статус | Что известно / чего не хватает |
|---|---|---|
| Отдельность каталога TEST от PRODUCTION | `OWNER_REPORTED` | Владелец сообщил о разных каталогах; Codex не проверял файловую систему или изоляцию. |
| Создание и первоначальный запуск TEST | `OWNER_REPORTED` | Владелец сообщает о ручном создании новой базы и запуске в режиме «1С:Предприятие»; Codex не запускал её. |
| Учётные записи и права разработки | `NOT_ATTEMPTED` / `UNVERIFIED` | Права Codex и полномочия владельца на разработку не проверялись. Любая проверка требует отдельного задания и разрешения. |
| Доступность и разрешение на `.epf` | `NOT_ATTEMPTED` / `REQUIRES_EXPLICIT_OWNER_APPROVAL` | `.epf` не создавался и не открывался; наличие прав и совместимость неизвестны. |
| Отсутствие нежелательных интеграций, обменов и автосервисов | `UNVERIFIED` | Наличие/состояние исходящих каналов и уведомлений не исследовалось. |
| Полностью синтетические данные во всей TEST | `UNVERIFIED` | Владелец создал синтетическую организацию, но в справочнике уже были записи неизвестного происхождения. Их содержание не исследовалось. |
| Начальная закрытость сеансов перед Task 008 | `PASS` | Один эксклюзивный read-only handle был получен до копирования. После сбоя состояние не перепроверялось. |
| Закрытость сеансов перед Task 010 | `PASS` | Один краткий exclusive read-only handle на точный стандартный файл получен и закрыт; процессы не исследовались. |
| Файловый backup и restore-copy parity Task 014 | `OWNER_REPORTED_PASS` | Владелец сообщил, что операторский запуск завершил `P8_SOURCE_FINAL` с `BACKUP_014=PASS`, `RESTORE_014=PASS`, `FILE_LEVEL_BACKUP=PASS`, `FILE_LEVEL_RESTORE=PASS`, `SOURCE_FINAL=PASS`. Codex не осматривал TEST или копии и не повторял вычисления. Исторические сбои Tasks 008/011/012 остаются без изменений. См. [отчёт 015](../reports/015_RECORD_BACKUP_AND_PLAN_APP_RESTORE.md). |
| Проверка восстановления/открытия в 1С | `NOT_ATTEMPTED` / `RESTORE_UNVERIFIED` | Приложение не запускалось; файловая parity не доказывает открытие базы в 1С. Готовность приложения остаётся `UNVERIFIED`; см. [план проверки восстановления](TEST_APPLICATION_RESTORE_PLAN.md). |
| Непосредственная post-copy проверка исходника и idle после Task 008 | `NOT_ATTEMPTED` / `UNVERIFIED` | Тогда после ошибки проверки не выполнялись. Последующая metadata диагностика Task 009 не является byte-integrity или idle check. |
| Metadata диагностика точных Task 008 каталогов (Task 009) | `PASS` в ограниченном объёме | Источник метаданных стабилен между двумя снимками; оба target отсутствуют; parity `NOT_APPLICABLE`; текущего места достаточно. Это не проверка байтов, не доказывает источник после Task 008 и не выявляет причину сбоя. См. [отчёт 009](../reports/009_DIAGNOSE_TEST_BACKUP_FAILURE.md). |
| Preflight инструментированной попытки (Task 010) | `BLOCKED` | Path/source metadata, stability, idle, отсутствие новых target names и capacity прошли. P0 не завершён, поскольку риск интеграций/обменов остаётся `UNVERIFIED`; baseline запрещает считать его отсутствующим без доказательств. P1–P8 не выполнялись, новые каталоги не создавались. См. [отчёт 010](../reports/010_INSTRUMENTED_TEST_BACKUP_RESTORE.md). |
| Offline backup/restore attempt (Task 011) | `FAIL` / `UNVERIFIED` | В узком offline scope все P0 gates прошли; P1 baseline вычислен только в памяти; P2 завершился `UNCLASSIFIED`. Backup target status `UNVERIFIED`, restore не создавался, P3–P8 не выполнялись. Интеграции остаются `UNVERIFIED`; это не блокировало только offline попытку. См. [отчёт 011](../reports/011_OFFLINE_TEST_BACKUP_RESTORE.md). |
| Текущая metadata-диагностика `_BACKUP_011` (Task 012) | `ABSENT` сейчас | Проверен только точный item/type без чтения содержимого. Это не устанавливает, был ли каталог создан на короткое время в Task 011 и не меняет исторический `BACKUP_011=UNVERIFIED`; см. [отчёт 012](../reports/012_DIAGNOSE_TEST_DIRECTORY_CREATION.md). |
| Создание пустого каталога `_DIR_PROBE_012` (Task 012) | `FAIL` / `UNCLASSIFIED` | D0–D2 прошли. Единственный D3 create-вызов завершился ошибкой неизвестной безопасной категории; разрешённая одна post-error metadata-проверка показала точный probe item как `ABSENT`. Повтор, содержимое базы и соседние элементы не проверялись. См. [отчёт 012](../reports/012_DIAGNOSE_TEST_DIRECTORY_CREATION.md). |
| Операторский диагностический скрипт (Task 013) | `OWNER_REPORTED_PASS` для одного пустого каталога | После независимого аудита владелец сообщил о ручном запуске и `CREATED_EMPTY_DIRECTORY`. Codex не подтверждал результат независимо; это не file-level backup и не restore. См. [отчёт 013](../reports/013_OPERATOR_FOLDER_WRITE_PROBE.md). |
| Операторский offline backup/restore-copy инструмент (Task 014) | `CODED` / `STATIC_CHECK=PASS` / `SYNTHETIC_TEST=PASS`; запуск `NOT_ATTEMPTED` | AST и изолированные синтетические проверки прошли. Ни source TEST, ни backup/restore targets не проверялись Codex. Сам инструмент требует независимого аудита перед будущим операторским запуском. См. [отчёт 014](../reports/014_OPERATOR_OFFLINE_TEST_BACKUP_TOOL.md). |
| Последующий операторский запуск Task 014 | `OWNER_REPORTED_PASS` для file-level backup, restore-copy parity и source-final проверки | Владелец предоставил итоговые статусные поля оператора. Это позднее evidence, не часть Task 014 отчёта и не независимая проверка Codex. `APPLICATION_RESTORE=NOT_ATTEMPTED`; см. [отчёт 015](../reports/015_RECORD_BACKUP_AND_PLAN_APP_RESTORE.md). |
| Подготовка application recovery smoke test (Task 015) | `PLAN_ONLY`; все runtime checks `NOT_ATTEMPTED` | План требует отдельного disposable clone и доказанной изоляции до запуска; текущие integrations остаются `UNVERIFIED`. См. [план](TEST_APPLICATION_RESTORE_PLAN.md) и [отчёт 015](../reports/015_RECORD_BACKUP_AND_PLAN_APP_RESTORE.md). |
| Инструмент подготовки disposable app clone (Task 016) | `CODED` / `STATIC_CHECK=PASS` / `SYNTHETIC_TEST=PASS`; один запуск `OWNER_REPORTED_PASS` | После аудита владелец сообщил о создании host-side `_APP_SMOKE_016` с file parity/source-final `PASS`. Codex TEST/clone не осматривал. Этот clone не считается изолированным; `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`. См. [report 016](../reports/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md) и [report 017](../reports/017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS.md). |
| Capability report для кандидатов изоляции (Task 017) | `CODED` / AST+synthetic helper checks `PASS`; host probe `NOT_ATTEMPTED` в Task 017 | Read-only source ограничен fixed edition/feature/virtualization fields и нормализованным output; не доказывает network isolation. Позднейший owner-reported run исправленной версии и его неопределённые feature results описаны в Task 019 ниже. См. [report 017](../reports/017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS.md). |
| Windows Sandbox config/preflight (Tasks 019–021) | `WSB_CONFIG=STATIC_VALIDATED`; `HOST_PREFLIGHT_TOOL=CODED_STATIC_TESTED_NOT_RUN`; host activation, Codex/owner preflight, guest launch `NOT_ATTEMPTED` | Task 020 added the fixed XML config and repository-only static validator. Task 021 adds a bounded read-only host preflight with only static/synthetic verification. Owner-reported GUI state remains unrechecked; effective network isolation, ingress and 1C recovery remain unverified/not attempted. Neither tool authorizes opening the config or activating the feature. См. [guide](WINDOWS_SANDBOX_SAFE_SETUP.md), [report 020](../reports/020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH.md) и [report 021](../reports/021_PREPARE_SANDBOX_HOST_PREFLIGHT.md). |
| Безопасный способ загрузки/открытия обработки | `UNVERIFIED` / `REQUIRES_EXPLICIT_OWNER_APPROVAL` | Способ, права, совместимость и ограничения загрузки не проверялись. Никакая загрузка не разрешена этим документом. |
| Защита от выбора/затрагивания PRODUCTION | `NOT_APPROVED` / `REQUIRES_EXPLICIT_OWNER_APPROVAL` | Техническое разделение доступа Codex не доказано. Нужны явная проверка границ и отдельное разрешение до любой автоматизации. |

## Stop conditions for future tasks

Если активная база не идентифицирована владельцем вручную; найдены реальные или неизвестные данные; не исключены обмены, уведомления или автосервисы; для меняющего данные опыта нет проверенной восстанавливаемой тестовой копии; отсутствуют полномочия; версия/совместимость не подтверждены; либо действие требует PRODUCTION — остановиться. Ничего не открывать, не запускать и не менять; передать вопрос владельцу для решения архитектора.

## Future admission procedure — не выполнять без отдельного задания

1. Перед каждой интерактивной операцией владелец вручную подтверждает выбор именно TEST. Отдельное задание должно разрешать конкретную операцию и категорию данных. Не предоставлять Codex доступ к PRODUCTION по умолчанию.
2. Владелец сообщил `OWNER_REPORTED_PASS` для file-level backup/restore-copy parity Task 014 и одного file-level clone run Task 016; Codex не осматривал копии. Clone создан на host и не считается изолированным. Исправленный readiness report позже запускался владельцем; feature queries остались `QUERY_ERROR`/`UNVERIFIED`, а Windows Sandbox и Hyper-V были owner-reported как unchecked в UI. Task 021 подготовила только код для категориального read-only host preflight; его entry point не запускался. После независимого аудита ChatGPT владелец может выполнить preflight ровно один раз в обычной PowerShell 7 сессии; результат не даёт разрешения на feature activation или guest launch. Это не подтверждает работоспособность Sandbox. Для будущего открытия 1С нужны отдельное задание, distinct clone и независимое доказательство outbound isolation; никогда не открывать рабочую базу или текущий host clone.
3. Не использовать неизвестные ранее существовавшие записи шаблона. Не отправлять документы, сообщения ЭДО или письма реальным получателям.
4. Отдельно установить безопасный способ запрета исходящих интеграций и уведомлений перед опытом; не считать их выключенными без проверки.
5. Если отдельно разрешено: сначала согласованный read-only тест доступа; затем `.epf` без изменений учётных данных; синтетические документы — только в следующих отдельных заданиях после решения архитектора, владельца и проверки восстановления.
6. Перед автоматическим запуском обеспечить явную техническую изоляцию доступа и полномочий. Инструкции `AGENTS.md` сами по себе не являются sandbox.

## Невыполненные проверки и вопросы

- Подтвердить, что все данные TEST синтетические, либо определить безопасный чистый тестовый контур без чтения/переноса production.
- Отдельно утвердить полномочия, способ проверки доступа и безопасную блокировку исходящих каналов.
- Проверка открытия в 1С на отдельном disposable clone и доказательство outbound isolation остаются `NOT_ATTEMPTED`/`UNVERIFIED`; никакое приложение ещё не запускалось по этому плану.
- Отдельно решить, допустим ли `.epf`, и каким безопасным способом проверять его совместимость.
- Утвердить техническую изоляцию, если потребуется автоматический доступ.

Пароли, номера лицензий, личные сведения и снимки экрана с идентификаторами не запрашиваются.

## Отграничение от разработки

Task 006 не выполняла операций в 1С; Task 007 остановилась до копирования; Tasks 008–012 также не запускали 1С. Task 011 остановилась на P2 с категорией `UNCLASSIFIED`; это историческое состояние не переинтерпретируется. Task 012 получила `UNCLASSIFIED` при единственной попытке создать пустой probe-каталог. После аудита владелец сообщил `OWNER_REPORTED_PASS` для directory probe Task 013, file-level backup/restore-copy parity Task 014 и file-level clone Task 016; Codex не проверял эти runtime результаты в TEST. Task 016 clone сообщён как host-side, isolation не доказана. Task 017 capability tool не запускался в рамках Task 017; поздний owner-reported run исправленной версии дал `QUERY_ERROR` по Sandbox/Hyper-V и остаётся только сообщённым владельцем свидетельством. Task 019 создала только guide и документационный XML example; Windows features и Sandbox не активировались. Outbound isolation и application restore остаются `UNVERIFIED`/`NOT_ATTEMPTED`. План следующего отдельного допуска приведён в [TEST_APPLICATION_RESTORE_PLAN.md](TEST_APPLICATION_RESTORE_PLAN.md). Узкое исключение Task 011 касалось только offline file-copy и не разрешало application-level действия. Код, `.epf`, `.cfe`, интеграция и генератор не реализованы. До отдельной приёмки ChatGPT статус остаётся `NOT_APPROVED`; продуктовая функциональность `NOT_IMPLEMENTED`; application readiness `UNVERIFIED`.
