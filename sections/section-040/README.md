# Storage

A container's own filesystem disappears when the container is replaced. This section teaches how Kubernetes keeps data alive: which volume types last as long as a container, a Pod or a claim, how a PersistentVolume and a PersistentVolumeClaim bind, and how a StorageClass and a Container Storage Interface (CSI) driver create volumes on demand. It also teaches the choices that decide how data behaves: access modes, volume modes, reclaim policies, expansion and the difference between persistence, replication and backup.

Each of the two modules has a playground, a graded lab and a hands-on reading path. The section ends with a capstone lab and a short knowledge check. The playgrounds and labs run on a single-node `kind` cluster (Kubernetes 1.35).

## Learning Outcomes

- Compare container-local, ephemeral and persistent storage lifecycles.
- Explain the PersistentVolume and PersistentVolumeClaim relationship.
- Describe StorageClass-based dynamic provisioning.
- Identify the CSI driver's role in storage operations.
- Distinguish ReadWriteOnce from ReadWriteOncePod.
- Compare filesystem and block volume modes.
- Predict Retain and Delete reclaim policy behavior.
- Explain why persistence, replication and backup are different properties.
