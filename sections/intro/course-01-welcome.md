# Welcome To The Course

This course trains you for the **Container Orchestration** part of the **Kubernetes and Cloud Native Associate (KCNA)** exam. That part is 28% of the exam. This page tells you who the course is for, what you can do at the end, which words and example application it uses, and how its pages fit together.

## Who this course is for

You know what a container is and you can read a short YAML file. You do not need to have run Kubernetes before. Each new idea is explained the first time it appears, and the course uses the real Kubernetes terms because those are the words in the product, in error messages and in the exam.

## What you can do at the end

The KCNA exam is a multiple-choice test. It checks that you can explain how Kubernetes works and choose the right answer for a short scenario. This course goes one step further: every module has a playground, a small Kubernetes cluster on your own machine, and a graded lab. When you have run a mechanism yourself, you remember what it does and what it does not do. The exam lists four topics for this part, and each one turns into skills you will practise.

The first topic is **networking**. You will learn to:

- Explain how a pod gets an address and how pods reach each other across nodes.
- Use a Service, its selector and its EndpointSlices to reach a changing set of pods, and compare `ClusterIP`, `NodePort` and `LoadBalancer`.
- Explain Ingress and the Gateway API, and block traffic with a `NetworkPolicy`.

The second topic is **security**. You will learn to:

- Separate authentication, authorization and admission, and give a service account only the rights it needs with RBAC.
- Restrict a pod with a security context and Pod Security Admission, and handle Secrets safely.

The third topic is **troubleshooting**. You will learn to:

- Read pod status, conditions and events to find which stage of the pod lifecycle failed.
- Tell a node problem from a workload problem, and DNS from a Service with no backends.

The fourth topic is **storage**. You will learn to:

- Compare container, ephemeral and persistent storage, and follow a claim to its volume.
- Choose access modes, volume modes and reclaim policies, and explain why persistence, replication and backup are different.

## The words this course uses

A **pod** runs one or more containers that share a network address. A **namespace** groups objects inside a cluster. The **API server** receives every request to create, read, change or delete an object. A **node** is a machine that runs pods. A **Service** gives a changing set of pods one stable address.

## The example application in your playground

Every playground and lab uses the same small application. The `scout` Deployment is an HTTP API, and the `probe` Deployment is a second backend. You send test requests from the `shuttle` pod, a client with `curl`, in the `starfleet` namespace. A second client, `drifter`, runs in the `outpost` namespace and acts as another team. Some playgrounds and labs start with something broken on purpose. That is the material, not a fault in the course.

## How the course is laid out

The course has four sections: Networking, Security, Troubleshooting and Storage. Each section starts with a short introduction and ends with a capstone lab and a knowledge check. Each module has a landing page, deep-dive parts, a graded lab and a summary. After the last section, a final knowledge check covers the whole domain.

Read each part with its playground open next to it. The commands are written so that you can copy them. The labs and playgrounds are written to run on a kind cluster, but they are not yet verified on a live run, so report any command that does not behave as the page says.
