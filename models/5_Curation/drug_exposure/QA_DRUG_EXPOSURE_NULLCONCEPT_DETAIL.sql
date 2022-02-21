------ QA_DRUG_EXPOSURE_NULLCONCEPT_DETAIL
--------------------------------------------------------------------- 

{{ config(materialized = 'view') }}

WITH NULLCONCEPT_DETAIL
AS (
	SELECT 'DRUG_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE
	WHERE (DRUG_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'DRUG_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE
	WHERE (DRUG_TYPE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'ROUTE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE
	WHERE (ROUTE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'DRUG_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE
	WHERE (DRUG_SOURCE_CONCEPT_ID IS NULL)
	)

SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLCONCEPT_DETAIL
  WHERE ERROR_TYPE <>'EXPECTED'	

 