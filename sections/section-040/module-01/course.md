# Volumes And Application State

A container writes to its own filesystem, and Kubernetes replaces containers often. A replaced container starts again from its image, so every file the old container wrote is gone. Applications that must keep state, such as a database or an upload directory, need storage that has a longer life than a container, and sometimes longer than a Pod.

This module follows the data through four lifetimes. A file in the container filesystem lasts as long as the container. A file in an `emptyDir` volume lasts as long as the Pod. A file in a PersistentVolume lasts until someone deletes the volume itself. You will write a file at each level, replace the container or the Pod, and see which files survive. You will then create the volume by hand, and finally let a StorageClass and a CSI driver create it for you.

The module has three parts. **Container Filesystem And Ephemeral Volumes** compares the writable container layer with `emptyDir`, `configMap`, `secret` and `hostPath` volumes. **PersistentVolumes And Claims** creates a PersistentVolume and a PersistentVolumeClaim by hand and shows how the control plane binds them. **StorageClasses, Provisioning And CSI** shows how a claim creates its own volume, which component does the work, and how a StatefulSet gives each replica its own claim.

## Learning objectives

After this module you can:

- Compare the lifetime of the container filesystem, `emptyDir`, a PersistentVolumeClaim and the PersistentVolume behind it.
- Name which volume types are for configuration and credentials, and which are for application data.
- Explain how a PersistentVolumeClaim binds to a PersistentVolume and which fields the match uses.
- Describe the steps of dynamic provisioning and say which component does each one.
- Explain what a CSI driver does and what the CSI sidecar containers do.
- Explain why a StatefulSet uses `volumeClaimTemplates`.

## Before you start

You need Kubernetes basics: namespaces, Pods, Deployments and the commands `kubectl get`, `kubectl apply`, `kubectl describe` and `kubectl exec`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35. It has the following objects:

| Namespace | Object | What it is |
| --- | --- | --- |
| `starfleet` | Deployment `scout` | One `busybox` container with an `emptyDir` volume at `/scratch`, a `configMap` volume at `/etc/scout` and a `secret` volume at `/etc/scout-secret` |
| `starfleet` | ConfigMap `scout-config`, Secret `scout-token` | The data behind those two volumes |
| `outpost` | (empty) | A second namespace for your own experiments |

The `scout` container ends itself when a file `/tmp/crash` exists, so you can restart the container on demand. The cluster has the default StorageClass `standard`. You run every command as the cluster administrator and `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
