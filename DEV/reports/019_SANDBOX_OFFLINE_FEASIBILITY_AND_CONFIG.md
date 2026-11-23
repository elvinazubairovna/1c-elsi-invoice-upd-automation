# Task 019 — Sandbox offline feasibility and config

## Статус при подготовке отчёта

Подготовлены плановая документация и XML-пример внутри Markdown; статическая XML проверка прошла. Windows-компоненты, Sandbox, Hyper-V, VM и 1С не активировались и не запускались. `Index`/`Outgoing`, commit, hooks, remote readback и exact-SHA CI выполняются после подготовки отчёта; CI пока `PENDING`. Это не архитектурная приёмка и не разрешение владельцу включать или запускать Sandbox.

| Поле | Значение |
|---|---|
| Task | `019_SANDBOX_OFFLINE_FEASIBILITY_AND_CONFIG` |
| Базовый local/remote SHA | `0f896957d60808d2438dd9df55cd7565f5e34f16` |
| Branch / origin | `main` / ожидаемый публичный origin |
| AGENTS-first | `PASS` — полный `AGENTS.md` прочитан до полного Task 019 |
| XML статическая проверка | `PASS` — in-memory parse; DTD запрещён; resolver отсутствует |
| Host feature activation / guest launch / 1С | `NOT_ATTEMPTED` / `NOT_ATTEMPTED` / `NOT_ATTEMPTED` |
| Guest isolation / application restore / production | `UNVERIFIED` / `NOT_ATTEMPTED` / `NONE` |
| Архитектура / генерация счетов и УПД | `NOT_APPROVED` / `NOT_IMPLEMENTED` |

## Owner-provided evidence и ограничения

Входные поля из задания записаны только как `OWNER_REPORTED`: edition `PRO`, virtualization `SUPPORTED`, run gate `NON_ELEVATED_PASS`, edition/virtualization queries `PASS`; Windows Sandbox и Hyper-V feature values `UNVERIFIED`, соответствующие queries `QUERY_ERROR`; общий итог `PARTIAL_REPORT`. Также владелец сообщил, что строки Windows Sandbox и Hyper-V были видны, но unchecked в Optional Features GUI. Это не проверено Codex и не является доказательством activation capability, entitlement, effective isolation или причины query errors. Query error не переименовывался в `DISABLED`/`NOT_AVAILABLE`.

Codex не выполнял host/system queries, не открывал Windows UI, реестр, Optional Features, BIOS/UEFI или локальные файлы; не взаимодействовал с TEST/PRODUCTION и не собирал 1С/лицензионные сведения. Существующие owner clones остаются нетронутыми и не считаются изолированными.

## Deliverable и статическая проверка

Создан [Windows Sandbox safe setup guide](../docs/WINDOWS_SANDBOX_SAFE_SETUP.md) на русском языке. В нём зафиксированы owner evidence, неизвестные prerequisites, официальный список общих требований, временный характер Sandbox, отсутствие ingress/installer/license/clone transport, альтернативы offline VM/computer, no-go статусы и необходимость отдельного разрешения для каждого будущего действия. Только Markdown содержит XML; исполняемого `.wsb` файла нет.

Команда статической проверки извлекла fenced `xml` snippet из Markdown и распарсила строку через `.NET XmlReader` с `DtdProcessing=Prohibit` и `XmlResolver=$null`. Проверены корень `Configuration`, точное наличие семи известных элементов и их значения: `vGPU=Disable`, `Networking=Disable`, `AudioInput=Disable`, `VideoInput=Disable`, `PrinterRedirection=Disable`, `ClipboardRedirection=Disable`, `ProtectedClient=Enable`; посторонние элементы и `MappedFolders`, `MappedFolder`, `HostFolder`, `LogonCommand`, `SandboxFolder`, `ReadOnly` отклоняются. Отдельный синтетический DTD/external-entity payload отвергнут парсером до разрешения внешней сущности. Результат: `PASS`. Ни XML shell association, ни запуск/сохранение `.wsb` не выполнялись.

Этот тест доказывает только синтаксис и содержимое XML snippet. Он не подтверждает effective guest isolation, feature availability, возможность безопасно передать installer/data, 1С compatibility/licensing, отсутствие внешних каналов или безопасность TEST.

## Официальные источники

