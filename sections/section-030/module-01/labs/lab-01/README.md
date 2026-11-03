---
estimated_duration: 25m
---

# Lab: Diagnosing Orchestration Failures

Graded lab for the orchestration-failure module. The cluster starts with six Deployments that fail at different stages of the pod lifecycle. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED.** This lab was built with static checks only (`astrona validate`, `bash -n`, YAML parsing). It has not been started, and its reference solution has not been run with `astrona test`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/module-01/labs/lab-01
astrona destroy ats-038-lab-030-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-lander-and-hauler-scheduled.sh` | `lander` and `hauler` roll out; no node carries `disktype=quantum`; `hauler` no longer requests 64 CPUs |
| `validate-tanker-image-pulls.sh` | `tanker` rolls out and no container waits on an image error |
| `validate-rover-stays-running.sh` | `rover` rolls out and its running pod has zero restarts after 15 seconds |
| `validate-miner-not-oomkilled.sh` | `miner` rolls out and no container has `OOMKilled` as its last terminated reason |
| `validate-warden-ready.sh` | `warden` rolls out and still has a readiness probe |
| `validate-workloads-not-removed.sh` | Guard: every Deployment has at least one replica and `scout` keeps its image |

`workloads-not-removed` passes before any change, because nothing has been removed yet. It fails when a fix scales a Deployment to zero or deletes it.
