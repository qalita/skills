# QALITA Skills Marketplace — Design

Date: 2026-07-09

## Purpose

Centralize QALITA's Claude Code skills (currently one exists, buried in
`packs/.claude/skills/`) into a dedicated, publicly-shareable repo
(`qalita/skills`) structured as a Claude Code plugin marketplace. Internal
QALITA engineers and external clients/partners should be able to install just
the skill(s) relevant to them.

## Audience

Internal QALITA team **and** clients/partners. Consequence: skill content
must stay generic — no internal infra details (Zot registry, Infisical vault
paths, internal Kubernetes namespaces, GH_PAT rotation, etc.). Deployment
guidance covers the public/documented path only (`helm repo add qalita
https://helm.qalita.io/`, public `docker-compose.yaml` pattern, standard
env vars) — not QALITA's own prod cluster.

## Repo layout

New repo `qalita/skills`, cloned locally at `~/qalita/skills/` alongside
the other qalita repos (added to the table in `~/qalita/AGENTS.md`).

Structured as a Claude Code plugin **marketplace** with three independent
plugins (mirrors the `superpowers` plugin layout under
`~/.claude/plugins/cache/claude-plugins-official/superpowers/`):

```
skills/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── qalita-pack-creation/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       └── creating-qalita-packs/
│   │           └── SKILL.md
│   ├── qalita-platform-cli/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/
│   │       └── using-qalita-platform/
│   │           └── SKILL.md
│   └── qalita-deployment/
│       ├── .claude-plugin/plugin.json
│       └── skills/
│           └── deploying-qalita-platform/
│               └── SKILL.md
├── README.md
└── LICENSE
```

Each plugin is independently versioned and installable
(`/plugin install qalita-pack-creation@qalita-skills`), so a client deploying
only the platform doesn't pull in the internal pack-authoring skill.

`marketplace.json` follows the schema seen in the official marketplace:
`name`, `description`, `owner`, and a `plugins` array where each entry has
`name`, `description`, `category`, and `source: "./plugins/<name>"`.

Each `plugin.json` follows the superpowers pattern: `name`, `description`,
`version` (start at `0.1.0`), `author` (QALITA SAS), `license`, `keywords`,
`skills: "./skills/"`.

## Skill 1 — `qalita-pack-creation` (`creating-qalita-packs`)

**Source of truth:** migrated verbatim from
`packs/.claude/skills/creating-qalita-packs/SKILL.md` (already
production-quality: pack folder structure, `properties.yaml`,
`pack_conf.json`, `main.py` pattern, `pyproject.toml`, versioning via
`properties.yaml`, publish flow, common mistakes).

**Migration steps:**
1. Copy the file into
   `plugins/qalita-pack-creation/skills/creating-qalita-packs/SKILL.md`
   unchanged.
2. Delete `packs/.claude/skills/` from the `packs` repo.
3. Update the "Creating a New Pack" section of `packs/AGENTS.md` to point at
   the new marketplace plugin instead of the local path (e.g. "install the
   `qalita-pack-creation` plugin from the `qalita/skills` marketplace:
   `/plugin marketplace add qalita/skills` then
   `/plugin install qalita-pack-creation@qalita-skills`").
4. Commit both changes in the `packs` repo as a separate commit from the new
   `skills` repo work.

## Skill 2 — `qalita-platform-cli` (`using-qalita-platform`)

Covers using the `qalita` CLI/worker to interact with the platform: pushing
data sources, running analyses/packs, listing resources, configuring a
worker. Grounded in the actual command surface found in
`qalita-cli/qalita/commands/`:

- **`qalita source`**: `add` (interactive), `validate`, `push` — registering
  and validating data sources against `source_conf.json`-style config.
- **`qalita pack`**: `list`, `validate`, `push`, `run`, `init` — listing
  available packs, validating a pack directory, publishing, running an
  analysis locally.
- **`qalita worker`**: `login`, `run`, `info`, `joblist` — authenticating a
  worker against the backend, running it in `worker` (long-lived,
  polls for jobs) or `job` (one-shot) mode.
- Key env vars: `QALITA_WORKER_NAME`, `QALITA_WORKER_ENDPOINT`,
  `QALITA_WORKER_TOKEN`, `QALITA_WORKER_MODE`, `QALITA_GRPC_ENDPOINT`,
  `SKIP_SSL_VERIFY` (dev only).
- REST v2 gotcha: creating a job is `POST /api/v2/jobs/create`, not
  `POST /api/v2/jobs` (405).
- Typical end-to-end workflow: configure worker → push a source → push/run
  a pack → check results on the platform.

## Skill 3 — `qalita-deployment` (`deploying-qalita-platform`)

Covers deploying and configuring the QALITA platform itself (backend,
frontend, workers) via either docker-compose or Helm, plus LDAP/mail/worker
configuration. Grounded in `platform/docker-compose.yaml` and
`helm-platform/charts/qalita/values.yaml`:

- **Docker-compose path**: services in `platform/docker-compose.yaml`
  (backend, frontend, postgres, seaweedfs/object storage, optional
  openldap), `.env` configuration.
- **Helm path**: `helm repo add qalita https://helm.qalita.io/`, chart at
  `qalita/qalita`; key `values.yaml` sections: `licenseUser`/`licenseKey`,
  `dockerregistry`, `frontend`, `backend.mail` (SMTP), `worker`,
  `postgresql`, `seaweedfs`, `redirect`, `helmsync`.
- **LDAP configuration**: `QALITA_AUTH_MODE=ldap` must be set explicitly
  (default is local/SAML — local admin bypasses LDAP either way); documented
  gotcha that the LDAP server URL's port must match the actual listener
  (e.g. bitnami openldap listens on `1389` internally even when the host
  port mapping says `389`) — mismatches surface as "Can't contact LDAP
  server".
- **Mail/SMTP configuration**: `backend.mail` values block (Helm) /
  equivalent env vars (docker-compose) for outbound notification email.
- **Worker deployment**: as an additional docker-compose service, or as the
  `worker` values block / a worker Helm subchart — pointing at
  `QALITA_WORKER_ENDPOINT` of the already-deployed backend.
- **Common pitfalls** section distilled from real troubleshooting: LDAP port
  mismatch, auth mode not switched, job-creation endpoint typo (shared with
  skill 2 where relevant to a freshly deployed instance).

No internal QALITA production secrets, registry URLs, or namespace names —
this skill teaches the generic/public deployment path only.

## Out of scope for this iteration

- CI/CD for the `skills` repo itself (lint/test workflow for SKILL.md
  files) — can be added later, not needed for a first working marketplace.
- Publishing the marketplace to the official Anthropic directory — this is
  a QALITA-owned marketplace added manually via
  `/plugin marketplace add qalita/skills`.

## Execution notes

- New repo is git-initialized locally at `~/qalita/skills/` (branch `main`).
- A remote GitHub repo `qalita/skills` will be created **private** and
  pushed to during implementation. Confirmed intent to make it **public**
  later (once content is reviewed), but that switch is out of scope for
  this iteration.
