# Question

Solve this question on: `terminal`

The team of the `orbit` namespace runs a StatefulSet `ledger` and a Deployment `reporter`. A review found that data can be lost and that one workload never starts. Fix the storage setup. Keep the names, the images and the commands of the workloads.

1. The StatefulSet `ledger` has 2 replicas and keeps `/var/ledger` in an `emptyDir`. Give each replica its own persistent volume instead, through a `volumeClaimTemplate` named `data` with the access mode `ReadWriteOnce`, `1Gi` and the StorageClass `standard`. Both replicas must be ready. A file written to `/var/ledger` in `ledger-0` must survive the deletion of that Pod.

2. The volumes that belong to the claims `data-ledger-0` and `data-ledger-1` must keep their data when a claim is deleted. Change them so that the data is retained.

3. The Deployment `reporter` mounts the claim `report-cache`, but its Pod never starts. Find out why, and fix the claim so that it is `Bound` with the StorageClass `standard` and the `reporter` Deployment is available. Keep the claim name `report-cache`.

`kubectl` already points at the cluster as the cluster administrator.
