SELECT
    disk.objId AS id,
    disk.diskId AS disk_id,
    disk.aggregateId AS aggregate_id    
FROM
    netapp_model_view.disk_aggregate_relationship disk