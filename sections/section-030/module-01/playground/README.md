# Diagnosing Orchestration Failures — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-030-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED. Built with static checks only; not booted yet.

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a
healthy `scout` and `shuttle` in `starfleet`, and six Deployments that fail on
purpose: `lander` and `hauler` stay Pending, `tanker` cannot pull its image,
`rover` crashes, `miner` is killed for memory and `warden` never becomes
Ready. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-030-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config
path. `astrona submit` and `astrona test` do not apply — there is no grading.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded images, starting manifests) |
| `manifests/starfleet.yaml` | Namespace, healthy `scout` with its Service, and `shuttle` |
| `manifests/faults.yaml` | The six faulty Deployments |
| `docs/overview.md` | What the environment contains and ideas to try |
