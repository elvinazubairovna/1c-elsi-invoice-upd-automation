# Отчёт 020 — подготовка пустого offline Sandbox запуска

## Результат

Подготовлена фиксированная конфигурация Windows Sandbox, repository-only read-only XML валидатор и операторские gates для будущих отдельных этапов. Конфигурация синтаксически и структурно проверена; это не доказательство эффективной runtime-изоляции и не разрешение открывать файл. Windows Sandbox, Hyper-V, `.wsb`, 1С, TEST и production не запускались/не открывались.

| Поле | Значение |
|---|---|
| Task | `020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH` |
| Expected base / local HEAD | `fbd735876d4679b4007fe26134dc81111c84022d` / совпадает |
| Remote `main` | GitHub connector показал latest commit `fbd735876d4679b4007fe26134dc81111c84022d`; локальный `git ls-remote` был недоступен из-за DNS |
| Branch / origin | `main` / ожидаемый HTTPS origin |
| Root AGENTS прочитан первым | `PASS` |
| WSB config | `CREATED`; `WSB_CONFIG=STATIC_VALIDATED` |
| XML / synthetic negatives / validator AST | `PASS` / 8 cases `PASS` / `PASS` |
| Host feature activation / guest launch | `NOT_ATTEMPTED` / `NOT_ATTEMPTED` |
| Guest network isolation / 1C offline install-license | `UNVERIFIED` / `UNVERIFIED` |
| Application restore / production access | `NOT_ATTEMPTED` / `NONE` |
| Product architecture / invoice-UPD | `NOT_APPROVED` / `NOT_IMPLEMENTED` |

## Git admission и выполненная область

Полностью прочитаны корневой `AGENTS.md`, затем Task 020. После них изучены Task/Report 019, Sandbox guide, restore plan, safety baseline, implementation status, changelog, README, architecture, requirements, security policy, development workflow, task template и непосредственно релевантные Reports 014–018. Git branch, origin URL, локальный HEAD, tracked status и `core.hooksPath=DEV/hooks` проверены. Local HEAD и свежий GitHub commit history совпали с ожидаемым базовым SHA. DNS-запрос `git ls-remote` завершился ошибкой разрешения адреса; branch history проверена через GitHub connector. Исходный Task 020 и исторический незатреканный Task 001 сохранены; Task 001 не staged.

Изменены только разрешённые пути:

- `DEV/tasks/020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH.md` — включено исходное задание verbatim.
- `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb` — ровно заданная XML-структура с семью security options; без комментариев, атрибутов, mapped folders, startup, путей и динамических значений.
- `DEV/tools/Test-ELSI-EmptySandboxConfig.ps1` — read-only валидатор фиксированного repository-relative config.
- `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` — обновлены состояние конфигурации, operator preflight, отдельные approval gates, licensing/install gate и предупреждение, что потенциально запускаемый файл пока открывать нельзя.
- `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` — статус Task 020 и ссылка на static config/validator; app restore и isolation остаются не подтверждены.
- `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` — обновлена Sandbox строка с различием static evidence и runtime.
- `DEV/docs/IMPLEMENTATION_STATUS.md` — добавлен Task 020 уровень coded/static-validated с непроведёнными host/guest/app проверками.
- `DEV/docs/CHANGELOG.md` — factual запись Task 020; Task 019 помечен ретроспективой.
- `DEV/reports/020_PREPARE_EMPTY_OFFLINE_SANDBOX_LAUNCH.md` — этот sanitized отчёт.

README не изменён: его общие ограничения и ссылки на план остаются точными, новых продуктовых возможностей нет. `ARCHITECTURE.md`, `REQUIREMENTS.md`, `SECURITY.md`, `DEVELOPMENT_WORKFLOW.md` и `TASK_TEMPLATE.md` проверены, но не требуют изменений: архитектура и бизнес-требования не менялись, существующая политика и процедура уже покрывают этот узкий технический артефакт. Предыдущие tasks/reports и инструменты read-only; внешние файлы не затрагивались.

## Статические и синтетические проверки

| Проверка | Команда/метод | Результат |
|---|---|---|
| Фиксированный `.wsb` XML | `pwsh -NoProfile -File DEV/tools/Test-ELSI-EmptySandboxConfig.ps1` | `STATUS=PASS`, `ERROR_CATEGORY=NONE` |
| Валидатор PowerShell AST | `System.Management.Automation.Language.Parser::ParseFile` через PowerShell 7 | `AST=PASS` |
| Синтетические отрицательные варианты | В памяти вызван только XML helper валидатора после dot-source; базовые строки синтетические, постоянные fixture-файлы не создавались | `PASS`, 8/8 отвергнуты: network enabled, clipboard enabled, mapped folders, LogonCommand, unknown node, duplicate field, DTD/external entity, malformed XML |
| Статический review источника | Полный файл вручную сверён по вызовам, путям и веткам ошибок | `PASS`: один фиксированный config read, DTD запрещён, resolver `$null`, без запуска процессов/ассоциаций, Windows/feature/registry/network/1C/TEST вызовов, записей и произвольного path параметра |
| Host/Sandbox/1C/TEST/PRODUCTION runtime | Не выполнялось | `NOT_ATTEMPTED` / `NONE` |

