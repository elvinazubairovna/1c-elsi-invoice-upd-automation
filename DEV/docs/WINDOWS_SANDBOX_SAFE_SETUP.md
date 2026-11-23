# Windows Sandbox: безопасная оценка и план подготовки

> Это документ для оценки и будущего отдельного допуска. Пример XML ниже — только текст в Markdown: файл `.wsb` не создавался, не устанавливался и не запускался. Не сохраняйте его как `.wsb`, не нажимайте на `.wsb` и не запускайте Windows Sandbox в рамках Task 019.

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
| `GUEST_CONFIG` | `DESIGN_ONLY` |
| `GUEST_NETWORK_ISOLATION` | `UNVERIFIED` |
| `HOST_FEATURE_ACTIVATION` | `NOT_ATTEMPTED` |
| `APPLICATION_RESTORE` | `NOT_ATTEMPTED` |
| `1C_OFFLINE_INSTALL_LICENSE` | `UNVERIFIED` |
| `OUTBOUND_ISOLATION` | `UNVERIFIED` |
| `TEST_DATA_FULLY_SYNTHETIC` | `UNVERIFIED` |
| `PRODUCTION_ACCESS` | `NONE` |

Не включать Windows components, не перезапускать Windows, не запускать Sandbox или 1С, не передавать тестовые файлы и не открывать TEST/PRODUCTION по этому runbook.

## Официальные источники Microsoft

Проверены публичные Microsoft Learn страницы (на страницах указано обновление `2026-03-29`):

- [Install Windows Sandbox — prerequisites и установка](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-install): требования к версии/архитектуре, virtualization, памяти, диску и CPU; включение optional feature через GUI и возможный restart.
- [Use and configure Windows Sandbox — `.wsb` XML options](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-configure-using-wsb-file): XML schema options и значения, defaults networking/clipboard, доступные controls и удаление содержимого при закрытии.
- [Windows Sandbox overview](https://learn.microsoft.com/en-us/windows/security/application-security/application-isolation/windows-sandbox/windows-sandbox-overview): временная природа Sandbox, поддерживаемые editions и общие границы/ограничения.

Официальные документы описывают продукт в общем. Они не подтверждают состояние конкретного компьютера, эффективную изоляцию, доступность файлового ingress/egress, права владельца, лицензию/совместимость 1С или пригодность данной TEST-копии.
