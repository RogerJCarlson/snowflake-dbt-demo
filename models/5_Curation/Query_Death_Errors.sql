--Query_Death_Errors

{{ config(materialized = 'view', schema='OMOP_QA') }}

SELECT
    QA_ERR_DBT.RUN_DATE
    , QA_ERR_DBT.STANDARD_DATA_TABLE
    , QA_ERR_DBT.QA_METRIC
    , QA_ERR_DBT.METRIC_FIELD
    , QA_ERR_DBT.ERROR_TYPE
    , DEATH.*
FROM
    {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
INNER JOIN {{ref('DEATH')}} AS DEATH ON
    QA_ERR_DBT.CDT_ID = DEATH.PERSON_ID
WHERE
    QA_ERR_DBT.STANDARD_DATA_TABLE = 'DEATH'


