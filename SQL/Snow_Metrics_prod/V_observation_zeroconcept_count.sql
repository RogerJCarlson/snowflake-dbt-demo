USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_OBSERVATION_ZEROCONCEPT_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_OBSERVATION_ZEROCONCEPT_COUNT AS (
--------------------------------------------------------------------- 
------ OBSERVATION_ZEROCONCEPT_COUNT
---------------------------------------------------------------------
WITH ZEROCONCEPT_COUNT
AS (
	SELECT 'OBSERVATION_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (OBSERVATION_CONCEPT_ID = 0)
	
	UNION ALL
	
	SELECT 'OBSERVATION_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (OBSERVATION_TYPE_CONCEPT_ID = 0)
	
	UNION ALL
	
	--VALUE_AS_CONCEPT_ID
	--IF THERE IS A VALUE IN 'VALUE_AS_NUMBER' THERE SHOULD NOT BE A ZERO IN 'VALUE_AS_CONCEPT_ID'
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (VALUE_AS_CONCEPT_ID = 0 AND VALUE_AS_NUMBER IS NOT NULL)
	
	UNION ALL
	
	--VALUE_AS_CONCEPT_ID
	--IF THERE IS NOT A VALUE IN 'VALUE_AS_NUMBER' THERE SHOULD BE A ZERO IN 'VALUE_AS_CONCEPT_ID'
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (VALUE_AS_CONCEPT_ID = 0 AND VALUE_AS_NUMBER IS NULL)
	
	UNION ALL
	
	--QUALIFIER_CONCEPT_ID
	--IF THERE IS A VALUE IN 'UNIT_SOURCE_VALUE' THERE SHOULD NOT BE A ZERO IN 'QUALIFIER_CONCEPT_ID'
	SELECT 'QUALIFIER_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (QUALIFIER_CONCEPT_ID = 0 AND QUALIFIER_SOURCE_VALUE IS NOT NULL)
	
	UNION ALL
	
	--QUALIFIER_CONCEPT_ID
	--IF THERE IS NOT A VALUE IN 'UNIT_SOURCE_VALUE' THERE SHOULD BE A ZERO IN 'QUALIFIER_CONCEPT_ID'
	SELECT 'QUALIFIER_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (QUALIFIER_CONCEPT_ID = 0 AND QUALIFIER_SOURCE_VALUE IS NULL)
	
	UNION ALL
	
	--UNIT_CONCEPT_ID
	--IF THERE IS A VALUE IN 'UNIT_SOURCE_VALUE' THERE SHOULD NOT BE A ZERO IN 'UNIT_CONCEPT_ID'
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (UNIT_CONCEPT_ID = 0 AND UNIT_SOURCE_VALUE IS NOT NULL)
	
	UNION ALL
	
	--UNIT_CONCEPT_ID
	--IF THERE IS NOT A VALUE IN 'UNIT_SOURCE_VALUE' THERE SHOULD BE A ZERO IN 'UNIT_CONCEPT_ID'
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (UNIT_CONCEPT_ID = 0 AND UNIT_SOURCE_VALUE IS NULL)
	
	UNION ALL
	
	SELECT 'OBSERVATION_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.OBSERVATION
	WHERE (OBSERVATION_SOURCE_CONCEPT_ID = 0)
)
	
--INSERT INTO OMOP_QA.QA_LOG   (    
--	RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,QA_ERRORS
--    ,ERROR_TYPE
--	,TOTAL_RECORDS)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'OBSERVATION' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.OBSERVATION) AS TOTAL_RECORDS
FROM ZEROCONCEPT_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
