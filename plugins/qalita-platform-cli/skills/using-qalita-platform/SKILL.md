---
name: using-qalita-platform
description: Use when interacting with the QALITA platform via the qalita CLI/worker — installing it, authenticating a worker, listing or pushing sources and packs, running an analysis job, or troubleshooting worker/job configuration
---

# Using the QALITA Platform (CLI & Worker)

The `qalita` CLI (PyPI package `qalita`) is both the developer CLI and the **worker** runtime: it authenticates against the platform backend, registers/pushes sources and packs, and executes analysis jobs (locally in `job` mode or continuously in `worker` mode).

## Install

```bash
pip install qalita        # or: python -m pip install qalita on Windows
qalita --help
```

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

```bash
export QALITA_WORKER_NAME=agent-1
export QALITA_WORKER_MODE=worker
export QALITA_WORKER_ENDPOINT=http://localhost:3080
export QALITA_WORKER_TOKEN=xxxxxxxx
qalita worker login
```

`login` validates the token, checks CLI/platform version compatibility, and registers the worker (writes `~/.qalita/.worker`).

## List platform resources

```bash
qalita source list     # sources known to this worker (from sources-conf.yaml)
qalita pack list       # packs available on the platform
qalita worker joblist  # this worker's job history
```

## Register and push a source

```bash
qalita source add                     # interactive prompt: name, type, connection details
qalita source validate                # validate sources-conf.yaml against the backend's expected schema
qalita source push                    # validate then publish all local sources to the platform
qalita source push --skip-validate    # (or QALITA_SKIP_VALIDATE=1) publish without validating first
```

`source add` supports `file`, `folder`, and most SQL/NoSQL/cloud storage types (`postgresql`, `mysql`, `oracle`, `mssql`, `sqlite`, `mongodb`, `s3`, `gcs`, `azure_blob`, `hdfs`, `snowflake`, `bigquery`, `databricks`, `redshift`, `clickhouse`, `duckdb`, `trino`, `teradata`, `sap_hana`, `cassandra`, `elasticsearch`, `ibm_db2`, `athena`, `synapse`). For SQL sources you can restrict the scan scope with `table_or_query` (default `*` scans everything).

## Run an analysis

Get the IDs first — `qalita source list` and `qalita pack list`.

**One-shot (job mode)** — runs immediately in the current process, useful while developing a pack:

```bash
QALITA_WORKER_MODE=job qalita worker run -s <source_id> -p <pack_id>
# pin exact versions:
QALITA_WORKER_MODE=job qalita worker run -s <source_id> -sv <source_version> -p <pack_id> -pv <pack_version>
```

**Continuous (worker mode)** — the worker waits for tasks assigned from the platform (manual "Trigger immediately", or scheduled **routines** created from a pack's or source's detail page):

```bash
QALITA_WORKER_MODE=worker qalita worker run
```

Uses gRPC by default for real-time job dispatch (`--no-grpc` falls back to REST polling).

## Push a pack

```bash
qalita pack validate -n <pack_name>    # checks folder structure, properties.yaml, pack_conf.json
qalita pack push -n <pack_name>        # validates, then tars and publishes ./<pack_name>_pack
```

See the `qalita-pack-creation` skill for how to build the pack itself.

## Common pitfalls

- **Worker sees no jobs in `worker` mode**: the target source must exist **with an `id`** in *that worker's* `~/.qalita/sources-conf.yaml` — pushing a source from another machine doesn't make it visible here.
- **Job creation via raw REST** (bypassing the CLI): the endpoint is `POST /api/v2/jobs/create`, not `POST /api/v2/jobs` (405). v2 list endpoints are also filtered by `partner_id` — an admin won't see another partner's workers.
- **Kubernetes intra-cluster gRPC**: if the backend's gRPC port (50051) is exposed on the same Service as the REST API with no separate ingress, set `QALITA_GRPC_ENDPOINT` explicitly — auto-derivation from `QALITA_WORKER_ENDPOINT` won't find it.
- **Version mismatch warning** on `worker login`: keep the CLI and platform versions compatible per the documentation's compatibility matrix.
