---
draft: true
exam_objectives:
  - Security
---
# Summary

Authentication establishes identity, authorization checks permission and admission applies additional policy to relevant changes. ServiceAccounts supply workload identities, while token lifetime and mounting choices affect exposure.

RBAC roles define permissions and bindings grant them to subjects. RoleBindings scope grants to a namespace; ClusterRoleBindings provide cluster-wide grants. Least privilege requires considering direct permissions, indirect effects and every applicable binding.
