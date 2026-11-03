# Diagnosing And Tightening Access

Permissions drift. Someone adds a broad grant to unblock a deploy, and it stays for years. When a request fails, someone else guesses at a fix. Both problems have the same cure: ask the API server what it would answer, read what it reports, and change the smallest thing that matters. This part shows the commands that give those answers and uses them to narrow a grant that is too wide.

## Asking the API server what is allowed

The command `kubectl auth can-i` sends a question to the authorizer and prints `yes` or `no`. The question has the form verb, resource and namespace. By default it asks about your own identity. The `--as` flag asks on behalf of another user, and for a ServiceAccount you use its full user name.

Ask whether `drifter` may list pods in the namespace `starfleet`:

<!-- astrona:playground:renew -->

```sh
kubectl auth can-i list pods -n starfleet --as=system:serviceaccount:outpost:drifter
```

The answer is `yes`, because of the cluster-wide binding from the previous example. The `--list` flag asks for everything instead of one verb:

```sh
kubectl auth can-i --list -n outpost --as=system:serviceaccount:outpost:drifter
```

The output is a table of resources, the verbs allowed on each and any `resourceNames`. It contains the rules from every role bound to the account, plus the basic rules that every authenticated identity gets, such as the right to ask the API server about its own permissions. Use `--list` to review one identity and a plain `can-i` to test one specific action.

The administrator running these commands needs permission to impersonate other identities. In the playground you are the cluster administrator, so the commands work. Another user would need the `impersonate` verb, which is itself a powerful right.

## Reading a Forbidden error

When a real request is refused, the message states the missing rule. A typical message has the form: `User "system:serviceaccount:starfleet:auditor" cannot delete resource "pods" in API group "" in the namespace "starfleet"`. It has five parts: the user, the verb, the resource, the API group and the namespace.

Those five parts are the rule you would have to add. In the example, the rule needs the verb `delete`, the resource `pods` and the API group `""`, in a `Role` in `starfleet`. Before you add it, ask whether the workload really needs to delete pods. The error tells you what is missing. It does not tell you whether to grant it.

Subresources need their own entries. The permission to read pod logs is `pods/log`, the permission to run `kubectl exec` is `pods/exec`, and scaling a Deployment is `deployments/scale`. A role that allows `get` on `pods` does not allow `get` on `pods/log`.

## Finding grants that are too wide

Wide grants hide in bindings. Two searches find the most common ones. First, look at who holds `cluster-admin`, which allows everything everywhere:

```sh
kubectl get clusterrolebindings -o wide
```

The `ROLE` column shows the role each binding grants and the `USERS`, `GROUPS` and `SERVICEACCOUNTS` columns show the subjects. Several `cluster-admin` bindings are system bindings created by Kubernetes, and these are not yours to change. A binding that gives `cluster-admin` or `edit` to an application ServiceAccount is a finding. Second, list the bindings in one namespace to see who has what there:

```sh
kubectl get rolebindings -n starfleet -o wide
```

A ServiceAccount that appears only in a `ClusterRoleBinding` has rights in every namespace. In the playground, `drifter-view` is such a binding. The team of `drifter` only needs to read pods in `outpost`. Replace the wide binding with a narrow one in two steps: create the narrow binding first so the client never loses access, then delete the wide one. Save this as `rolebinding-drifter-view.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: drifter-view
  namespace: outpost
subjects:
  - kind: ServiceAccount
    name: drifter
    namespace: outpost
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

Apply it and remove the wide binding:

```sh
kubectl apply -f rolebinding-drifter-view.yaml
kubectl delete clusterrolebinding drifter-view
```

The `RoleBinding` gives the rules of `view` in `outpost` only, and deleting the `ClusterRoleBinding` removes the rights everywhere else. Run the earlier `can-i list pods -n starfleet` command again. The answer is now `no`, while the same question for the namespace `outpost` still returns `yes`.

## Removing credentials that are not needed

Narrowing permissions is one part of tightening. The other part is removing credentials that a workload never uses. The `shuttle` Deployment only calls other Services, so its token is not needed. Setting `automountServiceAccountToken: false` in its pod template removes the token from new pods. A Deployment change starts a new rollout, and only the new pods lose the mount. Pods that already run keep the token until they are replaced.

When a task asks you to "stop a pod from using the API", there are two correct places: the ServiceAccount, which affects every pod that uses it, and the pod template, which affects one workload. Choose the narrower one when several workloads share an account.

## What you know now

You can ask the API server what any identity may do with `can-i --as` and `--list`, read a `Forbidden` error as a missing verb, resource, API group and namespace, search the bindings for grants that are too wide and replace a cluster-wide binding with a namespaced one. You also know that removing an unused token is part of tightening access. What a pod may do on its node, once it is running, is a different question, and RBAC does not answer it.

## Common pitfalls

> [!WARNING]
> `can-i` answers for the authorizer only. A request that passes RBAC can still be rejected by admission. Deleting a binding does not stop pods that already hold a token, because the token stays valid until it expires or the pod is deleted, although the API server rejects the requests it makes. Never delete system bindings whose names start with `system:`.
