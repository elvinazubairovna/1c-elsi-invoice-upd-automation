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

## Environment facts and unknowns

### CONFIRMED_FROM_REPOSITORY

- В репозитории заданы общие цели автоматизации счетов и УПД.
- Архитектура и способ интеграции с 1С ранее не утверждены; бизнес-функции не реализованы (E01).
- Предыдущее задание указывает, что 1С:Фреш ранее обсуждалась владельцем, но это только `OWNER_STATED_BUT_NOT_INDEPENDENTLY_VERIFIED`, не описание фактического размещения (E01).

### CONFIRMED_FROM_LOCAL_SAFE_INDICATORS

- Операционная система семейства Windows; PowerShell 7.6.5 и Git 2.53.0 доступны.
- Поиск только команд `1cv8`, `1cv8c`, `ibcmd`, `designer` через обычный PATH не нашёл их (E02). Не сканировались диски, реестр, службы, профили или другие проекты.
- Отсутствие этих команд не доказывает отсутствие GUI-клиента, локальной базы либо облачной подписки.

### CONFIRMED_FROM_OFFICIAL_PUBLIC_DOCS

- Официальная документация в общем виде описывает OData в 1С:Фреш для чтения и записи данных. В описанном вендором сценарии набор доступных объектов настраивается; настройка REST-сервиса требует административной роли «Полные права», которую страница для Fresh связывает с владельцем абонента. Для запросов описаны Basic-аутентификация и пользователь с административными правами или ролью `УдаленныйДоступOData`. Вендор рекомендует ограничивать доступ только используемыми видами объектов; действия OData подчиняются обычным проверкам прав и обработчикам событий. В Fresh отмечено отдельное ограничение на заголовок `1C_OData-DataLoadMode: true` (E05).
- Для публикации расширений/дополнительных отчётов и обработок публичные страницы описывают авторизацию разработчика, права владельца абонента, проверку/аудит вендором, выдачу доступа и установку владельцем. Сопровождение после обновлений — отдельная операционная обязанность (E04, E06–E09).
- Это факты о публично документированных механизмах, но не подтверждение продукта, версии, подписки, доступов или настройки конкретной среды.

### OWNER_STATED_BUT_NOT_INDEPENDENTLY_VERIFIED

- 1С:Фреш — ранее обсуждавшаяся возможная среда. Она не подтверждена как фактический продукт или тип размещения (E01).

### UNKNOWN / OWNER_CONFIRMATION_REQUIRED

- Точное название продукта/редакции 1С:Бухгалтерия и версия конфигурации/платформы.
- Размещение: 1С:Фреш, другая облачная площадка или локальная информационная база.
- Общая категория роли пользователя (например, владелец абонента или обычный пользователь); конкретные учётные данные не нужны.
- Поддерживает ли обслуживающая организация разработку/публикацию проверенных дополнений и применима ли к аккаунту процедура авторизации.
- Имеется ли отдельная тестовая информационная база только с синтетическими данными.
- Известно ли владельцу без дополнительного входа, что в его среде уже доступны соответствующие штатные интеграции/импорт-экспорт или настройки OData. Не требуется проводить исследовательский tour по настройкам.
- Доступность OData, состав разрешённых объектов, разрешённые операции, сетевые ограничения, применимые лимиты и конкретные права.

### NOT_PERMITTED_TO_PROBE

- Реальный tenant, приложение, пользовательские роли/учётные записи, данные базы, URL с идентификаторами, сетевые/API endpoints, конфигурация OData и настройки приложения.
- Файлы локальной среды вне репозитория, диски, реестр, профили, браузеры, хранилища credentials, процессы или службы.
- Любые операции входа, чтения, записи, установки, публикации или подключения.

## Possible integration paths — NOT APPROVED

