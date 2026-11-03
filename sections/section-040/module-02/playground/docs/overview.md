# Overview: Storage Decisions (Playground)

This is a **playground**, not a lab. It starts a fresh cluster with one claim and one workload, and then waits. There is no task, no `astrona submit` and no pass or fail. Change policies, delete claims, break things, `astrona destroy`, start over.

## What's in the box

- A single-node `kind` cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- The default StorageClass `standard`, installed by kind. Read its `reclaimPolicy`, `volumeBindingMode` and `allowVolumeExpansion` with `kubectl get storageclass standard -o yaml`.
- In `starfleet`:

  | Object | What it is |
  | --- | --- |
  | PersistentVolumeClaim `shuttle-logs` | 1Gi, `ReadWriteOnce`, class `standard`. A PersistentVolume that the provisioner created is bound to it |
  | Deployment `shuttle` | Mounts the claim at `/logs` and writes `/logs/marker.txt` |

- The namespace `outpost` is empty.

## Helper

Paste this once in each new terminal. It prints the name of the PersistentVolume that a claim in `starfleet` is bound to.

```sh
volume_of_claim() {
  kubectl -n starfleet get pvc "$1" -o jsonpath='{.spec.volumeName}'
  echo
}
```

Use it like this: `volume_of_claim shuttle-logs`.

## Practice tasks

- Start a second Pod in `starfleet` that mounts `shuttle-logs`. Predict whether it starts on a one-node cluster, then check with `kubectl get pods -o wide`.
- Create a claim with `ReadWriteOncePod` and start two Pods that use it. Read the events of the second Pod.
- Patch the reclaim policy of the volume behind `shuttle-logs` to `Retain`, delete the Deployment and the claim, and read the phase of the volume.
- Find the field in the volume that still names the deleted claim, and clear it so the volume becomes `Available` again.
- Edit the claim to request `2Gi`. Read the answer of the API server, then read `allowVolumeExpansion` of the class.
- Create a claim with `volumeMode: Block`, use it from a Pod with `volumeDevices`, and read the events to see whether the provisioner accepts it.
