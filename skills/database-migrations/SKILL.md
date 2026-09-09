---
name: database-migrations
description: Plan, implement, review, and verify database schema or data migrations with engine-aware locking, compatibility, backfill, rollback, and deployment sequencing. Use for migration files and persistent schema/data changes; do not use for ordinary application queries without a migration.
license: MIT
metadata:
  origin: "Adapted from affaan-m/ECC@11813f968cc0087b2793470a4082b754688bf168"
---

# Database Migrations

Treat a migration as a versioned compatibility change across database state, application versions, data volume, and deployment order.

## Discover before designing

Identify:

- database engine and version;
- ORM or migration tool and its pinned version;
- repository migration conventions and applied-history rules;
- table size, write pattern, constraints, indexes, triggers, and dependent code when known;
- whether the target is a local/disposable database, staging, or production;
- rollout and rollback capabilities.

Consult current engine/tool documentation when lock, DDL, transaction, or online-index behavior matters. Do not generalize PostgreSQL syntax or guarantees to other databases.

For PostgreSQL, also use the selected PostgreSQL skill for SQL, RLS, indexing, concurrency, and constraint details.

## Choose a safe lifecycle

Use a single migration only when the change is demonstrably compatible and bounded. Use expand/contract when old and new application versions may overlap:

1. **Expand:** add compatible schema without removing the old contract.
2. **Migrate:** backfill in bounded, restartable batches where volume requires it; validate progress and consistency.
3. **Switch:** deploy code that reads the new representation and stops depending on the old one.
4. **Contract:** remove obsolete schema only after usage and rollback windows permit it.

Separate schema and data operations when doing so reduces locks, transaction duration, rollback risk, or operational ambiguity. It is a decision based on the actual engine and tool, not an absolute formatting rule.

## Safety questions

- What application versions can run before, during, and after the migration?
- Can the operation lock or rewrite a large table?
- Is a default computed per row or metadata-only in this engine/version?
- Can index or constraint validation be staged?
- Is the backfill idempotent, observable, bounded, and resumable?
- What happens to concurrent writes?
- How is partial failure detected and resumed?
- Is rollback safe, or is roll-forward the correct recovery strategy?
- Are destructive steps delayed until data is no longer needed?

Never edit a migration known to be applied in a shared environment unless the project explicitly uses a safe reconciliation procedure.

## Implementation

- Follow the repository's naming and ordering.
- Keep the migration focused and deterministic.
- Avoid hidden network calls, production credentials, or environment-dependent data.
- Add guards only when supported and consistent with migration history.
- Update application code in the sequence required for compatibility.
- Document an irreversible step and its recovery path.

## Verification levels

Report exactly which level was achieved:

1. **Static:** syntax, formatting, schema diff, generated SQL, or migration graph inspected.
2. **Disposable database:** apply from the correct prior state, inspect schema/data, run affected tests, and exercise rollback or roll-forward where meaningful.
3. **Representative-volume test:** evaluate locks, duration, batching, and disk/replication impact with representative data.
4. **Staging/production:** only with explicit authorization and operational controls.

Static validation alone does not prove a migration applies successfully. A local empty database does not prove production-scale safety.

## Approval boundaries

Preparing migration files and testing in an authorized disposable database are ordinary implementation work. Applying a destructive/breaking migration, changing production data, or using production credentials requires explicit approval immediately before the operation.
