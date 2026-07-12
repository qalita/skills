# QALITA Skills Marketplace Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up `qalita/skills` as a Claude Code plugin marketplace with three independently-installable plugins (pack creation, platform CLI usage, platform deployment), migrating the existing `creating-qalita-packs` skill out of the `packs` repo in the process.

**Architecture:** A marketplace repo (`.claude-plugin/marketplace.json`) referencing three plugin directories under `plugins/`, each with its own `.claude-plugin/plugin.json` and a `skills/<skill-name>/SKILL.md`. No build step — these are static Markdown/JSON files loaded directly by Claude Code's plugin system, so "tests" are structural/JSON validity checks, not unit tests.

**Tech Stack:** Markdown (SKILL.md, README.md), JSON (marketplace.json, plugin.json), git. `jq` for JSON validation.

## Global Constraints

- Repo: `~/qalita/skills/` locally, remote `qalita/skills` on GitHub, **private** (confirmed intent to make public later — not part of this plan).
- Content must stay generic/public-safe: no internal QALITA infra details (Zot registry, Infisical paths, internal namespaces, GH_PAT). Deployment skill documents only the public path (`registry.qalita.io`, `helm.qalita.io`, the public `qalita/tutorials` docker-compose example).
- Default branch: `main`.
- License: Apache License 2.0 (matches the public/open positioning of `qalita/packs`, unlike the proprietary EULA used for the core product).
- Every SKILL.md needs YAML frontmatter with exactly `name` and `description` fields (matches the format already used by `packs/.claude/skills/creating-qalita-packs/SKILL.md` and by the installed `superpowers` plugin).

---

### Task 1: Repo scaffolding (README, LICENSE, directory skeleton)

**Files:**
- Create: `~/qalita/skills/README.md`
- Create: `~/qalita/skills/LICENSE`
- Create: `~/qalita/skills/.gitignore`

**Interfaces:**
- Produces: repo root that later tasks add `.claude-plugin/` and `plugins/` into.

- [ ] **Step 1: Write the LICENSE file**

```text
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the
      purposes of this License, Derivative Works shall not include works
      that remain separable from, or merely link (or bind by name) to the
      interfaces of, the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including the
      original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing
      the origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

   END OF TERMS AND CONDITIONS

   Copyright 2026 QALITA SAS

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```

- [ ] **Step 2: Write the .gitignore**

```gitignore
.DS_Store
*.swp
```

- [ ] **Step 3: Write the README**

```markdown
# QALITA Skills

<p align="center">
  <img width="250px" height="auto" src="https://app.platform.qalita.io/logo.svg" style="max-width:250px;"/>
</p>

A [Claude Code plugin marketplace](https://docs.claude.com/en/docs/claude-code/plugins) of QALITA skills — instructions that teach Claude Code (or any compatible agent) how to work with QALITA correctly.

## Available plugins

| Plugin | Skill | What it's for |
|---|---|---|
| `qalita-pack-creation` | `creating-qalita-packs` | Building and publishing a QALITA data quality pack (`properties.yaml`, `pack_conf.json`, `main.py`, versioning, CI publish). |
| `qalita-platform-cli` | `using-qalita-platform` | Using the `qalita` CLI/worker: authenticating, pushing sources and packs, running analyses, listing platform resources. |
| `qalita-deployment` | `deploying-qalita-platform` | Deploying the QALITA platform via Docker Compose or Helm, and configuring LDAP/SMTP/workers. |

Each plugin is independent — install only the one(s) relevant to you.

## Installation

```
/plugin marketplace add qalita/skills
/plugin install qalita-pack-creation@qalita-skills
/plugin install qalita-platform-cli@qalita-skills
/plugin install qalita-deployment@qalita-skills
```

## Contributing

Fork this repo and open a pull request. Each skill lives at
`plugins/<plugin-name>/skills/<skill-name>/SKILL.md` with YAML frontmatter
(`name`, `description`) followed by the skill instructions in Markdown.

## License

[Apache License, Version 2.0](./LICENSE).
```

- [ ] **Step 4: Verify files exist**

Run: `ls -la ~/qalita/skills/README.md ~/qalita/skills/LICENSE ~/qalita/skills/.gitignore`
Expected: all three files listed, no "No such file" errors.

