--QA_PROCEDURE_OCCURRENCE_DATEVDATETIME_COUNT
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH DATEVDATETIME_COUNT AS (
SELECT 'PROCEDURE_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	SUM(CASE WHEN (PROCEDURE_DATE <> CAST(PROCEDURE_DATETIME AS DATE)) THEN 1 ELSE 0 END) AS CNT
FROM {{ref('PROCEDURE_OCCURRENCE')}} AS T1
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'PROCEDURE_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('PROCEDURE_OCCURRENCE')}}) AS TOTAL_RECORDS
FROM DATEVDATETIME_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
