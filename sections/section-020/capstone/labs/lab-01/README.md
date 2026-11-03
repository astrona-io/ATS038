---
estimated_duration: 30m
---

# Capstone: Security

Graded integration lab for the whole section. **Status: UNTESTED** (built with static checks only). A new team namespace `orbit` starts with a pipeline account bound to `edit` in every namespace, a privileged and unhardened `beacon` that mounts a token and reads a Secret through an environment variable, and no Pod Security label. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/capstone/labs/lab-01
astrona destroy ats-038-capstone-020
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ci-deployer-updates-deployments.sh` | Guard: `ci-deployer` can get, list, watch, update and patch Deployments in `orbit`. It passes before any change because `edit` allows it, and fails if the fix removes the rights |
| `validate-ci-deployer-least-privilege.sh` | It cannot delete Deployments, read Secrets, create pods, use a wildcard, or reach other namespaces |
| `validate-ci-deployer-no-cluster-binding.sh` | No ClusterRoleBinding names it; the service account still exists |
| `validate-beacon-hardened.sh` | `beacon` is not privileged, has a numeric non-root user, no privilege escalation, a read-only root filesystem, `drop: [ALL]` and no token |
| `validate-beacon-secret-as-volume.sh` | No Secret environment variable; a read-only `beacon-key` volume |
| `validate-orbit-baseline-and-beacon-running.sh` | The label is `baseline`, a privileged pod is rejected by a server-side dry run, `beacon` is available and its Service has an endpoint |
