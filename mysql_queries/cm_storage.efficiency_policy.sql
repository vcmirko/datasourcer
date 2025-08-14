SELECT
    sis_policy.objid AS id,
    sis_policy.name AS NAME,
    sis_policy.vserverId AS vserver_id,
    sis_policy.jobScheduleId AS schedule_id,
    sis_policy.isEnabled AS enabled,
    sis_policy.comment AS comment,
    IF (sis_policy.duration IS NULL                    
    OR sis_policy.duration = '-',
    0,
    sis_policy.duration) AS duration,
    sis_policy.qosPolicyRaw AS qos_policy    
FROM
    netapp_model_view.sis_policy sis_policy