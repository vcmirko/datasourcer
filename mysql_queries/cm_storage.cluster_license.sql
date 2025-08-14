SELECT
    DISTINCT license.objId AS id,
    license.clusterId AS cluster_id,
    CASE license.package                                    
        WHEN 'snapmirror_dp' THEN 'snapmirror'                                    
        WHEN 'snapmanager_suite' THEN 'snapmanagersuite'                                    
        ELSE license.package                    
    END AS license    
FROM
    netapp_model_view.license license 