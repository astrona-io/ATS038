# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab is untested: the descriptions below say what to expect, not what a real run printed.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes. `ci-deployer-updates-deployments` passes because the `edit` role allows everything it asks. It is your guard while you replace the grant.

## Step 1: Replace the cluster-wide grant

Create the Role and the RoleBinding first, so the pipeline never loses access:

```sh
kubectl -n orbit create role deployment-updater --verb=get,list,watch,update,patch --resource=deployments.apps
kubectl -n orbit create rolebinding ci-deployer-deployment-updater --role=deployment-updater --serviceaccount=orbit:ci-deployer
```

Then delete the wide binding:

```sh
kubectl delete clusterrolebinding ci-deployer-edit
```

Check one allowed and one forbidden verb: `kubectl auth can-i patch deployments.apps -n orbit --as=system:serviceaccount:orbit:ci-deployer` should answer `yes`, and the same command with `delete` should answer `no`. Submit. The checks `ci-deployer-least-privilege` and `ci-deployer-no-cluster-binding` should now pass, and the guard still passes.

## Step 2: Harden beacon and move the Secret to a volume

One JSON patch changes the container, the pod and the volumes together, which causes only one rollout:

```sh
kubectl -n orbit patch deployment beacon --type json -p '[{"op":"remove","path":"/spec/template/spec/containers/0/env"},{"op":"replace","path":"/spec/template/spec/containers/0/securityContext","value":{"privileged":false,"allowPrivilegeEscalation":false,"readOnlyRootFilesystem":true,"capabilities":{"drop":["ALL"]}}},{"op":"add","path":"/spec/template/spec/containers/0/volumeMounts","value":[{"name":"beacon-key","mountPath":"/etc/beacon-key","readOnly":true}]},{"op":"add","path":"/spec/template/spec/volumes","value":[{"name":"beacon-key","secret":{"secretName":"beacon-key"}}]},{"op":"add","path":"/spec/template/spec/automountServiceAccountToken","value":false},{"op":"add","path":"/spec/template/spec/securityContext","value":{"runAsNonRoot":true,"runAsUser":10001,"runAsGroup":10001}}]'
kubectl -n orbit rollout status deployment/beacon
```

If the new pod does not start, read its events with `kubectl -n orbit describe pod -l app=beacon`. Submit. The checks `beacon-hardened` and `beacon-secret-as-volume` should pass.

## Step 3: Enforce baseline

Label the namespace. The fixed pod already satisfies the level, so `beacon` keeps running:

```sh
kubectl label namespace orbit pod-security.kubernetes.io/enforce=baseline
```

Submit a last time. All six checks should pass.

## Why the order matters

The label would not stop the privileged pod that already runs, but the pod could never restart. Hardening first and labeling after keeps the workload available during the whole change.
