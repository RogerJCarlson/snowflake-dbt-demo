----QA_MEASUREMENT_30AFTERDEATH_COUNT
-------------------------------------------------------------------

{{ config(materialized = 'view') }}


WITH MEASUREMENT30AFTERDEATH_COUNT AS (
SELECT 'MEASUREMENT_DATE' AS METRIC_FIELD, '30AFTERDEATH' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, 
	SUM(CASE WHEN (DATEDIFF(DAY, DEATH_DATE, MEASUREMENT_DATE) > 30) THEN 1 ELSE 0 END) AS CNT
FROM {{ref('MEASUREMENT')}} AS T1
INNER JOIN {{ref('DEATH')}} AS T2
	ON T1.PERSON_ID = T2.PERSON_ID
)
	
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('MEASUREMENT')}}) AS TOTAL_RECORDS
FROM MEASUREMENT30AFTERDEATH_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE

