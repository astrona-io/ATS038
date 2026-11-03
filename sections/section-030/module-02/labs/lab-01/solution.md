# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab has not been run yet, so this page shows the commands and says what to look for, and it does not print command output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-030/module-02/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes. `backends-untouched` passes because nothing has been edited. It stays your guard while you fix the others.

## Step 1: Fix the probe Service

Send the request first, so you see the symptom:

```sh
kubectl exec deploy/shuttle -n starfleet -- curl -s -o /dev/null -m 5 -w '%{http_code}\n' http://probe/get
```

The name resolves, because the Service exists, but the request does not get an answer. Compare the Service selector with the pod labels, and list the endpoints of the Service:

```sh
kubectl get service probe -n starfleet -o jsonpath='{.spec.selector}{"\n"}'
kubectl get pods -n starfleet --show-labels
kubectl get endpointslices -n starfleet -l kubernetes.io/service-name=probe
```

The selector is `app=probes`, the pod has `app=probe`, and the EndpointSlice has no endpoints. Change the Service, not the pod:

```sh
kubectl patch service probe -n starfleet --type=merge -p '{"spec":{"selector":{"app":"probe"}}}'
```

A merge patch on `selector` keeps the old key `app` and replaces its value. Submit:

```sh
astrona submit --keep
```

## Step 2: Fix the relay Service

The Service `relay` has an endpoint, so the selector is right. Show the port in the endpoint and the port the container listens on:

```sh
kubectl get endpointslices -n starfleet -l kubernetes.io/service-name=relay -o jsonpath='{.items[*].ports[*].port}{"\n"}'
kubectl get deployment relay -n starfleet -o jsonpath='{.spec.template.spec.containers[0].ports[*].containerPort}{"\n"}'
```

The endpoint says 8081 and the container listens on 8080. `curl` from `shuttle` ends with "connection refused". Point the Service at the named container port:

```sh
kubectl patch service relay -n starfleet --type=json -p='[{"op":"replace","path":"/spec/ports/0/targetPort","value":"http"}]'
astrona submit --keep
```

## Step 3: Create the ConfigMap for lander

The pod status and the pod events name the problem:

```sh
kubectl get pods -n starfleet -l app=lander
kubectl describe pod -n starfleet -l app=lander
```

The status is `CreateContainerConfigError`, and the event says the ConfigMap `lander-config` is not found. The container was never created, so there are no logs. Create the ConfigMap with the key from the Deployment:

```sh
kubectl create configmap lander-config -n starfleet --from-literal=LANDING_MODE=automatic
```

The kubelet retries on its own with a back-off. To skip the wait, restart the rollout, then submit:

```sh
kubectl rollout restart deployment/lander -n starfleet
kubectl rollout status deployment/lander -n starfleet
astrona submit
```

All four checks pass. When you are done:

```sh
astrona destroy ats-038-lab-030-02
```
