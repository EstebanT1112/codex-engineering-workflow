---
name: react-native-patterns
description: Implement or review React Native and Expo screens, navigation, state, data access, lists, native APIs, and platform behavior using the repository's actual SDK and libraries. Use for React Native or Expo work; do not apply React DOM assumptions.
license: MIT
metadata:
  origin: "Adapted from affaan-m/ECC@11813f968cc0087b2793470a4082b754688bf168"
---

# React Native and Expo Patterns

## Workflow

1. Detect the installed React Native or Expo SDK, navigation system, build workflow, styling approach, state/data libraries, and supported platforms.
2. Follow repository-native screen, component, hook, route, and test conventions.
3. Separate server cache, local UI state, route state, and form state according to their real lifetimes.
4. Validate external data at the boundary using existing dependencies; do not add a validation or state package by default.
5. Account for safe areas, keyboard behavior, touch targets, list performance, loading/error/empty states, offline behavior when required, and platform differences.
6. Request native permissions at the point of need and handle denial or restricted states.
7. Store sensitive material only through the project's secure-storage mechanism.
8. Verify focused behavior, typecheck, and the relevant device or simulator path when available.

## Boundaries

- React Native has no browser DOM; do not use HTML elements or browser-only APIs.
- Do not assume Expo Router, NativeWind, TanStack Query, or another library unless the repository already uses it or the user approves its addition.
- Do not claim device behavior verified from static checks alone.
