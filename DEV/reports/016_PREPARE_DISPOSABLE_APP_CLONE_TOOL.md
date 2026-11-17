# Отчёт 016 — инструмент подготовки disposable app clone

## Status

`SUCCESS` для создания PowerShell 7 operator-only source, статического аудита, синтетических helper проверок, документационной сверки и публикации. Это не выполнение клонирования, не проверка данных TEST, не application restore и не независимая приёмка инструмента ChatGPT.

## AGENTS-first и Git baseline

- Корневой `AGENTS.md` полностью прочитан первым; затем полностью прочитано точное задание 016.
- Локальная `main`, локальный `HEAD` и свежий GitHub `origin/main` совпали с ожидаемой базой `99204f657bbe484fdc9fc55beeb634aae90b67af`.
- Tracked tree был чист. Посторонние незатреканные Task 001 и исходный Task 016 сохранены и не staged.
- PowerShell 7 доступен (`7.6.9`); `core.hooksPath=DEV/hooks`.

## Scope and safety boundaries

Создан `DEV/tools/New-ELSI-DisposableAppClone.ps1`. Без `-RunClone` скрипт печатает фиксированные `USAGE` и `STATUS=READY_FOR_AUDIT`; нет preflight или filesystem lookup. Единственный write opt-in — `-RunClone`.

Будущие фиксированные вход и выход: system fixed local drive root + `1C_TEST` + `_RESTORE_CHECK_014` → `_APP_SMOKE_016`. Никакие параметры пути, поиска дисков/родителей или fallback не предусмотрены. Перед созданием проверяются OS/PowerShell/non-elevated режим, exact parent/source/target, Git/cloud boundary, reparse/ordinary entries, metadata snapshots, idle exclusive handle, размер исходного дерева и free-space reserve. Невалидные файлы, named streams, меняющийся источник, недоступная/существующая цель и неподдерживаемые элементы закрывают операцию.

Clone root и вложенные каталоги создаются Windows `CreateDirectory` API, который атомарно отказывает при существующем имени; файлы открываются `FileMode.CreateNew`. Нет удаления, cleanup, retry, overwrite, ACL/registry/network/service/process/launcher изменений, повышения прав, внешних вызовов или запуска 1С. Потоковый SHA-256/tree inventory остаётся в памяти и не выводится. Ошибки не публикуют exception text, имена, размеры, метаданные или digest. При частичном сбое целевой каталог сохраняется и маркируется `CREATED_UNVERIFIED`/`UNVERIFIED` — автоматической очистки нет.

P0 фиксирует границу и preconditions; P1 создаёт source baseline; P2 создаёт только отсутствующий root; P3 копирует дерево; P4 сравнивает clone; P5 повторно проверяет source. `CLONE_016=PASS` выдаётся только после tree/hash parity и `SOURCE_FINAL=PASS`. Это только file-level staging proof: application restore остаётся `NOT_ATTEMPTED`, outbound isolation `UNVERIFIED`, а полная синтетичность данных не устанавливается.

## Static and synthetic validations

| Проверка | Результат |
|---|---|
| PowerShell AST parse | `PASS` |
| Поверхность параметров | `PASS` — только opt-in switch `RunClone`; default branch не вызывает filesystem helpers |
| Default invocation | `PASS` — только фиксированные `USAGE=...` и `STATUS=READY_FOR_AUDIT` |
| Статический поиск запрещённых команд | `PASS` — отсутствуют delete/move, `Copy-Item`, process launch, network, ACL/registry/service, transcript и 1С вызовы |
| Ручной обзор write APIs | `PASS` — native atomic directory creation для отсутствующего имени; `FileMode.CreateNew`; timestamps только в новом clone |
| Fixed-boundary / reparse / named-stream / path containment review | `PASS` статически; реальные пути не проверялись |
| Синтетический alternate data stream | `PASS` — дополнительный именованный stream на вымышленном файле отклонён metadata helper |
| Синтетическое дерево | `PASS` — вымышленные файлы, root/nested/empty directories, tree/hash parity |
| Синтетическое изменение bytes | `PASS` — изменения source/clone после baseline дают mismatch; исходный файл до копии проверен неизменным после helper-copy |
| Существующая цель | `PASS` — атомарный отказ на существующем каталоге; synthetic sentinel остался прежним |
| Reparse metadata | `PASS` — mocked `Directory|ReparsePoint` отклонён |
| Классификация доступа | `PASS` — synthetic `UnauthorizedAccessException` → `ACCESS_DENIED`; OS ACL не менялись |
| Отсутствующий/нулевой standard DB placeholder | `PASS` — оба отклонены helper preflight |
| Operator `-RunClone`, TEST filesystem, 1С | `NOT_ATTEMPTED` |

Проверки выполнялись командами `pwsh -NoProfile -File DEV/tools/New-ELSI-DisposableAppClone.ps1` (safe default), PowerShell 7 `Parser::ParseFile`/AST static audit и `pwsh -NoProfile -File DEV/tools/.task016-synthetic-tests.ps1`. Последний путь был временным локальным harness, извлекал только функции из AST, создал bounded workspace fixture с вымышленными именами/байтами, прошёл `PASS` и удалён после теста; он не включён в Git. Отдельный synthetic fixture также проверил отказ на alternate data stream. Символьные ссылки/ACL отказ динамически не создавались; reparse отказ проверен mocked атрибутом, permission классификация — synthetic exception. Runtime Windows TEST behavior, объём/содержимое данных, actual access rights и application viability не подтверждены.

## Results and non-execution

