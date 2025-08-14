SELECT
    qtree.objId AS id,
    qtree.name AS NAME,
    qtree.oplocks AS oplock_mode,
    IF (ISNULL(volume.junctionPath),
    CONCAT('/',
    volume.name,
    '/',
    qtree.name),
    CONCAT(volume.junctionPath,
    '/',
    qtree.name)) AS path,
    LOWER(qtree.securityStyle) AS security_style,
    qtree.volumeId AS volume_id,
    quota.diskLimit/1024 AS disk_limit_mb,
    quota.softDiskLimit/1024 AS disk_soft_limit_mb,
    quota.fileLimit AS files_limit,
    quota.softFileLimit AS soft_files_limit,
    quota.threshold/1024 AS threshold_mb,
    quota.diskUsed/1024 AS disk_used_mb    
FROM
    netapp_model_view.volume volume,
    netapp_model_view.qtree qtree    
LEFT JOIN
    netapp_model_view.qtree_quota quota                                    
        ON quota.qtreeId = qtree.objId    
WHERE
    volume.objId = qtree.volumeId