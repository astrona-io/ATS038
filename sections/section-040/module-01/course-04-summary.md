# Summary

A container writes to a layer that belongs to that container instance. When the kubelet replaces the container, the layer is deleted. An `emptyDir` volume lasts as long as the Pod: it survives container restarts and disappears when the Pod is removed from the node. ConfigMap and Secret volumes carry configuration and credentials into the Pod as files. A `hostPath` volume keeps data on one node and exposes that node's filesystem, so it is not a storage choice for applications.

Data that must outlive a Pod needs a PersistentVolume. A PersistentVolume is a cluster-level object that describes real storage. A PersistentVolumeClaim is a namespaced request for storage. The PV controller in `kube-controller-manager` binds a claim to a volume when the StorageClass name matches, the volume offers every requested access mode, the capacity is large enough and the volume mode is equal. The binding is one to one, and a Pod reaches the volume only through the claim. A claim without a matching volume stays `Pending`.

A StorageClass lets the cluster create volumes on demand. The class names a provisioner, passes parameters, sets the reclaim policy and the binding mode, and says whether expansion is allowed. The provisioner watches claims, creates the storage and a PV, and the PV controller binds them. With `WaitForFirstConsumer`, a claim stays `Pending` until a Pod uses it, so the volume is created where the Pod runs. A Container Storage Interface driver is the standard way for a storage vendor to implement the create, attach, mount, resize and snapshot operations, with a controller plugin, a node plugin and sidecar containers that connect it to Kubernetes. A StatefulSet uses `volumeClaimTemplates` to give each replica its own claim.

Key facts:

- Container layer: lost at container restart. `emptyDir`: lost at Pod deletion. PersistentVolume: kept until the volume itself is deleted.
- A Pod names a PersistentVolumeClaim. It never names a PersistentVolume.
- The default StorageClass applies only when `storageClassName` is missing.
- A `Pending` claim can be normal with `WaitForFirstConsumer`. Read the events before changing anything.

<!-- astrona:playground:destroy -->
