SELECT
    snapmirror_policy_rule.objid AS id,
    snapmirror_policy_rule.snapMirrorLabel AS snapmirror_label,
    snapmirror_policy_rule.snapMirrorPolicyId AS snapmirror_policy_id,
    snapmirror_policy_rule.keep AS keep,
    snapmirror_policy_rule.preserve AS preserve,
    snapmirror_policy_rule.warn AS warn    
FROM
    netapp_model_view.snap_mirror_policy_rule snapmirror_policy_rule