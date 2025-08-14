SELECT
    pool.id AS id,
    pool.name AS NAME,
    pool.description AS description,
    pool.resourceKey AS UUID    
FROM
    ocum_view.resource_pool pool