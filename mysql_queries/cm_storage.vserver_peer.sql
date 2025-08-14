SELECT
    vp.objid AS id,
    vp.vServerId AS vserver_id,
    vp.peerVServerId AS peer_vserver_id,
    vp.peerStateRaw AS peer_state,
    vp.applications AS applications,
    vp.peerVServerName AS peer_vserver_local_name    
FROM
    netapp_model_view.vserver_peer vp    
WHERE
    vp.peerVserverid IS NOT NULL