- [ ] **Step 5: Commit**

```bash
cd ~/qalita/skills
git add README.md LICENSE .gitignore
git commit -m "chore: scaffold qalita-skills repo (README, LICENSE)"
```

---

### Task 2: marketplace.json

**Files:**
- Create: `~/qalita/skills/.claude-plugin/marketplace.json`

**Interfaces:**
- Consumes: nothing.
- Produces: the marketplace manifest that Task 3/5/6's `source: "./plugins/<name>"` entries must resolve to real directories once those tasks complete.

- [ ] **Step 1: Write marketplace.json**

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "qalita-skills",
  "description": "QALITA's official Claude Code skills: create data quality packs, use the qalita CLI/platform, and deploy the QALITA platform.",
  "owner": {
    "name": "QALITA SAS",
    "email": "contact@qalita.io"
  },
  "plugins": [
    {
      "name": "qalita-pack-creation",
      "description": "Create and publish QALITA data quality packs (properties.yaml, pack_conf.json, main.py pattern, versioning, CI publish).",
      "category": "development",
      "source": "./plugins/qalita-pack-creation",
      "homepage": "https://github.com/qalita/skills/tree/main/plugins/qalita-pack-creation"
    },
    {
      "name": "qalita-platform-cli",
      "description": "Use the qalita CLI/worker to authenticate, push sources and packs, run analyses, and manage jobs on the QALITA platform.",
      "category": "data",
      "source": "./plugins/qalita-platform-cli",
      "homepage": "https://github.com/qalita/skills/tree/main/plugins/qalita-platform-cli"
    },
    {
      "name": "qalita-deployment",
      "description": "Deploy and configure the QALITA platform via Docker Compose or Helm, including LDAP, SMTP, and worker deployment.",
      "category": "infrastructure",
      "source": "./plugins/qalita-deployment",
      "homepage": "https://github.com/qalita/skills/tree/main/plugins/qalita-deployment"
    }
  ]
}
```

- [ ] **Step 2: Validate JSON syntax**

Run: `jq . ~/qalita/skills/.claude-plugin/marketplace.json`
Expected: pretty-printed JSON echoed back, no `jq: error` output.

- [ ] **Step 3: Commit**

```bash
cd ~/qalita/skills
git add .claude-plugin/marketplace.json
git commit -m "feat: add marketplace.json declaring 3 QALITA plugins"
```

---

### Task 3: Plugin `qalita-pack-creation` (migrate `creating-qalita-packs`)

**Files:**
- Create: `~/qalita/skills/plugins/qalita-pack-creation/.claude-plugin/plugin.json`
- Create: `~/qalita/skills/plugins/qalita-pack-creation/skills/creating-qalita-packs/SKILL.md`

**Interfaces:**
- Consumes: content of `~/qalita/packs/.claude/skills/creating-qalita-packs/SKILL.md` (existing file, read-only source for this task — it is deleted from the `packs` repo in Task 4, a separate repo/commit).
- Produces: `plugins/qalita-pack-creation/` resolvable by the `source` path declared in Task 2's `marketplace.json`.

- [ ] **Step 1: Write plugin.json**

```json
{
  "name": "qalita-pack-creation",
  "displayName": "QALITA Pack Creation",
  "description": "Create and publish QALITA data quality packs: folder structure, properties.yaml, pack_conf.json, the main.py pattern, versioning, and CI publishing.",
  "version": "0.1.0",
  "author": {
    "name": "QALITA SAS",
    "email": "contact@qalita.io"
  },
  "homepage": "https://github.com/qalita/skills",
  "repository": "https://github.com/qalita/skills",
  "license": "Apache-2.0",
  "keywords": ["qalita", "data-quality", "packs"],
  "skills": "./skills/"
}
```

- [ ] **Step 2: Copy the existing skill content verbatim**

Copy `~/qalita/packs/.claude/skills/creating-qalita-packs/SKILL.md` to
`~/qalita/skills/plugins/qalita-pack-creation/skills/creating-qalita-packs/SKILL.md`
unchanged (same frontmatter, same body — it is already production-quality).

Run:
```bash
mkdir -p ~/qalita/skills/plugins/qalita-pack-creation/skills/creating-qalita-packs
cp ~/qalita/packs/.claude/skills/creating-qalita-packs/SKILL.md \
   ~/qalita/skills/plugins/qalita-pack-creation/skills/creating-qalita-packs/SKILL.md
