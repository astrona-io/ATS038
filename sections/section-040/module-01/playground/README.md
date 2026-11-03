# Volumes And Application State — Playground

- **ID:** PLAYGROUND
- **Slug:** ats-038-playground-040-01
- **Author:** Paris Nakita Kejser
- **Type:** Astrona playground — clean environment, no task, no grading
- **Status:** UNTESTED. Built with static checks only (`astrona validate`); it has not been booted.

A single-node kind cluster (Kubernetes 1.35, `kindest/node:v1.35.8`) with a `scout` Deployment in `starfleet`. The `scout` container mounts an `emptyDir`, a `configMap` and a `secret` volume and exits when `/tmp/crash` exists. The default StorageClass `standard` that kind provides is used for the claims you create. Nothing to submit.

## Run it

```sh
astrona run -c .
astrona destroy ats-038-playground-040-01
```

`astrona destroy` takes the environment name (`metadata.name`), not the config path.

## Layout

| Path | Purpose |
| --- | --- |
| `config.yaml` | Environment definition (runtime, preloaded image, starting manifest) |
| `manifests/starfleet.yaml` | Namespaces, ConfigMap, Secret and the `scout` Deployment |
| `docs/overview.md` | What the environment contains and ideas to try |
