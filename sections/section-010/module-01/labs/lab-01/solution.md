# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written from documentation. The lab has not been run, so the descriptions say what you should expect, not what a recorded run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-01/labs/lab-01
```

`astrona submit` right after the start should show one passing check, `probe-service-unchanged`, because the original Services already work. It stays your guard while you change the cluster.

## Step 1: Record the probe Pod address

The address is in the Pod status. Read it, then store it in the ConfigMap:

```sh
PROBE_IP=$(kubectl -n starfleet get pod -l app=probe -o jsonpath='{.items[0].status.podIP}')
kubectl -n starfleet create configmap probe-address --from-literal=podIP="$PROBE_IP"
```

`kubectl` should report that the ConfigMap was created. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-01/labs/lab-01 --keep
```

The check `probe-address-recorded` should now pass.

## Step 2: Create the headless Service

A headless Service has `clusterIP: None`, so its name resolves to the Pod address. Because there is no Service address that maps ports, the Service port must be the container port, 8080. Save this as `service-probe-pods.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe-pods
  namespace: starfleet
spec:
  clusterIP: None
  selector:
    app: probe
  ports:
    - name: http
      port: 8080
      targetPort: http
```

Apply it and test it from the `shuttle` Pod:

```sh
kubectl apply -f service-probe-pods.yaml
kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' http://probe-pods:8080/get
```

The request should print `200`. Submit again and the check `probe-pods-headless` should pass.

## Step 3: Create the ExternalName alias

A short name only searches the namespace of the client. To make `scout` resolve in `outpost`, create a Service of type ExternalName. CoreDNS answers it with a CNAME record that points at the fully qualified name. Save this as `service-scout-alias.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: scout
  namespace: outpost
spec:
  type: ExternalName
  externalName: scout.starfleet.svc.cluster.local
```

Apply it and test it from `drifter`:

```sh
kubectl apply -f service-scout-alias.yaml
kubectl -n outpost exec deploy/drifter -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' http://scout/healthz
```

The request should print `200`. Submit a last time. All four checks should pass.
