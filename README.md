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
/plugin marketplace add qalita-io/skills
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
