# Report 002 — Security and workflow

## Status

SUCCESS — требуемые проверки, сценарии безопасности и установка локальных hooks прошли. Отчёт подготовлен до содержащего его финального коммита. Его SHA не вписывается в сам отчёт; окончательный remote HEAD будет передан владельцу отдельно.

## Base state

- Base: `main` at `9f134c080cb7738ee39f1f17bdabb7a9fbd148c5`.
- Repository: public `elvinazubairovna/1c-elsi-invoice-upd-automation`.
- До работы были незатреканы исходный файл задания № 001 и предоставленный файл задания № 002. Оба сохранены без изменений; № 001 исключён из публикации, № 002 включён по разрешённой области.
- `pwsh` 7.6.5 и Git 2.53.0 доступны. `core.hooksPath` изначально не был задан; в `.git/hooks` были только sample hooks.

## Changed files

- `AGENTS.md`
- `.gitignore`
- `README.md`
- `DEV/docs/SECURITY.md`
- `DEV/docs/DEVELOPMENT_WORKFLOW.md`
- `DEV/tasks/002_SECURITY_AND_WORKFLOW.md` (предоставленное задание, текст сохранён)
- `DEV/tools/Test-Publication.ps1`
- `DEV/tools/Install-LocalHooks.ps1`
- `DEV/hooks/pre-commit`
- `DEV/hooks/pre-push`
- `tests/security/Invoke-SecurityTests.ps1`
- `.github/workflows/publication-security.yml`
- `DEV/reports/002_SECURITY_AND_WORKFLOW.md`

## Security model

Проверка читает индексированные Git objects (`Index`), всё дерево `HEAD` (`Tracked`) или все версии файлов во всех outgoing-коммитах (`Outgoing`). Она блокирует опасные расширения и каталоги независимо от `.gitignore`, известные высокоуверенные шаблоны секретов, присваивания секретов с неплейсхолдерными значениями, российские ИНН с валидными контрольными цифрами, явный текстовый шаблон бухгалтерского документа, неподдерживаемые бинарные данные, кодировки и неоднозначные Git records/refs. Найденные значения не выводятся; пути с вероятными персональными значениями маскируются.

Эти правила не обнаруживают все возможные персональные данные, секреты или новые форматы. Неизвестные бинарные файлы и невалидный UTF-8 запрещаются до отдельного решения. Ручной просмотр staged diff и всех outgoing-коммитов обязателен. Actions запускается после публикации и не предотвращает первое раскрытие в публичном репозитории.

## Checks and tests

- PowerShell AST parse трёх скриптов (`Test-Publication.ps1`, `Install-LocalHooks.ps1`, `Invoke-SecurityTests.ps1`): PASS.
- `pwsh -NoProfile -File tests/security/Invoke-SecurityTests.ps1`: PASS, 15/15.
  - PASS: безопасный Markdown.
  - PASS: принудительно индексированные PDF/XLSX/CSV блокируются.
  - PASS: вложенный `secrets/` блокируется.
  - PASS: синтетический token отклоняется без вывода значения.
  - PASS: синтетический контрольный ИНН отклоняется без вывода номера.
  - PASS: описание правила и placeholder assignment проходят.
  - PASS: синтетический счёт в `.txt` отклоняется.
  - PASS: запрещённый файл, добавленный одним коммитом и удалённый следующим, обнаружен в outgoing диапазоне.
  - PASS: неоднозначный и tab-separated ref input, Git вне репозитория и некорректный режим дают ненулевой код.
  - PASS: текущий проект проходит `Index` и `Tracked`.
- `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`: PASS.
- `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Tracked`: PASS.
- Outgoing no-op ref pair до публикации: PASS; сценарий outgoing add→delete отдельно подтверждён тестом.
- Проверка workflow-структуры и forbidden patterns: PASS. Использование официального `actions/checkout@v7` подтверждено наличием тега `v7`; credentials persistence отключён.
- `git diff --cached --check`: обнаружены только исходные двойные пробелы для Markdown line breaks в строках 3–7 предоставленного задания № 002. По требованию точного сохранения задание не редактировалось; в остальных подготовленных файлах таких предупреждений нет.
- `.gitignore`: проверены регистронезависимые расширения, вложенные каталоги и исключение `.env.example`.
- В staged list входят только разрешённые пути; нестандартный исходный файл задания № 001 отсутствует.

## Local hooks

- Установлен локальный `core.hooksPath=DEV/hooks`; `.git/hooks` не изменялся.
- `pwsh -NoProfile -File DEV/tools/Install-LocalHooks.ps1`: PASS.
- Installer выполнил живой `pre-commit` (`Index`) и проверку Outgoing mode с корректно переданным stdin. Обычный push дополнительно вызовет настоящий `pre-push` hook.
- Hooks — дополнительная защита: их можно обойти. `AGENTS.md` требует ручной запуск Index перед commit и Outgoing перед push; отсутствие/ошибка `pwsh` блокирует hook.

## GitHub Actions

- Workflow: `.github/workflows/publication-security.yml`.
- События: push в `main`, PR в `main`, `workflow_dispatch`; один job `publication-security`, `ubuntu-latest`, `contents: read`, `actions/checkout@v7` с `persist-credentials: false`.
- CI status на момент подготовки отчёта: PENDING — workflow начнётся после публикации. Итог первого запуска проверяется отдельно; запуск не считается успешным заранее.

## Git and publication

- До финального коммита: `main` на указанном base SHA; рабочие изменения ограничены путями выше. Пользовательский файл задания № 001 оставлен локально и вне index.
- Изменения подготовлены к обычному коммиту и push в `origin/main`, без перезаписи истории.
- Этот отчёт не содержит SHA коммита, который включает его самого. Итоговый удалённый HEAD и результат push будут сообщены владельцу отдельно.

## Deviations and unresolved issues

- Безопасность/форматирование: только исходные Markdown hard-break пробелы в задании № 002 делают `git diff --cached --check` ненулевым; исходный task файл сохранён как потребовано.
- Окончательный SHA, факт push и завершение GitHub Actions ещё не известны на момент подготовки отчёта. Они проверяются после коммита.
- Нет нерешённых архитектурных или бизнес-вопросов.
