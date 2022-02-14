USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_PROCEDURE_OCCURRENCE_NON_STANDARD_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_PROCEDURE_OCCURRENCE_NON_STANDARD_COUNT AS (

-------------------------------------------------------------------
----PROCEDURE_OCCURRENCE NON STANDARD -----------------------------
-------------------------------------------------------------------
----NONSTANDARD_COUNT
-------------------------------------------------------------------

WITH NONSTANDARD_COUNT
AS (
	SELECT 'PROCEDURE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.PROCEDURE_OCCURRENCE AS P
	LEFT JOIN CDM.CONCEPT AS C
		ON P.PROCEDURE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'PROCEDURE'
	WHERE PROCEDURE_CONCEPT_ID <> 0 AND PROCEDURE_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'PROCEDURE_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.PROCEDURE_OCCURRENCE AS P
	LEFT JOIN CDM.CONCEPT AS C
		ON P.PROCEDURE_TYPE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'TYPE CONCEPT' AND upper(C.VOCABULARY_ID) IN  ('TYPE CONCEPT')
	WHERE PROCEDURE_TYPE_CONCEPT_ID <> 0 AND PROCEDURE_TYPE_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'MODIFIER_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.PROCEDURE_OCCURRENCE AS P
	LEFT JOIN CDM.CONCEPT AS C
		ON P.MODIFIER_CONCEPT_ID = C.CONCEPT_ID AND upper(C.CONCEPT_CLASS_ID) IN ('CPT4 MODIFIER', 'HCPCS MODIFIER')
	WHERE MODIFIER_CONCEPT_ID <> 0 AND MODIFIER_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'PROCEDURE_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.PROCEDURE_OCCURRENCE AS P
	LEFT JOIN CDM.CONCEPT AS C
		ON P.PROCEDURE_SOURCE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'PROCEDURE'
	WHERE PROCEDURE_SOURCE_CONCEPT_ID <> 0 AND C.CONCEPT_ID IS NULL
)

--INSERT INTO OMOP_QA.QA_LOG   (    
--	RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	, METRIC_FIELD
--    ,QA_ERRORS
--    ,ERROR_TYPE
--	,TOTAL_RECORDS)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'PROCEDURE_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE (SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.PROCEDURE_OCCURRENCE) AS TOTAL_RECORDS
FROM NONSTANDARD_COUNT	
GROUP BY   METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
