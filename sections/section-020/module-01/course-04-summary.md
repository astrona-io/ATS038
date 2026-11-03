# Summary

Every request to the API server passes three checks in a fixed order. Authentication identifies the caller and returns a user and groups, or `401 Unauthorized`. Authorization decides whether that identity may perform the verb on the resource in the namespace, or returns `403 Forbidden`. Admission looks at the object itself and can reject or change it. Each check sees different information, so a rule that depends on the content of a pod can only be enforced by admission.

A ServiceAccount is the identity of a workload. Its user name is `system:serviceaccount:<namespace>:<name>`, it has no permissions when it is created, and every namespace has a `default` account that pods use when they name no other. The kubelet places a signed, expiring token bound to the pod in the container. Setting `automountServiceAccountToken: false` on the account or on the pod removes the token from workloads that never call the API.

RBAC stores permissions as objects. A role holds rules made of API groups, resources and verbs, and a binding gives a role to users, groups or ServiceAccounts. A `Role` and a `RoleBinding` work in one namespace. A `ClusterRole` can be bound in one namespace with a `RoleBinding`, or everywhere with a `ClusterRoleBinding`. RBAC has no deny rules, and `roleRef` cannot change after a binding is created.

Least privilege limits the verbs, the resources and the scope. Wide roles such as `edit`, `admin` and `cluster-admin`, wildcards and cluster-wide bindings give more than most workloads need. Permission to create pods or to list Secrets can expose Secret values.

The key facts to remember are these:

- A role says what may be done, a binding says who may do it, and the binding kind and namespace say where.
- A `RoleBinding` that points at a `ClusterRole` grants the rules in one namespace only.
- `kubectl auth can-i --as` and `--list` show what an identity can do. A `Forbidden` message names the missing user, verb, resource, API group and namespace.
- Narrow a wide grant by creating the narrow binding first and then deleting the wide one.

<!-- astrona:playground:destroy -->
