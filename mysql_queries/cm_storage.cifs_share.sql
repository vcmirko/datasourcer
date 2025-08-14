SELECT
    cifs_share.objId AS id,
    cifs_share.name AS NAME,
    cifs_share.path AS path,
    cifs_share.vserverId AS vserver_id,
    cifs_share.comment AS COMMENT,
    cifs_share.shareProperties AS share_properties    
FROM
    netapp_model_view.cifs_share