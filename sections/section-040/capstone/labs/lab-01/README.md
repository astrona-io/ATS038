---
estimated_duration: 30m
---

# Capstone: Storage

Graded integration lab for the whole Storage section. The namespace `orbit` starts with a StatefulSet that keeps data in an `emptyDir` and a Deployment that waits for a claim with a StorageClass that does not exist. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED.** Built with static checks only (`astrona validate`, `bash -n`). It has not been run, and the reference solution has not been proved with `astrona test`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-038-capstone-040
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-ledger-claims-bound.sh` | The `volumeClaimTemplate` `data` exists; `data-ledger-0` and `data-ledger-1` are `Bound`, 1Gi, `ReadWriteOnce`, class `standard` |
| `validate-ledger-ready.sh` | 2 of 2 replicas ready, no `emptyDir` named `data`, mounted at `/var/ledger` |
| `validate-ledger-data-persists.sh` | A file in `/var/ledger` survives deleting `ledger-0` (the check deletes that pod once) |
| `validate-ledger-volumes-retained.sh` | The volumes behind both ledger claims have policy `Retain` |
| `validate-reporter-running.sh` | `report-cache` is `Bound` with class `standard`, and `reporter` is available |

No check passes before the fix. The default class `standard` is assumed to bind when a Pod uses the claim.
