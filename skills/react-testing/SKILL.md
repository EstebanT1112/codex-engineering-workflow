---
name: react-testing
description: Write or repair behavior-focused tests for React web components, hooks, and pages using the repository's existing Vitest or Jest, React Testing Library, network mocks, and accessibility assertions. Use when React test code is part of the requested change.
license: MIT
metadata:
  origin: "Adapted from affaan-m/ECC@11813f968cc0087b2793470a4082b754688bf168"
---

# React Testing

## Workflow

1. Detect the actual React version, test runner, DOM environment, test utilities, provider wrappers, and existing conventions.
2. Choose the smallest test that observes user-visible behavior or a stable hook contract.
3. Query by role, name, label, or visible text and interact through the same controls a user uses.
4. Mock network boundaries with the repository's established mechanism; avoid mocking the component's own implementation details.
5. Cover the relevant success, failure, loading, validation, or accessibility behavior without duplicating framework behavior.
6. Reproduce regressions with a failing test before the fix when practical.
7. Run the focused test first, then the impacted suite and repository checks.

## Test Boundary

- Component tests cover rendering, interactions, validation, callbacks, and local request states.
- Browser or end-to-end tests cover navigation, real browser layout, multi-page flows, and deployed integration.
- Use `tdd-workflow` for the red-green-refactor sequence and `react-patterns` for component implementation.

Do not add a new runner, DOM shim, MSW, axe, or browser framework solely because this skill names the category.
