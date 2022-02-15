USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_MEASUREMENT_NONSTANDARD_DETAIL;
CREATE OR REPLACE VIEW OMOP_QA.V_MEASUREMENT_NONSTANDARD_DETAIL AS (

-------------------------------------------------------------------
----MEASUREMENT_NONSTANDARD_DETAIL
-------------------------------------------------------------------
WITH NONSTANDARD_DETAIL
AS (
	SELECT 'MEASUREMENT_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT AS M
	LEFT JOIN CDM.CONCEPT AS C
		ON M.MEASUREMENT_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'MEASUREMENT' AND upper(C.VOCABULARY_ID) IN  ('LOINC', 'SNOMED')
	WHERE MEASUREMENT_CONCEPT_ID <> 0 AND MEASUREMENT_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'MEASUREMENT_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT AS M
	LEFT JOIN CDM.CONCEPT AS C
		ON M.MEASUREMENT_TYPE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'TYPE CONCEPT' AND upper(C.VOCABULARY_ID) IN  ('TYPE CONCEPT')
	WHERE MEASUREMENT_TYPE_CONCEPT_ID <> 0 AND MEASUREMENT_TYPE_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'OPERATOR_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT AS M
	LEFT JOIN CDM.CONCEPT AS C
		ON M.OPERATOR_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'MEAS VALUE OPERATOR'
	WHERE OPERATOR_CONCEPT_ID <> 0 AND OPERATOR_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT AS M
	LEFT JOIN CDM.CONCEPT AS C
		ON M.VALUE_AS_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'MEAS VALUE' AND upper(C.VOCABULARY_ID) IN  ('LOINC', 'SNOMED')
	WHERE VALUE_AS_CONCEPT_ID <> 0 AND VALUE_AS_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT AS M
	LEFT JOIN CDM.CONCEPT AS C
		ON M.UNIT_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'UNIT'
	WHERE UNIT_CONCEPT_ID <> 0 AND UNIT_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'MEASUREMENT_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT AS M
	LEFT JOIN CDM.CONCEPT AS C
		ON M.MEASUREMENT_SOURCE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'MEASUREMENT' AND upper(C.VOCABULARY_ID) IN  ('LOINC', 'SNOMED')
	WHERE MEASUREMENT_SOURCE_CONCEPT_ID <> 0 AND C.CONCEPT_ID IS NULL
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NONSTANDARD_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
);