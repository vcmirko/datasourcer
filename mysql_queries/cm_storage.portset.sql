SELECT
    portset.objId AS id,
    portset.name AS name,
    LOWER(portset.type) AS type,
    portset.vserverId AS vserver_id    
FROM
    netapp_model_view.portset 