# Image Preparation And Container Startup

Once the scheduler has put a pod on a node, the kubelet takes over. It has to pull every image, create the containers and start their main processes. Most failures at this stage show a waiting reason in the container status instead of a clear error, so you need to know which reason means which problem, and which command gives the proof.

## Container states and where the reason lives

Every container in a pod has a state: `Waiting`, `Running` or `Terminated`. The `kubectl get pods` column `STATUS` shows a shortened form of that state. The full detail is in `.status.containerStatuses` of the pod. A `Waiting` state carries a `reason` such as `ErrImagePull`, `ImagePullBackOff`, `CrashLoopBackOff` or `CreateContainerConfigError`. A `Terminated` state carries a `reason`, an `exitCode` and timestamps. After a restart, the previous termination moves to `lastState`, which is why a pod can be `Running` and still show an old failure there.

The **restart policy** of a pod (`spec.restartPolicy`, which is `Always` for pods of a Deployment) tells the kubelet to start a terminated container again. The kubelet waits longer after each failure, starting at 10 seconds and doubling up to 5 minutes. This wait is the **back-off**. Names ending in `BackOff` mean the kubelet is waiting before the next attempt, not that it has given up.

## Image pull failures

The `tanker` Deployment uses the tag `6.15.999`. Show the pod and its events:

<!-- astrona:playground:renew -->

```sh
kubectl describe pod -n starfleet -l app=tanker
```

The status should be `ErrImagePull` first and `ImagePullBackOff` after the first retry. The events should show the kubelet's `Pulling` event, then a `Failed` event that contains the full image name and the registry's answer. The reason text tells the cause:

- "not found" or "manifest unknown" means the registry has no such tag, or no such image.
- "unauthorized" or "pull access denied" means the image exists but the cluster has no valid credentials. Private registries need an **image pull secret** (`imagePullSecrets` in the pod, or in its service account).
- "no such host" or a timeout means the node cannot reach the registry: a DNS or network problem on the node, not a problem in the Deployment.

`ErrImagePull` is the failed attempt. `ImagePullBackOff` is the waiting period between attempts. Both mean the same thing for diagnosis. The image pull policy also matters: `imagePullPolicy: IfNotPresent` skips the pull when the node already has the image, and `Always` asks the registry every time. A tag such as `latest` defaults to `Always`, which is why a registry outage can break a pod that restarted on a node that had the image.

Fix the tag. The command names the container (`tanker`) and the new image:

```sh
kubectl set image deployment/tanker tanker=ghcr.io/stefanprodan/podinfo:6.15.0 -n starfleet
```

## Containers that start and exit

The `rover` container pulls fine and then stops. Its status should show `CrashLoopBackOff`, and sometimes `Error` between restarts. **CrashLoopBackOff** means the container started, terminated, and the kubelet is waiting before it starts it again. It is a symptom, not a cause. The cause is in two places: the logs of the process and the exit code.

Read the logs of the last terminated container. Without `--previous`, `kubectl logs` shows the current container, which may be only seconds old or still waiting:

```sh
kubectl logs -n starfleet -l app=rover --previous
```

The log should show that the process printed an error about a missing mission file. Then read the exit code:

```sh
kubectl get pods -n starfleet -l app=rover -o jsonpath='{.items[*].status.containerStatuses[*].lastState.terminated.exitCode}'
```

Exit code `1` is a general application error. Code `0` means the process ended on its own, which is still wrong for a container that must keep running. Code `127` means "command not found", so the `command` or `args` in the pod are wrong. Code `137` means the process received `SIGKILL`. Code `143` means `SIGTERM`. In this case the `command` of the Deployment ends in `exit 1`, so no change to the image or the node can fix it. A container that never ran has no logs, which separates this case from a `CreateContainerConfigError`, where the container was never created.

## Memory limits and OOMKilled

A **memory limit** (`resources.limits.memory`) is enforced by the kernel on the node. When the container's processes use more memory than the limit, the kernel kills one of them, and the container terminates with the reason `OOMKilled` and exit code `137`. This is different from a request: the scheduler uses the request, and the kernel enforces the limit. A CPU limit never kills a container. It only slows it down.

The `miner` container needs about 20 MiB and has a limit of 16 MiB. Look at the reason of its last termination:

```sh
kubectl get pods -n starfleet -l app=miner -o jsonpath='{.items[*].status.containerStatuses[*].lastState.terminated.reason}'
```

The answer should be `OOMKilled`. The logs often show nothing wrong, because the kernel ended the process without warning, so the reason field is the proof. Raise the limit:

```sh
kubectl set resources deployment miner -n starfleet --limits=memory=128Mi
```

## Reading the whole container status

The `jsonpath` commands above read one field each. When you do not yet know which field matters, print the whole object and read the `containerStatuses` block:

```sh
kubectl get pods -n starfleet -l app=miner -o yaml
```

In that block, `state` is what the container is doing now, `lastState` is how the previous container ended, `restartCount` is how many times the kubelet restarted it, and `imageID` is the exact image digest the node used. A container whose image was never pulled has an empty `imageID`, which is another proof that the failure happened before the start.

## Putting the evidence together

For a pod with a node and a container that is not running, the order is the same each time. Read the `STATUS` and the container `state`. If it is `Waiting` with an image reason, read the pull event. If it is `CrashLoopBackOff`, read `logs --previous` and the exit code. If the reason is `OOMKilled`, compare the usage the application needs with the limit. If the container was never created, read the pod event for a missing ConfigMap, Secret or volume. Each branch ends in one change to one field.

After the three fixes, `kubectl get pods -n starfleet` should show `tanker`, `rover` and `miner` as `Running`. Watch the `RESTARTS` column for a minute: a count that keeps growing means the fix did not address the cause.

## What you know now

You can read container states, tell a pull failure from a crash and from a memory kill, and prove each with an event, a log or an exit code. The open question is the pod that runs and still does not receive traffic or keeps being restarted, which depends on the probes.

## Common pitfalls

> [!WARNING]
> `CrashLoopBackOff` is not a cause. Always read `kubectl logs --previous` and the last exit code. Do not raise a memory limit before you have seen `OOMKilled`, because exit code `1` is an application error and a larger limit does not change it. A request is not a limit: the scheduler reads the request and the kernel enforces the limit.
