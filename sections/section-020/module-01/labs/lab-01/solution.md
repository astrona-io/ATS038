# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested: the descriptions below say what to expect, not what a real run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-01/labs/lab-01
```

`astrona submit` right after the start shows two checks that already pass. `probe-least-privilege` passes because `probe` has no working rule yet, and `workloads-running` passes because nothing is broken. They stay your guards while you fix the faults.

## Step 1: Fix the Role for probe

Check what `probe` can do now:

```sh
kubectl auth can-i list pods -n starfleet --as=system:serviceaccount:starfleet:probe
```

The answer is `no`. Look at the rule in the Role:

```sh
kubectl get role pod-lister -n starfleet -o yaml
```

The rule names `apiGroups: ["apps"]`. Pods belong to the core API group, which is written as an empty string. Edit the Role and change the group:

```sh
kubectl edit role pod-lister -n starfleet
```

Set `apiGroups: [""]` and save. Run the `can-i` command again. The answer is now `yes`. Submit:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-01/labs/lab-01 --keep
```

The check `probe-can-list-pods` should now pass.

## Step 2: Narrow the drifter binding

Create the namespaced binding first, so `drifter` never loses access to `outpost`:

```sh
kubectl create rolebinding drifter-view -n outpost --clusterrole=view --serviceaccount=outpost:drifter
```

Then remove the cluster-wide binding:

```sh
kubectl delete clusterrolebinding drifter-view
```

A `RoleBinding` that points at a `ClusterRole` grants the rules in its own namespace only. Check both directions: `kubectl auth can-i list pods -n outpost --as=system:serviceaccount:outpost:drifter` should answer `yes`, and the same command with `-n starfleet` should answer `no`. Submit again. The check `drifter-reads-outpost-only` should pass.

## Step 3: Remove the token from shuttle

Set the field in the pod template of the Deployment:

```sh
kubectl -n starfleet patch deployment shuttle --type merge -p '{"spec":{"template":{"spec":{"automountServiceAccountToken":false}}}}'
```

The change starts a rollout. Wait for it to finish:

```sh
kubectl -n starfleet rollout status deployment/shuttle
```

The new pod has no `kube-api-access` volume. Submit a last time. All five checks should pass.

## Why the guards matter

A fix such as binding `cluster-admin` to `probe` would make `probe-can-list-pods` pass, but `probe-least-privilege` would then fail. Deleting the `shuttle` Deployment would remove the token, but `workloads-running` would fail.
