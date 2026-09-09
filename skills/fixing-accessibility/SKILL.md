---
name: fixing-accessibility
description: Audit and fix accessibility problems in web interfaces, including semantics, names, keyboard access, focus, forms, dialogs, status messages, contrast, zoom, and motion preferences. Use for explicit accessibility work or when implementing interactive web controls with material accessibility risk.
license: MIT
metadata:
  origin: "Original for Codex Engineering Workflow"
---

# Fixing Web Accessibility

## Workflow

1. Identify the affected user journey and the repository's existing accessibility tools.
2. Reproduce the problem with semantic inspection and keyboard use before changing code.
3. Prefer native HTML semantics; add ARIA only when native elements cannot express the interaction.
4. Repair accessible names, relationships, focus order, visible focus, error association, live feedback, contrast, zoom/reflow, and reduced motion as applicable.
5. Preserve behavior for pointer and touch users while adding keyboard and assistive-technology support.
6. Add a focused automated assertion when it can prevent regression.
7. Verify with repository checks and a bounded manual keyboard review. Report screen-reader or browser testing as skipped when it was not actually performed.

## Boundaries

- Do not claim WCAG conformance from lint or component tests alone.
- Do not add redundant roles, positive `tabindex`, or broad ARIA workarounds.
- Use the separate native `accessibility` capability when it is installed and the target is React Native, iOS, or Android.
