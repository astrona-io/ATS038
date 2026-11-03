# Workload Security — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-020-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED (static checks only)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in
`outpost`) with no security context, a Secret `api-key` in `starfleet`, and a
Deployment `debug-tool` in `outpost` whose container is privileged on purpose.
No Pod Security label is set. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-020-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/extras.yaml` | The `api-key` Secret and the privileged `debug-tool` Deployment |
| `docs/overview.md` | What the environment contains and ideas to try |
