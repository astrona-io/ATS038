# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written from documentation. The lab has not been run, so the descriptions say what you should expect, not what a recorded run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/capstone/labs/lab-01
```

`astrona submit` right after the start should show one passing check, `beacon-allows-relay`, because no policy exists yet.

## Step 1: Fix the beacon Service

Compare the selector with the Pod labels and read the slice:

```sh
kubectl -n orbit get svc beacon -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n orbit get pods --show-labels
kubectl -n orbit get endpointslices -l kubernetes.io/service-name=beacon
```

The selector is `app: beacon-v2` and the Pods carry `app=beacon`, so the slice has no endpoints. The `targetPort` 8080 is also wrong, because the container listens on 9898, which the port name `http` stands for. Patch the Service and test it:

```sh
kubectl -n orbit patch service beacon --type merge -p '{"spec":{"selector":{"app":"beacon"},"ports":[{"name":"http","port":80,"targetPort":"http"}]}}'
kubectl -n orbit exec deploy/relay -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' http://beacon/healthz
```

The request should print `200`. Submit and `beacon-service-fixed` should pass.

## Step 2: Create the headless and NodePort Services

Save this as `services-beacon.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: beacon-pods
  namespace: orbit
spec:
  clusterIP: None
  selector:
    app: beacon
  ports:
    - name: http
      port: 9898
      targetPort: http
---
apiVersion: v1
kind: Service
metadata:
  name: beacon-external
  namespace: orbit
spec:
  type: NodePort
  selector:
    app: beacon
  ports:
    - name: http
      port: 80
      targetPort: http
      nodePort: 30090
```

Apply it and read the result:

```sh
kubectl apply -f services-beacon.yaml
kubectl -n orbit get svc
```

The list should show `beacon-pods` without a cluster address and `beacon-external` with `80:30090/TCP`. Submit and `beacon-pods-headless` and `beacon-external-nodeport` should pass.

## Step 3: Allow only relay

Select the `beacon` Pods for ingress and allow the `relay` Pods on the container port. Save this as `networkpolicy-beacon-from-relay.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: beacon-from-relay
  namespace: orbit
spec:
  podSelector:
    matchLabels:
      app: beacon
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: relay
      ports:
        - protocol: TCP
          port: 9898
```

Apply it:

```sh
kubectl apply -f networkpolicy-beacon-from-relay.yaml
```

Wait a few seconds and submit. All five checks should pass. The `relay` Pod keeps reaching `beacon` through the Service, because the policy allows the Pod traffic that the Service forwards. The `drifter` Pod no longer reaches the `beacon` Pods.
