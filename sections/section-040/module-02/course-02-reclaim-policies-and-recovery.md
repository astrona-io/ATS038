---
draft: true
exam_objectives:
  - Storage
---
# Reclaim Policies And Recovery

The `probe` workload is removed, but its reports must be retained. Deleting a Pod, deleting its claim and deleting the underlying storage are different operations. A volume's reclaim policy controls what happens to the storage resource after its claim is released.

With Retain, the released volume and underlying data require manual handling rather than automatic reclamation. An operator must assess the data and prepare any reuse. Retention does not automatically rebind the same data to every new claim or guarantee that the application can recover it without a procedure.

With Delete, supported storage integration removes the volume and backing storage as part of reclamation. Actual cleanup can involve finalizers and driver actions. A policy that deletes storage makes claim deletion a significant data lifecycle event; deleting only the application Pod is not the same event.

A StatefulSet can give each application member a stable claim association, but claim retention and deletion behavior depend on its configuration and surrounding lifecycle decisions. Do not assume that deleting one kind of object always cascades to every storage resource. Read the policy that governs the relevant relationship.

Replication and backup remain separate. Replication can preserve availability through a component loss but can also copy a bad write. A backup provides a recovery point, subject to how and when it was created. Application-consistent recovery may require coordinating data across several volumes or an external database.

Before removing storage, identify the owner, retention policy, recovery requirements and a verified backup. For an exam scenario about retained data after claim deletion, distinguish the reclaim policy from Pod lifecycle and from a promise of automatic restoration.

## Following Deletion Through The Storage Lifecycle

Start with a Pod using a bound claim. Deleting only the Pod can leave the claim and storage intact, allowing a suitable replacement to reuse the data. Deleting the claim releases the association and brings the PV's reclaim policy into consideration. Deleting an application controller can have additional effects depending on its configured relationships and retention policy.

With Retain, the released storage needs manual handling. An operator may need to preserve data, assess ownership and prepare a controlled reuse or cleanup procedure. A new claim with a familiar name does not automatically establish that it receives the previous data. The retained resource's state and rebinding procedure matter.

With Delete, the storage integration can remove both the volume representation and its backing resource. Finalizers can keep the object visible while cleanup proceeds. A deletion timestamp therefore does not necessarily mean the external data is already gone, but it also does not make ongoing retention a safe assumption.

## Recovery Beyond Object Existence

A backup must cover the important data and be usable in a realistic restore procedure. A crash-consistent volume copy captures one kind of state; an application-consistent backup may coordinate transactions and several related data stores. The chosen method should match what the application needs to recover correctly.

Replication can preserve operation after one device or member fails but also repeat accidental or malicious changes. Historical recovery requires an appropriate earlier state, with retention and access controls. A retained PV is useful only if the operator can find it, mount it safely and recover meaningful application data.

Before deletion, identify the data owner, governing lifecycle policies and acceptable recovery outcome. After restoration, verify application records rather than only successful mounting. Storage cleanup and recovery are data-management decisions, not interchangeable ways to remove a workload from a cluster.

## Common pitfalls

> [!WARNING]
> Delete can remove backing storage after claim release. Retain keeps data for manual handling; it does not provide automatic recovery or replace a backup.
