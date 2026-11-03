# Question

Solve this question on: `terminal`

The `starfleet` namespace is running. The client `shuttle` cannot reach two backends through their Services, and the Deployment `lander` does not start. Trace each failure from the symptom to its cause and fix all three. Change only Services and add only the objects the task names. Do not change the Deployments `probe`, `relay` or `scout`, their labels or their ports.

1. `shuttle` must get HTTP 200 from `http://probe` (path `/get`). The `probe` pod is healthy. Find out why the Service does not send traffic to it.

2. `shuttle` must get HTTP 200 from `http://relay` (path `/get`). The Service has an endpoint, but the connection fails. Find out why and fix the Service.

3. The Deployment `lander` stays in an error state before its container starts. It reads the environment variable `LANDING_MODE` from the ConfigMap `lander-config`. Create what is missing, with the value `automatic`. Do not remove the variable from the Deployment.

`kubectl` already points at the cluster as the cluster administrator. The pod `shuttle` has `curl`: use `kubectl exec deploy/shuttle -n starfleet -- curl ...` to send test requests.
