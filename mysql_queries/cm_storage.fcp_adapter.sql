SELECT
    fcp_adapter.objid AS id,
    fcp_adapter.adapter AS name,
    fcp_adapter.nodeName AS world_wide_node_name,
    fcp_adapter.portName AS world_wide_port_name,
    fcp_adapter.maxSpeed AS max_speed,
    fcp_adapter.physicalProtocolRaw AS physical_protocol,
    fcp_adapter.mediaTypeRaw AS media_type,
    fcp_adapter.switchPort AS switch_port,
    fcp_adapter.stateRaw AS STATUS,
    fcp_adapter.nodeId AS node_id    
FROM
    netapp_model_view.fcp_port fcp_adapter