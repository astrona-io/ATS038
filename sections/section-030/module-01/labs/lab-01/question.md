# Question

Solve this question on: `terminal`

The `starfleet` namespace is running, but six Deployments do not work. Find out why each one fails from the pod status, the events and the logs, and fix each one by changing the Deployment. Do not label, taint or change the node. Do not scale a Deployment to zero or delete it. Do not change `scout` or `shuttle`.

1. The Deployment `lander` has a pod that stays `Pending`. The Deployment `hauler` has a pod that stays `Pending` for a different reason. Both must end up scheduled and available.

2. The Deployment `tanker` cannot start its container because the image cannot be pulled. It must run the `ghcr.io/stefanprodan/podinfo` image at a tag that exists.

3. The Deployment `rover` starts and then exits with code 1, and its pod restarts again and again. It must keep running without restarts.

4. The Deployment `miner` is killed again and again by the kernel because the process needs more memory than its limit allows. It must run without being killed.

5. The Deployment `warden` has a pod that is `Running` but never `Ready`. The pod must become `Ready`. Keep the readiness probe: change what it checks, do not remove it. The application serves `/readyz`.

`kubectl` already points at the cluster as the cluster administrator.
