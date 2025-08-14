SELECT
    AOCM.objid AS id,
    AOCM.objectstoreId AS object_store_id,
    AOCM.aggregateId AS aggregate_id    
FROM
    netapp_model_view.aggregate_objectstore_config_mapping AOCM    
LEFT JOIN
    netapp_model_view.aggregate aggregate                                    
        ON aggregate.objid = AOCM.aggregateId    
LEFT JOIN
    netapp_model_view.objectstore_config OC                                    
        ON OC.objid = AOCM.objectstoreId