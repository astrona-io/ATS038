# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet, so this page shows the commands and says what to look for, and it does not print command output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes. `workloads-not-removed` passes because every Deployment still exists. It stays your guard while you fix the others.

## Step 1: Sort the pods by lifecycle stage

List the pods with their nodes and states:

```sh
kubectl get pods -n starfleet -o wide
```

`lander` and `hauler` have a `Pending` pod with no node. `tanker` shows `ErrImagePull` or `ImagePullBackOff`. `rover` shows `CrashLoopBackOff` or `Error`. `miner` shows `OOMKilled` or `CrashLoopBackOff`. `warden` shows `Running` with `0/1` in the `READY` column.

## Step 2: Fix lander and hauler

Read the scheduler events of both pods:

```sh
kubectl describe pod -n starfleet -l app=lander
kubectl describe pod -n starfleet -l app=hauler
```

In the `Events` section of `lander`, the `default-scheduler` reports `FailedScheduling` and says the node did not match the pod's node selector. In the events of `hauler`, it says `Insufficient cpu`. Remove the `nodeSelector` from `lander` and lower the CPU request of `hauler`:

```sh
kubectl patch deployment lander -n starfleet --type=json -p='[{"op":"remove","path":"/spec/template/spec/nodeSelector"}]'
kubectl set resources deployment hauler -n starfleet --requests=cpu=10m
```

Both Deployments create a new pod. Wait for them, then submit:

```sh
kubectl rollout status deployment/lander -n starfleet
kubectl rollout status deployment/hauler -n starfleet
astrona submit --keep
```

`lander-and-hauler-scheduled` now passes.

## Step 3: Fix tanker

The events of the `tanker` pod name the image and the pull error:

```sh
kubectl describe pod -n starfleet -l app=tanker
```

The tag `6.15.999` does not exist in the registry. Set the correct tag. The first argument after the Deployment name is the container name:

```sh
kubectl set image deployment/tanker tanker=ghcr.io/stefanprodan/podinfo:6.15.0 -n starfleet
kubectl rollout status deployment/tanker -n starfleet
astrona submit --keep
```

## Step 4: Fix rover

The container prints an error and exits. Read its logs, and the logs of the previous container if the current one has just restarted:

```sh
kubectl logs -n starfleet -l app=rover --previous
kubectl get pods -n starfleet -l app=rover -o jsonpath='{.items[*].status.containerStatuses[*].lastState.terminated.exitCode}'
```

The message says the mission file is missing, and the exit code is `1`. The command in the Deployment ends with `exit 1`, so no image or node change can help. Replace the command with a process that keeps running:

```sh
kubectl patch deployment rover -n starfleet --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/command","value":["sh","-c","echo rover: running; while true; do sleep 30; done"]}]'
kubectl rollout status deployment/rover -n starfleet
astrona submit --keep
```

## Step 5: Fix miner

The last terminated state of the container gives the reason:

```sh
kubectl get pods -n starfleet -l app=miner -o jsonpath='{.items[*].status.containerStatuses[*].lastState.terminated.reason}'
```

The reason is `OOMKilled`: the process needs about 20 MiB and more while it builds its data, and the limit is 16 MiB. Raise the limit:

```sh
kubectl set resources deployment miner -n starfleet --limits=memory=128Mi
kubectl rollout status deployment/miner -n starfleet
astrona submit --keep
```

## Step 6: Fix warden

The pod runs, so the image and the process are fine. The `READY` column is `0/1` because the readiness probe fails. The events show the probe's HTTP status:

```sh
kubectl describe pod -n starfleet -l app=warden
```

The probe calls `/ready-check`, and the application does not serve that path. Change the probe path to `/readyz`:

```sh
kubectl patch deployment warden -n starfleet --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/path","value":"/readyz"}]'
kubectl rollout status deployment/warden -n starfleet
astrona submit
```

All six checks pass. When you are done:

```sh
astrona destroy ats-038-lab-030-01
```
