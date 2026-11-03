# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet, so this page shows the commands and says what to look for, and it does not print command output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes. `nothing-removed` passes because every Deployment still exists. It stays your guard.

## Step 1: Sort the symptoms

Start with the status of every pod and the events of the namespace, so you pick the right tool for each failure:

```sh
kubectl get pods -n orbit -o wide
kubectl get events -n orbit --sort-by=.lastTimestamp
```

`beacon` shows `ErrImagePull` or `ImagePullBackOff`. `signal` is `Pending` with no node. `relay` has a growing `RESTARTS` count. `cargo` shows `CreateContainerConfigError`.

## Step 2: Fix beacon, the image first and then the Service

The event names the image that fails to pull. The tag `6.15.999` does not exist:

```sh
kubectl set image deployment/beacon beacon=ghcr.io/stefanprodan/podinfo:6.15.0 -n orbit
kubectl rollout status deployment/beacon -n orbit
```

The pod now runs and is Ready, but the client request still fails. A Ready pod does not prove the Service reaches it. Compare the port in the EndpointSlice with the port of the container:

```sh
kubectl get endpointslices -n orbit -l kubernetes.io/service-name=beacon -o jsonpath='{.items[*].ports[*].port}{"\n"}'
kubectl get deployment beacon -n orbit -o jsonpath='{.spec.template.spec.containers[0].ports[*].containerPort}{"\n"}'
```

The endpoint says 9999 and the container listens on 9898. Point the Service at the named port and submit:

```sh
kubectl patch service beacon -n orbit --type=json -p='[{"op":"replace","path":"/spec/ports/0/targetPort","value":"http"}]'
astrona submit --keep
```

## Step 3: Fix signal

The scheduler event of the `Pending` pod says that no node has enough CPU:

```sh
kubectl describe pod -n orbit -l app=signal
kubectl set resources deployment signal -n orbit --requests=cpu=10m
kubectl rollout status deployment/signal -n orbit
astrona submit --keep
```

## Step 4: Fix relay

The container runs, and it is restarted. The pod events name the probe that fails, and the last terminated state shows that the kubelet stopped the container:

```sh
kubectl describe pod -n orbit -l app=relay
```

The liveness probe calls `/livez-check`, and the application answers with an error. Correct the path:

```sh
kubectl patch deployment relay -n orbit --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/livenessProbe/httpGet/path","value":"/healthz"}]'
kubectl rollout status deployment/relay -n orbit
astrona submit --keep
```

## Step 5: Fix cargo

The pod status and the event name the missing Secret. The container was never created, so there are no logs:

```sh
kubectl describe pod -n orbit -l app=cargo
kubectl create secret generic cargo-token -n orbit --from-literal=token=orbit-demo-token
kubectl rollout restart deployment/cargo -n orbit
kubectl rollout status deployment/cargo -n orbit
astrona submit
```

All five checks pass. When you are done:

```sh
astrona destroy ats-038-capstone-030
```
