# Отчёт 021 — подготовка предварительной проверки Windows Sandbox

## Итог и статусы

Подготовлен PowerShell 7 read-only preflight для будущего однократного owner-run после независимого аудита ChatGPT. Проверен только исходный текст и извлечённые pure helpers на синтетических значениях. Entry point на компьютере не запускался.

| Поле | Значение |
|---|---|
| Task | `021_PREPARE_SANDBOX_HOST_PREFLIGHT` |
| Expected base / local HEAD | `bb7ae3ea85bd0830d7107e4c3ba2617f53cd53e0` / совпадает |
| Branch / origin | `main` / ожидаемый HTTPS origin |
| Remote baseline | GitHub commit history показал тот же SHA; локальный `git ls-remote` вернул DNS failure |
| AGENTS-first | `PASS` — полностью прочитан до полного Task 021 |
| Owner provenance | `PRO_VIRT_SUPPORTED_GUI_UNCHECKED` (`OWNER_REPORTED`, не перепроверено) |
| Tool / static analysis | `CREATED` / `PASS` |
| Synthetic tests | `PASS` — pure helpers, gate/threshold/version/architecture/unknown/output allowlist cases |
| Codex / owner host preflight | `NOT_ATTEMPTED` / `NOT_ATTEMPTED` |
| Host feature activation / guest launch | `NOT_ATTEMPTED` / `NOT_ATTEMPTED` |
| Guest isolation / application restore / production access | `UNVERIFIED` / `NOT_ATTEMPTED` / `NONE` |
| Architecture / invoice-UPD | `NOT_APPROVED` / `NOT_IMPLEMENTED` |

## Git admission и область изменений

Полностью прочитаны root `AGENTS.md`, затем Task 021. Далее прочитаны Tasks/Reports 019–020, фиксированный `.wsb` config и XML validator, Sandbox guide, restore plan, safety baseline, implementation status, changelog, README, architecture, requirements, security, development workflow, task template и отчёты 019–020. Официальные prerequisites сверены по двум указанным Microsoft Learn страницам. Никаких TEST/production путей, содержимого или metadata не искали.

Локальные branch `main`, origin URL, `HEAD`, tracked/untracked status и `core.hooksPath=DEV/hooks` проверены после чтения документов. Локальный HEAD совпал с ожидаемой базой. Локальный `git ls-remote` был недоступен из-за DNS; GitHub connector показал свежий верхний commit `main` с тем же SHA. Исторический незатреканный Task 001 и входной Task 021 сохранены; Task 001 не включается.

Task 021 сообщает о successful Actions для базового Task 020 SHA и указывает run `45170321107`. Job readback через GitHub connector подтвердил `publication-security=completed/success`. Это прошлый baseline CI evidence, а не CI для нового Task 021 commit и не подтверждение работы хоста.

Разрешённые изменения:

- `DEV/tasks/021_PREPARE_SANDBOX_HOST_PREFLIGHT.md` — входное задание без редактирования.
- `DEV/tools/Get-ELSI-SandboxHostPreflight.ps1` — новый no-parameter read-only PowerShell 7 источник.
- `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` — объяснены точные scope/лимиты будущего preflight и owner command, допустимый только после независимого аудита.
- `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — зафиксировано coded/static/synthetic и unrun состояние инструмента.
- `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — обновлены Task 020/021 provenance и различие статической проверки от host runtime.
- `DEV/docs/IMPLEMENTATION_STATUS.md` — отражены только coded/static-tested helper state и все непроведённые host/guest/app проверки.
- `DEV/docs/CHANGELOG.md` — добавлена фактическая запись Task 021; Task 020 помечен ретроспективой.
- `DEV/reports/021_PREPARE_SANDBOX_HOST_PREFLIGHT.md` — этот sanitized отчёт.

