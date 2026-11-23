# Windows Sandbox: безопасная оценка и план подготовки

> Это документ для оценки и отдельных допусков. Task 019 содержала XML только как Markdown sample; Task 020 добавила пустую конфигурацию без host mappings и статический валидатор. Позднее владелец сообщил, что в Task 022 вручную открыл именно эту пустую конфигурацию, увидел отдельное окно Sandbox и закрыл его. Это `OWNER_REPORTED`, не независимое runtime-подтверждение Codex; ни данный отчёт, ни его исход не разрешают новый запуск или импорт файлов.

## Что известно и что пока неизвестно

Владелец сообщил после Task 018: `OS_EDITION_CLASS=PRO`, `VIRTUALIZATION_SUPPORT=SUPPORTED`, `RUN_GATE=NON_ELEVATED_PASS`, `EDITION_QUERY=PASS`, `VIRTUALIZATION_QUERY=PASS`; одновременно `WINDOWS_SANDBOX_FEATURE=UNVERIFIED`, `HYPERV_FEATURE=UNVERIFIED`, `SANDBOX_QUERY=QUERY_ERROR`, `HYPERV_QUERY=QUERY_ERROR`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `STATUS=PARTIAL_REPORT`. Это `OWNER_REPORTED`, а не результат проверки Codex. `QUERY_ERROR` не означает `DISABLED` или `NOT_AVAILABLE`.

На момент Tasks 019–021 владелец сообщал, что Windows Sandbox и Hyper-V видны, но не отмечены в GUI компонентов Windows; это историческое `OWNER_REPORTED` состояние. После Task 021 владелец сообщил, что включил только Windows Sandbox через GUI и перезапустил компьютер. В Task 022 после перезапуска checkbox Windows Sandbox был виден отмеченным. Это только `OWNER_REPORTED` UI evidence; Codex не проверял состояние host, политику, Hyper-V internals, entitlement или effective isolation. О Hyper-V после перезапуска отдельного утверждения нет. Не включать его по предположению.

Официальная документация Microsoft указывает следующие общие prerequisites Windows Sandbox: Windows 10 version 1903+ или Windows 11; AMD64, а для Windows 11 version 22H2+ также Arm64; аппаратная virtualization; минимум 4 GB RAM (рекомендуется 8 GB), 1 GB свободного диска и два CPU cores. В общих сведениях Microsoft перечислены поддерживаемые редакции Pro, Enterprise, Pro Education/SE и Education; Windows Home не поддерживается. Эти требования не проверялись на компьютере владельца и не доказывают наличие права на использование Sandbox или 1С.

Перед возможным будущим допуском владелец может, только в рамках отдельно утверждённого шага, самостоятельно просмотреть:

- в **Параметры → Система → О системе** — версию/редакцию Windows и архитектуру;
- в **Параметры → Система → Память** — доступное дисковое место, а в диспетчере задач — доступную память и CPU;
- в UEFI/BIOS или согласованном Windows UI — включена ли аппаратная virtualization;
- с ответственным за устройство — допустимость включения Sandbox, возможную необходимость перезапуска и последствия для текущей работы;
- отдельно — доступность проверенного офлайн-дистрибутива 1С, совместимость клиентской версии и разрешённый офлайн способ лицензирования/активации;
- отдельно спроектировать безопасную доставку нового disposable clone и установщика в гостевую среду.

Эти проверки не выполнялись сейчас. Не надо передавать сюда локальные пути, скриншоты с идентификаторами, ключи, учётные данные или сведения об установленных программах.

Windows Sandbox одноразовый: при закрытии гостя его файлы, установленное ПО и состояние удаляются. Microsoft указывает, что начиная с Windows 11 22H2 данные переживают перезапуск, инициированный внутри Sandbox, однако это не сохраняет содержимое после закрытия Sandbox. Не строить процесс на предположении о сохранении между сессиями.

## Кандидат минимальной конфигурации — только пример

