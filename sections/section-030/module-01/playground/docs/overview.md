# Overview: Diagnosing Orchestration Failures (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with one healthy application and six Deployments that fail on purpose, and then waits. There is no task, no `astrona submit` and no pass or fail. Diagnose, fix, break things again, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` is already pointed at it, as the cluster administrator.
- Everything runs in the `starfleet` namespace:

  | Deployment | What is wrong | Stage where it stops |
  | --- | --- | --- |
  | `scout`, `shuttle` | Nothing. They are healthy | Running and Ready |
  | `lander` | `nodeSelector` that no node matches | Scheduling |
  | `hauler` | CPU request larger than the node | Scheduling |
  | `tanker` | Image tag that does not exist | Image pull |
  | `rover` | The main process exits with code 1 | Container start |
  | `miner` | The process needs more memory than the limit | Container run |
  | `warden` | The readiness probe path returns an error | Readiness |

## Helpers

Paste these once in each new terminal. `why_pod` prints the phase and the container waiting reason of every pod with a label, and the last events of the namespace.

```sh
why_pod() {
  kubectl -n starfleet get pods -l "app=$1" -o wide
  kubectl -n starfleet get pods -l "app=$1" -o jsonpath='{range .items[*]}{.metadata.name}{" phase="}{.status.phase}{" waiting="}{.status.containerStatuses[*].state.waiting.reason}{" lastTerminated="}{.status.containerStatuses[*].lastState.terminated.reason}{"\n"}{end}'
  kubectl -n starfleet get events --sort-by=.lastTimestamp | tail -n 8
}
```

Use it like this: `why_pod lander`, `why_pod tanker`.

## Practice tasks

- List the pods and sort them into three groups: not scheduled, scheduled but not running, running but not Ready. Use only `kubectl get pods -o wide` and `kubectl describe pod`.
- For `lander`, read the scheduler event and name the node label it wants. Fix it by changing the Deployment, not the node.
- For `hauler`, find the node's allocatable CPU with `kubectl describe node` and compare it to the request.
- For `tanker`, read the event that names the image and the registry error, then correct the tag with `kubectl set image`.
- For `rover`, read the logs of the current container and of the previous one. Decide which of the two shows the failure.
- For `miner`, find the exit code and the reason of the last terminated state. Raise the memory limit and watch the restart count stop growing.
- For `warden`, show that the container runs but is not Ready, then change the probe path to `/readyz`.
- Run `kubectl rollout history deployment/tanker -n starfleet` before and after your fix and explain what a new revision is.
