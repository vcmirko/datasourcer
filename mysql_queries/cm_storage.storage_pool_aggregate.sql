SELECT
    storage_pool_aggregate_relationship.objid AS id,
    storage_pool_aggregate_relationship.storagePoolId AS storage_pool_id,
    storage_pool_aggregate_relationship.aggregateId AS aggregate_id,
    storage_pool_aggregate_relationship.usedCapacity/1024/1024 AS used_capacity_mb    
FROM
    netapp_model_view.storage_pool_aggregate_relationship storage_pool_aggregate_relationship