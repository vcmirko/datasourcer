SELECT
    port.objId AS id,
    port.name AS name,
    port.nodeId AS node_id,
    port.portTypeRaw AS type,
    port.roleRaw AS role,
    port.linkStatusRaw AS operational_status,
    port.mtu AS mtu,
    port.ifgrpPortId AS ifgrp_port_id,
    port.operationalSpeedRaw AS operational_speed,
    port.vlanIdentifier AS vlan_id,
    port.vlanPortId AS vlan_port_id,
    port.networkPortBroadcastDomainId AS broadcast_domain_id,
    port.healthStatusRaw AS health_status,
    port.ignoreHealthStatus AS ignore_health_status,
    port.healthDegradedReasonsRaw AS health_degraded_reasons    
FROM
    netapp_model_view.network_port port 