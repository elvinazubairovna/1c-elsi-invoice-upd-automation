# Отчёт 017 — фиксация clone и readiness отчёт для изоляции

## Статус на момент подготовки отчёта

Все разрешённые локальные изменения и статические/синтетические проверки подготовлены. Коммит, push, remote readback и commit-specific CI ещё pending на момент создания этого файла; итоговый статус публикации будет сообщён отдельно после gates. Это не архитектурная приёмка и не проверка среды владельца.

## AGENTS-first и Git admission

- Корневой `AGENTS.md` прочитан полностью первым; после него полностью прочитан `DEV/tasks/017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS.md`.
- Локальная ветка `main`, локальный `HEAD` и свежая запись GitHub branch history совпали с заданной базой `d1b731673b71a318209b3e412d7d02966b6486b0`. Origin URL соответствует репозиторию задания; `core.hooksPath=DEV/hooks`.
- В начале tracked worktree был чист. Незатреканные Task 001 и предоставленный Task 017 сохранены; Task 001 не включается в изменения. PowerShell 7 доступен и использовался для AST/static и синтетических проверок; OS/VM host capabilities не опрашивались.

## Owner-provided clone result — provenance

Задание передало санитизированные поля одного owner-run после независимого аудита Task 016: `CLONE_016=PASS`, `FILE_LEVEL_CLONE_PARITY=PASS`, `SOURCE_FINAL=PASS`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `PRODUCTION_ACCESS=NONE`, `STATUS=SUCCESS`. Они записаны как `OWNER_REPORTED_PASS` / `OWNER_PROVIDED_TOOL_OUTPUT` для этого одного запуска: сообщённый file-level clone из `_RESTORE_CHECK_014` в `_APP_SMOKE_016` на host, parity и source-final в рамках запуска.

Проведён только code-output consistency audit опубликованного Task 016 source: его success ветка пишет `CLONE_016=PASS`, `FILE_LEVEL_CLONE_PARITY=PASS` и `SOURCE_FINAL=PASS` после P4 tree parity и P5 повторной digest/metadata/source-final проверки. Этот аудит показывает, что поля соответствуют ветке успеха кода; он не перепроверяет выполнение, файлы, содержимое или локальный экран. Исторический report 016 оставлен неизменным, так как точно фиксирует состояние до запуска владельцем.

`CODEX_TEST_ACCESS=NONE`; clone каталоги не открывались и не опрашивались. PRODUCTION не обнаруживалась и не проверялась. Сообщённый clone — обычная host-side копия, не доказательство изоляции и не разрешение открыть его в 1С.

## Deliverable: `Get-ELSI-IsolationReadiness.ps1`

Создан `DEV/tools/Get-ELSI-IsolationReadiness.ps1`, без параметров и без режима повышения прав. Будущий запуск предусмотрен владельцем в обычной, не повышенной PowerShell 7 сессии, только после отдельного аудита ChatGPT.

### Допустимые будущие чтения

- Один точный read-only registry value `EditionID`, нормализуемый в `HOME`, `PRO`, `ENTERPRISE`, `EDUCATION`, `SERVER`, `OTHER` или `UNVERIFIED`.
- Два точных имени optional features (`Containers-DisposableClientVM` и `Microsoft-Hyper-V-All`) через `Get-WindowsOptionalFeature -Online -FeatureName <точное имя>`. Никакой список всех features не запрашивается. Отказ/ошибка запроса даёт `UNVERIFIED`; отсутствие результата после успешного запроса — `NOT_AVAILABLE`.
- Только класс `Win32_Processor` и три указанных свойства `VMMonitorModeExtensions`, `SecondLevelAddressTranslationExtensions`, `VirtualizationFirmwareEnabled`. Результаты агрегируются в памяти в `SUPPORTED`, `UNSUPPORTED` или `UNVERIFIED`; никакие CIM objects не печатаются. `UNSUPPORTED` означает, что как минимум один из ограниченного набора flags false, не анализ причины.

Если ОС не Windows, сессия повышена или API недоступен/отказал, поля сохраняют безопасные нормализованные `UNVERIFIED` статусы. Все ошибки перехватываются без текста ошибки. На выход идут только девять фиксированных ключей; `HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE`. Даже `STATUS=READ_ONLY_REPORT` сообщает лишь, что сформированы нормализованные строки, а не что хост или будущий guest изолирован.