Следующий пример использует документированные Microsoft XML options. Он выключает network, clipboard, vGPU, audio/video input и printer redirection, включает Protected Client, не содержит `MappedFolders`, `MappedFolder`, `HostFolder` или `LogonCommand`.

```xml
<Configuration>
  <vGPU>Disable</vGPU>
  <Networking>Disable</Networking>
  <AudioInput>Disable</AudioInput>
  <VideoInput>Disable</VideoInput>
  <PrinterRedirection>Disable</PrinterRedirection>
  <ClipboardRedirection>Disable</ClipboardRedirection>
  <ProtectedClient>Enable</ProtectedClient>
</Configuration>
```

Это **design-only empty isolation smoke candidate**, а не готовая конфигурация для 1С и не доказательство эффективной изоляции. Не создавайте и не запускайте `.wsb` сейчас. Обычный запуск Sandbox имеет включённые по умолчанию сеть и перенаправление буфера обмена; отсутствие этих тегов нельзя трактовать как безопасное значение. Явные `Disable` указаны именно в примере.

В конфигурации нет разрешённого способа передать в гостя установщик или данные. При выключенных clipboard и mapped folders одобренного ingress-пути нет. Для будущего запуска потребуется отдельное архитектурное и security-решение по offline-передаче **нового** тестового клона и дистрибутива, подтверждение его идентичности и фактической изоляции гостя до запуска 1С. Не предполагать, что Sandbox сам получает файлы, доступ к установленной на host 1С или нужную лицензию. Если отдельное решение когда-либо допускает временное host sharing, оно должно быть ограничено специально подготовленным staging-каталогом только для теста; нельзя подключать каталог существующего source/backup/restore/host clone либо production.

## Кратчайший путь и gates для отдельного будущего задания

1. Дождаться независимого аудита Task 019: он проверяет только этот runbook и статический XML пример.
2. Только после отдельного разрешения владелец решает, допустимо ли включение **Windows Sandbox** в GUI. Перед этим сохранить работу и оценить возможный запрос перезапуска и влияние на host. Не включать отдельный Hyper-V feature checkbox по одному факту его наличия. Если Windows просит неожиданный компонент, elevation, reboot либо появляется предупреждение о host impact — остановиться и получить решение; не обходить защиту и не менять сетевые/firewall-настройки.
3. Если отдельное задание разрешит и Sandbox будет включён, сначала рассмотреть только пустой гостевой smoke с отдельно проверенной конфигурацией: networking/clipboard явно disabled, mapped folders отсутствуют, ничего не установлено и не перенесено. Проверить effective isolation отдельными согласованными доказательствами; корректный XML сам по себе этого не подтверждает. В текущем задании запуск запрещён.
4. До любого 1С-теста отдельное задание должно подтвердить офлайн-установщик, совместимость платформы, право/работу офлайн-лицензии, безопасный путь доставки и отдельный новый disposable clone. Не открывать `_APP_SMOKE_016` на host и не отображать в госте backup/source/production folders.
5. Если Sandbox недоступен, не разрешён, несовместим с клиентом/лицензированием или изоляцию нельзя подтвердить, оценить в отдельном задании disposable offline VM либо выделенный offline computer. Для них также нужны отдельный план переноса копии, доказательство отключённой сети и отсутствия host/production shares. Сейчас ни один вариант не выбран и не подтверждён.
6. Критерии успешного/неуспешного восстановления в 1С определяются отдельным заданием. Не использовать реальные бухгалтерские данные или реальные адресаты.

## Текущий запретительный статус

| Поле | Статус |
|---|---|
| `CURRENT_SANDBOX_FEATURE` | `OWNER_GUI_UNCHECKED` |
| `GUEST_CONFIG` | `STATIC_VALIDATED`; runtime remains unverified |
| `GUEST_NETWORK_ISOLATION` | `UNVERIFIED` |
| `HOST_FEATURE_ACTIVATION` | `NOT_ATTEMPTED` |
| `APPLICATION_RESTORE` | `NOT_ATTEMPTED` |
| `1C_OFFLINE_INSTALL_LICENSE` | `UNVERIFIED` |
| `OUTBOUND_ISOLATION` | `UNVERIFIED` |
| `TEST_DATA_FULLY_SYNTHETIC` | `UNVERIFIED` |
| `PRODUCTION_ACCESS` | `NONE` |