Проверялись только публичные Microsoft Learn страницы, на которых указано последнее обновление `2026-03-29`:

- [Install Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install) — prerequisites, версия/архитектура, RAM/disk/CPU, hardware virtualization и GUI activation/restart.
- [Use and configure Windows Sandbox](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file) — допустимые XML tags/values, networking и clipboard defaults, mapped folders/logon command и удаление данных при close.
- [Windows Sandbox overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview) — disposable behavior и общая edition support.

Документы описывают Windows в общем и не подтверждают ни одного host-specific факта владельца.

## Documentation reconciliation

| Документ / источник | Осмотрен | Изменён и причина | Фактическая проверка и расхождения |
|---|---|---|---|
| `AGENTS.md`, Task 019 | Да; AGENTS.md полностью прочитан первым | Task 019 включён verbatim | Область, baseline, запреты, allowlist и publication gates сверены с источником |
| Task/Report 017–018, `Get-ELSI-IsolationReadiness.ps1` | Да | Нет; исторические файлы сохранены | Owner provenance и значения сверены с задачей 019; report/tool не исполнялись |
| `DEV/docs/WINDOWS_SANDBOX_SAFE_SETUP.md` | Да | Создан | Сверен с условиями Task 019 и тремя официальными Learn источниками; XML static check PASS |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` | Да | Да | Добавлены owner-reported statuses, guide link, плановые gates; app/isolations остаются unverified/not attempted |
| `DEV/docs/TEST_ENVIRONMENT_SAFETY.md` | Да | Да | Зафиксирован GUI/diagnostic provenance, plan-only status и новый matrix row; никакой host/test доступа не описан |
| `DEV/docs/IMPLEMENTATION_STATUS.md` | Да | Да | Записан `PLAN_ONLY` и static XML evidence; product/architecture categories unchanged |
| `DEV/docs/CHANGELOG.md` | Да | Да | Фактический Task 019 entry с ограничениями и ссылками |
| `README.md` | Да | Нет | Уже ведёт к recovery plan; guide связан из него, существенного README correction не требуется |
| `DEV/docs/ARCHITECTURE.md` | Да | Нет | Architecture remains `NOT_APPROVED`; новый вариант изоляции не выбран |
| `DEV/docs/REQUIREMENTS.md` | Да | Нет | Product requirements не менялись |
| `DEV/docs/SECURITY.md` | Да | Нет | Security policy не менялась; конкретные ограничения отражены в runbook |
| `DEV/docs/DEVELOPMENT_WORKFLOW.md` | Да | Нет | Workflow не менялся; publication gates применяются без исключений |
| `DEV/docs/TASK_TEMPLATE.md` | Да | Нет | Template не менялся; его документационные и status requirements соблюдены |
| `DEV/docs/TEST_APPLICATION_RESTORE_PLAN.md` / safety baseline current status | Да | В обоих учтено новое owner evidence | Ранее `QUERY_ERROR` не противоречит owner GUI report; ни то ни другое не подтверждает operability. No unresolved contradiction. |

Противоречий по статусу Sandbox не осталось: owner GUI evidence означает только видимый unchecked checkbox; tool result означает только `QUERY_ERROR` и `UNVERIFIED`; документация называет пример design-only. Не менялись `OUTBOUND_ISOLATION=UNVERIFIED`, `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `ARCHITECTURE=NOT_APPROVED`, `INVOICE_UPD_AUTOMATION=NOT_IMPLEMENTED`.

## Scope, privacy и публикация

Изменения ограничены: задача 019 verbatim; новый Markdown guide; recovery plan; safety baseline; implementation status; changelog; этот report. README не изменён. Не создавались `.wsb`, scripts, executables, installers, database exports, screenshots или persistent test fixtures. В тексте нет private host paths, usernames, license data, actual inventories, raw exceptions или бухгалтерских данных; owner evidence представлен только выданными sanitized status tokens.

Публикационные gates на момент подготовки отчёта: `Index=PENDING`, `Outgoing=PENDING`, `HOOKS=PENDING`, `GITHUB_PUSH=PENDING`, remote readback и final CI `PENDING`. Секьюрити workflow не менялся; специальный security workflow test не запускался. Если scanner или hook отклонит изменения, публикацию не обходить. `NEXT_ACTION=WAIT_FOR_CHATGPT_AUDIT`; Task 020 не начиналась.
