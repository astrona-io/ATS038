# Overview: Workload Security (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with the example workloads, a Secret and one privileged Deployment, and then waits. There is no task, no `astrona submit` and no pass or fail. Set security contexts, label namespaces, break things, run `astrona destroy`, and start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` already points at it, as the cluster administrator.
- The example workloads and two extra objects:

  | Namespace | Object | What it is |
  | --- | --- | --- |
  | `starfleet` | `scout`, `probe`, `shuttle` | The example application, with no security context |
  | `starfleet` | Secret `api-key` | One key, `token` |
  | `outpost` | `drifter` | A client that belongs to another team |
  | `outpost` | `debug-tool` | A `busybox` container with `privileged: true`, on purpose |

- No `pod-security.kubernetes.io` label is set on `starfleet` or `outpost`.

## Helper

Paste this once in each new terminal. `show_psa_labels` prints the Pod Security labels of a namespace.

```sh
show_psa_labels() {
  kubectl get namespace "$1" -o jsonpath='{.metadata.labels}'
  echo
}
```

Use it like this: `show_psa_labels outpost`.

## Practice tasks

- Create a `busybox:1.37` pod with no security context and another with `runAsUser: 10001`, `readOnlyRootFilesystem: true` and all capabilities dropped. Compare `id` and `touch /file` in both.
- Run a server-side dry run of `pod-security.kubernetes.io/enforce=restricted` on `starfleet` and list which settings each Deployment is missing.
- Enforce `baseline` on `outpost`, then try to create a privileged pod and read the rejection.
- Mount the Secret `api-key` as a volume in a pod and compare `printenv` with `cat /etc/api-key/token` for an environment variable and a volume.
- Run `kubectl get secret api-key -n starfleet -o jsonpath='{.data.token}' | base64 -d` and note what the encoding protects.