Не включать Windows components, не перезапускать Windows, не запускать Sandbox или 1С, не передавать тестовые файлы и не открывать TEST/PRODUCTION по этому runbook.

## Следующая операторская фаза — только после отдельных gates

Task 020 добавил в репозиторий потенциально запускаемый файл [`DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb`](../config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb) и read-only статический валидатор [`Test-ELSI-EmptySandboxConfig.ps1`](../tools/Test-ELSI-EmptySandboxConfig.ps1). XML статически проверяется, но это **не одобрение открытия**. Не открывайте файл двойным щелчком и не запускайте Sandbox обычным пунктом меню: такой запуск создаёт реальный гостевой сеанс, а default networking включён.

### Preflight владельца — будущий отдельный допуск

До изменения компонентов владелец должен отдельно проверить версию Windows, соответствие требованиям Sandbox, доступные RAM и место на диске, а также сохранить и закрыть важную работу, включая 1С. Не публикуйте системные идентификаторы, снимки с личными сведениями или локальную инвентаризацию. Если хотя бы одно требование или влияние на host неясно — Sandbox не включать.

### Включение компонента — только после явного отдельного решения

Только после отдельного явного разрешения владелец может выбрать компонент **Windows Sandbox** через GUI, если prerequisites и возможное влияние на host приемлемы. Не включать весь Hyper-V автоматически, не менять BIOS, сеть, общий firewall или параметры production. Windows может запросить elevation или перезапуск; сохраните работу заранее и остановитесь при неожиданном запросе, предупреждении или влиянии. Task 020 не выполняет и не разрешает эту активацию.

### Пустой гостевой smoke — после независимого аудита и отдельного go-ahead

Если отдельный аудит кода и операторский допуск завершены, кандидат запускается только через опубликованный и проверенный `.wsb`, никогда через generic Start menu/default launcher. Первый smoke должен быть пустым: никакой 1С, установщиков, TEST-файлов или импортов. Требуется проверить эффективную изоляцию внутри фактической среды; XML и настройки являются свидетельством конфигурации, но не runtime-attestation сети или безопасности. Сейчас запуск не разрешён.

### Лицензия, установка и доставка данных для 1С

До реального 1С-теста отдельно подтвердить законный и технически пригодный offline-путь установки/лицензирования 1С во временном guest. Нельзя считать, что host activation действует в Sandbox. Не передавать в публичные документы или чат ключи, PIN, лицензии, установщики или другие секреты. Если подходящий вариант не подтверждён, остановиться; отдельно оценить стабильную изолированную offline VM или выделенный offline test computer. Не переносить лицензионные данные с host.

У текущего host-side `_APP_SMOKE_016` нет статуса изолированного guest-клона; он остаётся нетронутым и не запускается. Для будущего guest потребуется новая отдельная nonproduction копия и специально проверенный способ передачи. Host source/backup каталог не маппить. При отключённых clipboard и mapped folders утверждённого пути импорта 1С/данных пока нет.

| Поле | Статус Task 020 |
|---|---|
| `WSB_CONFIG` | `STATIC_VALIDATED` |
| `HOST_SANDBOX_FEATURE` | `OWNER_GUI_UNCHECKED` |
| `HOST_FEATURE_ACTIVATION` | `NOT_ATTEMPTED` |
| `GUEST_LAUNCH` | `NOT_ATTEMPTED` |
| `GUEST_NETWORK_ISOLATION` | `UNVERIFIED` |
| `1C_OFFLINE_INSTALL_LICENSE` | `UNVERIFIED` |
| `APPLICATION_RESTORE` | `NOT_ATTEMPTED` |
| `PRODUCTION_ACCESS` | `NONE` |

