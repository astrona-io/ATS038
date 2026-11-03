# Overview: Identity And Access (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads and a few service accounts, and then waits. There is no task, no `astrona submit` and no pass or fail. Write roles and bindings, break them, run `astrona destroy`, and start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it, as the cluster administrator. Check other identities with `--as`.
- The example workloads, each on a service account with its own name:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `starfleet` | service account `auditor` | An identity with no permissions |
  | cluster-wide | ClusterRoleBinding `drifter-view` | Gives `drifter` the `view` role in every namespace, on purpose |

- No `Role` or `RoleBinding` exists yet in `starfleet` or `outpost`.

## Helper

Paste this once in each new terminal. `can_sa` asks whether a service account may do one verb on one resource. The first argument is `namespace/name` of the account.

```sh
can_sa() {
  kubectl auth can-i "$2" "$3" -n "${4:-starfleet}" --as="system:serviceaccount:$1"
}
```

Use it like this: `can_sa starfleet:auditor list pods` or `can_sa outpost:drifter list pods starfleet`.

## Practice tasks

- Run `kubectl auth whoami`, then `kubectl create token shuttle -n starfleet`, and note the difference between your identity and the identity the token proves.
- Give `auditor` exactly `get`, `list` and `watch` on pods in `starfleet`. Check each verb with `can_sa` before and after.
- Predict the answer of `can_sa outpost:drifter list pods starfleet`, then run it. Replace `drifter-view` with a `RoleBinding` in `outpost` and run it again.
- Run `kubectl exec -n starfleet deploy/shuttle -- ls /var/run/secrets/kubernetes.io/serviceaccount`. Set `automountServiceAccountToken: false` on the `shuttle` pod template and run the command on the new pod.
- Give `auditor` a rule on `secrets` with only the `list` verb and find out whether the Secret values can be read with a `list` request.
