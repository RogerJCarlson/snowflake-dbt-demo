--Query_Condition_Errors

{{ config(materialized = 'view', schema='OMOP_QA') }}

SELECT
    QA_ERR_DBT.RUN_DATE
    , QA_ERR_DBT.STANDARD_DATA_TABLE
    , QA_ERR_DBT.QA_METRIC
    , QA_ERR_DBT.METRIC_FIELD
    , QA_ERR_DBT.ERROR_TYPE
    , CONDITION_OCCURRENCE.*
FROM
    {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
INNER JOIN {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE ON
    QA_ERR_DBT.CDT_ID = CONDITION_OCCURRENCE.CONDITION_OCCURRENCE_ID
WHERE
    QA_ERR_DBT.STANDARD_DATA_TABLE = 'CONDITION_OCCURRENCE'