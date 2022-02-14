USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_SPECIMEN_DATEVDATETIME_COUNT AS (
---------------------------------------------------------------------
--SPECIMEN_DATEVDATETIME_COUNT
---------------------------------------------------------------------
WITH DATEVDATETIME_COUNT AS (
SELECT 'SPECIMEN_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	SUM(CASE WHEN (SPECIMEN_DATE <> CAST(SPECIMEN_DATETIME AS DATE)) THEN 1 ELSE 0 END) AS CNT
FROM CDM.SPECIMEN AS T1
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
	, 'SPECIMEN' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.SPECIMEN) AS TOTAL_RECORDS
FROM DATEVDATETIME_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