### Что tool не делает

Он не читает TEST/PRODUCTION, файлы баз, пути, приложения, процессы, службы, adapters, drives, users, environment, logs, network/DNS, hostname, domain, credentials или license data; не делает network/localhost запросов, не пишет/не логирует, не меняет Windows/VM/firewall/network, не устанавливает/включает features, не создаёт VM, не запускает 1С/Configurator/launcher, не запускает clone и не проверяет outbound connectivity. Нет output raw registry/CIM/error/build value.

## Статические и синтетические проверки

| Проверка | Результат |
|---|---|
| PowerShell `Parser::ParseFile` для полного источника | `PASS` |
| Поверхность параметров / entry point | `PASS` — пустой `param()`; проверки host выполняются только при запуске владельцем, не из статической harness |
| Инвентаризация команд AST | `PASS` — только mapping functions, точный `Get-WindowsOptionalFeature`, точный `Get-CimInstance`, `Get-Command`, `Set-StrictMode` и `Where-Object` |
| Поиск write/elevation/network/process/1C/широких inventory APIs | `PASS` — запрещённых вызовов не найдено; OS reads ограничены перечисленными API/свойствами |
| Sanitized output/static error-path review | `PASS` — только фиксированные allowlisted значения, catches скрывают raw exception, дополнительные PowerShell streams silenced |
| Synthetic normalization и simulated failure | `PASS` — 15 in-memory assertions для известных/неизвестных edition, feature status, отсутствующего результата, отказа query, virtualization flags и неизвестных приватноподобных строк |
| Script entry point / machine capability probe | `NOT_ATTEMPTED` |
| TEST clone / 1С / VM / network / settings | `NOT_ATTEMPTED` |

Команда AST/synthetic проверки: PowerShell 7 `Parser::ParseFile` и extraction только `FunctionDefinitionAst` из текста скрипта; извлечённые чистые normalizers вызваны на вручную заданных синтетических значениях. Harness не вызывал entry point и не обращался к machine APIs, не создавал файлов или fixtures. Проверка синтетически подтвердила, что query failure → `UNVERIFIED`, отсутствие результата при успешном query → `NOT_AVAILABLE`, неизвестная edition → `OTHER`, а неизвестные feature/virtualization значения не отражаются в выводе.

## Решение по изоляции — только планирование

План сравнивает отдельно конфигурируемую offline VM, Windows Sandbox и отдельный offline test computer. Текущая edition/feature/virtualization availability не известна, потому что host probe не запускался; наличие feature или CPU flags само по себе не доказывает безопасную сетевую конфигурацию. Отдельно потребуются подтверждение эффективной изоляции до старта 1С, отсутствие host/production shares, способ передачи distinct disposable clone, а также owner-handled установка/лицензия платформы 1С.

Сообщённый `_APP_SMOKE_016` создан на host и не должен открываться напрямую. При выборе VM следующее отдельное задание должно спроектировать перенос другой disposable copy внутрь guest без live host share и отдельно подтвердить её идентичность и отсутствие доступа к host/production ресурсам. Никаких настроек не меняли. Запрещены отключение всех host adapters, host-wide firewall changes для production 1С и подключение production data. Кратчайший следующий concrete operator action после аудита этого изменения — вернуть только строки read-only capability report; затем ChatGPT выдаёт одно узкое задание по конкретному кандидату/доказательству изоляции до 1С.

## Изменённые файлы и documentation reconciliation

