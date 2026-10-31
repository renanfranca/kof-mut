# KofMut

For large work, create a temporary `EXECPLAN.md`, continue one milestone at a time and record observed evidence in `.agent/validation/`. Delete the plan once the work is complete; git history keeps it.

- Keep selection, mutation, execution and reporting logic in Kof under `src/main/kof/kofmut/`.
- Use the official Kof lexer and parser through the installed distribution. Do not implement another grammar or transform raw source with regular expressions.
- Follow the concrete Kof selected on PATH on Linux/JVM. Approve compatibility by content identity and behavioral checks before evaluation, never by a literal version allowlist. Preserve actual version evidence; do not modify, download or update Kof as part of this project.
- Consult the relevant local documentation, implementation and tests in the Kof repository before relying on language or platform behavior.
- Drive changes through behavioral tests written in Kof. `./scripts/check` is the validation entry point.
- Prefer self-explanatory names over comments. When code seems to need a comment, extract a function or variable whose name says it instead. Never reference requirement or step numbers from temporary working documents in code or comments; those documents can be deleted.
- Preserve evaluated projects. Work on disposable copies; never mutate tests.
- Unknown syntax, invalid evidence, compilation failures and timeouts must remain explicit limitations or inconclusive results.
- Use synthetic fixtures. Keep logs in `.agent/tmp/`; do not copy private projects or credentials into this repository.
- Maintain public documentation in English and Brazilian Portuguese. CLI identifiers and JSON fields are canonical and are not translated.
- Use `GPL-3.0-only`. Do not bundle the Kof fat jar or its embedded JDK.
- Do not create worktrees, subagents, commits, remotes or publications without explicit user instructions covering them.

The user authorized GPT 6.1 Sol with xhigh reasoning for this implementation, replacing the plan's original Luna/high preference.
