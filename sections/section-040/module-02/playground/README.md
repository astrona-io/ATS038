# Storage Decisions — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-040-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED. Built with static checks only (`astrona validate`); it has not been booted.

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a dynamically provisioned claim `shuttle-logs` and the `shuttle` Deployment that writes a marker file to it. Use it to try access modes, reclaim policies and expansion. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-040-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded image, starting manifest) |
| `manifests/starfleet.yaml` | Namespaces, the `shuttle-logs` claim and the `shuttle` Deployment |
| `docs/overview.md` | What the environment contains and ideas to try |
