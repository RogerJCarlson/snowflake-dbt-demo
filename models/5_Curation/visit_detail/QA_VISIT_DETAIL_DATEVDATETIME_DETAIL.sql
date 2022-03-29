--QA_VISIT_DETAIL_DATEVDATETIME_DETAIL
---------------------------------------------------------------------
WITH DATEVDATETIME_DETAIL AS (
SELECT 'VISIT_START_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	VISIT_DETAIL_ID AS CDT_ID
FROM {{ref('VISIT_DETAIL')}} AS T1
WHERE VISIT_DETAIL_START_DATE <> CAST(VISIT_DETAIL_START_DATETIME AS DATE)

UNION ALL

SELECT 'VISIT_DETAIL_END_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	VISIT_DETAIL_ID AS CDT_ID
FROM {{ref('VISIT_DETAIL')}} AS T1
WHERE VISIT_DETAIL_END_DATE <> CAST(VISIT_DETAIL_START_DATETIME AS DATE)
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_DETAIL' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM DATEVDATETIME_DETAIL		
