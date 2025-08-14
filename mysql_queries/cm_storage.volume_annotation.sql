SELECT
    NULL AS id,
    volume.objid AS volume_id,
    annotationresourceobjectview.annotationId AS annotation_id    
FROM
    netapp_model_view.volume AS volume    
INNER JOIN
    ocum_view.annotationresourceobjectview AS annotationresourceobjectview                                    
        ON annotationresourceobjectview.resourceId = volume.objid