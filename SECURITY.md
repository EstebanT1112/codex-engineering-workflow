# Security Policy

## Supported versions

This project is still preparing its first public release.

| Version | Security support |
|---|---|
| Current default branch and latest published release | Supported |
| Older development snapshots | Not supported |

## Reporting a vulnerability

Use GitHub private vulnerability reporting from the repository's **Security** tab. Include the affected version or commit, impact, reproduction steps, and any suggested mitigation. Remove credentials, tokens, personal data, and unrelated repository content from the report.

If private vulnerability reporting is unavailable, contact the repository owner through a private contact method published on their GitHub profile. Do not open a public issue for an unpatched vulnerability or include exploit details in discussions.

The project aims to acknowledge a complete report within seven days and provide an initial assessment within fourteen days. These are response targets rather than guaranteed remediation dates. Disclosure timing should be coordinated after a fix or mitigation is available.

## Security boundary

This package installs instructions and skills into a local Codex profile. Its safety depends on package integrity, Codex permissions and sandboxing, repository policy, and explicit approval for privileged operations. A passing package hash check detects drift against the included lock; it does not authenticate the publisher.

The installer must never overwrite a different skill or non-empty global instruction file, install optional dependencies silently, print secrets, or weaken approval gates.
