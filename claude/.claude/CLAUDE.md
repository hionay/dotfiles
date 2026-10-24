@RTK.md

# Commits

Always use Conventional Commits 1.0.0 (https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Description: imperative, lowercase, no trailing period, under ~72 chars.
- Breaking changes: `!` after type/scope (`feat(api)!: ...`) and/or a `BREAKING CHANGE: <details>` footer.
- Body explains why, separated by a blank line. Footers use `Token: value` (e.g. `Refs: #123`).
- Applies to PR titles and squash-merge messages too.

# Subagents

When `superpowers:requesting-code-review` (or any review skill) says to dispatch a `general-purpose` reviewer, dispatch `subagent_type: "code-reviewer"` instead (it runs on Sonnet). Never pass `model: "opus"` for review subagents.
