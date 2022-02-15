USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA OMOP;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_DEVICE_EXPOSURE_NULL_CONCEPT_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_DEVICE_EXPOSURE_NULL_CONCEPT_COUNT AS (
---------------------------------------------------------------------
--DEVICE_EXPOSURE_NULL_CONCEPT_COUNT
---------------------------------------------------------------------
WITH CTE_ERROR_COUNT AS (
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		,'DEVICE_CONCEPT_ID' AS METRIC_FIELD
		,'NULL CONCEPT' AS QA_METRIC
		,'FATAL' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.DEVICE_EXPOSURE 
	WHERE (DEVICE_CONCEPT_ID IS NULL)
	UNION ALL
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		,'DEVICE_TYPE_CONCEPT_ID' AS METRIC_FIELD
		,'NULL CONCEPT' AS QA_METRIC
		,'FATAL' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.DEVICE_EXPOSURE 
	WHERE (DEVICE_TYPE_CONCEPT_ID IS NULL)
	UNION ALL
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		,'DEVICE_SOURCE_CONCEPT_ID' AS METRIC_FIELD
		,'NULL CONCEPT' AS QA_METRIC
		,'FATAL' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.DEVICE_EXPOSURE
	WHERE (DEVICE_SOURCE_CONCEPT_ID IS NULL)
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
	, STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE	
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.DEVICE_EXPOSURE) AS TOTAL_RECORDS
FROM CTE_ERROR_COUNT
GROUP BY STANDARD_DATA_TABLE, METRIC_FIELD, QA_METRIC, ERROR_TYPE

);