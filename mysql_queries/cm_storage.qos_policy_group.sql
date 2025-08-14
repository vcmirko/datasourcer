SELECT
    qos.objid AS id,
    qos.policyGroup AS name,
    qos.vserverId AS vserver_id,
    qos.policyGroupClass AS class,
    qos.maxThroughput AS max_throughput_limit,
    qos.minThroughput AS min_throughput_limit,
    qos.isAdaptive AS isAdaptive,
    qos.minIOPsAllocation AS min_iops_allocation,
    qos.allocation AS peak_iops_allocation,
    qos.isShared AS is_shared       
FROM
    netapp_model_view.qos_policy_group qos     
WHERE
    (
        qos.policyGroupClass='USER_DEFINED'                                                      
        OR qos.isAdaptive='1'                              
    )