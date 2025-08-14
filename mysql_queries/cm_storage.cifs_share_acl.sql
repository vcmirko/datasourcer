SELECT
    acl.objId AS id,
    acl.cifsShareId AS cifs_share_id,
    acl.userOrGroup AS user_or_group,
    acl.permission AS access_level    
FROM
    netapp_model_view.cifs_share_acl AS acl,
    netapp_model_view.cifs_share AS cifs    
WHERE
    acl.cifsShareId = cifs.objid