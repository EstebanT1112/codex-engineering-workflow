---
name: frontend-design
description: Define a distinctive and coherent visual direction for a new interface or a substantial redesign. Use when visual hierarchy, typography, color, layout rhythm, and interaction character must be decided before UI implementation; do not use for routine component edits.
license: MIT
metadata:
  origin: "Original adaptation for Codex Engineering Workflow"
---

# Frontend Design Direction

Create an intentional visual direction that can be implemented in the repository's real stack.

## Workflow

1. Read the product goal, audience, existing brand, screenshots, and design tokens that are actually available.
2. State one concise direction covering mood, hierarchy, type, color, spacing, shape, imagery, and motion.
3. Preserve established product conventions unless the user requested a redesign.
4. Turn the direction into concrete implementation decisions and reusable tokens where the current task needs them.
5. Check responsive behavior, content density, interaction states, contrast, and reduced-motion expectations.
6. Hand implementation to `frontend-ui-engineering`; use `imagegen` only when a raster asset is requested or clearly necessary.

## Boundaries

- Avoid generic template styling and arbitrary decoration.
- Do not invent brand rules when authoritative brand material exists.
- Do not add fonts, asset libraries, or design dependencies without a concrete requirement.
- A visual proposal is not completion; verify the implemented interface in its runnable environment.