Валидатор выдаёт только `STATUS=PASS|FAIL` и фиксированный `ERROR_CATEGORY`. XML static pass подтверждает только структуру и значения в репозитории. Он не подтверждает установку/состояние Windows feature, запуск гостя, effective network isolation, лицензирование, допустимость передачи данных либо application restore.

Официальные нормативные ссылки проверены на Microsoft Learn (страницы помечены `Last updated 2026-03-29`): [Windows Sandbox configuration / `.wsb` options](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file), [install prerequisites and restart behavior](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install), [overview, temporary state and editions](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview). В Microsoft documentation default networking и clipboard redirection включены; `.wsb` XML позволяет управлять нужными элементами, а закрытие удаляет guest content. Ни одна ссылка не подтверждает конфигурацию конкретного компьютера.

## Ограничения и неизменные статусы

Task 020 не активировал Windows Sandbox/Hyper-V, не перезапускал ОС, не открывал `.wsb`, не запускал guest/VM/1С, не собирал host capabilities и не касался TEST/PRODUCTION. Существующий `_APP_SMOKE_016` и прочие локальные артефакты не исследовались и остались нетронуты. Не запрашивались и не публиковались лицензионные сведения. Approved ingress для offline installer или новой guest clone отсутствует; источник/backup mapping запрещён. Owner-reported Windows edition/virtualization/GUI состояния остаются только `OWNER_REPORTED`; feature activation не предпринималась.

## Documentation reconciliation

| Документ / источник | Просмотрен | Изменён и причина | Фактическая проверка / противоречие |
|---|---|---|---|
| `AGENTS.md` и Task 020 | Да; AGENTS полностью прочитан первым | Task 020 включён verbatim; AGENTS не менялся | Allowlist, host limits, статические проверки и публикационные gates соблюдены. |
| Task/Report 019 и prior Reports 014–018 | Да | История не редактировалась | Provenance и прежние runtime ограничения сверены; результаты владельца не представлены как Codex evidence. |
| `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` | Да | Да — добавить fixed config reference, owner gates, лицензирование, актуальные статусы | Guide соответствует конфигурации и validator output; открытие запрещено до отдельного аудита/go-ahead. |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` | Да | Да — зафиксировать Task 020 статическую конфигурацию и отсутствие runtime proof | `APPLICATION_RESTORE=NOT_ATTEMPTED`, isolation `UNVERIFIED`; противоречий нет. |
| `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` | Да | Да — заменить устаревшее «только Markdown sample» актуальным coded/static status | Ровно одна статическая проверка конфигурации; TEST runtime не проверялся. |
| `DEV/docs/IMPLEMENTATION_STATUS.md` | Да | Да — добавить coded/static-validated vs host/guest not-attempted | Продукт `NOT_IMPLEMENTED`, architecture `NOT_APPROVED`, synthetic purity `UNVERIFIED`; без повышения runtime readiness. |
| `DEV/docs/CHANGELOG.md` | Да | Да — Task 020 factual entry; Task 019 обозначен ретроспективой | Изменения соответствуют файлам и локальным проверкам; нет заявления об effective isolation. |
| `README.md` | Да | Нет — material statement/link remains accurate | Sandbox указан как будущий план; функция не стала продуктовой. |
| `DEV/docs/ARCHITECTURE.md` | Да | Нет — техническая подготовка не утверждает архитектуру | Архитектура по-прежнему `NOT_APPROVED`. |
| `DEV/docs/REQUIREMENTS.md` | Да | Нет — бизнес-требования не менялись | Конфигурация не реализует продуктовую возможность. |
| `DEV/docs/SECURITY.md` | Да | Нет — базовая политика уже требует ручного review и синтетических данных | В staged содержимом не добавлены секреты, host paths, файлы данных или binaries; security workflow не менялся. |
| `DEV/docs/DEVELOPMENT_WORKFLOW.md` | Да | Нет — существующий task/review/publication workflow применим | Статус и gates отражены в отчёте и итоговом сообщении. |
| `DEV/docs/TASK_TEMPLATE.md` | Да | Нет — template остаётся согласован с задачей | Required report and documentation reconciliation представлены. |

Связка `task → config/validator → static and synthetic checks → canonical docs → report` прослеживается. Исправлена устаревшая формулировка, что `.wsb` существует только в Markdown. Незакрытых task-related противоречий не осталось. Категории архитектуры/продукта не изменились; только конфигурационный артефакт перешёл из design-only к `STATIC_VALIDATED`.

## Публикационные проверки

Отчёт создан до коммита. В финальном проходе будут вручную проверены точный staged allowlist, полный diff, UTF-8, ссылки, приватные/секретные данные и `git diff --cached --check`. Обязательные `Index` и `Outgoing` запускаются непосредственно перед commit/push; штатные hooks не обходятся. На момент создания отчёта commit, push, remote readback и exact-SHA CI ещё `PENDING`; итог CI будет сообщён владельцу только по подтверждённым данным GitHub.

`NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`. Это задание не разрешает открывать конфигурацию, включать Windows Sandbox, импортировать файлы, устанавливать/лицензировать 1С либо начинать Task 021.
