SELECT
    snapshot_policy_schedule.objid AS id,
    snapshot_policy_schedule.jobScheduleId AS schedule_id,
    snapshot_policy_schedule.count AS snapshot_count,
    snapshot_policy_schedule.prefix AS snapshot_prefix,
    snapshot_policy_schedule.snapMirrorLabel AS snapmirror_label,
    snapshot_policy_schedule.snapshotPolicyId AS snapshot_policy_id    
FROM
    netapp_model_view.snapshot_policy_schedule snapshot_policy_schedule    
WHERE
    snapshot_policy_schedule.jobScheduleId IS NOT NULL