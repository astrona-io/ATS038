---
draft: true
exam_objectives:
  - Storage
---
# Storage Lifecycles And Claims

The `probe` application caches temporary files and stores durable reports. These two data classes need different lifecycles. A container's writable layer is tied to container execution and is unsuitable for important retained data. A volume exposes storage to containers through a mount and can have a different lifecycle.

An `emptyDir` volume exists for a Pod's lifetime. Containers can share it, and data can survive a container restart within that Pod. Deleting the Pod removes that temporary volume. A replacement Pod does not inherit it simply because the workload uses the same application name.

A PersistentVolume (PV) represents provisioned storage in the cluster. A PersistentVolumeClaim (PVC) is a namespaced request for storage with requirements such as capacity and access mode. A Pod references the claim, which binds to a suitable volume. This separates an application's request from the infrastructure-specific storage details.

```mermaid
flowchart TB
    P["Pod"] -->|"uses"| C["PersistentVolumeClaim"]
    C -->|"binds"| V["PersistentVolume"]
    V -->|"represents"| S["Storage system"]
```
The Pod requests access through a claim, while the volume represents the provisioned storage.

Persistence means data can outlive a Pod according to the storage lifecycle. It does not prove that storage is replicated, backed up or accessible from every node. A local volume and a remote replicated service have different failure properties despite both being persistent.

For a scenario, first ask what must survive: a process restart, Pod replacement, node loss or a regional outage. An `emptyDir` can satisfy the first case but not all the others. Then examine the provisioned storage system and the application's data consistency requirements.

## Predicting What Survives Each Event

A temporary file in the container's writable layer belongs to that container execution environment. A file in an `emptyDir` belongs to the Pod's lifetime. A file on a suitable persistent volume can outlive the Pod through its claim and storage lifecycle. These three files may have identical names inside the process while behaving differently during failure.

For a container restart within the same Pod, the `emptyDir` can remain available. For Pod deletion, its data does not transfer to the replacement. For replacement using the same persistent claim, the data can be accessible again if the backend and mount requirements permit it. Node loss adds another question: whether that storage can be reached from the replacement's location.

A volume mount defines where the process sees data. Two containers share data only when they access the same underlying volume through appropriate mounts. One container's ordinary image directory does not become shared merely because the containers occupy one Pod.

## Claim Binding Is Not Data Protection

A PVC describes a request, including capacity, access mode and selected storage class where applicable. A bound PV represents the chosen storage resource. Binding establishes an association; it does not independently prove that the application can write consistent records, that the backend is replicated or that a backup exists.

The claim is namespaced while the volume resource is cluster-scoped. This separates application ownership from infrastructure representation. A Pod normally uses a claim in its relevant namespace rather than freely selecting arbitrary volumes as though all storage were one global directory.

Choose storage by loss tolerance and access needs. Temporary caches can use ephemeral storage when rebuilding is acceptable. Reports requiring retention need a suitable persistent or external data service and a recovery plan. A persistence choice should explain exactly which events the data survives and which still require backup or manual restoration.

## Common pitfalls

> [!WARNING]
> `emptyDir` survives a container restart within its Pod, but not Pod deletion. Persistent storage does not automatically provide backups or cross-node availability.
