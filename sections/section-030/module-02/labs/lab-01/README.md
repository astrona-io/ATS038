---
estimated_duration: 25m
---

# Lab: Diagnosing Cluster Services

Graded lab for the cluster-services module. The cluster starts with a Service whose selector matches nothing, a Service with the wrong target port and a pod that needs a missing ConfigMap. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED.** This lab was built with static checks only (`astrona validate`, `bash -n`, YAML parsing). It has not been started, and its reference solution has not been run with `astrona test`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/module-02/labs/lab-01
astrona destroy ats-038-lab-030-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-service-has-endpoints.sh` | The EndpointSlice of the `probe` Service has an address and `shuttle` gets HTTP 200 |
| `validate-relay-service-forwards.sh` | `shuttle` gets HTTP 200 from the `relay` Service |
| `validate-lander-starts.sh` | `lander` rolls out, still reads `LANDING_MODE` from `lander-config`, and the ConfigMap has a value |
| `validate-backends-untouched.sh` | Guard: `scout` answers and the `probe` and `relay` pods keep their label and port |

`backends-untouched` passes before any change, because nothing has been edited yet. It fails when a fix changes the pods instead of the Services.
