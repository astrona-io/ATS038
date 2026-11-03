# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This walkthrough was written from documentation. The lab has not been run, so the descriptions say what you should expect, not what a recorded run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-010/module-02/labs/lab-01
```

`astrona submit` right after the start should show one passing check, `scout-service-unchanged`. It stays your guard while you change the cluster.

## Step 1: Fix scout-public

Compare the Service selector with the Pod labels:

```sh
kubectl -n starfleet get svc scout-public -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n starfleet get pods --show-labels
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=scout-public
```

The selector says `app: scout-v2`, but the Pods carry `app=scout`, so the slice has no endpoints. The `targetPort` is also wrong: the `scout` container listens on 9898, which the named port `http` stands for. Patch both fields:

```sh
kubectl -n starfleet patch service scout-public --type merge -p '{"spec":{"selector":{"app":"scout"},"ports":[{"name":"http","port":80,"targetPort":"http"}]}}'
kubectl -n starfleet exec deploy/shuttle -- curl -s --max-time 5 -o /dev/null -w '%{http_code}\n' http://scout-public/healthz
```

The request should print `200`. Submit and the check `scout-public-fixed` should pass.

## Step 2: Create the NodePort Service

Save this as `service-scout-nodeport.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: scout-nodeport
  namespace: starfleet
spec:
  type: NodePort
  selector:
    app: scout
  ports:
    - name: http
      port: 80
      targetPort: http
      nodePort: 30080
```

Apply it:

```sh
kubectl apply -f service-scout-nodeport.yaml
kubectl -n starfleet get svc scout-nodeport
```

The list should show `80:30080/TCP`. Submit and the check `scout-nodeport` should pass.

## Step 3: Create the Ingress

Save this as `ingress-starfleet-web.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: starfleet-web
  namespace: starfleet
spec:
  ingressClassName: nginx
  rules:
    - host: scout.starfleet.test
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: scout-public
                port:
                  number: 80
```

Apply it:

```sh
kubectl apply -f ingress-starfleet-web.yaml
kubectl -n starfleet describe ingress starfleet-web
```

The description should list the rule and the backend. The address stays empty because no controller runs. Submit a last time. All four checks should pass.