| Option | Vendor reference | Publicly documented capability | Preconditions / restrictions | Evidence for THIS tenant | Unknowns | Security / operational concerns |
|---|---|---|---|---|---|---|
| A. Built-in document functionality; manual or semi-manual work | E01, E03 | Project requirements name invoice/UPD as goal; vendor lists accounting application and describes standard application use. Actual document forms are not inspected. | Correct product/configuration, user role, manual review and business procedure. | Нет подтверждения продукта, редакции, экранов или доступных операций. | Какие штатные документы доступны и как они создаются/подтверждаются. | Human review, duplicate prevention, access control, correctness of accounting fields. No workflow recommendation is made. |
| B. Additional processing / configuration extension in 1С:Фреш | E04, E06–E09 | Vendor documents extensions/reports/processings, with provider authorization, provider audit, owner-controlled access and installation. Additional processing can change data. | Fresh deployment and compatible configuration; authorized developer in servicing organization; rights/owner relationship; vendor review and publication; owner install; ongoing update support. | `UNVERIFIED`; no environment, provider, role, or eligibility confirmation. | Whether deployment is Fresh, service organization supports it, relevant approvals/rights and version compatibility. | Provider audit is a gate, not proof of fit or safety for this use; code may mutate accounting data; compatibility and maintenance. |
| C. Standard OData interface | E05; overview E03/E04 | Fresh documentation describes HTTP OData data reading/writing; published endpoint, object scope and user permissions govern access. | For documented Fresh: OData publication; object allowlist configured by an authorized owner/admin; dedicated user/role and authentication; supported operations and app permissions. Not all OData headers/features are supported. | `UNVERIFIED`; tenant type, enabled objects, endpoint, role and eligibility unknown. | Whether Fresh and the relevant OData configuration/rights exist; which objects/operations are permitted; account/network constraints. | Potentially mutating operations include create/update/delete and posting actions; least privilege and secret handling required; no credentials/endpoints collected or tested. |
| D. Local client / local information-base automation, only if local deployment is confirmed | E02; generic repository requirements E01 | No deployment-specific local mechanism established by this inventory. No 1C CLI command was found in PATH. | A local deployment, supported interface, suitable rights and explicit approved design would first need confirmation. | No local CLI discoverable; local database itself `UNKNOWN`. | Product, local client/server topology, interfaces, version and role. | Local automation can affect financial records; isolation, backups, auditability and human approval would require later design. |
| E. External automation or import/export | E03, E05, E10 | Public docs describe data exchange/OData and a Fresh integration overview; no particular external tool, import format, endpoint, or entitlement is established. | A vendor-supported mechanism, format, availability, permission and safe test environment must be confirmed for the deployment. | `UNVERIFIED`. | Whether any relevant import/export or external interface exists and may be used. | Files/exports may contain sensitive data; transport, credentials, idempotency and error recovery require explicit future review. |

These rows are comparison categories only. They do not rank choices or grant permission to connect or modify data.

## Privacy and access boundaries

- No account login, 1C launch, tenant/API request, application-settings tour, data access, deployment or configuration change occurred.
- No credentials, tenant URLs, identifiers, company data, screenshots, exports, invoices, contracts, amounts or accounting records are included.
- Public vendor pages were consulted only for general product information. No project files or user/company environment details were sent to search services.
- OData and custom additions can mutate application data; any later use requires a separately approved design, least privilege, synthetic test base where available, human review and appropriate owner/provider approval.

## Owner confirmation checklist

Please provide text-only, non-sensitive answers later through the project owner/architect:

1. Product and edition/version exactly as shown in the application's About page; omit tenant/account identifiers.
2. Deployment category: 1С:Фреш, another cloud host, or local information base.
3. Platform and configuration version numbers only; no server or database names.
4. Generic access role category relevant to integrations/add-ons; no username, login or credential.
5. Whether the servicing organization supports audited custom add-ons and whether the owner knows the applicable authorization process.
6. Whether a separate test information base with synthetic data exists. Do not export or provide a real database.
7. If already known, whether relevant built-in integration/import-export or OData access is available; no credentials, URLs, screenshots or risky settings tour.

## Decision gate for architect

Before any architecture or prototype task, ChatGPT needs the owner-confirmed product/deployment/version, generic privileges, provider support/authorization status, applicable interface availability/restrictions, and whether a synthetic-only test base exists. Separately approved business requirements and safety/approval controls would still be needed. Until then it is impossible to determine whether an extension, OData, local automation, or import/export is eligible; no architecture can be selected from these public materials alone.

## Not implemented and not verified

No invoicing or UPD generation, integration, prototype, tenant connection, API request, import/export flow, 1C configuration change, extension or deployment was implemented or tested. Architecture remains `NOT_APPROVED`; tenant readiness is `UNKNOWN`. This dossier is not production authorization and does not assert that any described mechanism is available to this deployment.
