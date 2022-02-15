USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_NOTE_NOMATCH_DETAIL AS (
---------------------------------------------------------------------
--NOTE_NOMATCH_DETAIL
---------------------------------------------------------------------
WITH NOMATCH_DETAIL
AS (
	SELECT 'NOTE_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NO-MATCH' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE AS NT
	LEFT JOIN CDM.CONCEPT AS C
		ON NT.NOTE_TYPE_CONCEPT_ID = C.CONCEPT_ID
	WHERE NOTE_TYPE_CONCEPT_ID <> 0 AND CONCEPT_ID IS NULL
	
	UNION ALL
	
	SELECT 'NOTE_CLASS_CONCEPT_ID' AS METRIC_FIELD, 'NO-MATCH' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE AS NT
	LEFT JOIN CDM.CONCEPT AS C
		ON NT.NOTE_CLASS_CONCEPT_ID = C.CONCEPT_ID
	WHERE NOTE_CLASS_CONCEPT_ID <> 0 AND CONCEPT_ID IS NULL
	
	UNION ALL
	
	SELECT 'ENCODING_CONCEPT_ID' AS METRIC_FIELD, 'NO-MATCH' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE AS NT
	LEFT JOIN CDM.CONCEPT AS C
		ON NT.ENCODING_CONCEPT_ID = C.CONCEPT_ID
	WHERE ENCODING_CONCEPT_ID <> 0 AND CONCEPT_ID IS NULL
	
	UNION ALL
	
	SELECT 'LANGUAGE_CONCEPT_ID' AS METRIC_FIELD, 'NO-MATCH' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, NOTE_ID AS CDT_ID
	FROM CDM.NOTE AS NT
	LEFT JOIN CDM.CONCEPT AS C
		ON NT.LANGUAGE_CONCEPT_ID = C.CONCEPT_ID
	WHERE LANGUAGE_CONCEPT_ID <> 0 AND CONCEPT_ID IS NULL
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
FROM NOMATCH_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'
);