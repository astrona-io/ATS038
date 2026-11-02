---
draft: true
exam_objectives:
  - Networking
---
# Summary

Pod networking connects workload network namespaces across nodes through a configured implementation. CNI defines a networking interface; policy and forwarding capabilities depend on the chosen implementation.

DNS helps clients discover Services without hard-coding Pod addresses. Names are scoped, cluster domains can vary, and headless Services expose a different discovery pattern. Resolution, routing and application readiness need separate evidence.