- `CODEX_TEST_ACCESS=NONE`; `CODEX_CLONE_RUN=NOT_ATTEMPTED`; `OPERATOR_CLONE_RUN=NOT_ATTEMPTED`.
- `_APP_SMOKE_016` не создавался. `_RESTORE_CHECK_014`, `_BACKUP_014`, `ELSI_TEST`, `_DIR_PROBE_013` и PRODUCTION не проверялись, не читались, не менялись и не копировались Codex.
- Не запускались `-RunClone`, 1С, Configurator, launcher, API, EDI, email, synchronization или network actions. Не менялись VM/host network settings. Никакие данные не регистрировались и не открывались.
- Данные-кандидат могут содержать неизвестные записи: `DATA_PURITY=UNVERIFIED`. Outbound isolation `UNVERIFIED`; application recovery `NOT_ATTEMPTED`.
- Product architecture `NOT_APPROVED`; invoice/UPD automation `NOT_IMPLEMENTED`.

## Changed files

- `DEV/tasks/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md` — исходное задание, включено без редактирования.
- `DEV/tools/New-ELSI-DisposableAppClone.ps1` — новый generic operator source.
- `DEV/reports/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md` — этот фактический отчёт.
- `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — отмечены подготовка tool, неисполнение и audit/owner gates.
- `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — новый coded/static/synthetic, но unrun статус.
- `DEV/docs/IMPLEMENTATION_STATUS.md` — разделены coded/checked и operator/application runtime состояния.
- `DEV/docs/CHANGELOG.md` — factual Task 016 entry.

README не менялся: текущие ссылки остаются верными, продуктовый интерфейс не добавлялся.

## Documentation reconciliation

| Документ / источник | Проверка | Изменение и причина | Evidence / противоречия |
|---|---|---|---|
| `AGENTS.md` | Прочитан полностью первым | Без изменения | Task scope, checks, status and publication workflow followed. |
| `DEV/tasks/016_PREPARE_DISPOSABLE_APP_CLONE_TOOL.md` | Прочитан полностью | Включён verbatim | Источник разрешённых путей, поведения и ограничений. |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` | Проверен и обновлён | Tool описан как staging-only, unrun и требующий независимого аудита + отдельной инструкции владельцу | Соответствует operator source и отсутствию `-RunClone`; не выдаёт разрешение на 1С. |
| `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` | Проверен и обновлён | Добавлены Task 016 coded/static/synthetic/unrun row и новый admission step | File backup остаётся только owner-reported; app restore `NOT_ATTEMPTED`, outbound/data purity `UNVERIFIED`. |
| `DEV/docs/IMPLEMENTATION_STATUS.md` | Проверен и обновлён | Добавлен Task 016 с разделением статического/синтетического evidence и runtime | Архитектура `NOT_APPROVED`, продукт `NOT_IMPLEMENTED`; нет production-ready claims. |
| `DEV/docs/CHANGELOG.md` | Проверен и обновлён | Добавлена factual Task 016 запись | Указывает, что tool не исполнялся и тестовые fixtures были synthetic. |
| `README.md` | Проверен, без изменения | Не нужен новый продуктовый entry point; safety links остаются актуальными | Никаких противоречащих утверждений о clone tool не было. |
| `DEV/docs/ARCHITECTURE.md` | Проверен, без изменения | Task не принимает продуктовых архитектурных решений | Архитектура остаётся `NOT_APPROVED`. |
| `DEV/docs/REQUIREMENTS.md` | Проверен, без изменения | Бизнес-требования не менялись | Скрипт — ограниченный operator staging tool, не product implementation. |
| `DEV/docs/SECURITY.md` | Проверен, без изменения | Общая политика публикации не менялась | Отчёт/source reviewed на sensitive data; никаких security workflows не менялось. |
| `DEV/docs/DEVELOPMENT_WORKFLOW.md` | Проверен, без изменения | Процедура task/audit не менялась | Task process и required checks соблюдены. |
| `DEV/docs/TASK_TEMPLATE.md` | Проверен, без изменения | Универсальный шаблон не изменялся | Конфликта с task requirements нет. |
| Task/Report 015; plan/report 014; reference Task014 tool | Проверены | Исторические документы и tool оставлены без изменения | Plan требует отдельный clone; Task016 реализует только clone source, без app launch; P8 ownership qualification сохранена. |
| Report 013 и prior reports 008–012 (релевантная safety history) | Сверены по существующим canonical docs/references | Без изменения | Исторические сбои и owner-reported directory probe не переинтерпретированы этим tool. |

Все изменения остаются в allowlist. Task-related противоречий не осталось: владелец сообщил backup/parity, но Codex не проверял копии; clone tool синтетически проверен, но не запускался; `APPLICATION_RESTORE=NOT_ATTEMPTED`; outbound isolation и data purity остаются `UNVERIFIED`.

## Publication and security state at report time

Отчёт создан до финального commit. Перед commit проверяются точный allowlist, весь staged diff, UTF-8, relative links, `git diff --cached --check` и ручной privacy review. Затем вручную выполняются `Test-Publication.ps1 -Mode Index` непосредственно перед commit и `-Mode Outgoing` для точного update перед push; hooks `DEV/hooks` не обходятся. Commit SHA, remote readback и commit-specific Actions в этом отчёте не предуказываются.

Источник содержит только generic path segments, synthetic-safe статусные tokens и fixed error categories. Нет путей Windows, учётных имён, снимков, данных/идентификаторов бухгалтерии, file hashes, inventories, размеров, credentials или лицензионных сведений. Runtime message и filesystem inventory наружу не выводятся.

## Next action

`WAIT_FOR_CHATGPT_AUDIT`. Не просить владельца запускать инструмент до независимого аудита и отдельной явной инструкции. 1С не открывать; Task 017 не начинать.