`README.md` не изменён: он уже ведёт к каноническим safety/recovery docs и не содержит обещаний о host readiness. `ARCHITECTURE.md` и `REQUIREMENTS.md` не затронуты: продуктовые решения и бизнес-требования не менялись. `SECURITY.md`, `DEVELOPMENT_WORKFLOW.md` и `TASK_TEMPLATE.md` проверены, их правила достаточны; новый scanner, security workflow, hooks, `.wsb`, предыдущие задачи и инструменты не менялись.

## Поведение preflight-скрипта

Выход — ровно 16 фиксированных строк с заданными ключами и allowlisted категориями. Script не имеет пользовательских параметров и не печатает raw values, пути, build, размеры или ошибки. Gate в обычной сессии сначала проверяет только Windows platform и elevated identity. При elevated, non-Windows или неизвестном gate pure probe plan пуст, последующие проверки пропускаются.

Только для будущего owner-run после аудита, если gate `NON_ELEVATED_PASS`, отдельные независимые try/catch выполняют узкие read-only чтения:

- `Environment.OSVersion.Version` — категория Windows 10 build 18362+ / Windows 11 без публикации номера;
- `RuntimeInformation.OSArchitecture` — x64 либо ARM64 только начиная с Windows 11 22H2;
- один `Win32_ComputerSystem.TotalPhysicalMemory` запрос;
- один `Win32_Processor.NumberOfCores` запрос для суммы физических cores;
- только `DriveInfo.AvailableFreeSpace` на одном fixed системном томе, корень которого выводится из Windows directory внутри процесса.

Нет запросов Windows Optional Features, registry, дисков/томов по списку, сети, процессов, служб, установленных приложений, Windows UI, Sandbox, 1С, TEST/PRODUCTION. Ошибки изолируются по одному probe и становятся `UNVERIFIED`; исключения не печатаются. Virtualization и feature checkbox состояния повторно не читаются: вывод остаётся `OWNER_REPORTED` / `NOT_REVERIFIED`. `4 GB` RAM, `1 GB` системного места и `2` физических cores — официальные общие минимумы; `8 GB` RAM — рекомендация Microsoft. `5 GB` disk — консервативная практическая рекомендация Task 021, а не требование Microsoft. Ни один результат не разрешает активацию или запуск Sandbox.

## Статические и синтетические проверки

| Проверка | Метод | Результат |
|---|---|---|
| PowerShell 7 полный AST parse | `System.Management.Automation.Language.Parser::ParseFile` | `PASS` |
| Command / data-source allowlist | AST перечисление всех команд и ручная проверка узких .NET/CIM источников | `PASS`: только `Set-StrictMode`, встроенные pure helpers, точечные `Get-CimInstance` запросы, platform/identity, OSVersion/architecture, Windows directory и один `DriveInfo` |
| Prohibited API scan | Статический поиск activation, UI, process/service, network, registry discovery, drive enumeration, file writes и TEST/1C APIs | `PASS`: запрещённых вызовов нет |
| Pure-helper synthetic matrix | В памяти извлечены только `Get-ELSIProbePlan`, numeric/status normalizers, version/architecture classifiers и report decision helper | `PASS`, 49 assertions: full eligibility, Win10 min and below, Win11, x64, ARM64 boundary before/at 22H2, old OS/X86, each resource below threshold, null/non-numeric/mixed inputs, gate short-circuit, fixed keys and suppression of raw fixture values |
| Independent query failure simulation | Null один probe за раз, остальные — synthetic successful values | `PASS`, 5/5; успешные категории сохраняются, итог становится `PARTIAL_REPORT` |
| Output schema / enum allowlist | Четыре synthetic report scenarios, форматирование и фиксированный набор значений | `PASS`, 64 field-lines; только keys/statuses разрешённого набора |
| Entrypoint / real host APIs | Не выполнялись | `NOT_ATTEMPTED` |
| Windows Sandbox, `.wsb`, 1С, TEST/PRODUCTION | Не запускались/не открывались/не проверялись | `NOT_ATTEMPTED` / `NONE` |

