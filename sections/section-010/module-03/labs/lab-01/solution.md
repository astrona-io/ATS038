# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written from documentation. The lab has not been run, so the descriptions say what you should expect, not what a recorded run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-03/labs/lab-01
```

`astrona submit` right after the start should show one passing check, `drifter-resolves-and-reaches-scout`, and `probe-allows-shuttle` should pass too. The other two fail because nothing is restricted yet.

## Step 1: Isolate probe

A policy that selects the `probe` Pods for ingress isolates them. One rule then allows the `shuttle` Pods on the container port 8080. Save this as `networkpolicy-probe-from-shuttle.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: probe-from-shuttle
  namespace: starfleet
spec:
  podSelector:
    matchLabels:
      app: probe
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: shuttle
      ports:
        - protocol: TCP
          port: 8080
```

Apply it:

```sh
kubectl apply -f networkpolicy-probe-from-shuttle.yaml
```

Wait a few seconds and submit. The check `probe-blocks-drifter` should now pass, and `probe-allows-shuttle` should still pass.

## Step 2: Restrict the egress of drifter

An egress policy for `drifter` needs two destinations: the DNS Pods, so that names resolve, and the `scout` Pods on port 9898, which is the container port and not the Service port 80. Save this as `networkpolicy-drifter-egress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: drifter-egress
  namespace: outpost
spec:
  podSelector:
    matchLabels:
      app: drifter
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: starfleet
          podSelector:
            matchLabels:
              app: scout
      ports:
        - protocol: TCP
          port: 9898
```

Apply it and test both paths from `drifter`:

```sh
kubectl apply -f networkpolicy-drifter-egress.yaml
kubectl -n outpost exec deploy/drifter -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' http://scout.starfleet/healthz
kubectl -n outpost exec deploy/drifter -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' http://relay.starfleet/get
```

The first request should print `200`. The second should print `000` after about five seconds, because `drifter` has no rule for `relay`. Submit a last time. All four checks should pass.

If the first request fails at once with a resolution error, the DNS rule is missing or its labels do not match the DNS Pods. Check them with `kubectl -n kube-system get pods --show-labels`.
