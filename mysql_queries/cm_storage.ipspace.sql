SELECT
    ipspace.objId AS id,
    ipspace.name AS name,
    ipspace.clusterId AS cluster_id    
FROM
    netapp_model_view.network_ip_space ipspace 