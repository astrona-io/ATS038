# Summary

An access mode states how nodes may mount a volume. `ReadWriteOnce` allows one node to mount it read-write, and every Pod on that node can use it. `ReadOnlyMany` and `ReadWriteMany` allow many nodes, and they need a shared storage backend such as a network file system. `ReadWriteOncePod` allows one Pod in the whole cluster, the scheduler enforces it, and only CSI volumes support it. A claim binds only to a volume that offers every mode it lists. The volume mode decides the presentation: `Filesystem` gives a directory at the `mountPath`, and `Block` gives a raw device at the `devicePath` of `volumeDevices`.

The reclaim policy of a PersistentVolume decides what happens when its claim is deleted. Under `Delete`, the PV and the storage are removed, and the data is gone. Under `Retain`, the PV stays in the phase `Released` with its data, and it does not bind to a new claim until an administrator removes the stale `claimRef`. A StorageClass sets the policy for the volumes that it creates, with `Delete` as the default, and the policy of an existing PV can be patched before the claim is deleted. The PV controller carries out the policy.

A claim can grow when its StorageClass sets `allowVolumeExpansion: true`. The backend grows the volume and the kubelet grows the file system, and a claim can never shrink. Volume snapshots are point-in-time copies made through a CSI driver and modeled by `VolumeSnapshotClass`, `VolumeSnapshot` and `VolumeSnapshotContent`.

Persistence, replication and backup are three separate properties. Persistence keeps data after a Pod is gone. Replication keeps a second live copy against hardware failure. A backup keeps an older, separate copy for recovery from mistakes and total loss. A replicated volume is not a backup, because it copies deletions and bad writes too.

Key facts:

- `ReadWriteOnce` limits nodes. `ReadWriteOncePod` limits Pods.
- `Retain` keeps the volume and the data. `Delete` removes both.
- The reclaim policy is read when the claim is deleted, so change it first.
- Expansion needs `allowVolumeExpansion: true`, and a claim cannot shrink.

<!-- astrona:playground:destroy -->
