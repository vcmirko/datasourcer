SELECT
    OC.objid AS id,
    OC.clusterId AS cluster_id,
    OC.name AS name,
    OC.containerName AS container_name,
    OC.providerTypeRaw AS provider_type,
    OC.server AS server,
    OC.isSslEnabled AS is_ssl_enabled,
    NIS.objid AS ipspace_id    
FROM
    netapp_model_view.objectstore_config OC    
LEFT JOIN
    netapp_model_view.network_ip_space NIS                                    
        ON NIS.clusterId = OC.clusterId                                    
        AND NIS.name = OC.ipSpace