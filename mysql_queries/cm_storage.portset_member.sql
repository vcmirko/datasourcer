SELECT
    portset_to_port.objId AS id,
    portset_to_port.portsetId AS portset_id,
    network_lif.objId AS logical_interface_id    
FROM
    netapp_model_view.portset_to_port,
    netapp_model_view.network_lif    
WHERE
    portset_to_port.clusterId=network_lif.clusterId                    
    AND portset_to_port.vserverId=network_lif.vserverId                    
    AND portset_to_port.portName=network_lif.name    
UNION
SELECT
    portset_to_port.objId AS id,
    portset_to_port.portsetId AS portset_id,
    fcp_lif.objId AS logical_interface_id    
FROM
    netapp_model_view.portset_to_port,
    netapp_model_view.fcp_lif    
WHERE
    portset_to_port.clusterId=fcp_lif.clusterId                    
    AND portset_to_port.vserverId=fcp_lif.vserverId                    
    AND portset_to_port.portName=fcp_lif.name