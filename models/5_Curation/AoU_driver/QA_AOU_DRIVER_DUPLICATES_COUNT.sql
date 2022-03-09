--QA_AOU_DRIVER_DUPLICATES_COUNT 
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH TMP_DUPES AS (
                
SELECT EPIC_PAT_ID,
        COUNT(*) AS CNT
                FROM {{ref('AOU_DRIVER')}} AS Tmp
                GROUP BY EPIC_PAT_ID
                HAVING Count(*) > 1
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
    , 'AOU_DRIVER' AS STANDARD_DATA_TABLE
    , 'DUPLICATE' AS QA_METRIC
    , 'RECORDS'  AS METRIC_FIELD
    , COALESCE(SUM(CNT),0) AS QA_ERRORS
    , CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
    , (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('AOU_DRIVER')}}) AS TOTAL_RECORDS
FROM TMP_DUPES
