USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_NOTE_NULLFK_DETAIL AS (
---------------------------------------------------------------------
--NOTE_NULLFK_DETAIL
---------------------------------------------------------------------
WITH NULLFK_DETAIL
AS (
	SELECT 'PROVIDER_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE
	WHERE (PROVIDER_ID IS NULL)
	
	UNION ALL
	
	SELECT 'VISIT_OCCURRENCE_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE
	WHERE (VISIT_OCCURRENCE_ID IS NULL)
	
	UNION ALL
	
	SELECT 'PERSON_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE
	WHERE (PERSON_ID IS NULL)
	)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'NOTE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLFK_DETAIL
  WHERE ERROR_TYPE <>'EXPECTED'
);
