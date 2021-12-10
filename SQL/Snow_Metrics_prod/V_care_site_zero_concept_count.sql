USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


--DROP VIEW CDM.V_CARE_SITE_ZERO_CONCEPT_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_CARE_SITE_ZERO_CONCEPT_COUNT AS (
---------------------------------------------------------------------
--CARE_SITE_ZERO_CONCEPT_COUNT
---------------------------------------------------------------------
WITH CTE_ZERO_CONCEPT_COUNT AS (
	SELECT 'CARE_SITE' AS STANDARD_DATA_TABLE
		,'PLACE_OF_SERVICE_CONCEPT_ID' AS METRIC_FIELD
		,'ZERO CONCEPT' AS QA_METRIC
		,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM CDM.CARE_SITE 
	WHERE (PLACE_OF_SERVICE_CONCEPT_ID = 0 )
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
	,(SELECT COUNT(*) AS NUM_ROWS FROM CDM.CARE_SITE) AS TOTAL_RECORDS
FROM CTE_ZERO_CONCEPT_COUNT
GROUP BY STANDARD_DATA_TABLE, METRIC_FIELD, QA_METRIC, ERROR_TYPE
);