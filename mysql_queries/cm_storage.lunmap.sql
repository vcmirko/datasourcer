SELECT
    lun_map.objId AS id,
    lun_map.lunId AS lun_id,
    lun_map.igroupId AS igroup_id,
    lun_map.lun AS lun_map_value    
FROM
    netapp_model_view.lun_map lun_map 