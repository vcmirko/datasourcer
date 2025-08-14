SELECT
    snapshot_policy.objId AS id,
    snapshot_policy.clusterId AS cluster_id,
    IF (ISNULL(snapshot_policy.vserverId),
    vserver.objId,
    snapshot_policy.vserverId) as vserver_id,
    snapshot_policy.comment AS comment,
    snapshot_policy.isEnabled AS enabled,
    snapshot_policy.name AS NAME    
FROM
    netapp_model_view.snapshot_policy snapshot_policy,
    netapp_model_view.vserver vserver    
where
    vserver.clusterId = snapshot_policy.clusterId                    
    AND vserver.typeRaw = 'admin'