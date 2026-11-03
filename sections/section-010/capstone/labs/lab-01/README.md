---
estimated_duration: 30m
---

# Capstone: Networking

Graded integration lab for the whole section. **Status: UNTESTED.** It was built from documentation and has not been run yet. A namespace `orbit` starts with a Service whose selector matches nothing, and no NetworkPolicy. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/capstone/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/capstone/labs/lab-01
astrona destroy ats-038-capstone-010
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-beacon-service-fixed.sh` | `beacon` has a ready endpoint and `relay` gets 200 through the Service name |
| `validate-beacon-pods-headless.sh` | `beacon-pods` has `clusterIP: None`, selects `app=beacon` and has ready endpoints |
| `validate-beacon-external-nodeport.sh` | `beacon-external` is NodePort 30090 and answers on its cluster address |
| `validate-beacon-allows-relay.sh` | `relay` still reaches a `beacon` Pod on 9898 by Pod address |
| `validate-beacon-blocks-drifter.sh` | `drifter` does not reach a `beacon` Pod by Pod address. This check passes only after the policy exists, because the Pod address does not depend on the broken Service |

`beacon-allows-relay` passes before any change, because no policy exists yet. It guards against a policy that blocks `relay` as well.
