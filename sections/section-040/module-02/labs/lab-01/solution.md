# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was not run when it was written, so this page describes what you should see and does not show command output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/module-02/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes. `shuttle-logs-intact` passes because the claim is bound and its data exists. It stays your guard while you work, and it fails if you delete and re-create the claim.

## Step 1: Create the volume

A hand-made PersistentVolume describes storage that already exists. On the one-node cluster, a directory of the node is enough. Save this as `pv-archive.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: archive-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: manual
  hostPath:
    path: /mnt/archive-pv
    type: DirectoryOrCreate
```

Apply it and read the status:

```sh
kubectl apply -f pv-archive.yaml
kubectl get pv archive-pv
```

The volume should show `Available`.

## Step 2: Create the claim

The claim names the same class, the same access mode and a size that fits. Save this as `pvc-archive-claim.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: archive-claim
  namespace: starfleet
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: manual
  resources:
    requests:
      storage: 1Gi
```

Apply it and wait for the Pod:

```sh
kubectl apply -f pvc-archive-claim.yaml
kubectl -n starfleet get pvc archive-claim
kubectl -n starfleet wait --for=condition=Ready pod/archivist --timeout=120s
```

The PV controller binds the claim to `archive-pv`, because the class, the mode and the size match. The `archivist` Pod then starts. Run `astrona submit`. The checks `archive-pv-retain`, `archive-claim-bound` and `archivist-running` should pass.

## Step 3: Set the dynamic volume to Retain

The reclaim policy belongs to the volume, so find the volume behind the claim and patch it:

```sh
kubectl -n starfleet get pvc shuttle-logs -o jsonpath='{.spec.volumeName}{"\n"}'
```

Replace `<PV_NAME>` with the name that the command printed:

```sh
kubectl patch pv <PV_NAME> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
kubectl get pv <PV_NAME>
```

The `RECLAIM POLICY` column should read `Retain`. If you delete the claim during the cleanup, the volume now becomes `Released` and keeps its data. Run `astrona submit`. All five checks should pass.
