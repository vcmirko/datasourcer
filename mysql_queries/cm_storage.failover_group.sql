SELECT
    failover_group.objId AS id,
    failover_group.name AS name,
    failover_group.clusterId AS cluster_id,
    failover_group.networkPortBroadcastDomainId AS broadcast_domain_id    
FROM
    netapp_model_view.network_failover_group failover_group;