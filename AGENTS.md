# KofMut

Read `EXECPLAN.md` before implementation. Continue one milestone at a time and record observed evidence at milestone boundaries.

- Keep selection, mutation, execution and reporting logic in Kof under `src/main/kof/kofmut/`.
- Use the official Kof lexer and parser through the installed distribution. Do not implement another grammar or transform raw source with regular expressions.
- Support Kof 0.6.4 on Linux/JVM until compatibility proofs justify another version. Do not modify or update Kof as part of this project.
- Consult the relevant local documentation, implementation and tests in the Kof repository before relying on language or platform behavior.
- Drive changes through behavioral tests written in Kof. `./scripts/check` is the validation entry point.
- Preserve evaluated projects. Work on disposable copies; never mutate tests.
- Unknown syntax, invalid evidence, compilation failures and timeouts must remain explicit limitations or inconclusive results.
- Use synthetic fixtures. Keep logs in `.agent/tmp/`; do not copy private projects or credentials into this repository.
- Maintain public documentation in English and Brazilian Portuguese. CLI identifiers and JSON fields are canonical and are not translated.
- Use `GPL-3.0-only`. Do not bundle the Kof fat jar or its embedded JDK.
- Do not create worktrees, subagents, commits, remotes or publications without explicit user instructions covering them.

The user authorized GPT 6.1 Sol with xhigh reasoning for this implementation, replacing the plan's original Luna/high preference.
