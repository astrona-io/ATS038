# Curriculum Coverage

Exam: Kubernetes and Cloud Native Associate (KCNA). Domain: Container Orchestration (28%).

Verified against the [official objectives](https://training.linuxfoundation.org/certification/kubernetes-cloud-native-associate/) on 2026-10-10. Module titles and questions are original teaching material, not official exam questions.

| Section | Official objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | Networking | 3 | Written; review pending |
| 020 | Security | 2 | Written; review pending |
| 030 | Troubleshooting | 2 | Written; review pending |
| 040 | Storage | 2 | Written; review pending |

| Section / module | Module | Teaching lessons | Measurable outcomes |
| --- | --- | --- | --- |
| 010 / 01 | Pod Networking | 2 | Explain Pod addresses and communication in the Kubernetes network model.; Identify the network plugin's role and the CNI interface.; Explain Service discovery through DNS.; Distinguish name resolution from application reachability. |
| 010 / 02 | Services And External Access | 2 | Explain Service selectors, ports and EndpointSlices.; Compare ClusterIP, NodePort and LoadBalancer Services.; Distinguish Ingress from a Service and its implementation.; Explain the role separation in the Gateway API. |
| 010 / 03 | Traffic Control | 2 | Explain how NetworkPolicy selects and isolates Pods.; Predict whether both traffic directions permit a connection.; Distinguish network policy from service mesh capabilities.; Explain TLS encryption and certificate verification. |
| 020 / 01 | Identity And Access | 2 | Distinguish authentication, authorization and admission.; Explain ServiceAccounts and token-based workload identities.; Compare Role, ClusterRole and their bindings.; Apply least privilege to an API permission scenario. |
| 020 / 02 | Workload Security | 2 | Explain security context controls and their limits.; Compare the Privileged, Baseline and Restricted Pod Security profiles.; Identify sensitive credential handling and excessive privileges.; Distinguish image vulnerability checks from artifact identity checks. |
| 030 / 01 | Diagnosing Orchestration Failures | 2 | Use status, conditions and events to identify a failed lifecycle stage.; Distinguish placement failures from preparation failures.; Explain image pull errors and startup errors.; Choose evidence before making a corrective change. |
| 030 / 02 | Diagnosing Cluster Services | 2 | Distinguish a node problem from a single workload problem.; Separate DNS resolution from Service backend connectivity.; Explain how storage and resource pressure affect workloads.; Choose the smallest diagnostic scope supported by evidence. |
| 040 / 01 | Volumes And Application State | 2 | Compare container-local, ephemeral and persistent storage lifecycles.; Explain the PersistentVolume and PersistentVolumeClaim relationship.; Describe StorageClass-based dynamic provisioning.; Identify the CSI driver's role in storage operations. |
| 040 / 02 | Storage Decisions | 2 | Distinguish ReadWriteOnce from ReadWriteOncePod.; Compare filesystem and block volume modes.; Predict Retain and Delete reclaim policy behavior.; Explain why persistence, replication and backup are different properties. |

Every section begins with an introduction. Every module ends with a summary before the next module. YAML question banks follow the final module summary of each section; a domain review bank closes the course. They are indexed separately for future application integration.

This course has no labs or playgrounds, as requested by the maintainer. All material is readable without a cluster. Technical content remains draft until review; no runtime execution or lab validation is claimed.
