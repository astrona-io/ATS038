---
draft: true
exam_objectives:
  - Storage
---
# Summary

Container-local storage, Pod-lifetime volumes and persistent storage have different retention boundaries. Claims describe application requirements and bind to volumes that represent provisioned storage. Data durability still depends on the backend and backup plan.

StorageClasses support defined storage offerings and dynamic provisioning. CSI drivers integrate storage operations with Kubernetes. Binding mode, capacity and topology can connect storage readiness to Pod placement.
