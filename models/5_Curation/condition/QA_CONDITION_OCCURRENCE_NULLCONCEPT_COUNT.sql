
------QA_CONDITION_OCCURRENCE_NULLCONCEPT_COUNT
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH NULLCONCEPT_COUNT
AS (
	SELECT 'CONDITION_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
	, COUNT(*) AS CNT
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'CONDITION_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
	, COUNT(*) AS CNT
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_TYPE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'CONDITION_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
	, COUNT(*) AS CNT
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_SOURCE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'CONDITION_STATUS_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
	, COUNT(*) AS CNT
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_STATUS_CONCEPT_ID IS NULL)
	)

SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'CONDITION_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.CONDITION_OCCURRENCE) AS TOTAL_RECORDS
FROM NULLCONCEPT_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE

