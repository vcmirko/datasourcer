SELECT
    NULL AS id,
    cluster.objid AS cluster_id,
    annotationresourceobjectview.annotationId AS annotation_id    
FROM
    netapp_model_view.cluster AS cluster    
INNER JOIN
    ocum_view.annotationresourceobjectview AS annotationresourceobjectview                                    
        ON annotationresourceobjectview.resourceId = cluster.objid