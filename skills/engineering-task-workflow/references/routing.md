# Skill routing

Read this reference when choosing specialist skills, resolving overlap, or working in an unfamiliar stack.

## Selection procedure

1. Identify the current stage: planning, implementation, debugging, review, verification, or delivery.
2. Identify concrete signals from the request and repository.
3. Select the smallest set of skills that changes a decision or improves execution.
4. Read each selected `SKILL.md` before applying it.
5. Follow project rules and user instructions when a skill contains incompatible defaults.
6. Do not run optional scripts, installers, hooks, MCP servers, or dependency additions merely because a skill mentions them.
7. Consult the machine-readable catalog at `../../../manifests/skill-catalog.json` when availability or overlap is unclear.

Availability is a gate, not a trigger. Bundled skills still require a matching task signal. Optional skills may be selected only when Codex actually discovers them in the current environment.

## Core routing

| Trigger | Route |
|---|---|
| Material ambiguity, high-impact product choice, migration/contract risk | `intent-driven-development` |
| Behavior change with meaningful regression risk | `tdd-workflow` when a focused test can fail meaningfully first |
| Non-trivial bug or unexplained failure | `systematic-debugging`; do not use a second general debugging workflow |
| Approaching a completion claim | `verification-before-completion` |

## API and backend

| Trigger | Route |
|---|---|
| REST endpoint semantics | `api-design` |
| Contract shared by independent producer/consumer or breaking change | `contract-first` in addition to domain implementation |
| Node/Express/Next server patterns | `backend-patterns` only when that stack is confirmed |
| Error contract, retries, or external dependency failure | `error-handling` when the failure mode justifies it |

`api-design`, `contract-first`, and `backend-patterns` are separate layers. The first governs HTTP semantics, the second governs independently evolving boundaries, and the third applies implementation patterns only to confirmed Node.js, Express, or Next.js server code. Load more than one only when the task crosses those layers.

## Data

| Trigger | Route |
|---|---|
| Schema or data migration | `database-migrations` |
| PostgreSQL schema, query, RLS, index, function, trigger, or concurrency | `supabase-postgres-best-practices` |

Use both for a PostgreSQL migration: one governs lifecycle and rollout; the other governs database design and SQL behavior. Do not route to `postgres-patterns`.

## Frontend and UX

| Trigger | Route |
|---|---|
| Production UI implementation | `frontend-ui-engineering` |
| New visual direction or substantial redesign | `frontend-design` |
| Broad journey, information architecture, or substantial UX critique | `ui-ux-pro-max` on demand |
| Existing UI needs narrow polish | `make-interfaces-feel-better` when available |
| Web accessibility | `fixing-accessibility` |
| React component/hook behavior | `react-patterns` |
| React tests | `react-testing` |
| React performance issue supported by measurement | `react-performance` when installed |
| Vite configuration/build/HMR | `vite-patterns` when installed, after checking the actual version |
| shadcn project confirmed by configuration | `shadcn` |
| React Native or Expo | `react-native-patterns` |
| Native accessibility | `accessibility` when installed, not the web skill alone |
| Motion already present or explicitly requested | `motion-ui` when installed |
| Significant visual change with runnable preview | `browser-qa` when installed |
| Critical journey with an E2E framework configured | `e2e-testing` when installed |
| UI action appears to revert or race | `systematic-debugging`, then `click-path-audit` when installed and the state path is the suspected surface |

For broad design work, select at most one lead analysis skill by default: `ui-ux-pro-max` for the user journey or `frontend-design` for visual direction. Add `frontend-ui-engineering` when implementation begins. Framework, accessibility, polish, motion, and browser skills refine that work only when their narrower trigger exists.

## Design and assets

- Use `brand` only when brand identity, voice, positioning, or consistency is an explicit requirement and prefer authoritative existing brand material.
- Use `imagegen` only when a raster asset is actually requested or required.
- Keep concept/direction, UI implementation, asset generation, and repository integration as separate stages.
- Codex integrates the final reviewed asset into the repository.
- Do not route through the excluded meta-skill `design` or the excluded `banner-design` workflow.

## Security

- Apply secure-by-default reasoning inside the main workflow when risk requires it.
- Use `security-best-practices` only within its declared trigger boundaries: an explicit security review/report or secure-by-default implementation in a supported stack.
- Prefer scanners and tests already configured in the repository.
- Do not stack `security-review`, `security-scan`, and a generic second checklist.
- A HIGH/CRITICAL self-review focuses on trust boundaries, abuse cases, authorization, data exposure, failure behavior, and negative tests.

## Release and maintenance

- Use `production-audit` only when installed and for a real release or operational readiness question.
- Use `architecture-decision-records` only for a decision difficult to reverse.
- Use `living-docs-governance` only after demonstrated documentation drift.
- Use `inherit-legacy-style` for explicit legacy onboarding, never as global memory.
- Use `codebase-onboarding` for an unfamiliar or architecturally unclear repository; basic discovery remains mandatory without it.

## Excluded routes

Do not select these as workflow components:

- `verification-loop`
- ECC `delivery-gate`
- `context-budget`
- `strategic-compact`
- `debugging-strategies`
- `coding-standards`
- `postgres-patterns`
- `security-review`
- `security-scan`
- `frontend-patterns`
- `baseline-ui`
- `ui-styling`
- `frontend-design-direction`
- `design`
- `banner-design`
- `product-lens`

Some may remain installed for historical or manual use. Their presence does not make them a valid automatic route.
