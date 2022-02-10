USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_OBSERVATION_DATEVDATETIME_COUNT AS (
---------------------------------------------------------------------
--OBSERVATION_DATEVDATETIME_COUNT
---------------------------------------------------------------------
WITH DATEVDATETIME_DETAIL AS (
SELECT 'NOTE_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	NOTE_ID AS CDT_ID
FROM CDM.NOTE AS T1
WHERE NOTE_DATE <> CAST( NOTE_DATETIME AS DATE)
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'NOTE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM DATEVDATETIME_DETAIL		
);