| Документ / источник | Проверен | Изменён и зачем | Проверка / расхождение |
|---|---|---|---|
| `AGENTS.md` | Да, первым, полностью | Нет | Процедура и запреты соблюдены. |
| `DEV/tasks/017_RECORD_CLONE_AND_CHECK_ISOLATION_READINESS.md` | Да, полностью | Включается verbatim по allowlist | Источник требований; копия исходного task file не редактировалась. |
| `DEV/tools/Get-ELSI-IsolationReadiness.ps1` | Да, AST + ручной review | Создан новый read-only source | Проверки выше; entry point не запускался. |
| `DEV/tasks/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md`, `DEV/reports/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md`, clone source | Да, полностью; success path и его вывод проверены | Нет, исторические файлы сохранены | Source success path согласован с владельческими маркерами; не независимое runtime evidence. Отчёт 016 фиксирует состояние на дату отчёта. |
| Task/Report 015 | Да | Нет | Исходные owner-reported backup/parity claims сохраняются и не смешиваются с app restore. |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` | Да | Да | Добавлены owner clone provenance, non-isolation и read-only capability step; сравнение трёх вариантов, prerequisites, запрещённые shortcuts, distinct clone transfer, concrete next action. |
| `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` | Да | Да | Добавлены provenance-qualified clone и unrun probe, отсутствие Codex доступа и stop gate до app launch. Исторические Task 014/016 отчёты не переписаны. |
| `DEV/docs/IMPLEMENTATION_STATUS.md` | Да | Да | Добавлена Task 017 evidence-level запись; кодированное, synthetic-checked, owner-reported и not-attempted состояния разделены. Архитектура и продуктовые категории не изменились. |
| `DEV/docs/CHANGELOG.md` | Да | Да | Добавлен фактический Task 017 entry с evidence/limitations. |
| `README.md` | Да | Нет | Ссылка на recovery plan актуальна; новый скрипт является операторским/internal readiness report, отдельная README ссылка не нужна. Противоречия не выявлено. |
| `DEV/docs/ARCHITECTURE.md` | Да | Нет | Новое архитектурное решение не принималось; статус остаётся `NOT_APPROVED`. |
| `DEV/docs/REQUIREMENTS.md` | Да | Нет | Бизнес-требования не изменялись. |
| `DEV/docs/SECURITY.md` | Да | Нет | Политика публикации не менялась; секреты/реальные данные не добавлены. |
| `DEV/docs/DEVELOPMENT_WORKFLOW.md` | Да | Нет | Task и publication process не менялись. |
| `DEV/docs/TASK_TEMPLATE.md` | Да | Нет | Шаблон актуален; не создаёт разрешения на операторский запуск. |
| Релевантная safety history Tasks/Reports 013–015 | Да | Нет | Не переписана. Сообщённый Task 016 запуск отражён в новом отчёте с provenance, а не как независимое наблюдение. |

Противоречие о существовании клона разрешено по времени и происхождению: Task/Report 016 описывают состояние до позднейшего запуска владельца; они оставлены неизменными, а новое состояние записано отдельно как `OWNER_REPORTED_PASS`. Состояния `APPLICATION_RESTORE=NOT_ATTEMPTED`, `OUTBOUND_ISOLATION=UNVERIFIED`, `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED` не менялись.

**Разрешённые файлы (7):** исходный Task 017; новый capability tool; этот report; recovery plan; safety baseline; implementation status; changelog. `README.md` и остальные прочитанные документы оставлены без изменений. Незатреканный Task 001 не включается.

## Privacy, checks и публикация

В документе используются generic folder components и только заданные безопасные status tokens. Нет скриншотов, приватных путей, имён пользователей, локальных характеристик host, raw registry/CIM/errors, database contents, file hashes/inventories/sizes, credentials или license details. Ручной staged review, UTF-8/relative link checks, exact allowlist и publication scanner выполняются до commit. `Index`, outgoing `Outgoing`, hooks, remote readback и commit-specific CI на этом отчёте ещё `PENDING`; CI `PASS` будет указан только при завершённом успешном run на точном SHA.

`tests/security/Invoke-SecurityTests.ps1` не относится к этому diff: security workflow и scanner не менялись. Если появится required gate failure, изменения останутся локально и публикация остановится.

## Неизменившиеся рисковые категории и следующий шаг

- `OWNER_CLONE_016=OWNER_REPORTED_PASS`; `OWNER_CLONE_PARITY=OWNER_REPORTED_PASS`; `OWNER_SOURCE_FINAL=OWNER_REPORTED_PASS` — только один предоставленный запуск.
- `CODEX_HOST_PROBE=NOT_ATTEMPTED`; `OWNER_HOST_PROBE=NOT_ATTEMPTED` в рамках Task 017.
- `CODEX_TEST_ACCESS=NONE`; `PRODUCTION_ACCESS=NONE`; `APPLICATION_RESTORE=NOT_ATTEMPTED`; `OUTBOUND_ISOLATION=UNVERIFIED`.
- `ARCHITECTURE=NOT_APPROVED`; `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`; `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`.

`NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`. Не открывать clone в 1С и не начинать Task 018.
