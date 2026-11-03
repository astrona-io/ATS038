# Security Contexts And Pod Admission

A container is a normal Linux process with extra isolation around it. By default that process runs as the user that the image defines, often root, and it can ask the kernel for more privileges. If an attacker takes over the application, these defaults decide how much damage the attacker can do on the node. A security context is the part of the pod spec that changes those defaults. This part explains each important setting, shows two pods side by side and then explains what the Pod Security admission controller checks in a pod spec.

## What a security context sets

A security context is a set of fields in the pod spec. Fields under `spec.securityContext` apply to every container in the pod. Fields under `spec.containers[].securityContext` apply to one container and win when both are set. The kubelet and the container runtime read these fields and configure the Linux process when the container starts.

The most important fields are these:

- `runAsNonRoot: true` makes the kubelet refuse to start a container whose user is root (user ID 0). The check reads the numeric user ID, so an image that names a user by text must also have `runAsUser` set to a number.
- `runAsUser` and `runAsGroup` set the numeric user and group IDs of the process.
- `allowPrivilegeEscalation: false` sets the Linux `no_new_privs` flag, so a process cannot gain more privileges than its parent through a setuid binary.
- `readOnlyRootFilesystem: true` mounts the container root filesystem read-only. The application can still write to volumes that you mount, such as an `emptyDir`.
- `capabilities` adds or drops Linux capabilities. A capability is one slice of the powers of root, for example binding to a port below 1024. `drop: ["ALL"]` removes all of them.
- `seccompProfile` selects a filter for system calls. The value `RuntimeDefault` uses the default profile of the container runtime.
- `privileged: true` gives the container almost all the powers of root on the node, including access to host devices. Few workloads need it.

## Two pods side by side

The best way to see the effect is to run the same image twice. Save this as `pods-shell.yaml`. It defines one pod without a security context and one with the settings above:

<!-- astrona:playground:renew -->

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: plain-shell
  namespace: starfleet
spec:
  containers:
    - name: shell
      image: busybox:1.37
      command: ["sleep", "3600"]
---
apiVersion: v1
kind: Pod
metadata:
  name: hardened-shell
  namespace: starfleet
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 10001
    runAsGroup: 10001
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: shell
      image: busybox:1.37
      command: ["sleep", "3600"]
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop: ["ALL"]
```

Apply it:

```sh
kubectl apply -f pods-shell.yaml
```

Wait until both pods are running, then ask each one which user it runs as:

```sh
kubectl exec -n starfleet plain-shell -- id
kubectl exec -n starfleet hardened-shell -- id
```

The first pod reports user ID 0, which is root. The second pod reports user ID 10001. The difference comes from `runAsUser`, which the kubelet and the container runtime apply when they start the process. Now try to write a file in each pod:

```sh
kubectl exec -n starfleet plain-shell -- touch /probe-file
kubectl exec -n starfleet hardened-shell -- touch /probe-file
```

The first command succeeds. The second fails with a message that the filesystem is read-only, because `readOnlyRootFilesystem` is set. The container runtime enforces this, not the application.

## Why these settings matter

Each setting closes one way to escalate after a break-in. A non-root user cannot edit most system files or open privileged ports. A read-only root filesystem stops an attacker from writing a new program or changing the application files on disk. Dropped capabilities remove powers such as changing network settings, and `no_new_privs` blocks setuid tricks. Together they make the compromised process far less useful.

If an application needs a writable directory, mount an `emptyDir` volume at that path instead of turning off `readOnlyRootFilesystem`. If it needs to bind to port 80, run it on a high port and let a Service map port 80 to it.

## The limits of a security context

A security context restricts one Linux process, but all containers on a node still share one kernel. A flaw in the kernel can let a process escape the restrictions. A security context also does nothing about network access, and it does not stop an application from leaking data it is allowed to read. It is one layer of several, and `privileged: true` removes most of it.

## What admission checks

A security context is a request in a pod spec. Nothing forces a team to write it. The Pod Security admission controller, a built-in admission step in the API server, enforces a minimum. It reads the pod spec of every new pod and compares it with the standard that the namespace has chosen. There are three Pod Security Standards:

| Level | What it allows |
| --- | --- |
| Privileged | Everything, including privileged containers and host access |
| Baseline | Blocks known privilege escalations: privileged containers, host namespaces, host ports, `hostPath` volumes and added capabilities outside a short list |
| Restricted | Baseline plus the hardening settings: `runAsNonRoot: true`, `allowPrivilegeEscalation: false`, all capabilities dropped and a `seccompProfile` of `RuntimeDefault` or `Localhost` |

The Restricted level does not require `readOnlyRootFilesystem`. That setting is good practice, but it is not part of the standard.

## What you know now

You know what each main security context field controls, you have seen the same image run as root and as a fixed non-root user, and you know the three standards that admission uses to judge a pod spec. How a namespace chooses a level, and what the API server does when a pod breaks it, is still open.

## Common pitfalls

> [!WARNING]
> `runAsNonRoot: true` fails at start if the image user is a name and no numeric `runAsUser` is set. A read-only root filesystem breaks applications that write to `/tmp`, so mount an `emptyDir` there. Setting `privileged: true` to fix a permission error removes the isolation the other fields add.
