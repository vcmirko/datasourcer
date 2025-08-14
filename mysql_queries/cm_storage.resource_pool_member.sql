SELECT
    NULL AS id,
    pool_aggregates.resourcePool_Id AS resource_pool_id,
    pool_aggregates.aggregate_id AS aggregate_id      
FROM
    ocum_view.resource_pool_aggregates pool_aggregates