```

- [ ] **Step 3: Validate JSON and frontmatter**

Run:
```bash
jq . ~/qalita/skills/plugins/qalita-pack-creation/.claude-plugin/plugin.json
head -5 ~/qalita/skills/plugins/qalita-pack-creation/skills/creating-qalita-packs/SKILL.md
```
Expected: `jq` prints valid JSON; the `head` output starts with `---`, then a
`name: creating-qalita-packs` line, then a `description:` line, then `---`.

- [ ] **Step 4: Diff against the source to confirm a verbatim copy**

Run: `diff ~/qalita/packs/.claude/skills/creating-qalita-packs/SKILL.md ~/qalita/skills/plugins/qalita-pack-creation/skills/creating-qalita-packs/SKILL.md`
Expected: no output (files identical).

- [ ] **Step 5: Commit**

```bash
cd ~/qalita/skills
git add plugins/qalita-pack-creation
git commit -m "feat: add qalita-pack-creation plugin (migrated from packs repo)"
```

---

### Task 4: Remove the skill from the `packs` repo and update AGENTS.md

**Files:**
- Delete: `~/qalita/packs/.claude/skills/` (entire directory)
- Modify: `~/qalita/packs/AGENTS.md` (the "Creating a New Pack" section)

**Interfaces:**
- Consumes: Task 3 must be committed first (the content now lives safely in the `skills` repo before it's deleted here).
- Produces: nothing consumed by later tasks — this is a cleanup task in a **different git repo** (`packs`), committed separately from the `skills` repo work.

- [ ] **Step 1: Delete the old skill directory**

Run: `rm -rf ~/qalita/packs/.claude/skills`

- [ ] **Step 2: Update AGENTS.md's "Creating a New Pack" section**

In `~/qalita/packs/AGENTS.md`, replace:

```markdown
## Creating a New Pack

**REQUIRED SKILL:** Before creating a new pack (or modifying pack structure/config/versioning), read [.claude/skills/creating-qalita-packs/SKILL.md](.claude/skills/creating-qalita-packs/SKILL.md) — it documents required files, config templates, the `main.py` pattern, versioning, and publishing.
```

with:

```markdown
## Creating a New Pack

