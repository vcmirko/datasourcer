SELECT
    storage_pool.objId AS id,
    storage_pool.NAME AS name,
    storage_pool.clusterId AS cluster_id,
    storage_pool.allocationUnitSize/1024/1024 AS allocation_unit_size_mb,
    storage_pool.poolUsableSize/1024/1024 AS pool_usable_size_mb,
    storage_pool.poolTotalSize/1024/1024 AS pool_total_size_mb,
    storage_pool.storageType AS storage_type,
    storage_pool.diskCount AS disk_count    
FROM
    netapp_model_view.storage_pool storage_pool 