USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_VISIT_OCCURRENCE_ZEROCONCEPT_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_VISIT_OCCURRENCE_ZEROCONCEPT_COUNT AS (
---------------------------------------------------------------------
------ VISIT_OCCURRENCE ZERO CONCEPT WARNING ------------------------
--------------------------------------------------------------------- 
------ VISIT_OCCURRENCE_ZEROCONCEPT_COUNT
--------------------------------------------------------------------- 
WITH ZEROCONCEPT_COUNT AS (
	SELECT 'VISIT_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (VISIT_CONCEPT_ID = 0)
UNION ALL
	SELECT 'VISIT_TYPE_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (VISIT_TYPE_CONCEPT_ID = 0)
UNION ALL
	SELECT 'VISIT_SOURCE_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (VISIT_SOURCE_CONCEPT_ID = 0)
UNION ALL
	SELECT 'ADMITTING_SOURCE_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.VISIT_OCCURRENCE
	WHERE (ADMITTING_SOURCE_CONCEPT_ID = 0)
UNION ALL
	SELECT 'DISCHARGE_TO_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (DISCHARGE_TO_CONCEPT_ID = 0) AND DISCHARGE_TO_SOURCE_VALUE IS NULL
UNION ALL
		SELECT 'DISCHARGE_TO_CONCEPT_ID' AS METRIC_FIELD,'ZERO CONCEPT' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (DISCHARGE_TO_CONCEPT_ID = 0) AND DISCHARGE_TO_SOURCE_VALUE IS NOT NULL
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
	,'VISIT_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.VISIT_OCCURRENCE) AS TOTAL_RECORDS
FROM ZEROCONCEPT_COUNT
GROUP BY  METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
