
------QA_CONDITION_OCCURRENCE_NULLCONCEPT_DETAIL
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH NULLCONCEPT_DETAIL
AS (
	SELECT 'CONDITION_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		,CONDITION_OCCURRENCE_ID AS CDT_ID
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'CONDITION_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		,CONDITION_OCCURRENCE_ID AS CDT_ID
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_TYPE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'CONDITION_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		,CONDITION_OCCURRENCE_ID AS CDT_ID
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_SOURCE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'CONDITION_STATUS_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		,CONDITION_OCCURRENCE_ID AS CDT_ID
	FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE 
	WHERE (CONDITION_STATUS_CONCEPT_ID IS NULL)
	)

SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'CONDITION_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLCONCEPT_DETAIL	
  WHERE ERROR_TYPE <>'EXPECTED'	

 