# Traffic Control — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-010-03
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED. Built from documentation; the environment has not been booted yet.

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with the
Starfleet workloads: `scout` (podinfo), `probe` (go-httpbin) and `shuttle`
(curl client) in `starfleet`, and `drifter` (curl client) in `outpost`.
`scout` and `probe` each have a ClusterIP Service on port 80. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-010-03
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespaces, service accounts, workloads and Services |
| `docs/overview.md` | What the environment contains and ideas to try |
