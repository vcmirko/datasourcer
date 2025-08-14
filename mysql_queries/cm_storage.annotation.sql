SELECT
    annotation.id AS id,
    annotationtype.name AS name,
    annotation.name AS value    
FROM
    ocum_view.annotationtype AS annotationtype,
    ocum_view.annotation AS annotation    
WHERE
    annotation.type_id = annotationtype.id