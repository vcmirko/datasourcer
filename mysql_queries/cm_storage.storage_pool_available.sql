SELECT
    storage_pool_available.objid AS id,
    storage_pool_available.storagePoolId AS storage_pool_id,
    storage_pool_available.nodeId AS node_id,
    storage_pool_available.allocationUnitCount AS allocation_unit_count,
    storage_pool_available.availableSize/1024/1024 AS available_size_mb    
FROM
    netapp_model_view.storage_pool_available storage_pool_available