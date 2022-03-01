--Query_Visit_Occurrence_Errors

SELECT
    QA_ERR.RUN_DATE
    , QA_ERR.STANDARD_DATA_TABLE
    , QA_ERR.QA_METRIC
    , QA_ERR.METRIC_FIELD
    , QA_ERR.ERROR_TYPE
    , VISIT_OCCURRENCE.*
FROM
    {{ref('QA_ERR')}} AS QA_ERR
INNER JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE ON
    QA_ERR.CDT_ID = VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID
    AND QA_ERR.CDT_ID = VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID
WHERE
    QA_ERR.STANDARD_DATA_TABLE = 'VISIT_OCCURRENCE'