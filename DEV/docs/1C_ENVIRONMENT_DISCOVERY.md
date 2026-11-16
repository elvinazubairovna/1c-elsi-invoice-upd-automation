# Исследование среды 1С: подтверждённые факты и открытые вопросы

**Состояние:** инвентаризация и публичное исследование завершены; готовность фактического tenant неизвестна. Все варианты ниже — `NOT APPROVED`.
**Дата проверки публичных источников:** 2026-11-15.

## Purpose and scope

Это безопасная read-only инвентаризация для будущего решения архитектора. Проверены известные файлы репозитория, безопасные локальные признаки доступности инструментов и публичные официальные страницы. Не выполнялся вход в 1С, запуск 1С, просмотр данных или настроек, запрос к tenant/API, пробное подключение, установка, изменение конфигурации или проверка полномочий. Ни один факт о реальной базе/учётной записи не выводится из документации вендора.

## Evidence register

| ID | Тип источника | Источник / URL | Дата наблюдения | Утверждение и уверенность |
|---|---|---|---|---|
| E01 | Репозиторий: задача 004 и требования | `DEV/tasks/004_1C_ENVIRONMENT_DISCOVERY.md`; `DEV/docs/REQUIREMENTS.md` | 2026-11-15 | Цель проекта описывает будущие счета/УПД; конкретная интеграция и технические решения не утверждены. Высокая уверенность в содержимом репозитория. |
| E02 | Локальные безопасные индикаторы | Командные версии ОС/PowerShell/Git и поиск только известных имён команд 1С в PATH | 2026-11-15 | Windows, PowerShell 7.6.5 и Git 2.53.0 доступны; команды `1cv8`, `1cv8c`, `ibcmd`, `designer` не обнаружены через `Get-Command`. Это не доказывает отсутствие локального приложения и ничего не говорит о доступности облака. |
| E03 | Официальный FAQ 1С:Фреш | [«Справка и поддержка — Приложения сервиса»](https://www.1cfresh.com/articles/faq_app) | 2026-11-15; страница опубликована 2017-03-01 | Описывает типовые приложения, доработки через расширения/дополнительные отчёты и интерфейс OData; для клиентской доработки направляет к обслуживающей организации, установку связывает с владельцем абонента. Общее описание, не подтверждение конкретного tenant. |
| E04 | Официальный FAQ для разработчиков | [«Справка и поддержка — Информация для разработчиков»](https://www.1cfresh.com/articles/faq_dev) | 2026-11-15; страница опубликована 2021-10-17 | Указывает OData для обмена/интеграции; добавление расширений/обработок связывает с разработчиками обслуживающих организаций, авторизованными провайдером. Загруженное направляется на аудит; использование после успешного аудита. Общее описание. |
| E05 | Официальная инструкция 1С:Фреш | [«Работа с данными приложения в сервисе 1С:Фреш через стандартный интерфейс OData»](https://www.1cfresh.com/articles/data_odata) | 2026-11-15; страница опубликована 2022-09-30 | Публично описывает чтение и запись, настройку доступных объектов и пользователя/роль OData; см. ограничения ниже. Не доказывает доступность/настройки в нашей среде. |
| E06 | Официальная процедура для обслуживающих организаций | [«Как добавить для своего клиента расширение конфигурации, дополнительный отчет или обработку?»](https://www.1cfresh.com/articles/so_addprocess) | 2026-11-15; страница опубликована 2016-09-28 | Описывает разработку, тестирование, аудит провайдером, предоставление доступа и установку владельцем абонента. Не подтверждает, что такой процесс доступен именно нам. |
| E07 | Официальная авторизация разработчиков | [«Авторизация разработчиков расширений, дополнительных отчетов и обработок»](https://www.1cfresh.com/articles/so_addprocess_dev) | 2026-11-15; страница опубликована 2016-09-28 | Авторизация относится к сотрудникам обслуживающей организации; требуется процедура провайдера и право владельца абонента на добавление. Общее условие, не факт о наших ролях. |
| E08 | Официальная инструкция для абонента | [«Как расширить возможности приложений сервиса?»](https://www.1cfresh.com/articles/work_addprocess) | 2026-11-15; страница опубликована 2016-09-28 | Клиент обращается к обслуживающей организации; согласуются правообладатель и разработчик; после аудита доступ зависит от владельца, а установку выполняет владелец абонента. Общее условие. |
| E09 | Официальная инструкция 1С | [«Как установить расширение, дополнительный отчет или обработку в приложение?»](https://www.1cfresh.com/articles/app_addprocess) | 2026-11-15; страница опубликована 2016-09-30 | Описывает установку/удаление владельцем абонента в приложении. Никаких действий в приложении в этой задаче не производилось. |
| E10 | Официальная документация 1С:ИТС | [«Возможности подсистемы Фреш для интеграции с другими сервисами»](https://its.1c.ru/db/content/fresh/src/index.html) | 2026-11-15; страница изменена 2026-06-24 | Публично доступен обзор нескольких интеграционных механизмов. Часть связанной подробной документации может требовать доступа; она не изучалась и помечена `UNVERIFIED`. |
| E11 | Официальный каталог 1С:Фреш | [«1С:Магазин расширений»](https://dev.1cfresh.com/) | 2026-11-15 | Каталог описывает существующие расширения и аудит. Коммерческая запись/доступность продукта не подтверждает возможность разработки, публикации или установки пользовательского расширения в данном tenant. |
| E12 | Owner-reported facts in Task 005 | `DEV/tasks/005_LOCAL_1C_CAPABILITY_ASSESSMENT.md` | 2026-11-15 | Владелец сообщил текущую локальную файловую среду и безопасные версии продукта/платформы. Статус только `OWNER_REPORTED`, независимо не проверено. |
| E13 | Owner-reported facts in Task 006 | `DEV/tasks/006_TEST_ENVIRONMENT_SAFETY_BASELINE.md`; [safety baseline](TEST_ENVIRONMENT_SAFETY.md) | 2026-11-16 | Владелец сообщил, что создал и вручную запускал отдельную TEST-базу. Наличие ранее существовавших записей неизвестного происхождения означает, что состав данных и изоляция не подтверждены; Codex к базе не обращался. |

## Environment facts and unknowns

### CONFIRMED_FROM_REPOSITORY

- В репозитории заданы общие цели автоматизации счетов и УПД.
- Архитектура и способ интеграции с 1С ранее не утверждены; бизнес-функции не реализованы (E01).
- Task 004 фиксировала ранее обсуждавшийся владельцем lead 1С:Фреш как `OWNER_STATED_BUT_NOT_INDEPENDENTLY_VERIFIED`. Более поздние безопасные сведения владельца в Task 005 сообщают локальный файловый вариант; это обновлённое `OWNER_REPORTED` значение, а не независимая проверка (E12).

### OWNER_REPORTED (Task 005, не проверено Codex)

- «Бухгалтерия предприятия», редакция 3.0; версия конфигурации `3.0.208.14`.
- Платформа «1С:Предприятие 8.5», версия `8.5.1.1343`.
- Локальная файловая информационная база, не Fresh; приложение запускается в тонком клиенте.
- Владелец сообщил о кнопках «1С:Предприятие»/«Конфигуратор» в окне запуска и отсутствии расширений от проверенных поставщиков в окне «О программе».
- Эти сведения не подтверждены Codex. Кнопка не доказывает права/успешный запуск; отсутствие расширений от проверенных поставщиков не доказывает отсутствие иных обработок. Скриншоты/пути/лицензии не читались.

### CONFIRMED_FROM_LOCAL_SAFE_INDICATORS

- Для рабочей среды Windows, PowerShell 7.6.5 и Git 2.53.0 были доступны при предыдущей задаче.
- Узкий поиск команд `1cv8`, `1cv8c`, `ibcmd`, `designer` по PATH ранее не обнаружил эти команды (E02); текущая задача повторно не исследовала локальную систему.
- Отсутствие команд не доказывает отсутствие GUI-клиента/базы и не говорит о правах или пригодности для автоматизации.

### CONFIRMED_FROM_OFFICIAL_PUBLIC_DOCS

- Официальные страницы описывают Fresh OData для чтения и записи, его объектные/пользовательские ограничения и обработку прав. Это относится к описанному Fresh сценарию, а не подтверждает локальную базу владельца (E05).
- Публичные страницы Fresh описывают авторизацию, аудит, доступ, установку и сопровождение обработок/расширений в сервисе. Это не доказывает права/условия локальной среды (E04, E06–E09).
- Эти публикации описывают общие механизмы и не подтверждают индивидуальную совместимость, роль или настройку базы.

### UNKNOWN / OWNER_CONFIRMATION_REQUIRED

- В Task 006 владелец сообщил о созданной отдельной TEST-базе (`OWNER_REPORTED`); полностью синтетический состав данных, безопасность и пригодность не проверены. См. [канонический safety baseline](TEST_ENVIRONMENT_SAFETY.md).
- Может ли владелец/ответственный специалист подтверждённо создавать и запускать внешние обработки в такой тестовой базе; права рабочей базы не проверять.
- Каковы действительные права пользователя, состояние безопасного режима и процессы сопровождения.
- Поддерживается ли пара конфигурации `3.0.208.14` и платформы `8.5.1.1343` для нужного вида `.epf`/`.cfe`; точная совместимость не выводится из названия/номеров или кнопки запуска.
- Какие штатные формы, интерфейсы, обмены/импорт-экспорт или разрешённые объекты реально доступны; настройки приложения не исследовались.
- Любые OData/API сетевые публикации, авторизация, разрешённые объекты/операции и сетевые ограничения.
### NOT_PERMITTED_TO_PROBE

- Реальный tenant, приложение, пользовательские роли/учётные записи, данные базы, URL с идентификаторами, сетевые/API endpoints, конфигурация OData и настройки приложения.
- Файлы локальной среды вне репозитория, диски, реестр, профили, браузеры, хранилища credentials, процессы или службы.
- Любые операции входа, чтения, записи, установки, публикации или подключения.

## Possible integration paths — NOT APPROVED

| Option | Vendor reference | Publicly documented capability | Preconditions / restrictions | Evidence for THIS tenant | Unknowns | Security / operational concerns |
|---|---|---|---|---|---|---|
| A. Built-in document functionality; manual or semi-manual work | E01, E03 | Project requirements name invoice/UPD as goal; vendor lists accounting application and describes standard application use. Actual document forms are not inspected. | Correct product/configuration, user role, manual review and business procedure. | Владелец сообщил продукт и редакцию (E12); фактические формы и доступные операции не проверялись. | Какие штатные документы доступны и как они создаются/подтверждаются. | Human review, duplicate prevention, access control, correctness of accounting fields. No workflow recommendation is made. |
| B. Additional processing / configuration extension in 1С:Фреш | E04, E06–E09 | Vendor describes these mechanisms and authorization/audit process for Fresh. Additional processing can change data. | Fresh deployment, authorized developer, rights/owner relationship, provider review/publication and owner installation. | Owner now reports local file deployment, not Fresh (`OWNER_REPORTED`, E12); Fresh-specific path is not established for this deployment. | Whether owner report is current/correct; applicable local `.epf`/`.cfe` rights and compatibility remain separate unknowns. | Audit does not prove fit for local use; additions may mutate data; update compatibility and maintenance. |
| C. Standard OData interface | E05; overview E03/E04 | Fresh documentation describes HTTP OData read/write; object scope and user permissions govern it. | For the Fresh mechanism, publication/configuration, limited object set, appropriate account role and authentication are prerequisites. Do not transfer these conditions to local deployment. | Owner reports a local file base rather than Fresh; no local OData availability/publication is established. | Whether any separately supported local interface is required, enabled and permitted. | Mutating operations can change accounting data; limit rights and avoid secrets. No endpoint or credentials were collected/tested. |
| D. Local client / local information-base automation | E02, E12; generic requirements E01 | No deployment-specific local mechanism established. No 1C CLI command was found in PATH in the earlier narrow check. | Owner reports a local file base and thin client; this remains `OWNER_REPORTED`, not independently verified. A supported interface, suitable rights and explicit approved design are still required. | Local file deployment reported, not verified; no commands discoverable in PATH previously. | Product/configuration compatibility, user privileges, interfaces, test-base existence and update support. | Local automation can affect financial records; do not open/copy/backup the working base; isolation, recovery and review require separate design. |
| E. External automation or import/export | E03, E05, E10 | Public docs describe data exchange/OData and a Fresh integration overview; no particular external tool, import format, endpoint, or entitlement is established. | A vendor-supported mechanism, format, availability, permission and safe test environment must be confirmed for the deployment. | `UNVERIFIED`. | Whether any relevant import/export or external interface exists and may be used. | Files/exports may contain sensitive data; transport, credentials, idempotency and error recovery require explicit future review. |

These rows are comparison categories only. They do not rank choices or grant permission to connect or modify data.

## Privacy and access boundaries

- No account login, 1C launch, tenant/API request, application-settings tour, data access, deployment or configuration change occurred.
- No credentials, tenant URLs, identifiers, company data, screenshots, exports, invoices, contracts, amounts or accounting records are included.
- Public vendor pages were consulted only for general product information. No project files or user/company environment details were sent to search services.
- OData and custom additions can mutate application data; any later use requires a separately approved design, least privilege, synthetic test base where available, human review and appropriate owner/provider approval.

## Owner confirmation checklist

Обновление Task 005 уже содержит безопасные `OWNER_REPORTED` продукт/редакцию/версии и локальный файловый вариант. Если позже потребуется уточнение — только текстом и без идентификаторов. Остаются три кратких вопроса:

1. Есть ли отдельно пустая/синтетическая тестовая база без копий реальных счетов или контрагентов? `UNKNOWN` до ответа.
2. Может ли владелец/ответственный специалист отдельно подтвердить возможность создавать и использовать `.epf` именно на тестовой базе, не проверяя права в рабочей базе? `UNKNOWN` до ответа.
3. Предполагается ли будущая автоматизация в той же локальной базе либо в отдельном согласованном контуре? `UNKNOWN` до ответа.

Не просить пароли, права администратора, имена/пути базы, URL, скриншоты, лицензионные сведения, файлы выгрузки или запуск Конфигуратора.
## Decision gate for architect

Before any architecture or prototype task, ChatGPT needs the owner to confirm that the reported product/deployment/version are current, generic test-base privileges, provider support/authorization status, applicable interface availability/restrictions, and whether a synthetic-only test base exists. Separately approved business requirements and safety/approval controls would still be needed. Until then it is impossible to determine whether an extension, OData, local automation, or import/export is eligible; no architecture can be selected from these public materials alone.

## Not implemented and not verified

No invoicing or UPD generation, integration, prototype, tenant connection, API request, import/export flow, 1C configuration change, extension or deployment was implemented or tested. Architecture remains `NOT_APPROVED`; tenant readiness is `UNKNOWN`. This dossier is not production authorization and does not assert that any described mechanism is available to this deployment.
