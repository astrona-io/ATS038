# Identity And Access — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-020-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED (static checks only)

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads (`scout`, `probe`, `shuttle` in `starfleet`, `drifter` in
`outpost`) on their own service accounts, an `auditor` service account with no
rights, and a `ClusterRoleBinding` `drifter-view` that gives `drifter` the
built-in `view` role in every namespace on purpose. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-020-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` and `astrona test` do not apply: there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts and the Starfleet workloads |
| `manifests/access.yaml` | The `auditor` service account and the broad `drifter-view` binding |
| `docs/overview.md` | What the environment contains and ideas to try |
