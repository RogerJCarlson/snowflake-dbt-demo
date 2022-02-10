USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_DRUG_EXPOSURE_END_BEFORE_START_DETAIL AS (
---------------------------------------------------------------------
--DRUG_EXPOSURE_END_BEFORE_START_DETAIL
---------------------------------------------------------------------
WITH END_BEFORE_START_DETAIL AS (
SELECT 'DRUG_EXPOSURE_END_DATE' AS METRIC_FIELD, 'END_BEFORE_START' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, DRUG_EXPOSURE_ID AS CDT_ID
FROM CDM.DRUG_EXPOSURE
WHERE DRUG_EXPOSURE_END_DATE < DRUG_EXPOSURE_START_DATE
	OR
	DRUG_EXPOSURE_END_DATETIME < DRUG_EXPOSURE_START_DATETIME
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM END_BEFORE_START_DETAIL		
);
