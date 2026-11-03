# Diagnosing Cluster Services — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-030-02
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED. Built with static checks only; not booted yet.

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a
healthy `scout`, `shuttle` and `drifter`, and five broken pieces around them:
a Service whose selector matches nothing (`probe`), a Service with the wrong
`targetPort` (`relay`), a pod that needs a ConfigMap that does not exist
(`lander`), a Service whose only pod fails its readiness probe (`gate`) and a
pod that waits on a claim with a missing StorageClass (`archive`). Nothing to
submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-030-02
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` and `astrona test` do not apply — there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, healthy `scout` with its Service, `shuttle` and `drifter` |
| `manifests/faults.yaml` | `probe`, `relay`, `lander`, `gate`, `archive` and the claim `ledger` |
| `docs/overview.md` | What the environment contains and ideas to try |
