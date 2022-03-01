--QA_VISIT_OCCURRENCE_NULLFK_COUNT
---------------------------------------------------------------------

WITH NULLFK_COUNT AS (
	SELECT 'PERSON_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_OCCURRENCE')}} AS T1
	WHERE (PERSON_ID IS NULL)
UNION ALL
	SELECT 'PROVIDER_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_OCCURRENCE')}}  AS T1
	WHERE (PROVIDER_ID IS NULL)
UNION ALL
	SELECT 'CARE_SITE_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_OCCURRENCE')}}  AS T1
	WHERE (VISIT_SOURCE_CONCEPT_ID IS NULL)
UNION ALL
	SELECT 'PRECEDING_VISIT_OCCURRENCE_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('VISIT_OCCURRENCE')}}  AS T1
	WHERE (PRECEDING_VISIT_OCCURRENCE_ID IS NULL)
)
	
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('VISIT_OCCURRENCE')}} ) AS TOTAL_RECORDS
FROM NULLFK_COUNT
GROUP BY   METRIC_FIELD, QA_METRIC, ERROR_TYPE
