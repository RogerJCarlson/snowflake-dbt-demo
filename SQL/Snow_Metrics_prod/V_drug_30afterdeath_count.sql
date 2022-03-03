USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_DRUG_30AFTERDEATH_COUNT;
CREATE OR REPLACE VIEW OMOP_QA.V_DRUG_30AFTERDEATH_COUNT AS (
-------------------------------------------------------------------
----DRUG_30AFTERDEATH_COUNT
-------------------------------------------------------------------
WITH DRUG30AFTERDEATH_COUNT AS (
SELECT 'DRUG_EXPOSURE_START_DATE' AS METRIC_FIELD, '30AFTERDEATH' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, 
	SUM(CASE WHEN (DATEDIFF(DAY, DEATH_DATE, DRUG_EXPOSURE_START_DATE) > 30) THEN 1 ELSE 0 END) AS CNT
FROM CDM.DRUG_EXPOSURE AS T1
INNER JOIN CDM.DEATH AS T2
	ON T1.PERSON_ID = T2.PERSON_ID
WHERE DATEDIFF(DAY, DEATH_DATE, DRUG_EXPOSURE_START_DATE) > 30
)
--	
--INSERT INTO OMOP_QA.QA_LOG   (    
--	RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,QA_ERRORS
--    ,ERROR_TYPE
--	,TOTAL_RECORDS)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.DRUG_EXPOSURE) AS TOTAL_RECORDS
FROM DRUG30AFTERDEATH_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
