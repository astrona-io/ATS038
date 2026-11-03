---
estimated_duration: 20m
---

# Lab: Services And External Access

Graded lab for the Services module. **Status: UNTESTED.** The lab was built from documentation and has not been run yet. The cluster starts with a faulty Service. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-02/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-02/labs/lab-01
astrona destroy ats-038-lab-010-02
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-public-fixed.sh` | `scout-public` selects `app=scout`, has a ready endpoint, and `shuttle` gets 200 |
| `validate-scout-nodeport.sh` | `scout-nodeport` is type NodePort with node port 30080 and answers on its cluster address |
| `validate-ingress-routes-scout.sh` | The Ingress has the host, path, path type and backend from the task |
| `validate-scout-service-unchanged.sh` | Guard: the original `scout` Service still answers. It passes before any change and catches a learner who breaks it |
