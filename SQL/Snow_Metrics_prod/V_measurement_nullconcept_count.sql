USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_MEASUREMENT_NULLCONCEPT_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_MEASUREMENT_NULLCONCEPT_COUNT AS (
---------------------------------------------------------------------
------ MEASUREMENT_NULLCONCEPT_COUNT
--------------------------------------------------------------------- 
WITH NULLCONCEPT_COUNT
AS (
	SELECT 'MEASUREMENT_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.MEASUREMENT
	WHERE (MEASUREMENT_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'OPERATOR_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.MEASUREMENT
	WHERE (OPERATOR_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.MEASUREMENT
	WHERE (VALUE_AS_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.MEASUREMENT
	WHERE (UNIT_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'MEASUREMENT_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.MEASUREMENT
	WHERE (MEASUREMENT_SOURCE_CONCEPT_ID IS NULL)
)
	
--INSERT INTO OMOP_QA.QA_LOG   (    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,QA_ERRORS
--    ,ERROR_TYPE
--	,TOTAL_RECORDS)

SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.MEASUREMENT) AS TOTAL_RECORDS
FROM NULLCONCEPT_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
