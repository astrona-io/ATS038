---
estimated_duration: 20m
---

# Lab: Workload Security

Graded lab for the workload security module. **Status: UNTESTED** (built with static checks only). The cluster starts with an unhardened `scout`, a `shuttle` that reads a Secret through an environment variable, and a privileged `debug-tool` in `outpost`. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-02/labs/lab-01
astrona destroy ats-038-lab-020-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-hardened.sh` | The `scout` pod template has a non-root numeric user, `allowPrivilegeEscalation: false`, a read-only root filesystem and `drop: [ALL]` |
| `validate-scout-still-serves.sh` | Guard: `shuttle` gets HTTP 200 from `scout`. It passes before any change and fails if hardening breaks the application |
| `validate-shuttle-secret-as-volume.sh` | No Secret environment variable, a read-only `api-key` volume, the file holds the Secret value, `API_KEY` is unset in the pod |
| `validate-outpost-enforces-baseline.sh` | The label is `baseline`; server-side dry runs reject a privileged pod and accept a plain pod |
| `validate-debug-tool-unprivileged.sh` | `debug-tool` is available, runs, and no container is privileged |
