---
estimated_duration: 20m
---

# Lab: Pod Networking

Graded lab for the Pod networking module. **Status: UNTESTED.** The lab was built from documentation and has not been run yet. The cluster starts with the Starfleet workloads. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-01/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-038-lab-010-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-address-recorded.sh` | The ConfigMap value equals the current `probe` Pod IP |
| `validate-probe-pods-headless.sh` | `probe-pods` has `clusterIP: None`, selects `app=probe`, and `shuttle` gets 200 from port 8080 |
| `validate-outpost-scout-alias.sh` | `scout` in `outpost` is an ExternalName Service to the FQDN, and `drifter` gets 200 |
| `validate-probe-service-unchanged.sh` | Guard: the original `probe` Service still answers. It passes before any change and catches a learner who breaks it |
