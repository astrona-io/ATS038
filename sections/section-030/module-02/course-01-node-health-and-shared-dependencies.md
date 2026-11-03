# Node Health And Shared Dependencies

When one pod fails, you look at the pod. When many pods fail at once, or a pod fails in a way that nothing in its own spec explains, you look at what the pods share. This part teaches you to read a node's health, to compare the node's capacity with what the pods have asked for, and to follow a pod that waits on a ConfigMap, a Secret or a storage claim.

## One workload or the whole node

The first question is how wide the problem is. A problem in one pod, with the other pods of the same node healthy, is a workload problem. A problem in every pod on one node is a node problem. A problem in every pod that uses one ConfigMap, Secret, Service or claim is a shared dependency problem. Asking this question first keeps you from reading logs of a healthy application while the node under it is failing.

List the nodes and then the pods with their nodes:

<!-- astrona:playground:renew -->

```sh
kubectl get nodes
kubectl get pods -A -o wide
```

The `STATUS` column of a node is `Ready` or `NotReady`. A pod list sorted by node shows at once whether the broken pods share a node. In a single-node cluster every pod shares the node, so use the pod status instead: pods that are `Running` and Ready prove that the kubelet, the container runtime and the network on that node work.

## Node conditions

The kubelet reports the health of its node as a list of **conditions** on the node object. `Ready` is `True` when the kubelet is healthy and can run pods. Four more conditions report resource pressure: `MemoryPressure`, `DiskPressure`, `PIDPressure` and `NetworkUnavailable`. Read them with `describe`:

```sh
kubectl describe node
```

In the output, the `Conditions` table lists each condition with its status and a reason. In a healthy node, `Ready` is `True` and the pressure conditions are `False`. The same output shows the `Taints`, the `Capacity` and `Allocatable` of the node, and `Allocated resources`, which is the sum of the requests and limits of the pods on it.

When a condition changes, the **node lifecycle controller** (part of `kube-controller-manager`) reacts. If the kubelet stops reporting, the node becomes `NotReady` after a grace period of 40 seconds by default. The controller then adds the taints `node.kubernetes.io/unreachable` and `node.kubernetes.io/not-ready`, and pods that do not tolerate them are evicted after 300 seconds. Pressure conditions add taints too, such as `node.kubernetes.io/memory-pressure`, and the kubelet itself starts to evict pods when memory or disk runs low. Lower-priority and over-requesting pods go first.

The pod symptoms follow from this: pods on a `NotReady` node show `Unknown` or are replaced by the controllers on other nodes, and new pods do not land on a node with pressure. The cause is then on the node: the kubelet process, the container runtime, the disk or the network, and you look there, not in the application.

## Capacity, allocatable and requests

The scheduler fits pods by requests, so a node can be "full" while its real CPU use is low. Compare `Allocated resources` with `Allocatable` in the same `describe` output. When the requested percentage is close to 100, the next pod with a request cannot be scheduled, and its event says `Insufficient cpu` or `Insufficient memory`. The usage is a separate number that comes from the metrics server through `kubectl top`. This playground has no metrics server, so `kubectl top` does not work here. On any cluster without a metrics server, that command fails in the same way. Real usage and requested capacity are different questions.

## System components and cluster-wide warnings

Some shared parts run as pods themselves. CoreDNS, the proxy that forwards Service traffic (`kube-proxy`) and the network plugin run in the `kube-system` namespace. If one of them is not Running, many applications fail at the same time in ways that look unrelated. Check them, and list every warning event in the cluster:

```sh
kubectl get pods -n kube-system
kubectl get events -A --field-selector type=Warning
```

All system pods should be `Running` and Ready. The second command filters the events by their type, so the output contains only the problems: failed scheduling, failed pulls, failed probes, failed mounts. Group the warnings by the object they name. Many warnings about different pods with the same reason, such as `FailedMount` or `Failed` pulls from one registry, point at one shared cause. Warnings about one object point at that object.

## Dependencies a pod needs before it starts

A pod can reference objects that must exist before the container is created. The kubelet checks them while it prepares the pod. A missing one blocks that pod, and every pod that uses the same object is blocked in the same way, which is why this is a shared dependency problem.

The `lander` pod reads the variable `LANDING_MODE` from the ConfigMap `lander-config`, and the ConfigMap does not exist. Look at the pod:

```sh
kubectl describe pod -n starfleet -l app=lander
```

The status should be `CreateContainerConfigError`, and the event should say that the ConfigMap `lander-config` was not found. The container was never created, so `kubectl logs` has nothing to show. Missing Secrets give the same status. A missing ConfigMap or Secret that is mounted as a volume gives a different symptom: the pod stays in `ContainerCreating`, and the event says `MountVolume.SetUp failed` with the object name. Create the ConfigMap with the key the Deployment asks for:

```sh
kubectl create configmap lander-config -n starfleet --from-literal=LANDING_MODE=automatic
```

The kubelet retries with a back-off, so the pod starts within a short time without any change to the Deployment. That is the sign of a dependency fix: the pod template stays the same and the pod recovers once the object exists.

## A pod that waits on storage

The `archive` pod mounts a PersistentVolumeClaim (PVC, a request for storage) named `ledger`. Follow the chain from the pod to the claim:

```sh
kubectl get pvc -n starfleet
kubectl describe pvc ledger -n starfleet
```

The claim should be `Pending`, and its event should say that the StorageClass `missing-class` was not found. The pod's own `FailedScheduling` event says the pod has unbound immediate PersistentVolumeClaims. Read it from the symptom down: the pod waits for the claim, the claim waits for a StorageClass, and the StorageClass does not exist. The pod needs no change. The fix is in the claim. A PVC's `storageClassName` cannot be changed after creation, so the fix is to create the claim again with a class that exists.

## Choosing the smallest scope

Work from the narrowest scope that the evidence supports, and widen only when the evidence says so. Start with the pod: its status, its events and its logs. If the events name an object the pod depends on, check that object. If several pods fail with the same event, check what they share. Only when pods on one node fail together, or the node condition is not `Ready`, move to the node. Restarting a node or deleting every pod in a namespace is the widest and slowest action, and it also removes the evidence that you still need.

Each step also tells you who owns the fix. A pod problem belongs to the application team. A missing ConfigMap belongs to whoever deploys the application. A `NotReady` node belongs to the platform team. Naming the scope names the owner.

## What you know now

You can decide whether a failure is in one workload, on a node or in a dependency, read node conditions and capacity, and follow a pod that waits on a ConfigMap, a Secret or a claim. The open question is the pod that is healthy and still cannot be reached, which depends on the Service and the name lookup in front of it.

## Common pitfalls

> [!WARNING]
> Do not read application logs when the container was never created: there are none. Requests decide scheduling and real usage comes from the metrics server, so a node can be full of requests and idle. A pod that waits on a missing object recovers by itself after you create the object, so do not edit the Deployment for it.
