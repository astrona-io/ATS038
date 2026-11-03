# Diagnosing Orchestration Failures

A pod that does not run has failed at one specific stage of its lifecycle. Kubernetes records that stage in the pod status, the pod conditions and the events, and each stage has different causes and different fixes. This module teaches you to read that evidence, name the stage, and change exactly one thing.

Keep one sentence in mind: **the stage tells you which component failed, and the component tells you where to look.** The scheduler places pods on nodes, the kubelet and the container runtime pull images and start containers, and the kubelet runs the probes. A `Pending` pod with no node is a scheduler problem. A pod with a node and a waiting container is a kubelet or registry problem. A running pod that is not Ready is an application or probe problem.

The module has three parts. **Placement And Dependency Evidence** explains the pod phases and conditions, reads events, and diagnoses pods that stay `Pending` because of a node selector or a resource request that no node can satisfy. **Image Preparation And Container Startup** diagnoses `ErrImagePull`, `ImagePullBackOff`, `CrashLoopBackOff` and `OOMKilled`, and shows which logs and exit codes prove each one. **Probes And Safe Corrective Changes** explains liveness, readiness and startup probes, and shows how to change a Deployment safely and roll the change back.

## Learning objectives

After this module you can:

- Use pod phase, conditions and events to name the lifecycle stage where a pod stopped.
- Tell a scheduling failure from an image, container start or probe failure.
- Read a `FailedScheduling` event and name the node selector, taint or resource request behind it.
- Explain `ErrImagePull`, `ImagePullBackOff`, `CrashLoopBackOff` and `OOMKilled`, and find the exit code and the previous logs.
- Explain what readiness, liveness and startup probes do and what a failing probe causes.
- Choose the evidence to collect before a change, change one thing, and verify or roll back.

## Before you start

You need Kubernetes basics: namespaces, pods, Deployments, and the commands `kubectl get`, `kubectl apply` and `kubectl delete`.

Your playground is a single-node `kind` cluster running Kubernetes 1.35, with no extra tools. Everything runs in the `starfleet` namespace. A **Deployment** keeps a set number of identical pods running and replaces them when they fail. Two Deployments are healthy and six fail on purpose:

| Deployment | What is wrong | Stage where it stops |
| --- | --- | --- |
| `scout`, `shuttle` | Nothing. They are healthy | Running and Ready |
| `lander` | A `nodeSelector` that no node matches | Scheduling |
| `hauler` | A CPU request larger than the node | Scheduling |
| `tanker` | An image tag that does not exist | Image pull |
| `rover` | The main process exits with code 1 | Container start |
| `miner` | The process needs more memory than its limit | Container run |
| `warden` | The readiness probe path returns an error | Readiness |

You run every command as the cluster administrator. `kubectl` already points at the playground cluster.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
