# Identity And Access

Every request that reaches a Kubernetes cluster goes to the API server, and the API server must decide three things before it stores anything: who is calling, whether that caller may do this, and whether the object itself is acceptable. A wrong answer in either direction is a problem. If access is too strict, a deploy pipeline fails with `Forbidden`. If access is too loose, one stolen token can read every Secret in a namespace.

This module follows that decision step by step. You will see the three checks in order, learn what a ServiceAccount is and how a pod gets a token, write a `Role` and a `RoleBinding`, and then find and tighten access that is wider than it needs to be.

The module has three parts. The first part, **API Request Checks And Workload Identity**, separates authentication, authorization and admission, and explains ServiceAccounts and their tokens. The second part, **RBAC Scope And Least Privilege**, compares `Role`, `ClusterRole` and their bindings and applies least privilege. The third part, **Diagnosing And Tightening Access**, checks permissions for any identity, reads a `Forbidden` error and removes grants that are too broad.

## Learning goals

After this module you can:

- Distinguish authentication, authorization and admission, and say which HTTP status code each failure returns.
- Explain what a ServiceAccount is, how a pod receives a token and why the token expires.
- Compare `Role`, `ClusterRole`, `RoleBinding` and `ClusterRoleBinding` and predict where a binding grants access.
- Apply least privilege: grant only the verbs, resources and namespace a workload needs.
- Check permissions for another identity with `kubectl auth can-i --as` and read a `Forbidden` error.
- Stop a pod from receiving a ServiceAccount token it does not use.

## Before you start

You need basic Kubernetes knowledge: namespaces, pods, Deployments and the commands `kubectl get`, `kubectl apply` and `kubectl delete`. You do not need to have used RBAC before. Every term is defined where it first appears.

Your playground is a single-node `kind` cluster that runs Kubernetes 1.35. `kubectl` already points at it, and you act as the cluster administrator. The cluster holds the example application and a few identities:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | `scout`, `probe`, `shuttle` | The example application. Each Deployment runs under a ServiceAccount of the same name |
| `outpost` | `drifter` | A client that belongs to another team, under the ServiceAccount `drifter` |
| `starfleet` | ServiceAccount `auditor` | An identity with no permissions yet. You will give it some |
| cluster-wide | ClusterRoleBinding `drifter-view` | Gives `drifter` the built-in `view` role in every namespace. This grant is too broad on purpose |

No `Role` or `RoleBinding` exists yet in `starfleet` or `outpost`.

Launch your playground now and keep it open while you read:

<!-- astrona:playground -->
