SELECT
    vserver_association.id AS id,
    vserver_association.sourceVserverId AS source_vserver_id,
    vserver_association.destinationVserverId AS destination_vserver_id,
    vserver_association.connectionType AS type,
    CONCAT(IF(vserver_association.sourceVserverId IS NULL,
    'any',
    source_vserver.uuid),
    '_',
    destination_vserver.uuid,
    '_',
    vserver_association.connectionType) AS uuid    
FROM
    ocum_view.vserver_destination vserver_association    
LEFT JOIN
    netapp_model_view.vserver source_vserver                                    
        ON source_vserver.objid = vserver_association.sourceVserverId,
    netapp_model_view.vserver destination_vserver    
WHERE
    destination_vserver.objid = vserver_association.destinationVserverId 