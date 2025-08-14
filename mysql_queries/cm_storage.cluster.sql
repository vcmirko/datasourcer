SELECT
    cluster.objId AS id,
    vserver.objId AS admin_vserver_id,
    cluster.name AS NAME,
    cluster.location AS location,
    cluster.managementIp AS primary_address,
    cluster.uuid AS UUID,
    cluster.serialNumber AS serial_number,
    CONCAT(cluster.versionGeneration,
    '.',
    cluster.VersionMajor,
    '.',
    cluster.versionMinor) AS VERSION,
    cluster.isMetroCluster AS is_metrocluster,
    cluster.mtConfigurationStateRaw AS mt_configuration_state,
    cluster.mtModeRaw AS mt_mode,
	'' as source
FROM
    netapp_model_view.cluster cluster,
    netapp_model_view.vserver vserver    
WHERE
    vserver.clusterId = cluster.objId                    
    AND vserver.typeRaw = 'admin' 
