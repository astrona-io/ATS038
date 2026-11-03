# Storage Decisions

A claim that binds is only the beginning. Four choices decide how the data behaves afterwards. The access mode decides which nodes and Pods may use the volume at the same time. The volume mode decides whether the Pod sees a directory or a raw device. The reclaim policy decides whether the data survives when the claim is deleted. Expansion, snapshots and backups decide what you can do when the data grows or is damaged.

This module teaches each choice with a case you can run. You will mount one claim in two Pods and read what `ReadWriteOnce` allows. You will switch a volume's reclaim policy and delete its claim to see the volume enter the `Released` phase. You will then ask for a larger volume and read how the StorageClass answers. Along the way, you separate three properties that people often mix up: persistence, replication and backup.

The module has three parts. **Access Modes And Data Presentation** compares `ReadWriteOnce`, `ReadOnlyMany`, `ReadWriteMany` and `ReadWriteOncePod`, and filesystem and block volume modes. **Reclaim Policies And Recovery** explains `Retain` and `Delete`, the `Released` phase and how to reuse a retained volume. **Expansion, Snapshots And Data Protection** covers resizing a claim, volume snapshots and the difference between persistence, replication and backup.

## Learning objectives

After this module you can:

- Distinguish `ReadWriteOnce` from `ReadWriteOncePod` and say what each limits.
- Choose between a filesystem and a block volume mode for a workload.
- Predict what happens to a PersistentVolume and its data under `Retain` and `Delete` when the claim is deleted.
- Change the reclaim policy of an existing volume and recover data from a `Released` volume.
- Explain when a claim can be expanded and which components do the work.
- Explain why a replicated volume is not a backup.

## Before you start

You need to know how a PersistentVolumeClaim binds to a PersistentVolume, what a StorageClass is and how a Pod mounts a claim.

Your playground is a single-node `kind` cluster running Kubernetes 1.35, with the default StorageClass `standard`. It has these objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | PersistentVolumeClaim `shuttle-logs` | A 1Gi claim with the class `standard` and the access mode `ReadWriteOnce` |
| `starfleet` | Deployment `shuttle` | One `busybox` container that mounts `shuttle-logs` at `/logs` and writes `/logs/marker.txt` |
| `outpost` | (empty) | A second namespace for your own experiments |

You run every command as the cluster administrator and `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
