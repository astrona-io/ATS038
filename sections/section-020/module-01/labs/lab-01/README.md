---
estimated_duration: 20m
---

# Lab: Identity And Access

Graded lab for the identity and access module. **Status: UNTESTED** (built with static checks only). The cluster starts with a Role that names the wrong API group, a cluster-wide `view` binding for `drifter`, and a `shuttle` pod that mounts a service account token. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-01/labs/lab-01
astrona destroy ats-038-lab-020-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-can-list-pods.sh` | `probe` can get, list and watch pods in `starfleet` |
| `validate-probe-least-privilege.sh` | Guard: `probe` cannot delete pods, read Secrets, create Deployments, use a wildcard, or read pods in `outpost` or cluster-wide. It passes before any change, because `probe` has no working rule yet, and fails if the fix is too broad |
| `validate-drifter-reads-outpost-only.sh` | `drifter` lists pods in `outpost` and nowhere else, and no ClusterRoleBinding names it |
| `validate-shuttle-token-not-mounted.sh` | No running `shuttle` pod has a `kube-api-access` volume |
| `validate-workloads-running.sh` | Guard: all Deployments are available and the service accounts exist. It passes before any change |
