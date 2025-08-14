SELECT
    igroup.objId AS id,
    IF(COUNT(igroup_initiator.initiatorName) = 0,
    NULL,
    
LEFT(GROUP_CONCAT(igroup_initiator.initiatorName SEPARATOR ','),
1024)) AS initiators,
igroup.name AS name,
igroup.osType AS os_type,
portset_to_igroup.portsetId AS portset_id,
igroup.type AS protocol,
igroup.vserverId AS vserver_id FROM
    netapp_model_view.igroup igroup    
LEFT JOIN
    netapp_model_view.portset_to_igroup portset_to_igroup                                    
        ON portset_to_igroup.igroupId = igroup.objId    
LEFT JOIN
    netapp_model_view.igroup_initiator igroup_initiator                                    
        ON igroup.objId = igroup_initiator.igroupId    
GROUP BY
    igroup.objId