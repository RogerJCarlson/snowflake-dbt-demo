--QA_VISIT_DETAIL_END_BEFORE_START_DETAIL
---------------------------------------------------------------------
WITH END_BEFORE_START_DETAIL AS (
SELECT 'VISIT_DETAIL_END_DATETIME' AS METRIC_FIELD, 'END_BEFORE_START' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, VISIT_DETAIL_ID AS CDT_ID
FROM {{ref('VISIT_DETAIL')}} 
WHERE VISIT_DETAIL_END_DATETIME < VISIT_DETAIL_START_DATETIME
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_DETAIL' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM END_BEFORE_START_DETAIL	

