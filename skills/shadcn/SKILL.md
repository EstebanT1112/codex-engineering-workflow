---
name: shadcn
description: Build, add, compose, or repair shadcn/ui components in a repository that already uses shadcn or when the user explicitly requests it. Use repository configuration and installed versions; do not activate for unrelated Tailwind or generic React work.
license: MIT
metadata:
  origin: "Original Codex-compatible adaptation"
---

# shadcn/ui Repository Work

## Workflow

1. Confirm shadcn from repository evidence such as `components.json`, component paths, aliases, styling setup, and package manifests.
2. Read the local component and its dependencies before adding or changing anything.
3. Use the repository's package manager and pinned versions. Prefer existing primitives and variants.
4. Preserve local tokens, composition patterns, accessibility behavior, server/client boundaries, and import aliases.
5. When adding a component, inspect the generated diff and keep only files required by the requested behavior.
6. Test interaction and state behavior, then run relevant typecheck, lint, build, and browser checks.

## Boundaries

- Never run an `@latest` installer or add a registry without explicit need and review.
- A skill instruction does not authorize package installation, network access, overwrite, or deletion.
- Do not replace locally customized components merely to match upstream output.
- Use `frontend-design` for visual direction and `frontend-ui-engineering` for the surrounding product flow.
