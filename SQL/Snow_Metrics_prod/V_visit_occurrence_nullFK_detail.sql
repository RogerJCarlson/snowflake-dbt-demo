USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE VIEW OMOP_QA.V_VISIT_OCCURRENCE_NULLFK_DETAIL AS (
---------------------------------------------------------------------
--VISIT_OCCURRENCE_NULLFK_DETAIL
---------------------------------------------------------------------
WITH NULLFK_DETAIL AS (
	SELECT 'PERSON_ID' AS METRIC_FIELD	,'NULL FK' AS QA_METRIC	,'WARNING' AS ERROR_TYPE
		,VISIT_OCCURRENCE_ID AS CDT_ID
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (PERSON_ID IS NULL)
UNION ALL
	SELECT 'PROVIDER_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,VISIT_OCCURRENCE_ID AS CDT_ID
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (PROVIDER_ID IS NULL)
UNION ALL
	SELECT 'CARE_SITE_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'WARNING' AS ERROR_TYPE
		,VISIT_OCCURRENCE_ID AS CDT_ID
	FROM CDM.VISIT_OCCURRENCE AS T1
	WHERE (CARE_SITE_ID IS NULL)
UNION ALL
	SELECT 'PRECEDING_VISIT_OCCURRENCE_ID' AS METRIC_FIELD,'NULL FK' AS QA_METRIC,'EXPECTED' AS ERROR_TYPE
		,VISIT_OCCURRENCE_ID AS CDT_ID
	FROM CDM.VISIT_OCCURRENCE
	WHERE (PRECEDING_VISIT_OCCURRENCE_ID IS NULL)

)
--INSERT INTO OMOP_QA.QA_ERR(    
--	RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'VISIT_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLFK_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
);
