# Enforcing Pod Security Levels

Teams will not write a safe security context in every pod, and a review cannot catch every mistake. A cluster needs a rule that runs on every pod and refuses the unsafe ones. Pod Security admission is that rule. It is built into the API server, and a namespace turns it on with labels. This part shows how the labels work, what the three modes do and how to read a rejection.

## Labels choose the level and the mode

The Pod Security admission controller reads labels on a namespace. A label name has the form `pod-security.kubernetes.io/<mode>`, and its value is a level: `privileged`, `baseline` or `restricted`. The mode says what the API server does when a pod breaks the level:

- `enforce` rejects the pod. The API server returns an error and does not create the pod.
- `warn` accepts the pod and sends a warning to the client that made the request.
- `audit` accepts the pod and adds an annotation to the audit log entry for the request.

A namespace can set all three modes with different levels. A common pattern is `enforce: baseline` together with `warn: restricted`. Pods that break baseline are rejected, and pods that only miss the restricted hardening produce a warning, so teams see what the next step is before it becomes mandatory.

The controller checks pods when they are created or changed. It also checks the pod template of workload objects such as Deployments, but only to warn, because the pods are created later by a controller. An `enforce` label never stops a pod that already runs. It applies to the next pod that the API server has to admit.

## Test a level before applying it

The `outpost` namespace has a Deployment named `debug-tool` that runs a privileged container. Setting the label would not stop that pod, but the next restart would fail. Before you set a label, ask the API server what it would say. A server-side dry run of the label change checks the existing pods and prints warnings without changing anything:

<!-- astrona:playground:renew -->

```sh
kubectl label --dry-run=server --overwrite namespace outpost pod-security.kubernetes.io/enforce=baseline
```

The output contains a warning that existing pods in the namespace violate the new `baseline` level. It names the `debug-tool` pod and the reason, a privileged container. It also ends with a line that says the namespace was labeled as a dry run, and nothing is stored. Use this command to find what a level would break before you turn it on.

## Enforce a level

Fix the workload first, then set the label. In the playground, remove the privilege from `debug-tool`. Patch its container to set `privileged` to false:

```sh
kubectl -n outpost patch deployment debug-tool --type json -p '[{"op":"replace","path":"/spec/template/spec/containers/0/securityContext/privileged","value":false}]'
```

The patch starts a rollout, and the new pod passes the check. Now enforce the level:

```sh
kubectl label namespace outpost pod-security.kubernetes.io/enforce=baseline
```

From this point the API server evaluates each new pod in `outpost` against `baseline`. The Deployments keep running because their pods already satisfy the level.

## Read a rejection

Prove that the level works by creating a pod that breaks it. Save this as `pod-privileged.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: privileged-test
  namespace: outpost
spec:
  containers:
    - name: shell
      image: busybox:1.37
      command: ["sleep", "3600"]
      securityContext:
        privileged: true
```

Apply it:

```sh
kubectl apply -f pod-privileged.yaml
```

The command fails with a `Forbidden` error from the server. The message says the pod violates `PodSecurity "baseline:latest"` and names the broken rule, a privileged container, together with the container name and the field. This is an admission rejection, not an RBAC error. The identity is allowed to create pods, but the pod spec is not acceptable. The text `baseline:latest` means the level and the Kubernetes version of the checks. A label `pod-security.kubernetes.io/enforce-version` can pin the checks to one version, for example `v1.35`.

## Warn before you enforce

In `starfleet` the workloads have no security context, so they break `restricted`. Set only the warning mode there and restart one Deployment:

```sh
kubectl label namespace starfleet pod-security.kubernetes.io/warn=restricted
kubectl -n starfleet rollout restart deployment/scout
```

The restart succeeds, and the client prints warnings that the pod template breaks several `restricted` rules: `allowPrivilegeEscalation`, `capabilities`, `runAsNonRoot` and `seccompProfile`. These four settings are the usual gap between an unhardened pod and the restricted level. The warning is the signal to add them. Nothing is rejected, because only `warn` is set.

## Exemptions and limits

An administrator can exempt some namespaces, users or runtime classes in the Pod Security admission configuration of the API server. The system namespace `kube-system` is commonly exempt, because some system components need host access. Pod Security admission checks only pod specs. It does not check what an image contains, who may call the API, or network traffic. Rules that need more detail, such as "images must come from one registry", need a policy engine or a validating admission policy.

## What you know now

You know that a namespace selects a level and a mode with labels, that `enforce` rejects, `warn` warns the client and `audit` annotates the audit log, and that existing pods are not stopped. You can test a label with a server-side dry run, fix a workload before enforcing, and read a `PodSecurity` rejection as an admission message. What admission does not cover remains the job of other controls.

## Common pitfalls

> [!WARNING]
> Labeling a namespace `enforce=restricted` while its Deployments break the level does not stop the running pods, but every later restart is rejected, and the failure shows up as `FailedCreate` events on the ReplicaSet. Run the dry run first. A namespace with no labels uses the cluster default, which is often `privileged`.
