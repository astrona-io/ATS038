# Question

Solve this question on: `terminal`

The `starfleet` namespace is running. The `scout` Deployment keeps its report files in an `emptyDir`, and the `probe` Deployment never starts. Fix both with storage objects. Do not change the container images or commands.

1. Create a PersistentVolumeClaim named `scout-data` in `starfleet` with the access mode `ReadWriteOnce`, a request of `1Gi` and the StorageClass `standard`. Change the Deployment `scout` so that the volume `data` (mounted at `/data`) uses this claim instead of an `emptyDir`. A file written to `/data` must survive the deletion of the `scout` Pod.

2. The Deployment `probe` mounts the claim `probe-data`, but its Pod stays `Pending`. Find out why, and fix the claim so that it is `Bound` with the StorageClass `standard` and the `probe` Pod runs. Keep the claim name `probe-data` and keep the Deployment as it is.

`kubectl` already points at the cluster as the cluster administrator.
