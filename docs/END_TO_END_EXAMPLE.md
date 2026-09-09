# End-to-end example: order status filter

This example records the first repository feature completed with the public Codex Engineering Workflow. It is intentionally small, dependency-free, and reproducible.

## Request

> Add an optional status filter to `list_orders`. Preserve the current behavior when no status is supplied, preserve input order, return an empty result when nothing matches, add meaningful tests, and verify the repository.

## Analysis and routing

- Task type: `FEATURE`
- Risk: `LOW`
- Repository: Python 3.11+, standard library only
- Project instructions: `examples/order-status-filter/AGENTS.md`
- Selected capabilities:
  - `engineering-task-workflow` for discovery, review, verification, and delivery
  - `tdd-workflow` because the behavior has a focused observable test boundary
  - `verification-before-completion` for the final evidence gate
- Deliberately skipped:
  - `intent-driven-development`, because the request already defines observable acceptance criteria
  - `systematic-debugging`, because the RED failure was expected and its cause was explicit
  - framework, database, UI, and security specialists, because the detected stack and task do not need them

This is the smallest route that materially improves the task. The selected capabilities are also checked against `manifests/skill-catalog.json` by the example verifier.

## Acceptance criteria

1. Calling `list_orders(orders)` returns every order in its original order.
2. Calling `list_orders(orders, status=...)` returns only matching orders in their original order.
3. A filter with no matches returns an empty tuple.
4. The caller's iterable is not mutated.
5. The implementation remains typed and adds no dependency.

## TDD evidence

The focused test was added before production code changed. The first valid test run executed three tests: the compatibility test passed and the two filter tests failed with:

```text
TypeError: list_orders() got an unexpected keyword argument 'status'
Ran 3 tests
FAILED (errors=2)
```

The implementation then added a keyword-only `status: OrderStatus | None` parameter and filtered into a new tuple. No unrelated abstraction or dependency was added.

## Review

The changed behavior is limited to `order_tracker/orders.py` and `tests/test_orders.py`. The review confirmed that the default behavior remains compatible, order is preserved, arbitrary iterables are consumed once, and the input is not mutated.

## Reproduce the final verification

From the distribution root on Windows:

```powershell
.\scripts\Test-EndToEndExample.ps1
```

If Python is not on `PATH`, pass its executable explicitly:

```powershell
.\scripts\Test-EndToEndExample.ps1 -PythonExecutable 'C:\path\to\python.exe'
```

The command validates the selected route against the catalog and runs the repository test suite. A valid result reports `status: PASS`, `route_valid: true`, `tests_passed: 4`, and `test_exit_code: 0`.

The final source remains under `examples/order-status-filter/` so future contributors and CI can rerun the same evidence instead of relying on this report alone.
