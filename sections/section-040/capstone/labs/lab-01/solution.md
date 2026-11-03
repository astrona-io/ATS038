# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was not run when it was written, so this page describes what you should see and does not show command output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-040/capstone/labs/lab-01
```

## Step 1: Replace the StatefulSet with one that has volumeClaimTemplates

The field `volumeClaimTemplates` cannot be edited on an existing StatefulSet. Delete the StatefulSet, then create it again with the template. The old Pods used an `emptyDir`, so no claims exist and no data is lost. Delete it:

```sh
kubectl -n orbit delete statefulset ledger
```

Save this as `statefulset-ledger.yaml`:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: ledger
  namespace: orbit
spec:
  serviceName: ledger
  replicas: 2
  selector:
    matchLabels:
      app: ledger
  template:
    metadata:
      labels:
        app: ledger
    spec:
      containers:
        - name: ledger
          image: busybox:1.37
          command: ["sh", "-c", "sleep 36000"]
          volumeMounts:
            - name: data
              mountPath: /var/ledger
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes:
          - ReadWriteOnce
        storageClassName: standard
        resources:
          requests:
            storage: 1Gi
```

The pod template has no `volumes` entry named `data`. The `volumeClaimTemplate` provides the volume with that name. Apply it and wait:

```sh
kubectl apply -f statefulset-ledger.yaml
kubectl -n orbit rollout status statefulset/ledger
kubectl -n orbit get pvc
```

The StatefulSet controller creates the claims `data-ledger-0` and `data-ledger-1`. They should become `Bound` as the Pods start one after the other. Run `astrona submit`. The checks `ledger-claims-bound`, `ledger-ready` and `ledger-data-persists` should pass.

## Step 2: Retain the ledger volumes

Print the volume names of both claims:

```sh
kubectl -n orbit get pvc data-ledger-0 data-ledger-1 -o jsonpath='{range .items[*]}{.spec.volumeName}{"\n"}{end}'
```

Patch each volume. Replace `<PV_NAME>` with each printed name in turn:

```sh
kubectl patch pv <PV_NAME> -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

Read the policies with `kubectl get pv`. Both should show `Retain`. Run `astrona submit`. The check `ledger-volumes-retained` should pass.

## Step 3: Fix the reporter claim

```sh
kubectl -n orbit describe pvc report-cache
```

The events say that the StorageClass `fast` was not found. `storageClassName` cannot be edited, so delete the claim and create it again. The `reporter` Pod was never scheduled, so the claim is not protected and the delete finishes. Save this as `pvc-report-cache.yaml`:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: report-cache
  namespace: orbit
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
kubectl -n orbit delete pvc report-cache
kubectl apply -f pvc-report-cache.yaml
kubectl -n orbit rollout status deployment/reporter
```

The `reporter` Pod schedules, the claim binds and the Deployment becomes available. Run `astrona submit`. All five checks should pass.
