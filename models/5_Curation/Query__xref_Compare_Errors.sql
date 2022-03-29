--Query__xref_Compare_Errors

WITH SQRY_COUNT_DBT_ERRORS AS(
SELECT
    STANDARD_DATA_TABLE
    , QA_METRIC
    , METRIC_FIELD
    , ERROR_TYPE
    , QA_ERRORS AS SNOWFLAKE_DBT_ERRORS
    , TOTAL_RECORDS AS SNOWFLAKE_DBT_TOTAL
FROM
    SH_OMOP_DB_PROD.OMOP_QA.QA_LOG_DBT
WHERE
    ERROR_TYPE IS NOT NULL
ORDER BY
    STANDARD_DATA_TABLE)
,

SQRY_COUNT_SN_ERRORS AS(
SELECT
    STANDARD_DATA_TABLE
    , QA_METRIC
    , METRIC_FIELD
    , ERROR_TYPE
    , QA_ERRORS AS SNOWFLAKE_ERRORS
    , TOTAL_RECORDS AS SNOWFLAKE_TOTAL
FROM
    SH_OMOP_DB_PROD.OMOP_QA.QA_LOG
WHERE
    ERROR_TYPE IS NOT NULL
ORDER BY
    STANDARD_DATA_TABLE)

SELECT
    SQRY_COUNT_DBT_ERRORS.STANDARD_DATA_TABLE
    , SQRY_COUNT_DBT_ERRORS.QA_METRIC
    , SQRY_COUNT_DBT_ERRORS.METRIC_FIELD
    , SQRY_COUNT_DBT_ERRORS.ERROR_TYPE
    , SQRY_COUNT_DBT_ERRORS.SNOWFLAKE_DBT_ERRORS
    , SQRY_COUNT_DBT_ERRORS.SNOWFLAKE_DBT_TOTAL
    , CAST(SNOWFLAKE_ERRORS AS INT) AS SNOW_ERRORS
    , SQRY_COUNT_SN_ERRORS.SNOWFLAKE_TOTAL AS SNOW_TOTAL
FROM
    SQRY_COUNT_DBT_ERRORS
LEFT JOIN SQRY_COUNT_SN_ERRORS ON
    (SQRY_COUNT_DBT_ERRORS.METRIC_FIELD = SQRY_COUNT_SN_ERRORS.METRIC_FIELD)
    AND (SQRY_COUNT_DBT_ERRORS.QA_METRIC = SQRY_COUNT_SN_ERRORS.QA_METRIC)
    AND (SQRY_COUNT_DBT_ERRORS.STANDARD_DATA_TABLE = SQRY_COUNT_SN_ERRORS.STANDARD_DATA_TABLE)