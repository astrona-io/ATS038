# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested: the descriptions below say what to expect, not what a real run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-02/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes. `scout-still-serves` passes because nothing is changed yet. It is your guard while you harden `scout`.

## Step 1: Harden scout

Patch the pod template with the pod-level user and the container-level fields:

```sh
kubectl -n starfleet patch deployment scout --type merge -p '{"spec":{"template":{"spec":{"securityContext":{"runAsNonRoot":true,"runAsUser":10001,"runAsGroup":10001},"containers":[{"name":"scout","securityContext":{"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}}]}}}}'
```

The merge patch matches the container by its `name` and keeps the other fields. Wait for the rollout:

```sh
kubectl -n starfleet rollout status deployment/scout
```

If the new pod does not become ready, read the events with `kubectl -n starfleet describe pod -l app=scout`. Then submit. The checks `scout-hardened` and `scout-still-serves` should pass.

## Step 2: Move the Secret from a variable to a volume

Replace the variable with a read-only volume in one patch:

```sh
kubectl -n starfleet patch deployment shuttle --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/0/env"},{"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"api-key","mountPath":"/etc/api-key","readOnly":true}]},{"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"api-key","secret":{"secretName":"api-key"}}]}]'
```

Wait for the rollout, then read the file in the new pod:

```sh
kubectl -n starfleet rollout status deployment/shuttle
kubectl -n starfleet exec deploy/shuttle -- cat /etc/api-key/token
```

The command prints the Secret value. The variable `API_KEY` no longer exists in the new pod. Submit. The check `shuttle-secret-as-volume` should pass.

## Step 3: Remove the privilege and enforce baseline

Remove the privilege first, so the next pod of `debug-tool` passes the level:

```sh
kubectl -n outpost patch deployment debug-tool --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/securityContext/privileged","value":false}]'
kubectl -n outpost rollout status deployment/debug-tool
```

Then label the namespace:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline
```

The label alone would not stop the privileged pod that already runs, but that pod could never be restarted. Removing the privilege first keeps `debug-tool` running through the change. Submit a last time. All five checks should pass.

## Why the guard matters

If a hardening change breaks `scout`, for example by a user ID the image cannot run as, `scout-hardened` passes but `scout-still-serves` fails. This shows that a setting is only correct when the application still works.
