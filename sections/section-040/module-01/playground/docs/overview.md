# Overview: Volumes And Application State (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with one workload and waits. There is no task, no `astrona submit` and no pass or fail. Create volumes, delete Pods, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- The default StorageClass `standard`, installed by kind. Check it with `kubectl get storageclass`.
- In `starfleet`:

  | Object | What it is |
  | --- | --- |
  | Deployment `scout` | One `busybox` container with an `emptyDir` at `/scratch`, a ConfigMap volume at `/etc/scout` and a Secret volume at `/etc/scout-secret` |
  | ConfigMap `scout-config` | Keys `mode` and `interval` |
  | Secret `scout-token` | Key `token` |

- The namespace `outpost` is empty.
- The `scout` container exits with an error when the file `/tmp/crash` exists. The file lives in the container's own filesystem layer, so the restarted container does not have it.

## Helper

Paste this once in each new terminal. It runs a command inside the `scout` container.

```sh
in_scout() {
  kubectl -n starfleet exec deploy/scout -- sh -c "$1"
}
```

Use it like this: `in_scout 'ls /etc/scout'`.

## Practice tasks

- Write one file to `/tmp`, one to `/scratch`, then create `/tmp/crash`. After the container restarts, find out which file is still there. Read the restart count with `kubectl -n starfleet get pods`.
- Delete the Pod with `kubectl -n starfleet delete pod -l app=scout` and check `/scratch` in the replacement Pod.
- Change a value in the ConfigMap with `kubectl -n starfleet edit configmap scout-config` and watch the file under `/etc/scout` change without a restart.
- Create a PersistentVolumeClaim in `outpost` that uses the `standard` StorageClass. Read its status before and after a Pod uses it.
- Write a StatefulSet with a `volumeClaimTemplates` entry, scale it to 2, delete one Pod and compare the claim names.
