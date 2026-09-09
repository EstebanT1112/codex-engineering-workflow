# Workflow details

Read this reference for MEDIUM/HIGH/CRITICAL tasks, work that spans several components, or any task with review/correction loops.

## Stages and evidence

### RECEIVED → ANALYZED

Establish:

- the requested outcome and explicit exclusions;
- repository root and current working directory;
- applicable global, root, and nested instructions;
- Git branch, status, baseline, staged/untracked files, and pre-existing changes;
- languages, frameworks, package manager, and relevant commands;
- architecture, schema, contracts, and migrations touched by the request;
- primary task type and risk reasons.

Use the minimum reads needed to reduce uncertainty. Do not inventory the whole repository by default.

### ANALYZED → PLANNED

Define acceptance criteria that can be evaluated through behavior, tests, diff inspection, or another concrete artifact. A criterion should describe the result, not the implementation step.

The plan should identify:

- the smallest coherent change;
- likely files or components;
- tests to add or update;
- verification commands;
- compatibility, data, security, or rollout concerns;
- approvals that may be needed later.

Do not ask the user to approve an ordinary implementation plan unless a real product choice remains unresolved.

### PLANNED → IMPLEMENTING

Before writing:

- confirm the change is authorized by the request;
- protect unrelated user modifications;
- load only specialist skills needed for the current work;
- use an existing project pattern where it fits;
- decide whether a regression test should precede the implementation.

Research and review-only tasks may move from PLANNED directly to VERIFYING because they have no implementation stage.

### IMPLEMENTING → REVIEWING

Implementation is only a candidate result. Establish the real changed-file set from Git or filesystem evidence. Check:

- behavior and acceptance coverage;
- boundary and error behavior;
- consistency with repository patterns;
- accidental generated files, lockfile changes, or broad formatting;
- schema/API compatibility;
- security and data handling where relevant;
- whether documentation needs an update because behavior changed.

### REVIEWING → VERIFYING

Review findings must be resolved, explicitly accepted as non-blocking, or reported as a limitation. Do not start expensive broad checks when a local review already found a blocking defect.

### VERIFYING → CORRECTING

When a check fails because of the change:

1. retain the exact useful failure evidence;
2. diagnose the cause;
3. make the narrow correction;
4. inspect the new diff;
5. rerun the failed check and any check invalidated by the correction.

When a check exposes a pre-existing failure, demonstrate why it is unrelated and report it without silently modifying unrelated scope.

### VERIFYING → DELIVERY_GATE → DONE

The gate evaluates the current workspace state. A PASS from before the latest edit is stale. DONE requires:

- acceptance criteria evaluated;
- current diff understood;
- required checks executed or an explicit, material limitation;
- no blocking finding left open;
- no privileged action implied as already performed;
- no unsupported success claim.

## Invalid shortcuts

- `RECEIVED → IMPLEMENTING` for non-trivial work.
- `IMPLEMENTING → DONE`.
- Treating compilation as functional verification when behavior changed.
- Treating a model summary as proof of files changed or tests passed.
- Reusing verification results after changing affected code.
- Calling a migration validated without exercising it against an appropriate disposable or authorized database when that evidence is required.

## Checkpoints

Use the task thread for normal continuity. Leave a concise status update after major boundaries in long work: what is known, what changed, what remains uncertain, and what the next action will resolve.

Create a durable plan or ADR only when the repository already uses one, the user requests it, the task crosses sessions, or the decision is difficult to reverse.
