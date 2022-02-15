USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_OBSERVATION_NONSTANDARD_DETAIL;
CREATE OR REPLACE VIEW OMOP_QA.V_OBSERVATION_NONSTANDARD_DETAIL AS (

-------------------------------------------------------------------
----SPECIMEN NOT STANDARD ----------------------------------------
-------------------------------------------------------------------
----NONSTANDARD_DETAIL
-------------------------------------------------------------------
WITH NONSTANDARD_DETAIL
AS (
	SELECT 'OBSERVATION_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, OBSERVATION_ID AS CDT_ID
	FROM CDM.OBSERVATION AS OB
	LEFT JOIN CDM.CONCEPT AS C
		ON OB.OBSERVATION_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'OBSERVATION' 
	WHERE OBSERVATION_CONCEPT_ID <> 0 AND OBSERVATION_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'OBSERVATION_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, OBSERVATION_ID AS CDT_ID
	FROM CDM.OBSERVATION AS OB
	LEFT JOIN CDM.CONCEPT AS C
		ON OB.OBSERVATION_TYPE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'TYPE CONCEPT' AND upper(C.VOCABULARY_ID) =  ('TYPE CONCEPT')
	WHERE OBSERVATION_TYPE_CONCEPT_ID <> 0 AND OBSERVATION_TYPE_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, OBSERVATION_ID AS CDT_ID
	FROM CDM.OBSERVATION AS OB
	LEFT JOIN CDM.CONCEPT AS C
		ON OB.VALUE_AS_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'OBSERVATION'
	WHERE VALUE_AS_CONCEPT_ID <> 0 AND VALUE_AS_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'QUALIFIER_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, OBSERVATION_ID AS CDT_ID
	FROM CDM.OBSERVATION AS OB
	LEFT JOIN CDM.CONCEPT AS C
		ON OB.QUALIFIER_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'OBSERVATION' AND upper(C.CONCEPT_CLASS_ID) =  ('QUALIFIER VALUE')
	WHERE QUALIFIER_CONCEPT_ID <> 0 AND QUALIFIER_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, OBSERVATION_ID AS CDT_ID
	FROM CDM.OBSERVATION AS OB
	LEFT JOIN CDM.CONCEPT AS C
		ON OB.UNIT_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'UNIT'
	WHERE UNIT_CONCEPT_ID <> 0 AND UNIT_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'OBSERVATION_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE
		, OBSERVATION_ID AS CDT_ID
	FROM CDM.OBSERVATION AS OB
	LEFT JOIN CDM.CONCEPT AS C
		ON OB.OBSERVATION_SOURCE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'OBSERVATION' 
	WHERE OBSERVATION_SOURCE_CONCEPT_ID <> 0 AND C.CONCEPT_ID IS NULL
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'OBSERVATION' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NONSTANDARD_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
);