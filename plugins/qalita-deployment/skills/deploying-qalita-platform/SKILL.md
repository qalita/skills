---
name: deploying-qalita-platform
description: Use when deploying the QALITA platform itself (backend, frontend, docs, database, cache, object storage) via Docker Compose or the Helm chart, configuring SMTP/LDAP authentication, or deploying additional workers
---

# Deploying the QALITA Platform

The platform's control plane is: **backend** (API), **frontend**, **documentation**, **PostgreSQL** (relational data), **Redis** (cache), **SeaweedFS** (S3-compatible object storage for task logs/pack archives). A valid license (user + key) is mandatory — it authenticates against `registry.qalita.io` for both image pulls and license validation.

## Requirements

| OS          | CPU    | RAM    | Storage     |
| ----------- | ------ | ------ | ----------- |
| linux/amd64 | 4 vCPU | 16 GiB | 100 GiB SSD |

Workers must be able to reach the backend's ingress/endpoint over the network — check firewall/proxy rules before deploying workers remotely.

## Path 1 — Docker Compose (single host / evaluation)

```bash
docker login registry.qalita.io   # username + license key
```

Images are pinned to your licensed version tag (e.g. `2.16.2`) — `registry.qalita.io` does not serve `latest`.

Minimal stack (`docker-compose.yaml`): `backend`, `doc`, `frontendprod`, `db` (postgres), `cache` (redis), `s3` (seaweedfs, needs a sibling `s3_config.json`). Full reference:
[qalita-io/tutorials/deploy/docker-compose](https://github.com/qalita-io/tutorials/tree/main/deploy/docker-compose).

Key backend env vars:

| Group          | Variables                                                                                                                           |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Database       | `POSTGRESQL_SERVER`, `POSTGRESQL_PORT`, `POSTGRESQL_USERNAME`, `POSTGRESQL_PASSWORD`, `POSTGRESQL_DATABASE`                         |
| Cache          | `REDIS_SERVER`, `REDIS_PORT`, `REDIS_PASSWORD`                                                                                      |
| Object storage | `QALITA_S3_URL`, `QALITA_S3_KEY_ID`, `QALITA_S3_KEY_SECRET`                                                                         |
| License        | `QALITA_LICENSE_USER`, `QALITA_LICENSE_KEY`, `QALITA_LICENSE_REGISTRY_URL`                                                          |
| Public URLs    | `QALITA_PUBLIC_PLATFORM_URL`, `QALITA_PUBLIC_DOC_URL`, `QALITA_PUBLIC_API_URL`                                                      |
| Core           | `QALITA_SECRET_KEY`, `QALITA_ADMIN_USERNAME`, `QALITA_ADMIN_PASSWORD`, `QALITA_ENV`, `QALITA_AUTH_MODE`, `QALITA_ORGANIZATION_NAME` |

```bash
docker compose up -d
```

## Path 2 — Kubernetes / Helm (production)

Requirements: Kubernetes 1.24+, Helm 3.0+, Cert-Manager 1.0+. Chart dependencies: `seaweedfs`, `postgresql` (bitnami), `redis` (bitnami).

```bash
kubectl create namespace qalita
helm repo add qalita https://helm.qalita.io/
helm repo update
helm dependency update
helm install qalita qalita/qalita -f values.yaml -n qalita
```

You **must** override defaults with your own `values.yaml` — see the chart's values reference on ArtifactHub (`https://artifacthub.io/packages/helm/qalita/qalita?modal=values`). With `cluster.domain=example.com` the chart exposes `https://example.com` (frontend), `https://api.example.com` (backend), `https://doc.example.com` (docs).

Network matrix (what talks to what):

| Component              | Ingress          | Service:Port                   |
| ---------------------- | ---------------- | ------------------------------ |
| Backend Database       | —                | `qalita-postgresql:5432`       |
| Backend Caching        | —                | `qalita-redis-master:6379`     |
| Backend Object Storage | —                | `seaweedfs-s3:8333`            |
| Backend Server         | `api.domain.com` | `qalita-backend-service:3080`  |
| Documentation          | `doc.domain.com` | `qalita-doc-service:80`        |
| Frontend               | `domain.com`     | `qalita-frontend-service:3000` |

## Authentication modes

`QALITA_AUTH_MODE` selects how users log in:

- `table` — local DB accounts (`QALITA_ADMIN_USERNAME`/`QALITA_ADMIN_PASSWORD` bootstrap the first admin). Default for a fresh eval stack.
- `saml` — Microsoft Entra ID (`MICROSOFT_CLIENT_ID`, `MICROSOFT_CLIENT_SECRET`, `MICROSOFT_TENANT_ID`, `MICROSOFT_REDIRECT_URL`) or Google OAuth (`GOOGLE_OAUTH_CLIENT_ID`, `GOOGLE_OAUTH_CLIENT_SECRET`, `GOOGLE_OAUTH_REDIRECT_URL`).
- `ldap` — bind against an existing directory:

| Variable                                    | Purpose                                                                                                                  |
| ------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| `LDAP_SERVER`                               | e.g. `ldap://ldap.company.com:389`                                                                                       |
| `LDAP_DN`                                   | base DN, e.g. `dc=company,dc=com`                                                                                        |
| `LDAP_SEARCH_USER` / `LDAP_SEARCH_PASSWORD` | bind account used to search the directory                                                                                |
| `LDAP_SEARCH_USER_FILTER`                   | e.g. `(&(objectClass=person)(uid=%s))`                                                                                   |
| `LDAP_SEARCH_GROUP_FILTER`                  | e.g. `(&(objectClass=posixGroup)(memberUid=%s))`                                                                         |
| `LDAP_GROUP_DN`                             | optional group search base                                                                                               |
| `LDAP_ROLE_MAPPING`                         | maps LDAP groups to platform roles, e.g. `admin:cn=admins,dc=company,dc=com;dataengineer:cn=engineers,dc=company,dc=com` |
| `LDAP_TLS`                                  | `true`/`false`                                                                                                           |

The local `QALITA_ADMIN_USERNAME` account always bypasses LDAP, regardless of `QALITA_AUTH_MODE` — useful as a break-glass login.

**Gotcha:** `LDAP_SERVER`'s port must match what the directory server actually listens on internally, not just its host-mapped port — e.g. a bitnami-style OpenLDAP container often listens on `1389` internally even if its host port mapping shows `389`. A mismatch surfaces as "Can't contact LDAP server" with no other detail.

## Mail / SMTP

| Variable                                      | Purpose                                 |
| --------------------------------------------- | --------------------------------------- |
| `MAIL_SERVER`, `MAIL_PORT`                    | SMTP relay host/port                    |
| `MAIL_USERNAME`, `MAIL_PASSWORD`              | SMTP auth                               |
| `MAIL_FROM`, `MAIL_FROM_NAME`                 | sender identity                         |
| `MAIL_STARTTLS`, `MAIL_SSL_TLS`               | transport security (mutually exclusive) |
| `MAIL_USE_CREDENTIALS`, `MAIL_VALIDATE_CERTS` | auth/cert enforcement toggles           |

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
