# Curriculum Coverage

Exam: Kubernetes and Cloud Native Associate (KCNA). Domain: Container Orchestration (28%).

Verified against the [official objectives](https://training.linuxfoundation.org/certification/kubernetes-cloud-native-associate/) on 2026-10-10. Module titles and questions are original teaching material, not official exam questions.

| Section | Official objective | Modules | Status |
| --- | --- | --- | --- |
| 010 | Networking | 3 | Hands-on build; UNTESTED |
| 020 | Security | 2 | Hands-on build; UNTESTED |
| 030 | Troubleshooting | 2 | Hands-on build; UNTESTED |
| 040 | Storage | 2 | Hands-on build; UNTESTED |

| Section / module | Module | Teaching lessons | Measurable outcomes |
| --- | --- | --- | --- |
| 010 / 01 | Pod Networking | 3 | Explain Pod addresses and communication in the Kubernetes network model.; Identify the network plugin's role and the CNI interface.; Explain Service discovery through DNS.; Distinguish name resolution from application reachability. |
| 010 / 02 | Services And External Access | 3 | Explain Service selectors, ports and EndpointSlices.; Compare ClusterIP, NodePort and LoadBalancer Services.; Distinguish Ingress from a Service and its implementation.; Explain the role separation in the Gateway API. |
| 010 / 03 | Traffic Control | 3 | Explain how NetworkPolicy selects and isolates Pods.; Predict whether both traffic directions permit a connection.; Distinguish network policy from service mesh capabilities.; Explain TLS encryption and certificate verification. |
| 020 / 01 | Identity And Access | 3 | Distinguish authentication, authorization and admission.; Explain ServiceAccounts and token-based workload identities.; Compare Role, ClusterRole and their bindings.; Apply least privilege to an API permission scenario. |
| 020 / 02 | Workload Security | 3 | Explain security context controls and their limits.; Compare the Privileged, Baseline and Restricted Pod Security profiles.; Identify sensitive credential handling and excessive privileges.; Distinguish image vulnerability checks from artifact identity checks. |
| 030 / 01 | Diagnosing Orchestration Failures | 3 | Use status, conditions and events to identify a failed lifecycle stage.; Distinguish placement failures from preparation failures.; Explain image pull errors and startup errors.; Choose evidence before making a corrective change. |
| 030 / 02 | Diagnosing Cluster Services | 3 | Distinguish a node problem from a single workload problem.; Separate DNS resolution from Service backend connectivity.; Explain how storage and resource pressure affect workloads.; Choose the smallest diagnostic scope supported by evidence. |
| 040 / 01 | Volumes And Application State | 3 | Compare container-local, ephemeral and persistent storage lifecycles.; Explain the PersistentVolume and PersistentVolumeClaim relationship.; Describe StorageClass-based dynamic provisioning.; Identify the CSI driver's role in storage operations. |
| 040 / 02 | Storage Decisions | 3 | Distinguish ReadWriteOnce from ReadWriteOncePod.; Compare filesystem and block volume modes.; Predict Retain and Delete reclaim policy behavior.; Explain why persistence, replication and backup are different properties. |

Every section begins with an introduction. Every module has a playground, a graded lab, three deep-dive parts and a summary that ends with the playground destroy marker. Each section ends with a capstone lab and a `quiz.yaml` knowledge check; `sections/final-domain-quiz.yaml` closes the course. The older `questions.yaml` banks are retained but not registered.

Labs and playgrounds are in scope since 2026-11-03 (the earlier reading-only restriction was lifted by the maintainer). They are statically validated only and marked UNTESTED; technical content remains draft until review.
