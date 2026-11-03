---
estimated_duration: 25m
---

# Lab: Traffic Control

Graded lab for the traffic control module. **Status: UNTESTED.** The lab was built from documentation and has not been run yet. In particular, enforcement by the default kind network plugin must be confirmed on the first run. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-03/labs/lab-01
astrona destroy ats-038-lab-010-03
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-probe-allows-shuttle.sh` | `shuttle` gets 200 from the `probe` Pod on 8080 |
| `validate-probe-blocks-drifter.sh` | `drifter` no longer gets 200 from the `probe` Pod |
| `validate-drifter-egress-restricted.sh` | `drifter` no longer reaches `relay`, which has no ingress policy, so only the egress policy can block it |
| `validate-drifter-resolves-and-reaches-scout.sh` | Guard: `drifter` resolves and reaches `scout`. It passes before any change and fails if the egress policy forgets DNS or port 9898 |
