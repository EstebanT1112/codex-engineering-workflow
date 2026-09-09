# Third-Party Notices

This distribution includes material copied or adapted from the projects below. The project-level MIT license covers original material in this repository. Upstream copyright notices and license terms remain applicable to their material.

Canonical local license copies:

- [ECC MIT license](LICENSES/ECC-MIT.txt)
- [Superpowers MIT license](LICENSES/SUPERPOWERS-MIT.txt)
- [Supabase Agent Skills MIT license](LICENSES/SUPABASE-MIT.txt)
- [OpenAI security skill Apache 2.0 license](LICENSES/OPENAI-SECURITY-APACHE-2.0.txt)

Machine-readable source refs, relationships, and license paths are recorded in [provenance.json](manifests/provenance.json).

## ECC — Everything Claude Code

- Repository: <https://github.com/affaan-m/ECC>
- Audited source ref: `11813f968cc0087b2793470a4082b754688bf168`
- Upstream license: MIT
- Copyright: Copyright (c) 2026 Affaan Mustafa

Included material:

| Local skill | Relationship to upstream |
|---|---|
| `intent-driven-development` | Reviewed copy |
| `tdd-workflow` | Adapted workflow |
| `database-migrations` | Adapted workflow |
| `react-patterns` | Adapted workflow |
| `error-handling` | Reviewed copy |
| `api-design` | Reviewed copy |
| `contract-first` | Reviewed copy |
| `backend-patterns` | Reviewed copy |
| `react-testing` | Adapted workflow |
| `react-native-patterns` | Adapted workflow |

The adaptations target Codex Desktop, remove incompatible or unwanted defaults, and retain only the workflow needed by this project. ECC is a source library and engineering reference; this project does not distribute ECC as its runtime, memory layer, hook system, MCP platform, or orchestrator.

### ECC license

```text
MIT License

Copyright (c) 2026 Affaan Mustafa

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Supabase Agent Skills

- Repository: <https://github.com/supabase/agent-skills>
- Audited source ref: `8331f910845103c08d51f6ca1d86ebb7d1f745e3`
- Upstream license: MIT
- Copyright: Copyright (c) 2026 Supabase

Included material: `supabase-postgres-best-practices` as a reviewed copy with Codex display metadata. Its complete upstream license is retained at `skills/supabase-postgres-best-practices/LICENSE`.

## OpenAI Skills

- Repository: <https://github.com/openai/skills>
- Audited source ref: `49f948faa9258a0c61caceaf225e179651397431`
- Upstream license: Apache License 2.0 for the redistributed skill

Included material: `security-best-practices`, adapted to the package's autonomous engineering workflow. Its complete upstream license is retained at `skills/security-best-practices/LICENSE.txt`.

## Superpowers

- Repository: <https://github.com/obra/superpowers>
- Audited source ref: `b36e0829c6d0140e93cfef2ca599b1b07d4a7797`
- Upstream license: MIT
- Copyright: Copyright (c) 2025 Jesse Vincent

Included material:

| Local skill | Relationship to upstream |
|---|---|
| `verification-before-completion` | Reviewed copy |
| `systematic-debugging` | Adapted workflow |

### Superpowers license

```text
MIT License

Copyright (c) 2025 Jesse Vincent

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
