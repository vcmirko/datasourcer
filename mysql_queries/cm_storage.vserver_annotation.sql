SELECT
    NULL AS id,
    vserver.objid AS vserver_id,
    annotationresourceobjectview.annotationId AS annotation_id   
FROM
    netapp_model_view.vserver AS vserver   
INNER JOIN
    ocum_view.annotationresourceobjectview AS annotationresourceobjectview                           
        ON annotationresourceobjectview.resourceId = vserver.objid