Не включайте Windows Sandbox по этому документу, не открывайте `.wsb` и не запускайте 1С. Для будущего guest import или app check требуется отдельное задание, review и operator approval.

## Предварительная оценка требований host — после аудита скрипта

Task 021 подготовила `DEV/tools/Get-ELSI-SandboxHostPreflight.ps1` для однократного запуска владельцем в обычном PowerShell 7 **только после независимого аудита точного исходника ChatGPT**. Команда после такого аудита:

```powershell
pwsh -NoProfile -File DEV/tools/Get-ELSI-SandboxHostPreflight.ps1
```

Скрипт только классифицирует совместимость Windows, архитектуру, RAM, число физических ядер и свободное место на системном томе. Он не перепроверяет Windows Sandbox/Hyper-V checkbox и не вызывает ненадёжный feature query; статусы `PRO`, `SUPPORTED`, `OWNER_GUI_UNCHECKED` остаются сообщёнными владельцем и помечаются `NOT_REVERIFIED`. Скрипт не запрашивает повышение прав и отказывается продолжать проверки при elevated, non-Windows или неизвестном запуске. В output нет точных размеров, версии/build, путей или иных идентификаторов.

Официальные общие минимумы Microsoft: Windows 10 build 18362+ или Windows 11; x64, либо ARM64 для Windows 11 22H2+; RAM 4 GB; свободное место 1 GB; два CPU cores; включённая аппаратная virtualization. 8 GB RAM указаны Microsoft как рекомендация. Для оценки запаса места Task 021 использует 5 GB как консервативный практический ориентир, а не как минимум Microsoft. `READ_ONLY_REPORT` означает только, что скрипт получил категории для всех полей; отдельное `FAIL` в любом минимальном поле — стоп-сигнал. Даже полный report без FAIL не подтверждает effective guest isolation или готовность 1С и не даёт разрешения включать Windows Sandbox. При FAIL, `PARTIAL_REPORT`, `UNVERIFIED` или `BLOCKED_BY_RUN_GATE` остановиться и запросить решение; не менять настройки host.

| Поле | Статус Task 021 |
|---|---|
| `HOST_PREFLIGHT_TOOL` | `CODED_STATIC_TESTED_NOT_RUN` |
| `CODEX_HOST_PREFLIGHT` | `NOT_ATTEMPTED` |
| `OWNER_HOST_PREFLIGHT` | `NOT_ATTEMPTED` |
| `HOST_FEATURE_ACTIVATION` | `NOT_ATTEMPTED` |
| `GUEST_LAUNCH` | `NOT_ATTEMPTED` |
| `GUEST_NETWORK_ISOLATION` | `UNVERIFIED` |
| `APPLICATION_RESTORE` | `NOT_ATTEMPTED` |
| `PRODUCTION_ACCESS` | `NONE` |

Не публикуйте полный экран, точные ресурсы или host identifiers. После отдельного аудита можно вернуть только фиксированные строки результата, без свободного текста.

## Официальные источники Microsoft

Проверены публичные Microsoft Learn страницы (на страницах указано обновление `2026-03-29`):

- [Install Windows Sandbox — prerequisites и установка](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install): требования к версии/архитектуре, virtualization, памяти, диску и CPU; включение optional feature через GUI и возможный restart.
- [Use and configure Windows Sandbox — `.wsb` XML options](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file): XML schema options и значения, defaults networking/clipboard, доступные controls и удаление содержимого при закрытии.
- [Windows Sandbox overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview): временная природа Sandbox, поддерживаемые editions и общие границы/ограничения.

Официальные документы описывают продукт в общем. Они не подтверждают состояние конкретного компьютера, эффективную изоляцию, доступность файлового ingress/egress, права владельца, лицензию/совместимость 1С или пригодность данной TEST-копии.

## Task 022 — owner-reported empty guest outcome и следующий отдельный профиль

