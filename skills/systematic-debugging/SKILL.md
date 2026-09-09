---
name: systematic-debugging
description: Investigate bugs, test failures, build failures, performance regressions, and unexpected behavior by reproducing the issue, tracing evidence, testing one hypothesis, and fixing the root cause. Use before speculative fixes; do not use for planned feature work without a failure.
license: MIT
metadata:
  origin: "Adapted from obra/superpowers@b36e0829c6d0140e93cfef2ca599b1b07d4a7797"
---

# Systematic Debugging

Find and verify the cause before changing behavior. A plausible explanation is a hypothesis until evidence supports it.

## 1. Establish the failure

- Read the complete useful error, stack trace, status code, and affected path.
- Reproduce with the smallest reliable command or sequence.
- Record whether the failure is deterministic, intermittent, environment-specific, or external.
- Check current Git changes, relevant recent changes, configuration, dependency versions, and runtime assumptions.
- Preserve unrelated user changes.

If reproduction is unsafe or requires production, stop before the effect and build the strongest safe diagnostic path.

## 2. Locate the failing boundary

Trace inputs and outputs across the shortest relevant path. Inspect the point where expected state first becomes incorrect.

Add temporary diagnostics only when existing evidence is insufficient. Diagnostics must be targeted and redacted:

- never dump the full environment;
- never print tokens, credentials, cookies, personal data, or connection strings;
- prefer presence, type, length, hash, status, or bounded identifiers;
- remove temporary diagnostics unless they are justified as lasting observability.

Compare with a working path in the same repository when available. Identify meaningful differences without assuming every difference is causal.

## 3. Test one hypothesis

State one falsifiable hypothesis and the evidence that would confirm or reject it. Test the smallest variable possible.

- If rejected, remove speculative changes and form a new hypothesis from the new evidence.
- Do not stack several possible fixes into one experiment.
- After two failed correction attempts against the same symptom, stop patching and reassess the reproduction, assumptions, architecture, and external documentation.

Ask the user only if a product decision, inaccessible environment, credential, or privileged action is required to continue.

## 4. Implement the root-cause fix

- Add the smallest useful regression test or reproduction harness when practical.
- Make one coherent fix at the source of the faulty behavior.
- Avoid opportunistic refactors.
- Run the focused reproduction and relevant surrounding checks.
- Inspect the final diff and remove temporary artifacts.

If the cause is external or environmental, implement only the handling justified by evidence: a clear error, validated retry, timeout, fallback, or observability. Do not disguise an unknown cause as fixed.

## Completion evidence

Report:

- the observed root cause;
- the evidence that isolated it;
- the correction;
- the regression or reproduction result;
- relevant checks and remaining uncertainty.

Never report a fix when only the symptom disappeared once or when verification used a different environment without explaining the boundary.
