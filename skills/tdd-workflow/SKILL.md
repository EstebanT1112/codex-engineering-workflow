---
name: tdd-workflow
description: Use test-driven development for behavior changes, bug fixes, and refactors when an automated test can provide meaningful regression evidence. Do not use for documentation-only work, generated artifacts, or changes where a test would merely mirror implementation.
license: MIT
metadata:
  origin: "Adapted from affaan-m/ECC@11813f968cc0087b2793470a4082b754688bf168"
---

# Test-Driven Development Workflow

Use the repository's existing test stack to protect observable behavior. Keep the cycle proportional to the change.

## Decide the test boundary

Before editing production code:

1. identify the behavior that should change or remain stable;
2. choose the lowest-cost test that exercises that behavior through a meaningful boundary;
3. prefer an existing nearby test pattern and runner;
4. avoid mocks that make the test pass without exercising the contract.

Do not add a new test framework unless the task clearly requires it and the dependency is justified.

## RED

- Add or adjust one focused test for the intended behavior.
- Run the narrow test.
- Confirm it fails for the expected reason, rather than syntax, fixture, environment, or unrelated failures.
- If the behavior cannot be reproduced, investigate before changing production code.

For a refactor with unchanged behavior, existing passing tests may be the baseline. Add a characterization test only when the important behavior is otherwise unprotected.

## GREEN

- Implement the smallest coherent change that satisfies the behavior.
- Run the focused test again.
- Do not bundle unrelated cleanup, abstractions, or future cases into the fix.

## REFACTOR

Once the focused test passes:

- improve clarity only where the current change benefits;
- preserve the observable contract;
- rerun the focused test after refactoring;
- inspect the diff for accidental scope.

## Broaden verification

Run the relevant surrounding suite and repository-required typecheck, lint, or build. A focused RED/GREEN cycle does not prove integration or release readiness.

Coverage thresholds come from the repository or task. Do not impose a fixed percentage. Measure coverage only when it answers a real acceptance or risk question.

## Boundaries

- Do not create trivial tests solely to demonstrate TDD.
- Do not rewrite good tests to match a faulty implementation.
- Do not declare success from a test run that predates the final code change.
- Do not commit after each phase; commit remains under the user's control.
- If a regression test is impractical, record why and use the strongest available deterministic or runtime evidence.
