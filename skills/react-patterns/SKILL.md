---
name: react-patterns
description: Implement or review React web components, hooks, state, effects, composition, forms, and rendering boundaries using the repository's actual React and framework versions. Use for React web work; do not use for React Native or generic visual direction.
license: MIT
metadata:
  origin: "Adapted from affaan-m/ECC@11813f968cc0087b2793470a4082b754688bf168"
---

# React Patterns

Preserve the repository's framework, version, state model, component library, and testing conventions. Do not introduce a new state, form, fetching, or styling library unless the requested behavior needs it.

## Component boundaries

- Keep rendering pure: the same props and state should produce the same UI.
- Prefer composition and explicit props over inheritance, hidden registries, or global context.
- Split a component when responsibilities, update frequency, reuse, or testing boundaries become clearer; do not split only to reduce line count.
- Use semantic HTML before ARIA and preserve keyboard/focus behavior.

## State placement

Place state at the narrowest owner that needs to coordinate it:

1. local component state for local interaction;
2. lift to the nearest common owner when a few related components share it;
3. context for stable, low-frequency cross-tree concerns;
4. an existing external store for shared high-frequency or domain state;
5. the repository's server-state mechanism for remote data.

Derive values during render when possible. Do not copy props or query data into state without a synchronization requirement.

## Effects

Use an effect to synchronize React with an external system: subscription, timer, imperative API, storage, network mechanism not owned by the framework, or third-party widget.

- Do not use effects for values that can be derived during render.
- Clean up subscriptions and cancel or ignore stale asynchronous work.
- Include dependencies that reflect the actual synchronization contract.
- Prefer event handlers for work caused by a user action.

## Data and framework boundaries

Discover the actual router/framework before applying framework-specific patterns.

- Use React Server Components or Server Actions only when the installed framework and route architecture support them.
- Preserve serialization and server/client boundaries already used by the project.
- Use the existing query/cache solution for client server-state; avoid ad hoc effect-based fetching when the project already provides one.
- Validate assumptions against current framework documentation when APIs or conventions are version-sensitive.

## Forms

- Use native form behavior and accessible labels/errors as the baseline.
- Keep simple forms simple.
- Use the existing form/schema library for cross-field validation, dynamic collections, or complex workflows.
- Preserve submitted values and focus when validation fails.

## Performance

- Measure or identify a concrete render problem before memoizing.
- Use stable keys tied to identity, never array position when items can reorder.
- Avoid recreating large contexts or subscriptions for unrelated updates.
- Virtualize only when list size and rendering cost justify it.
- Treat `memo`, `useMemo`, and `useCallback` as targeted optimizations, not defaults.

## Testing and review

Test behavior through user-observable outcomes. Use the repository's React testing skill and tools when writing component tests. Review loading, empty, error, success, disabled, focus, responsive, and cleanup behavior when relevant.

Do not route this skill to React Native; use the dedicated RN/Expo skill. Visual direction belongs to the design skill, while this skill governs React implementation behavior.
