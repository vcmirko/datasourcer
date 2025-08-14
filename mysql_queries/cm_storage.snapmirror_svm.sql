SELECT
    snapmirror.objId AS id,
    snapmirror.tries AS tries,
    snapmirror.relationshipTypeRaw AS TYPE,
    snapmirror.destinationVserverId AS destination_vserver_id,
    snapmirror.maxTransferRate AS max_transfer_rate,
    snapmirror.snapMirrorPolicyId AS snapmirror_policy_id,
    snapmirror.jobScheduleId AS schedule_id,
    snapmirror.mirrorStateRaw AS state,
    snapmirror.relationshipIdentifier AS relationship_identifier,
    vserver.objid AS source_vserver_id    
FROM
    netapp_model_view.snap_mirror snapmirror,
    netapp_model_view.vserver vserver,
    netapp_model_view.cluster cluster,
    netapp_model_view.vserver_peer peer    
where
    cluster.name = snapmirror.sourceCluster                    
    AND peer.peerVServerName = snapmirror.sourceVserver                    
    AND vserver.clusterId = cluster.objid                    
    AND snapmirror.destinationVserverId = peer.vServerId                    
    AND peer.peerVServerId= vserver.ObjId                    
    AND snapmirror.destinationVolumeId IS NULL                    
    AND snapmirror.sourceVolumeId IS NULL                    
    AND snapmirror.sourceVserver IS NOT NULL