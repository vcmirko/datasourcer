SELECT
    vserver_to_aggregate.objId AS id,
    vserver_to_aggregate.aggregateId AS aggregate_id,
    vserver_to_aggregate.vserverId AS vserver_id    
FROM
    netapp_model_view.vserver_to_aggregate vserver_to_aggregate 