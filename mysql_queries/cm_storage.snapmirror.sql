SELECT
    snapmirror.objId AS id,
    snapmirror.destinationVolumeId AS secondary_volume_id,
    snapmirror.tries AS tries,
    snapmirror.relationshipTypeRaw AS TYPE,
    snapmirror.sourceVolumeId AS volume_id,
    snapmirror.maxTransferRate AS max_transfer_rate,
    snapmirror.snapMirrorPolicyId AS snapmirror_policy_id,
    snapmirror.jobScheduleId AS schedule_id,
    snapmirror.mirrorStateRaw AS state,
    snapmirror.relationshipIdentifier AS relationship_identifier,
    snapmirror.vserverSnapMirrorId AS vserver_snapmirror_id,    
    snapmirror.mirrorstate as mirror_state,
    snapmirror.relationshipstatus as relationship_status,
    snapmirror.lagtime as lag_time,
    snapmirror.policytype as policy_type,
    snapmirror.relationshiptype as  relationship_type 	
FROM
    netapp_model_view.snap_mirror snapmirror    
WHERE
    snapmirror.destinationVolumeId IS NOT NULL                    