Все наблюдения ниже сообщены владельцем 23 ноября 2026 года; Codex не запускал host preflight, Windows Sandbox или 1С и не проверял screenshot'ы/локальные файлы:

- После аудита владелец запустил Task 021 preflight в обычной PowerShell 7: по сообщённому экрану `HOST_RUN_GATE=NON_ELEVATED_PASS`, `STATUS=READ_ONLY_REPORT`, категории версии ОС, архитектуры, RAM, диска и физических ядер были `PASS`. Это `OWNER_REPORTED_PASS`; ранее сообщённые `PRO` и поддержка virtualization остаются более ранними owner claims, preflight их не перепроверял.
- Владелец через GUI отметил только компонент Windows Sandbox и перезапустил ноутбук; после перезапуска сообщил, что checkbox Sandbox отмечен. Это не подтверждает OS policy, внутреннее состояние Hyper-V или эффективную изоляцию.
- Владелец локально запустил неизменённый Task 020 статический валидатор и сообщил `STATUS=PASS`, `ERROR_CATEGORY=NONE`. Это проверка XML-конфигурации, не runtime isolation.
- Владелец вручную открыл `DEV/config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb`: появилось отдельное окно Windows Sandbox. В него не переносились 1С, установщики, файлы, mapped folders или TEST-данные; Sandbox после пустого smoke был закрыт.
- В госте экран **Settings → Network & Internet** показал текст «Соединение отсутствует». Это только `OWNER_REPORTED_UI_NO_CONNECTION`; packet/route/adapter/policy проверок не было. `GUEST_NETWORK_ISOLATION=RUNTIME_UNVERIFIED`, `OUTBOUND_ISOLATION=UNVERIFIED`. Доказательства экрана гостя недоступны.
- В рамках этих действий `GUEST_LAUNCH=OWNER_REPORTED_EMPTY_SUCCESS_CLOSED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `PRODUCTION_ACCESS=NONE`; оригинальный host-side `_APP_SMOKE_016` не открывали и не меняли. `TEST_DATA_FULLY_SYNTHETIC=UNVERIFIED` сохраняется.

### Три разных профиля и границы передачи

1. **Пустая конфигурация Task 020:** опубликованный [`ELSI_EMPTY_OFFLINE_SANDBOX.wsb`](../config/ELSI_EMPTY_OFFLINE_SANDBOX.wsb) не содержит `MappedFolders`/`LogonCommand`; владелец сообщил об одном пустом запуске и закрытии. UI «Соединение отсутствует» не доказывает, что сеть технически недоступна.
2. **Будущая синтетическая ingress-конфигурация Task 022:** [`New-ELSI-SyntheticSandboxIngress.ps1`](../tools/New-ELSI-SyntheticSandboxIngress.ps1) — только код. После независимого аудита его owner-run может создать новую локальную disposable папку с одним безвредным marker-файлом и отдельный `.wsb`, который отображает только эту папку гостю с `ReadOnly=true`; сеть, clipboard и периферийные перенаправления выключены, ProtectedClient включён. В Task 022 этот tool не запускался, папка и `.wsb` не создавались.
3. **Установка 1С или импорт TEST/backup:** `NOT_APPROVED`. Не отображать в госте TEST, `_APP_SMOKE_016`, source/backup/restore-каталоги, документы, установщики или любые реальные данные. Read-only mapping всё равно раскрывает гостю содержимое выбранной host-папки; это иной профиль, чем пустой Sandbox, и не доказывает isolation.

Даже при успешном статическом XML helper report означает только `NETWORKING=DISABLED_IN_CONFIG`, а не фактический запрет сетевых коммуникаций. Возможные Windows policy overrides и эффективное состояние гостя остаются непроверенными. Следующий простой шаг после отдельного аудита ChatGPT — владелец может запустить только подготовительный tool и вернуть его фиксированные статусы; **не открывать** созданный `.wsb` до нового отдельного аудита/явного допуска. Ни один статус Task 021/022 не разрешает запуск 1С или передачу существующей TEST-копии.

### Развилка проверки правомерного и offline-маршрута 1С

Это только критерии для отдельного решения; мы не исследовали установленную платформу, пользовательские аккаунты, ключи, PIN, лицензии, дистрибутивы или эту TEST-базу.

1. Сначала определить у правообладателя/обслуживающего партнёра, существует ли законный offline-дистрибутив нужной платформы и совместим ли он с отдельным стендом. Сам факт наличия installer на host ничего не разрешает и не создаёт approved ingress.
2. Для реального коммерческого учётного теста потребуются подходящая коммерческая основная поставка/клиентские права и подтверждение условий использования для отдельного компьютера/виртуальной среды. Официальный FAQ 1С говорит, что область основной поставки связана с локальной сетью её использования; лицензия разработчика предназначена для разработки/отладки, community-лицензия — для разработки, а учебные версии не предназначены для автоматизации процессов реального предприятия. Их нельзя выдавать за коммерческую лицензию на реальный бухгалтерский сценарий.
3. До выбора ephemeral Sandbox выяснить для **конкретного** продукта, нужен ли portal/account/телефон, онлайн доступ или отдельная активация/восстановление. Страница 1С для developer/community вариантов требует регистрации с подтверждением мобильного телефона; официальный FAQ описывает email/phone получение программной лицензии для отдельных базовых поставок, но это нельзя обобщать на все коммерческие лицензии. Документация 1Ci предупреждает, что параметры VM могут меняться и вызывать повторное восстановление программной лицензии. Следовательно, офлайн-лицензирование ephemeral guest сейчас `UNVERIFIED`; никакие секреты не предоставлять Codex.
4. Если допустимую офлайн установку, лицензию, активационный маршрут и совместимость нельзя подтвердить заранее, не использовать Sandbox для 1С. Отдельно оценить устойчивую offline VM или standalone lab computer с собственным лицензированием и изоляцией.

Официальные источники 1С/1Ci: [ответы по лицензированию 1С:Предприятия 8](https://v8.1c.ru/priobretenie-i-vnedrenie/otvety-na-tipovye-voprosy-po-litsenzirovaniyu-1s-predpriyatiya-8/), [учебные версии](https://v8.1c.ru/podderzhka-i-obuchenie/uchebnye-versii/), [лицензия разработчика](https://v8.1c.ru/platforma/litsenziya-dlya-razrabotchikov/) и [лицензии в виртуальной среде](https://kb.1ci.com/1C_Enterprise_Platform/FAQ/Administration/Licenses/How_to_avoid_constant_software_license_restoration_in_virtual_environment/). Источники описывают общие условия и не решают применимость к конкретной установке/конфигурации.

| Поле | Текущий evidence после Task 022 |
|---|---|
| `OWNER_PREFLIGHT` | `OWNER_REPORTED_PASS` |
| `HOST_SANDBOX_FEATURE` | `OWNER_GUI_CHECKED_POST_REBOOT` |
| `EMPTY_GUEST_LAUNCH` | `OWNER_REPORTED_SUCCESS_CLOSED` |
| `GUEST_UI_NETWORK` | `OWNER_REPORTED_NO_CONNECTION` |
| `GUEST_NETWORK_ISOLATION` / `OUTBOUND_ISOLATION` | `RUNTIME_UNVERIFIED` / `UNVERIFIED` |
| `SYNTHETIC_INGRESS_TOOL` | `CODED_STATIC_TESTED_NOT_RUN` |
| `SYNTHETIC_INGRESS_OWNER_RUN` | `NOT_ATTEMPTED` |
| `OFFLINE_1C_INSTALL_LICENSE` | `UNVERIFIED` |
| `APPLICATION_RESTORE` | `NOT_ATTEMPTED` |
| `ARCHITECTURE` / `INVOICE_UPD_AUTOMATION` | `NOT_APPROVED` / `NOT_IMPLEMENTED` |
| `PRODUCTION_ACCESS` | `NONE` |
