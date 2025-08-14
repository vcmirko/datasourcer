SELECT
    cp.objid AS id,
    cp.clusterId AS primary_cluster_id,
    cp.remoteClusterId AS peer_cluster_id,
    cp.remoteClusterUUID AS cluster_uuid,
    cp.peerAddresses AS peer_addresses,
    cp.availability AS availability,
    cp.activeAddresses AS active_addresses,
    cp.serialNumber AS serial_number,
    cp.remoteClusterNodes AS remote_cluster_nodes,
    cp.isClusterHealthy AS is_cluster_healthy,
    cp.unreachableLocalNodes AS unreachable_local_nodes,
    cp.addressFamily AS address_family,
    cp.authStatusAdmin AS auth_status_admin,
    cp.authStatusOperational AS auth_status_operational,
    nis.objid AS ipspace_id      
FROM
    netapp_model_view.cluster_peer cp      
LEFT JOIN
    netapp_model_view.network_ip_space nis                                                      
        ON cp.networkIpSpaceId = nis.objid      
WHERE
    cp.remoteClusterId IS NOT NULL