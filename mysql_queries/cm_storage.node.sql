SELECT
    node.objId AS id,
    node.clusterId AS cluster_id,
    node.partnerNodeId AS ha_partner_id,
    vserver.objId AS node_vserver_id,
    node.name AS NAME,
    lif.address AS primary_address,
    node.model AS model,
    node.serialNumber AS serial_number,
    node.uuid AS system_id,
    CONCAT(node.versionGeneration,
    '.',
    node.VersionMajor,
    '.',
    node.versionMinor) AS os_version,
    node.owner AS OWNER,
    node.location AS location,
    node.productType AS product_type,
    node.isFailoverEnabled AS failover_enabled,
    node.isTakeOverPossible AS takeover_possible,
    node.failoverState AS failover_state,
    node.memorySizeMb AS memory_size_mb,
    IF(ISNULL(node_flash_device_count_table.flash_device_count),
    0,
    node_flash_device_count_table.flash_device_count) AS flash_device_count,
    node.isAllFlashOptimized AS is_flash_optimized    
FROM
    netapp_model_view.node node    
INNER JOIN
    netapp_model_view.vserver vserver                                    
        ON vserver.name = node.name                                    
        AND vserver.typeRaw = 'node'                                    
        AND vserver.clusterId = node.clusterId    
LEFT JOIN
    netapp_model_view.network_lif lif                                    
        ON lif.roleRaw = 'node_mgmt'                                    
        AND lif.vserverId = vserver.objId    
LEFT JOIN
    (
        SELECT
            COUNT(flash_device.objId) AS flash_device_count,
            node.objId AS node_id                                    
        FROM
            netapp_model_view.flash_device flash_device,
            netapp_model_view.node node                                    
        WHERE
            node.objId = flash_device.nodeId                                    
        GROUP BY
            flash_device.nodeId                    
    ) node_flash_device_count_table                                    
        ON node.objId = node_flash_device_count_table.node_id    
GROUP BY
    node.objid 