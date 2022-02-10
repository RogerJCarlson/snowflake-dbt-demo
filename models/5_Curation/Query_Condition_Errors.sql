--Query_Condition_Errors

{{ config(materialized = 'view') }}

SELECT
    QA_ERR.RUN_DATE
    , QA_ERR.STANDARD_DATA_TABLE
    , QA_ERR.QA_METRIC
    , QA_ERR.METRIC_FIELD
    , QA_ERR.ERROR_TYPE
    , CONDITION_OCCURRENCE.*
FROM
    {{ref('QA_ERR')}} AS QA_ERR
INNER JOIN {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE ON
    QA_ERR.CDT_ID = CONDITION_OCCURRENCE.CONDITION_OCCURRENCE_ID
    AND QA_ERR.CDT_ID = CONDITION_OCCURRENCE.CONDITION_OCCURRENCE_ID
WHERE
    QA_ERR.STANDARD_DATA_TABLE = 'CONDITION_OCCURRENCE'