Тестовая оболочка была только in-memory PowerShell-кодом: парсер считал исходник, затем AST использовался для определения именно pure helper functions. Host query functions и entrypoint AST не исполнялись. Постоянные synthetic fixture files не создавались. Здесь `READ_ONLY_REPORT` означает только полноту категориального отчёта; отдельные `FAIL` — stop condition, и даже все `PASS` не доказывают guest isolation, license readiness или разрешение включить feature.

Официальные источники Microsoft Learn (на страницах указано `Last updated 2026-03-29`): [Windows Sandbox install prerequisites](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install) и [Sandbox configuration options](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file). Фактические характеристики Windows владельца не опрашивались.

## Documentation reconciliation

| Документ / источник | Осмотрен | Изменён и почему | Проверка / расхождения |
|---|---|---|---|
| `AGENTS.md`, Task 021 | Да; AGENTS прочитан первым, Task полностью после | Task 021 включается verbatim; AGENTS не изменён | Область, allowlist, runtime запреты и publication gates сверены. |
| Tasks/Reports 019–020, `.wsb`, Task 020 validator | Да | Без изменений | Предыдущие статусы `STATIC_VALIDATED` сохранены; настоящая конфигурация и валидатор не запускались этим заданием. |
| `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` | Да | Да — добавить граничное описание preflight и команду только после аудита | Сопоставлено с источниками Microsoft; категория не представлена как isolation/feature readiness. |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` | Да | Да — зафиксировать новый инструмент, audit gate и unrun status | `APPLICATION_RESTORE=NOT_ATTEMPTED`; `GUEST_NETWORK_ISOLATION=UNVERIFIED`. |
| `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` | Да | Да — обновить Task 020/021 evidence provenance и matrix row | Codex/owner host run остаются not attempted; исторические owner claims не переоценены. |
| `DEV/docs/IMPLEMENTATION_STATUS.md` | Да | Да — добавить coded/static/synthetic status | Product/architecture statuses неизменны; запуск и runtime readiness не повышены. |
| `DEV/docs/CHANGELOG.md` | Да | Да — фактическая Task 021 запись, Task 020 помечен retrospection | Отражает проверенные только статические/синтетические действия. |
| `README.md` | Да | Нет — материал остаётся точным | Проект не получил новую продуктовую функцию; safety links уже доступны. |
| `DEV/docs/ARCHITECTURE.md` | Да | Нет — архитектурного решения нет | Архитектура остаётся `NOT_APPROVED`. |
| `DEV/docs/REQUIREMENTS.md` | Да | Нет — бизнес-требования не менялись | Продукт остаётся `NOT_IMPLEMENTED`. |
| `DEV/docs/SECURITY.md` | Да | Нет — общая политика не меняется | Источник не публикует raw host values/secrets; security workflow не менялся. |
| `DEV/docs/DEVELOPMENT_WORKFLOW.md` | Да | Нет — применены уже описанные gates | Отчёт содержит результаты и reconciliation. |
| `DEV/docs/TASK_TEMPLATE.md` | Да | Нет — шаблон применим без изменений | Нет противоречия требованиям 021. |

Task → read-only source → AST/pure synthetic checks → canonical docs → report согласованы. Противоречий, требующих архитектурного решения, нет. `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`, `HOST_FEATURE_ACTIVATION=NOT_ATTEMPTED`, `GUEST_LAUNCH=NOT_ATTEMPTED`, `GUEST_NETWORK_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE` не изменились. Новый единственный статус — preflight tool `CODED` / `STATIC_CHECK=PASS` / `SYNTHETIC_TEST=PASS`, entrypoint unrun.

## Публикация

Отчёт создан до commit. Перед публикацией будут проверены точные staged paths, весь diff, UTF-8, ссылки, приватные данные, `git diff --cached --check`; затем вручную запускаются Index/Outgoing publication checks с неизменёнными hooks. Final remote SHA, GitHub readback и exact-SHA Actions будут сообщены после push. `CI=PASS` будет указан только при найденном completed/success workflow для exact commit; отсутствие combined status само по себе не считается отсутствием Actions run.

`NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`. Не запускать новый инструмент, не активировать feature, не открывать `.wsb`, не запускать Sandbox/1С и не начинать Task 022.
