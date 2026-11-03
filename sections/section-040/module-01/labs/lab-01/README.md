---
estimated_duration: 20m
---

# Lab: Volumes And Application State

Graded lab for the Volumes And Application State module. The cluster starts with a Deployment that keeps data in an `emptyDir` and a Deployment that waits for a claim with a StorageClass that does not exist. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED.** Built with static checks only (`astrona validate`, `bash -n`). It has not been run, and the reference solution has not been proved with `astrona test`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/module-01/labs/lab-01
astrona destroy ats-038-lab-040-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-data-bound.sh` | The claim `scout-data` is `Bound`, 1Gi, `ReadWriteOnce`, class `standard` |
| `validate-scout-mounts-claim.sh` | `scout` mounts `scout-data` at `/data`, has no `emptyDir` for it and is available |
| `validate-scout-data-persists.sh` | A file written to `/data` survives deleting the pod (the check deletes one `scout` pod) |
| `validate-probe-data-bound.sh` | The claim `probe-data` uses `standard` and is `Bound` |
| `validate-probe-running.sh` | `probe` is available and still mounts `probe-data` |

No check passes before the fix. The kind default class is assumed to be `standard` and to bind when a Pod uses the claim.
