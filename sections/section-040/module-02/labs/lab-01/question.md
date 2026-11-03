# Question

Solve this question on: `terminal`

The `starfleet` namespace is running. The crew keeps two kinds of data on volumes, and a cleanup of the namespace is planned. Prepare the volumes so that no data is lost. Do not delete the `shuttle` Deployment, the `shuttle-logs` claim or the `archivist` Pod.

1. The `archivist` Pod waits for a claim named `archive-claim` in `starfleet`. Create a PersistentVolume named `archive-pv` and the claim, so that the Pod starts. The volume has a capacity of `1Gi`, the access mode `ReadWriteOnce`, the StorageClass name `manual`, a `hostPath` of your choice under `/mnt` and the reclaim policy `Retain`. The claim asks for the same class, the same access mode and `1Gi`.

2. The claim `shuttle-logs` is bound to a volume that the provisioner created. When the claim is deleted in the cleanup, the logs must stay on the volume. Change that volume so that it keeps its data when the claim is deleted. Do not delete or re-create the claim.

`kubectl` already points at the cluster as the cluster administrator.
