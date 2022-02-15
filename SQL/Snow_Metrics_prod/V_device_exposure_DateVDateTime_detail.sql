USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_DEVICE_EXPOSURE_DATEVDATETIME_DETAIL AS (
---------------------------------------------------------------------
--DEVICE_EXPOSURE_DATEVDATETIME_DETAIL
---------------------------------------------------------------------
WITH DATEVDATETIME_DETAIL AS (
SELECT 'DEVICE_EXPOSURE_START_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	DEVICE_EXPOSURE_ID AS CDT_ID
FROM CDM.DEVICE_EXPOSURE AS T1
WHERE DEVICE_EXPOSURE_START_DATE <> CAST(DEVICE_EXPOSURE_START_DATETIME AS DATE)

UNION ALL

SELECT 'DEVICE_EXPOSURE_END_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	 DEVICE_EXPOSURE_ID AS CDT_ID
FROM CDM.DEVICE_EXPOSURE AS T1
WHERE DEVICE_EXPOSURE_END_DATE <> CAST(DEVICE_EXPOSURE_END_DATETIME AS DATE)
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM DATEVDATETIME_DETAIL
);