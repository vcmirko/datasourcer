SELECT
    aggregate.objId AS id,
    aggregate.nodeId AS node_id,
    aggregate.name AS NAME,
    IF(ISNULL(aggregate.sizeTotal),
    0,
    aggregate.sizeTotal/1024/1024) AS size_mb,
    IF(ISNULL(aggregate.sizeUsed),
    0,
    aggregate.sizeUsed/1024/1024) AS used_size_mb,
    IF(ISNULL(aggregate.sizeAvail),
    0,
    aggregate.sizeAvail/1024/1024) AS available_size_mb,
    aggregate.raidTypeRaw AS RAID_TYPE,
    aggregate.raidStatus AS raid_status,
    IF(ISNULL(aggregate.blockTypeRaw),
    '64-bit',
    REPLACE(aggregate.blockTypeRaw,
    '_',
    '-')) AS block_type,
    aggregate.stateRaw AS state,
    IF(ISNULL(aggr_disk_count_table.disk_count),
    0,
    aggr_disk_count_table.disk_count) AS number_of_disks,
    IF(ISNULL(volume_count_table.vol_count),
    0,
    volume_count_table.vol_count) AS volume_count,
    aggregate.isHybrid AS is_hybrid,
    aggregate.isHybridEnabled AS hybrid_enabled,
    aggregate.hybridCacheSizeTotal/1024/1024 AS hybrid_cache_size_mb,
    IF (ISNULL(aggregate.snapshotSizeTotal),
    0,
    aggregate.snapshotSizeTotal/1024/1024) AS snapshot_total_size_mb,
    aggregate.snapshotSizeUsed/1024/1024 AS snapshot_used_size_mb,
    aggregate.hasLocalRoot AS has_local_root,
    aggregate.hasPartnerRoot AS has_partner_root,
    oc_aggregate.bytesUsedPerDay/1024/1024 AS daily_growth_rate_mb,
    oc_aggregate.daysUntilFull AS days_until_full,
    aggregate.snapLockTypeRaw AS snaplock_type,
    aggregate.isSnapLock AS is_snaplock,
    aggregate.aggregateTypeRaw AS type,
    aggregate.isComposite AS is_composite    
FROM
    netapp_model_view.aggregate aggregate    
LEFT JOIN
    (
        SELECT
            COUNT(disk.objId) AS disk_count,
            aggr.objId AS aggr_id                                    
        FROM
            netapp_model_view.disk_aggregate_relationship DISK,
            netapp_model_view.aggregate aggr                                    
        WHERE
            aggr.objId = disk.aggregateId                                    
        GROUP BY
            disk.aggregateId                    
    ) aggr_disk_count_table                                    
        ON aggregate.objId = aggr_disk_count_table.aggr_id    
LEFT JOIN
    (
        SELECT
            COUNT(volume.objId) AS vol_count,
            aggr.objId AS aggr_id                                    
        FROM
            netapp_model_view.volume volume,
            netapp_model_view.aggregate aggr                                    
        WHERE
            aggr.objId = volume.aggregateId                                    
        GROUP BY
            volume.aggregateId                    
    ) volume_count_table                                    
        ON aggregate.objId = volume_count_table.aggr_id ,
    ocum_view.aggregate oc_aggregate    
WHERE
    oc_aggregate.id = aggregate.objId