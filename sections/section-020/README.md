# Section 020: Security

Makes the reader able to explain who may do what in the Kubernetes API and what a pod may do on its node. The section covers how the API server checks a request, how ServiceAccounts, Roles and bindings grant access, how security contexts and Pod Security admission limit a pod, and how Secrets and images are protected. This is the Container Orchestration part of the Kubernetes and Cloud Native Associate (KCNA) exam that asks about access, workload isolation and credentials.

All labs and playgrounds in this section are untested. They are built with static checks only.

---

## What You Will Learn

- Distinguish authentication, authorization and admission, and say which failure returns `401` and which returns `403`
- Explain ServiceAccounts and the bound, expiring tokens that pods receive
- Choose between Role and ClusterRole, and between RoleBinding and ClusterRoleBinding
- Apply least privilege to an API permission scenario
- Check access with `kubectl auth can-i --as` and read a Forbidden error
- Explain security context controls and their limits
- Compare the Privileged, Baseline and Restricted Pod Security levels
- Enforce a level on a namespace with the enforce, warn and audit modes
- Explain what base64 does and does not protect, and deliver a Secret as a volume
- Distinguish an image vulnerability scan from a signature or digest check

---

## The Learning Path

### 1. Identity And Access
*   **Module Reader:** **[Module 1: Identity And Access](./module-01/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-01/playground` — kind cluster, no extra tools. Namespaces `starfleet` and `outpost` with the Starfleet workloads, a ServiceAccount `auditor` and a ClusterRoleBinding `drifter-view` that is wider than it should be.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-01/playground
    ```
*   **Graded Lab:** `sections/section-020/module-01/labs/lab-01` — fix a Role with the wrong API group, replace a cluster-wide binding with a namespaced one, and stop a pod from mounting a token it does not use.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-01/labs/lab-01
    astrona submit -c .
    ```

### 2. Workload Security
*   **Module Reader:** **[Module 2: Workload Security](./module-02/course.md)**
*   **Hands-on Playground:** `sections/section-020/module-02/playground` — kind cluster, no extra tools. The Starfleet workloads without security contexts, a Secret `api-key` in `starfleet`, and a privileged `debug-tool` Deployment in `outpost`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-02/playground
    ```
*   **Graded Lab:** `sections/section-020/module-02/labs/lab-01` — harden `scout`, move a Secret from an environment variable to a read-only volume, and enforce the Baseline level on `outpost`.
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/module-02/labs/lab-01
    astrona submit -c .
    ```

### Section Capstone Challenge
*   **Comprehensive Challenge:** Security Capstone — `sections/section-020/capstone/labs/lab-01`
    ```bash
    astrona run --git ssh://git@github.com/astrona-io/ATS038.git -c sections/section-020/capstone/labs/lab-01
    astrona submit -c .
    ```
*   **Hands-on Objective:** In the namespace `orbit` the reader replaces a cluster-wide `edit` binding for `ci-deployer` with a Role that allows only the Deployment verbs it needs, hardens the privileged `beacon` Deployment, delivers its Secret as a volume and enforces the Baseline level. The grader checks `can-i` answers and the pod specs, and that `beacon` keeps serving.

---

## Ready For Assessment?

The section ends with a twelve-question knowledge check in `quiz.yaml`.
