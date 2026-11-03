# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was not run when it was written, so this page describes what you should see and does not show command output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/module-01/labs/lab-01
```

## Step 1: Create the claim for scout

Save this as `pvc-scout-data.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: scout-data
  namespace: starfleet
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 1Gi
```

Apply it and read the status:

```sh
kubectl apply -f pvc-scout-data.yaml
kubectl -n starfleet get pvc scout-data
```

The `standard` class normally waits for the first Pod that uses the claim, so the claim shows `Pending` for now. That is expected.

## Step 2: Mount the claim in scout

Open the Deployment and replace the `emptyDir` of the volume `data`:

```sh
kubectl -n starfleet edit deployment scout
```

The `volumes` entry must become:

```yaml
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: scout-data
```

Wait for the rollout and check the claim again:

```sh
kubectl -n starfleet rollout status deployment/scout
kubectl -n starfleet get pvc scout-data
```

The claim should now show `Bound`. Run `astrona submit`. The checks `scout-data-bound`, `scout-mounts-claim` and `scout-data-persists` should pass. The last one writes a file, deletes the Pod and reads the file in the replacement.

## Step 3: Find why probe is Pending

```sh
kubectl -n starfleet get pods
kubectl -n starfleet describe pvc probe-data
```

The events of the claim say that the StorageClass `fast` was not found. No class with that name exists, so no provisioner reacts.

## Step 4: Re-create the claim

A claim's `storageClassName` cannot be edited. Delete the claim and create it again with the right class. The `probe` Pod was never scheduled, so the claim is not protected and the delete finishes. Save this as `pvc-probe-data.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: probe-data
  namespace: starfleet
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 1Gi
```

Delete the old claim, apply the new one and wait for the Deployment:

```sh
kubectl -n starfleet delete pvc probe-data
kubectl apply -f pvc-probe-data.yaml
kubectl -n starfleet rollout status deployment/probe
```

The `probe` Pod now schedules, the claim binds and the Deployment becomes available. Run `astrona submit`. All five checks should pass.
