SELECT
    export_policy.objId AS id,
    export_policy.name AS name,
    export_policy.vserverId AS vserver_id    
FROM
    netapp_model_view.export_policy export_policy 