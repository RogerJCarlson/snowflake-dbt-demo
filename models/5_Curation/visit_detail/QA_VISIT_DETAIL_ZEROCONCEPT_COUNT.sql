------ QA_VISIT_DETAIL_ZEROCONCEPT_COUNT
--------------------------------------------------------------------- 
WITH ZEROCONCEPT_COUNT AS (
	SELECT 'VISIT_DETAIL_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_DETAIL')}}  AS T1
	WHERE (VISIT_DETAIL_CONCEPT_ID = 0)
UNION ALL
	SELECT 'VISIT_DETAIL_TYPE_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_DETAIL')}}  AS T1
	WHERE (VISIT_DETAIL_TYPE_CONCEPT_ID = 0)
UNION ALL
	SELECT 'VISIT_DETAIL_SOURCE_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_DETAIL')}}  AS T1
	WHERE (VISIT_DETAIL_SOURCE_CONCEPT_ID = 0)
UNION ALL
	SELECT 'ADMITTING_SOURCE_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (ADMITTING_SOURCE_CONCEPT_ID = 0)
UNION ALL
	SELECT 'DISCHARGE_TO_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (DISCHARGE_TO_CONCEPT_ID = 0) AND DISCHARGE_TO_SOURCE_VALUE IS NULL
UNION ALL
		SELECT 'DISCHARGE_TO_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (DISCHARGE_TO_CONCEPT_ID = 0) AND DISCHARGE_TO_SOURCE_VALUE IS NOT NULL
)
	
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_DETAIL' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('VISIT_DETAIL')}}) AS TOTAL_RECORDS
FROM ZEROCONCEPT_COUNT
GROUP BY  METRIC_FIELD, QA_METRIC, ERROR_TYPE

