USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_VISIT_DATEVDATETIME_DETAIL AS (
---------------------------------------------------------------------
--VISIT_DATEVDATETIME_DETAIL
---------------------------------------------------------------------
WITH DATEVDATETIME_DETAIL AS (
SELECT 'VISIT_START_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	VISIT_OCCURRENCE_ID AS CDT_ID
FROM CDM.VISIT_OCCURRENCE AS T1
WHERE VISIT_START_DATE <> CAST(VISIT_START_DATETIME AS DATE)

UNION ALL

SELECT 'VISIT_END_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	VISIT_OCCURRENCE_ID AS CDT_ID
FROM CDM.VISIT_OCCURRENCE AS T1
WHERE VISIT_END_DATE <> CAST(VISIT_START_DATETIME AS DATE)
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM DATEVDATETIME_DETAIL	
);
