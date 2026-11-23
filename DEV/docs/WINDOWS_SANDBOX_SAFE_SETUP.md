# Windows Sandbox: безопасная оценка и план подготовки

> Это документ для оценки и будущего отдельного допуска. В Task 019 XML существовал только как Markdown sample. Task 020 добавил отдельный фиксированный `.wsb` файл и выполнил его статическую проверку; ни файл, ни Windows Sandbox не открывались и не запускались. Наличие файла не разрешает его открывать.

## Что известно и что пока неизвестно

Владелец сообщил после Task 018: `OS_EDITION_CLASS=PRO`, `VIRTUALIZATION_SUPPORT=SUPPORTED`, `RUN_GATE=NON_ELEVATED_PASS`, `EDITION_QUERY=PASS`, `VIRTUALIZATION_QUERY=PASS`; одновременно `WINDOWS_SANDBOX_FEATURE=UNVERIFIED`, `HYPERV_FEATURE=UNVERIFIED`, `SANDBOX_QUERY=QUERY_ERROR`, `HYPERV_QUERY=QUERY_ERROR`, `OUTBOUND_ISOLATION=UNVERIFIED`, `APPLICATION_RESTORE=NOT_ATTEMPTED`, `STATUS=PARTIAL_REPORT`. Это `OWNER_REPORTED`, а не результат проверки Codex. `QUERY_ERROR` не означает `DISABLED` или `NOT_AVAILABLE`.

Затем владелец сообщил, что в окне **«Включение или отключение компонентов Windows»** строки Windows Sandbox и Hyper-V были видны, но не отмечены. Это только `OWNER_REPORTED` наблюдение двух unchecked checkbox в GUI. Оно не подтверждает работоспособность, совместимость, entitlement, установку/активацию либо effective isolation. В Task 019 никто не менял эти флажки или другие настройки. Hyper-V не следует включать по предположению только потому, что его отдельный флажок виден.

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

## Официальные источники Microsoft

Проверены публичные Microsoft Learn страницы (на страницах указано обновление `2026-03-29`):

- [Install Windows Sandbox — prerequisites и установка](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install): требования к версии/архитектуре, virtualization, памяти, диску и CPU; включение optional feature через GUI и возможный restart.
- [Use and configure Windows Sandbox — `.wsb` XML options](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file): XML schema options и значения, defaults networking/clipboard, доступные controls и удаление содержимого при закрытии.
- [Windows Sandbox overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview): временная природа Sandbox, поддерживаемые editions и общие границы/ограничения.

Официальные документы описывают продукт в общем. Они не подтверждают состояние конкретного компьютера, эффективную изоляцию, доступность файлового ingress/egress, права владельца, лицензию/совместимость 1С или пригодность данной TEST-копии.
