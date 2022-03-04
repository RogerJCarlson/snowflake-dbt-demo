------ QA_VISIT_OCCURRENCE_NULLCONCEPT_DETAIL
---------------------------------------------------------------------
WITH NULLCONCEPT_DETAIL AS (
	SELECT 'VISIT_DETAIL_CONCEPT_ID' AS METRIC_FIELD	,'NULL CONCEPT' AS QA_METRIC	,'FATAL' AS ERROR_TYPE
		,VISIT_DETAIL_ID AS CDT_ID
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (VISIT_DETAIL_CONCEPT_ID IS NULL)
UNION ALL
	SELECT 'VISIT_DETAIL_TYPE_CONCEPT_ID' AS METRIC_FIELD,'NULL CONCEPT' AS QA_METRIC,'FATAL' AS ERROR_TYPE
		,VISIT_DETAIL_ID AS CDT_ID
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (VISIT_DETAIL_TYPE_CONCEPT_ID IS NULL)
UNION ALL
	SELECT 'VISIT_DETAIL_SOURCE_CONCEPT_ID' AS METRIC_FIELD,'NULL CONCEPT' AS QA_METRIC,'FATAL' AS ERROR_TYPE
		,VISIT_DETAIL_ID AS CDT_ID
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (VISIT_DETAIL_SOURCE_CONCEPT_ID IS NULL)
UNION ALL
	SELECT 'ADMITTING_SOURCE_CONCEPT_ID' AS METRIC_FIELD,'NULL CONCEPT' AS QA_METRIC,'FATAL' AS ERROR_TYPE
		,VISIT_DETAIL_ID AS CDT_ID
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (ADMITTING_SOURCE_CONCEPT_ID IS NULL)
UNION ALL
	SELECT 'DISCHARGE_TO_CONCEPT_ID' AS METRIC_FIELD,'NULL CONCEPT' AS QA_METRIC,'FATAL' AS ERROR_TYPE
		,VISIT_DETAIL_ID AS CDT_ID
	FROM {{ref('VISIT_DETAIL')}} AS T1
	WHERE (DISCHARGE_TO_CONCEPT_ID IS NULL)
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_DETAIL' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLCONCEPT_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
 
 