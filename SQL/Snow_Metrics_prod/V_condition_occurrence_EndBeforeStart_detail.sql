USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_CONDITION_OCCURRENCE_END_BEFORE_START_DETAIL AS (
---------------------------------------------------------------------
--CONDITION_OCCURRENCE_END_BEFORE_START_DETAIL
---------------------------------------------------------------------
WITH END_BEFORE_START_DETAIL AS (
SELECT 'CONDITION_END_DATETIME' AS METRIC_FIELD, 'END_BEFORE_START' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, CONDITION_OCCURRENCE_ID AS CDT_ID
FROM CDM.CONDITION_OCCURRENCE 
WHERE CONDITION_END_DATETIME < CONDITION_START_DATETIME
)
--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'CONDITION_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM END_BEFORE_START_DETAIL		
);