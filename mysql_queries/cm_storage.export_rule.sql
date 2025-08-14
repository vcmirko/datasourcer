SELECT
    export_rule.objId AS id,
    export_rule.clientMatch AS clientmatch,
    export_rule.exportPolicyId AS policy_id,
    export_rule.accessProtocol AS protocol,
    export_rule.roRule AS ro_rule,
    export_rule.ruleIndex AS rule_index,
    export_rule.rwRule AS rw_rule,
    export_rule.superUserSecurity AS super_user    
FROM
    netapp_model_view.export_rule export_rule 