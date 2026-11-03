---
estimated_duration: 30m
---

# Capstone: Troubleshooting

Graded integration lab for the whole section. A new team namespace `orbit` starts with a healthy client and four applications that fail at different stages: one with two faults in a row (image and Service), one that cannot be scheduled, one killed by its liveness probe and one that waits on a missing Secret. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED.** This lab was built with static checks only (`astrona validate`, `bash -n`, YAML parsing). It has not been started, and its reference solution has not been run with `astrona test`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/capstone/labs/lab-01
astrona destroy ats-038-capstone-030
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-reachable.sh` | `beacon` rolls out and `shuttle` gets HTTP 200 from the `beacon` Service |
| `validate-signal-scheduled.sh` | `signal` rolls out and still has a CPU request |
| `validate-relay-stays-running.sh` | `relay` rolls out, keeps its liveness probe, and its running pod has zero restarts after 15 seconds |
| `validate-cargo-starts.sh` | `cargo` rolls out, still reads `CARGO_TOKEN` from `cargo-token`, and the Secret has the key `token` |
| `validate-nothing-removed.sh` | Guard: all five Deployments keep at least one replica and no node has a `disktype` label |

`nothing-removed` passes before any change, because `shuttle` is healthy and nothing has been removed. It fails when a fix scales a Deployment to zero.
