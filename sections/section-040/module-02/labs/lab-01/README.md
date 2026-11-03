---
estimated_duration: 20m
---

# Lab: Storage Decisions

Graded lab for the Storage Decisions module. The cluster starts with a dynamically provisioned claim that uses the `Delete` policy and a Pod that waits for a claim that does not exist yet. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED.** Built with static checks only (`astrona validate`, `bash -n`). It has not been run, and the reference solution has not been proved with `astrona test`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-038-lab-040-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-archive-pv-retain.sh` | `archive-pv` is 1Gi, `ReadWriteOnce`, class `manual`, has a `hostPath` and policy `Retain` |
| `validate-archive-claim-bound.sh` | `archive-claim` is `Bound` to `archive-pv` |
| `validate-archivist-running.sh` | The `archivist` pod is `Running` and wrote `/archive/owner` |
| `validate-shuttle-volume-retained.sh` | The volume behind `shuttle-logs` has policy `Retain` |
| `validate-shuttle-logs-intact.sh` | Guard: `shuttle-logs` is `Bound` and `/logs/marker.txt` is intact. It passes before any change |

The default class `standard` is assumed to provision a volume when the `shuttle` pod starts. A hand-made `hostPath` volume with `DirectoryOrCreate` is assumed to work in the kind node.