**REQUIRED SKILL:** Before creating a new pack (or modifying pack structure/config/versioning), install the `qalita-pack-creation` plugin from the [`qalita/skills`](https://github.com/qalita/skills) marketplace — it documents required files, config templates, the `main.py` pattern, versioning, and publishing.

```
/plugin marketplace add qalita/skills
/plugin install qalita-pack-creation@qalita-skills
```
```

- [ ] **Step 3: Verify the old path is gone and AGENTS.md no longer references it**

Run:
```bash
test -d ~/qalita/packs/.claude/skills && echo "STILL EXISTS" || echo "removed"
grep -c "qalita-pack-creation" ~/qalita/packs/AGENTS.md
```
Expected: `removed`, then a count of `1` or more (new reference present).

- [ ] **Step 4: Commit in the packs repo**

```bash
cd ~/qalita/packs
git add -A AGENTS.md
git status   # confirm .claude/skills deletion is staged
git commit -m "docs: migrate creating-qalita-packs skill to qalita/skills marketplace"
```

---

### Task 5: Plugin `qalita-platform-cli` (`using-qalita-platform`)

**Files:**
- Create: `~/qalita/skills/plugins/qalita-platform-cli/.claude-plugin/plugin.json`
- Create: `~/qalita/skills/plugins/qalita-platform-cli/skills/using-qalita-platform/SKILL.md`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `plugins/qalita-platform-cli/` resolvable by `marketplace.json` (Task 2).

- [ ] **Step 1: Write plugin.json**

```json
{
  "name": "qalita-platform-cli",
  "displayName": "QALITA Platform CLI",
  "description": "Use the qalita CLI/worker to authenticate, push sources and packs, run analyses, and manage jobs on the QALITA platform.",
  "version": "0.1.0",
  "author": {
    "name": "QALITA SAS",
    "email": "contact@qalita.io"
  },
  "homepage": "https://github.com/qalita/skills",
  "repository": "https://github.com/qalita/skills",
  "license": "Apache-2.0",
  "keywords": ["qalita", "cli", "worker", "data-quality"],
  "skills": "./skills/"
}
```

- [ ] **Step 2: Write SKILL.md**

```markdown
---
name: using-qalita-platform
description: Use when interacting with the QALITA platform via the qalita CLI/worker — installing it, authenticating a worker, listing or pushing sources and packs, running an analysis job, or troubleshooting worker/job configuration
---

# Using the QALITA Platform (CLI & Worker)

The `qalita` CLI (PyPI package `qalita`) is both the developer CLI and the **worker** runtime: it authenticates against the platform backend, registers/pushes sources and packs, and executes analysis jobs (locally in `job` mode or continuously in `worker` mode).

## Install

\`\`\`bash
pip install qalita        # or: python -m pip install qalita on Windows
qalita --help
\`\`\`

Requires Python >= 3.8. Alternative: the Docker image instead of a local pip install.

## Core concepts

- **Worker modes** — set via `QALITA_WORKER_MODE` or `qalita worker -m <mode>`:
  - `job`: `qalita worker run` executes **one** job immediately then exits. Used for developing/debugging packs.
  - `worker`: `qalita worker run` loops forever, polling the backend for tasks/routines to execute.
- **Config files** live under `~/.qalita/` (override the base dir with `QALITA_HOME`):
  - `~/.qalita/sources-conf.yaml` — locally registered sources.
  - `~/.qalita/.worker` — the worker's registration state after `qalita worker login`.
  - A worker in `worker` mode can only run tasks on sources present **with an `id`** in its own `sources-conf.yaml` — a source pushed from a different machine/worker is invisible to this one until it's added and pushed here too.

## Authenticate a worker

Minimal + connected configuration (env vars, or a `.env-local` file sourced with `set -a; source .env-local; set +a`):

| Variable | Purpose |
|---|---|
| `QALITA_WORKER_NAME` | Free-form name shown in the platform UI |
| `QALITA_WORKER_MODE` | `job` or `worker` |
| `QALITA_WORKER_ENDPOINT` | Backend API URL, e.g. `http://localhost:3080` |
| `QALITA_WORKER_TOKEN` | API token from the platform (Data Engineer role or higher) |
| `QALITA_GRPC_ENDPOINT` | (Optional) explicit gRPC target override — needed in Kubernetes when the gRPC port is exposed on the same Service as the REST API, since it can't be auto-derived |
| `SKIP_SSL_VERIFY` | (Dev only) skip TLS verification |

\`\`\`bash
export QALITA_WORKER_NAME=agent-1
export QALITA_WORKER_MODE=worker
export QALITA_WORKER_ENDPOINT=http://localhost:3080
export QALITA_WORKER_TOKEN=xxxxxxxx
qalita worker login
\`\`\`

`login` validates the token, checks CLI/platform version compatibility, and registers the worker (writes `~/.qalita/.worker`).

## List platform resources

\`\`\`bash
qalita source list    # sources known to this worker (from sources-conf.yaml)
qalita pack list       # packs available on the platform
qalita worker joblist  # this worker's job history
\`\`\`

## Register and push a source

\`\`\`bash
qalita source add                    # interactive prompt: name, type, connection details
qalita source validate                # validate sources-conf.yaml against the backend's expected schema
qalita source push                    # validate then publish all local sources to the platform
qalita source push --skip-validate    # (or QALITA_SKIP_VALIDATE=1) publish without validating first
\`\`\`

`source add` supports `file`, `folder`, and most SQL/NoSQL/cloud storage types (`postgresql`, `mysql`, `oracle`, `mssql`, `sqlite`, `mongodb`, `s3`, `gcs`, `azure_blob`, `hdfs`, `snowflake`, `bigquery`, `databricks`, `redshift`, `clickhouse`, `duckdb`, `trino`, `teradata`, `sap_hana`, `cassandra`, `elasticsearch`, `ibm_db2`, `athena`, `synapse`). For SQL sources you can restrict the scan scope with `table_or_query` (default `*` scans everything).

## Run an analysis

Get the IDs first — `qalita source list` and `qalita pack list`.

**One-shot (job mode)** — runs immediately in the current process, useful while developing a pack:

\`\`\`bash
QALITA_WORKER_MODE=job qalita worker run -s <source_id> -p <pack_id>
# pin exact versions:
QALITA_WORKER_MODE=job qalita worker run -s <source_id> -sv <source_version> -p <pack_id> -pv <pack_version>
\`\`\`

**Continuous (worker mode)** — the worker waits for tasks assigned from the platform (manual "Trigger immediately", or scheduled **routines** created from a pack's or source's detail page):

\`\`\`bash
QALITA_WORKER_MODE=worker qalita worker run
\`\`\`

Uses gRPC by default for real-time job dispatch (`--no-grpc` falls back to REST polling).

## Push a pack

\`\`\`bash
qalita pack validate -n <pack_name>   # checks folder structure, properties.yaml, pack_conf.json
qalita pack push -n <pack_name>        # validates, then tars and publishes ./<pack_name>_pack
\`\`\`

See the `qalita-pack-creation` skill for how to build the pack itself.

## Common pitfalls

- **Worker sees no jobs in `worker` mode**: the target source must exist **with an `id`** in *that worker's* `~/.qalita/sources-conf.yaml` — pushing a source from another machine doesn't make it visible here.
- **Job creation via raw REST** (bypassing the CLI): the endpoint is `POST /api/v2/jobs/create`, not `POST /api/v2/jobs` (405). v2 list endpoints are also filtered by `partner_id` — an admin won't see another partner's workers.
- **Kubernetes intra-cluster gRPC**: if the backend's gRPC port (50051) is exposed on the same Service as the REST API with no separate ingress, set `QALITA_GRPC_ENDPOINT` explicitly — auto-derivation from `QALITA_WORKER_ENDPOINT` won't find it.
- **Version mismatch warning** on `worker login`: keep the CLI and platform versions compatible per the documentation's compatibility matrix.
```

- [ ] **Step 3: Validate JSON and frontmatter**

Run:
```bash
jq . ~/qalita/skills/plugins/qalita-platform-cli/.claude-plugin/plugin.json
head -5 ~/qalita/skills/plugins/qalita-platform-cli/skills/using-qalita-platform/SKILL.md
```
Expected: `jq` prints valid JSON; `head` shows frontmatter starting with `---`, a `name: using-qalita-platform` line, a `description:` line, then `---`.

- [ ] **Step 4: Commit**

```bash
cd ~/qalita/skills
git add plugins/qalita-platform-cli
git commit -m "feat: add qalita-platform-cli plugin (using-qalita-platform skill)"
```

---

### Task 6: Plugin `qalita-deployment` (`deploying-qalita-platform`)

**Files:**
- Create: `~/qalita/skills/plugins/qalita-deployment/.claude-plugin/plugin.json`
- Create: `~/qalita/skills/plugins/qalita-deployment/skills/deploying-qalita-platform/SKILL.md`

**Interfaces:**
- Consumes: nothing from other tasks.
- Produces: `plugins/qalita-deployment/` resolvable by `marketplace.json` (Task 2).

- [ ] **Step 1: Write plugin.json**

```json
{
  "name": "qalita-deployment",
  "displayName": "QALITA Deployment",
  "description": "Deploy and configure the QALITA platform via Docker Compose or Helm, including LDAP, SMTP, and worker deployment.",
  "version": "0.1.0",
  "author": {
    "name": "QALITA SAS",
    "email": "contact@qalita.io"
  },
  "homepage": "https://github.com/qalita/skills",
  "repository": "https://github.com/qalita/skills",
  "license": "Apache-2.0",
  "keywords": ["qalita", "deployment", "helm", "docker-compose", "ldap"],
  "skills": "./skills/"
}
```

- [ ] **Step 2: Write SKILL.md**

```markdown
---
name: deploying-qalita-platform
description: Use when deploying the QALITA platform itself (backend, frontend, docs, database, cache, object storage) via Docker Compose or the Helm chart, configuring SMTP/LDAP authentication, or deploying additional workers
---

# Deploying the QALITA Platform

The platform's control plane is: **backend** (API), **frontend**, **documentation**, **PostgreSQL** (relational data), **Redis** (cache), **SeaweedFS** (S3-compatible object storage for task logs/pack archives). A valid license (user + key) is mandatory — it authenticates against `registry.qalita.io` for both image pulls and license validation.

## Requirements

| OS | CPU | RAM | Storage |
|---|---|---|---|
| linux/amd64 | 4 vCPU | 16 GiB | 100 GiB SSD |

Workers must be able to reach the backend's ingress/endpoint over the network — check firewall/proxy rules before deploying workers remotely.

## Path 1 — Docker Compose (single host / evaluation)

\`\`\`bash
docker login registry.qalita.io   # username + license key
\`\`\`

Images are pinned to your licensed version tag (e.g. `2.16.2`) — `registry.qalita.io` does not serve `latest`.

Minimal stack (`docker-compose.yaml`): `backend`, `doc`, `frontendprod`, `db` (postgres), `cache` (redis), `s3` (seaweedfs, needs a sibling `s3_config.json`). Full reference:
[qalita/tutorials/deploy/docker-compose](https://github.com/qalita/tutorials/tree/main/deploy/docker-compose).

Key backend env vars:

| Group | Variables |
|---|---|
| Database | `POSTGRESQL_SERVER`, `POSTGRESQL_PORT`, `POSTGRESQL_USERNAME`, `POSTGRESQL_PASSWORD`, `POSTGRESQL_DATABASE` |
| Cache | `REDIS_SERVER`, `REDIS_PORT`, `REDIS_PASSWORD` |
| Object storage | `QALITA_S3_URL`, `QALITA_S3_KEY_ID`, `QALITA_S3_KEY_SECRET` |
| License | `QALITA_LICENSE_USER`, `QALITA_LICENSE_KEY`, `QALITA_LICENSE_REGISTRY_URL` |
| Public URLs | `QALITA_PUBLIC_PLATFORM_URL`, `QALITA_PUBLIC_DOC_URL`, `QALITA_PUBLIC_API_URL` |
| Core | `QALITA_SECRET_KEY`, `QALITA_ADMIN_USERNAME`, `QALITA_ADMIN_PASSWORD`, `QALITA_ENV`, `QALITA_AUTH_MODE`, `QALITA_ORGANIZATION_NAME` |

\`\`\`bash
docker compose up -d
\`\`\`

## Path 2 — Kubernetes / Helm (production)

Requirements: Kubernetes 1.24+, Helm 3.0+, Cert-Manager 1.0+. Chart dependencies: `seaweedfs`, `postgresql` (bitnami), `redis` (bitnami).

\`\`\`bash
kubectl create namespace qalita
helm repo add qalita https://helm.qalita.io/
helm repo update
helm dependency update
helm install qalita qalita/qalita -f values.yaml -n qalita
\`\`\`

You **must** override defaults with your own `values.yaml` — see the chart's values reference on ArtifactHub (`https://artifacthub.io/packages/helm/qalita/qalita?modal=values`). With `cluster.domain=example.com` the chart exposes `https://example.com` (frontend), `https://api.example.com` (backend), `https://doc.example.com` (docs).

Network matrix (what talks to what):

| Component | Ingress | Service:Port |
|---|---|---|
| Backend Database | — | `qalita-postgresql:5432` |
| Backend Caching | — | `qalita-redis-master:6379` |
| Backend Object Storage | — | `seaweedfs-s3:8333` |
| Backend Server | `api.domain.com` | `qalita-backend-service:3080` |
| Documentation | `doc.domain.com` | `qalita-doc-service:80` |
| Frontend | `domain.com` | `qalita-frontend-service:3000` |

## Authentication modes

`QALITA_AUTH_MODE` selects how users log in:

- `table` — local DB accounts (`QALITA_ADMIN_USERNAME`/`QALITA_ADMIN_PASSWORD` bootstrap the first admin). Default for a fresh eval stack.
- `saml` — Microsoft Entra ID (`MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`, `MICROSOFT_TENANT_ID`, `MICROSOFT_REDIRECT_URL`) or Google OAuth (`GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REDIRECT_URL`).
- `ldap` — bind against an existing directory:

| Variable | Purpose |
|---|---|
| `LDAP_SERVER` | e.g. `ldap://ldap.company.com:389` |
| `LDAP_DN` | base DN, e.g. `dc=company,dc=com` |
| `LDAP_SEARCH_USER` / `LDAP_SEARCH_PASSWORD` | bind account used to search the directory |
| `LDAP_SEARCH_USER_FILTER` | e.g. `(&(objectClass=person)(uid=%s))` |
| `LDAP_SEARCH_GROUP_FILTER` | e.g. `(&(objectClass=posixGroup)(memberUid=%s))` |
| `LDAP_GROUP_DN` | optional group search base |
| `LDAP_ROLE_MAPPING` | maps LDAP groups to platform roles, e.g. `admin:cn=admins,dc=company,dc=com;dataengineer:cn=engineers,dc=company,dc=com` |
| `LDAP_TLS` | `true`/`false` |

The local `QALITA_ADMIN_USERNAME` account always bypasses LDAP, regardless of `QALITA_AUTH_MODE` — useful as a break-glass login.

**Gotcha:** `LDAP_SERVER`'s port must match what the directory server actually listens on internally, not just its host-mapped port — e.g. a bitnami-style OpenLDAP container often listens on `1389` internally even if its host port mapping shows `389`. A mismatch surfaces as "Can't contact LDAP server" with no other detail.

## Mail / SMTP

| Variable | Purpose |
|---|---|
| `MAIL_SERVER`, `MAIL_PORT` | SMTP relay host/port |
| `MAIL_USERNAME`, `MAIL_PASSWORD` | SMTP auth |
| `MAIL_FROM`, `MAIL_FROM_NAME` | sender identity |
| `MAIL_STARTTLS`, `MAIL_SSL_TLS` | transport security (mutually exclusive) |
| `MAIL_USE_CREDENTIALS`, `MAIL_VALIDATE_CERTS` | auth/cert enforcement toggles |

Used for notification emails (invites, alerts). Point `MAIL_SERVER`/`MAIL_PORT` at your real relay in production — dev stacks typically use a local catch-all SMTP instead.

## Deploying workers

Workers are separate from the control plane and should run **as close to the data source as possible**. Three modalities:

1. **Desktop/CLI** — `pip install qalita` on a workstation; see the `qalita-platform-cli` skill for `worker login`/`run`.
2. **Docker** — run the CLI's Docker image with the same worker env vars.
3. **Kubernetes** — enable the chart's worker sub-resource with `worker.enabled=true` in `values.yaml`, either in the platform's own namespace or a separate one closer to the data (see the chart's `worker` values block on ArtifactHub for all options).

A worker only needs outbound network access to the backend's ingress/endpoint — no inbound ports are required on the worker side.

## Common pitfalls

- Using `latest` against `registry.qalita.io` — only versioned tags are served; pin the tag to your licensed version.
- Forgetting `s3_config.json` next to `docker-compose.yaml` — the `s3` (seaweedfs) service mounts it and won't start correctly without it.
- Leaving `QALITA_AUTH_MODE` unset after configuring LDAP env vars — the mode must be switched to `ldap` explicitly for them to take effect.
- Deploying a worker that can't reach the backend's endpoint over the network (firewall/proxy) — check the network matrix above before troubleshooting the worker itself.
```

- [ ] **Step 3: Validate JSON and frontmatter**

Run:
```bash
jq . ~/qalita/skills/plugins/qalita-deployment/.claude-plugin/plugin.json
head -5 ~/qalita/skills/plugins/qalita-deployment/skills/deploying-qalita-platform/SKILL.md
```
Expected: `jq` prints valid JSON; `head` shows frontmatter starting with `---`, a `name: deploying-qalita-platform` line, a `description:` line, then `---`.

- [ ] **Step 4: Commit**

```bash
cd ~/qalita/skills
git add plugins/qalita-deployment
git commit -m "feat: add qalita-deployment plugin (deploying-qalita-platform skill)"
```

---

### Task 7: Marketplace structural validation

**Files:**
- None created — this task only validates Tasks 1–6's output together.

**Interfaces:**
- Consumes: `marketplace.json` (Task 2) and all three `plugins/*/` directories (Tasks 3, 5, 6).

- [ ] **Step 1: Write a validation script**

Create `~/qalita/skills/scripts/validate-marketplace.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== Validating marketplace.json =="
jq -e '.plugins | length == 3' .claude-plugin/marketplace.json > /dev/null
echo "OK: 3 plugins declared"

echo "== Validating each plugin =="
for name in $(jq -r '.plugins[].name' .claude-plugin/marketplace.json); do
  source_path=$(jq -r --arg n "$name" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
  dir="${source_path#./}"

  test -d "$dir" || { echo "FAIL: $dir does not exist for plugin $name"; exit 1; }

  plugin_json="$dir/.claude-plugin/plugin.json"
  test -f "$plugin_json" || { echo "FAIL: missing $plugin_json"; exit 1; }
  jq -e --arg n "$name" '.name == $n' "$plugin_json" > /dev/null \
    || { echo "FAIL: $plugin_json name field does not match '$name'"; exit 1; }

  skills_dir="$dir/skills"
  skill_count=$(find "$skills_dir" -name "SKILL.md" | wc -l | tr -d ' ')
  [ "$skill_count" -ge 1 ] || { echo "FAIL: no SKILL.md found under $skills_dir"; exit 1; }

  find "$skills_dir" -name "SKILL.md" | while read -r skill_file; do
    head -1 "$skill_file" | grep -q '^---$' \
      || { echo "FAIL: $skill_file missing frontmatter opening ---"; exit 1; }
    grep -q '^name:' "$skill_file" \
      || { echo "FAIL: $skill_file missing 'name:' frontmatter field"; exit 1; }
    grep -q '^description:' "$skill_file" \
      || { echo "FAIL: $skill_file missing 'description:' frontmatter field"; exit 1; }
  done

  echo "OK: $name ($skill_count SKILL.md)"
done

echo "== All checks passed =="
```

- [ ] **Step 2: Make it executable and run it**

Run:
```bash
chmod +x ~/qalita/skills/scripts/validate-marketplace.sh
~/qalita/skills/scripts/validate-marketplace.sh
```
Expected output ends with:
```
OK: qalita-pack-creation (1 SKILL.md)
OK: qalita-platform-cli (1 SKILL.md)
OK: qalita-deployment (1 SKILL.md)
== All checks passed ==
```

- [ ] **Step 3: If any FAIL line appears, fix the referenced file and re-run Step 2 before continuing.**

- [ ] **Step 4: Commit the validation script**

```bash
cd ~/qalita/skills
git add scripts/validate-marketplace.sh
git commit -m "test: add marketplace structural validation script"
```

---

### Task 8: Create the GitHub remote and push both repos

**Files:**
- None created — this task pushes existing commits from Tasks 1–7 (`skills` repo) and Task 4 (`packs` repo).

**Interfaces:**
- Consumes: all prior tasks' commits.

- [ ] **Step 1: Confirm no uncommitted changes remain in either repo**

Run:
```bash
cd ~/qalita/skills && git status --short
cd ~/qalita/packs && git status --short
```
Expected: both empty (nothing to commit).

- [ ] **Step 2: Create the private GitHub repo**

**Confirm with the user immediately before running this** — it creates a new repo under the `qalita` org, a shared/visible action.

```bash
cd ~/qalita/skills
gh repo create qalita/skills --private --source=. --remote=origin --description "QALITA's official Claude Code skills marketplace"
```

- [ ] **Step 3: Push the skills repo**

```bash
cd ~/qalita/skills
git push -u origin main
```
Expected: push succeeds, prints the new branch tracking info.

- [ ] **Step 4: Push the packs repo changes**

**Confirm with the user immediately before running this** — pushes to an existing shared repo.

```bash
cd ~/qalita/packs
git push origin HEAD
```
Expected: push succeeds.

- [ ] **Step 5: Add `skills` to `~/qalita/AGENTS.md`'s repo table**

In `~/qalita/AGENTS.md`, add a row to the `## Repos` table:

```markdown
| qalita/skills          | `skills/`           | Marketplace de Claude Code skills QALITA |
```

- [ ] **Step 6: Verify the remote is reachable**

Run: `gh repo view qalita/skills --json name,visibility,url`
Expected: JSON showing `"name": "skills"`, `"visibility": "PRIVATE"`, and the repo URL.
