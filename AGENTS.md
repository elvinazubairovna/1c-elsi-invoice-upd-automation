# Project instructions

- Before each task, read this file and the corresponding file in `DEV/tasks/`.
- Perform only the assigned task. Do not make independent architecture, business logic, requirements, data structure, or security decisions.
- Do not edit files outside the task's permitted scope or delete user data.
- Do not run dangerous commands without authorization. Never use `git push --force`.
- Do not publish confidential information. Use fictional data for tests.
- Run the checks required by the task and record results in `DEV/reports/`.
- Before committing, inspect the exact file list, staged diff, secrets, real accounting data, and accidental documents.
- Before every `git commit`, manually run `pwsh -NoProfile -File DEV/tools/Test-Publication.ps1 -Mode Index`; before every `git push`, manually run it with `-Mode Outgoing` and the same refs that will be pushed. Hooks are an extra guard and can be bypassed.
- Run `pwsh -NoProfile -File tests/security/Invoke-SecurityTests.ps1` for security workflow changes. If PowerShell 7 or a required check fails, stop the operation and report it.
- Publish only when every security condition is met. If publication is blocked, preserve local changes and report why.
- Do not call a task complete without evidence from its required checks.
- Request new technical decisions from ChatGPT through the project owner.
