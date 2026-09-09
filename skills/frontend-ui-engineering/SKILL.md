---
name: frontend-ui-engineering
description: Build or modify production user interfaces when the task requires responsive layout, accessible interaction, component state, forms, loading and error states, or integration with an existing frontend stack. Use for implementation work after the repository stack and visual direction are known.
license: MIT
metadata:
  origin: "Original for Codex Engineering Workflow"
---

# Frontend UI Engineering

Implement complete user-facing behavior inside the repository's existing framework and design system.

## Workflow

1. Discover the actual framework, component library, styling system, browser targets, and repository commands.
2. Translate the request into visible states: default, loading, empty, error, disabled, success, and responsive variants that apply.
3. Reuse established components and tokens before creating new ones.
4. Keep data access, business rules, and presentation boundaries consistent with the codebase.
5. Implement semantic structure, keyboard behavior, focus handling, labels, and useful status feedback.
6. Preserve existing behavior outside the requested flow.
7. Test observable behavior at the lowest reliable level, then run relevant typecheck, lint, build, and browser checks.

## Boundaries

- Use `frontend-design` for a new or materially changed visual direction.
- Use `fixing-accessibility` for a focused web accessibility audit or repair.
- Use `react-patterns` only when the repository is React web.
- Do not add a UI library, state manager, animation package, or icon set unless the task requires it and the repository does not already provide a suitable option.
- Do not present placeholder controls or mock data as working functionality.
