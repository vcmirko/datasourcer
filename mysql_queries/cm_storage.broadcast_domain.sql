SELECT
    broadcast_domain.objId AS id,
    broadcast_domain.name AS name,
    broadcast_domain.networkIpSpaceId AS ipspace_id,
    broadcast_domain.mtu AS mtu    
FROM
    netapp_model_view.network_port_broadcast_domain broadcast_domain