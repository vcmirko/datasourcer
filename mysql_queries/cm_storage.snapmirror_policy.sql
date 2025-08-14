SELECT
    snapmirror_policy.objid AS id,
    snapmirror_policy.name AS NAME,
    snapmirror_policy.vserverId AS vserver_id,
    snapmirror_policy.comment AS comment,
    snapmirror_policy.transferPriorityRaw AS transfer_priority,
    snapmirror_policy.restartRaw AS restart,
    snapmirror_policy.tries AS tries,
    snapmirror_policy.ignoreAccessTime AS ignore_atime,
    snapmirror_policy.type AS type    
FROM
    netapp_model_view.snap_mirror_policy snapmirror_policy