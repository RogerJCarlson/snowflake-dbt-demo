------ QA_MEASUREMENT_NULLCONCEPT_DETAIL
--------------------------------------------------------------------- 

{{ config(materialized = 'view') }}

WITH NULLCONCEPT_DETAIL
AS (
	SELECT 'MEASUREMENT_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
	WHERE (MEASUREMENT_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'OPERATOR_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
	WHERE (OPERATOR_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
	WHERE (VALUE_AS_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
	WHERE (UNIT_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'MEASUREMENT_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
	WHERE (MEASUREMENT_SOURCE_CONCEPT_ID IS NULL)
)

SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLCONCEPT_DETAIL	
  WHERE ERROR_TYPE <>'EXPECTED'	
 
 