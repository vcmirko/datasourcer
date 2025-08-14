SELECT
    network_lif_derived.objId AS id,
    network_lif_derived.vserverId AS vserver_id,
    lif.name AS NAME,
    lif.roleRaw AS role,
    network_lif_derived.homePortId AS home_port_id,
    network_lif_derived.currentPortId AS current_port_id,
    lif.operationalStatusRaw AS STATUS,
    network_lif_derived.address AS address,
    network_lif_derived.netmask AS netmask,
    lif.dataProtocols AS protocols,
    CASE                                    
        WHEN lif.failovergroupid is NULL THEN NULL                                    
        ELSE nfg.name                    
    END AS failover_group,
    network_lif_derived.failoverPolicyRaw AS failover_policy,
    NULL AS fcp_adapter_id,
    network_lif_derived.netmaskLength AS netmask_length,
    network_lif.isdnsupdateenabled AS is_dns_update_enabled,
    network_lif.listenfordnsquery AS listen_for_dns_query    
FROM
    netapp_model_view.network_lif_derived network_lif_derived,
    netapp_model_view.lif lif,
    netapp_model_view.network_lif network_lif,
    netapp_model_view.network_failover_group nfg    
WHERE
    network_lif_derived.uuid = lif.uuid                    
    AND network_lif_derived.vserverId = lif.vserverId                    
    AND network_lif.uuid = lif.uuid                    
    AND network_lif.vserverId = lif.vserverId                    
    AND (
        lif.failovergroupid is NULL                                    
        OR lif.failovergroupid = nfg.objid                    
    )    
UNION
SELECT
    fcp_lif.objId AS id,
    fcp_lif.vserverId AS vserver_id,
    lif.name AS NAME,
    lif.roleRaw AS role,
    NULL AS home_port_id,
    NULL AS current_port_id,
    lif.operationalStatusRaw AS STATUS,
    fcp_lif.portName AS address,
    NULL AS netmask,
    lif.dataProtocols AS protocols,
    CASE                                    
        WHEN lif.failovergroupid is NULL THEN NULL                                    
        ELSE nfg.name                    
    END AS failover_group,
    'disabled' AS failover_policy,
    fcp_lif.currentPortId AS fcp_adapter_id,
    NULL AS netmask_length,
    NULL AS is_dns_update_enabled,
    NULL AS listen_for_dns_query    
FROM
    netapp_model_view.fcp_lif_derived fcp_lif,
    netapp_model_view.lif lif,
    netapp_model_view.network_failover_group nfg    
WHERE
    fcp_lif.uuid = lif.uuid                    
    AND fcp_lif.vserverId = lif.vserverId                    
    AND (
        lif.failovergroupid is NULL                                    
        OR lif.failovergroupid = nfg.objid                    
    )