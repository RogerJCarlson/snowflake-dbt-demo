USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_PROCEDURE_OCCURRENCE_ZEROCONCEPT_DETAIL;
CREATE OR REPLACE VIEW OMOP_QA.V_PROCEDURE_OCCURRENCE_ZEROCONCEPT_DETAIL AS (
--------------------------------------------------------------------- 
------ PROCEDURE_OCCURRENCE_ZEROCONCEPT_DETAIL
---------------------------------------------------------------------
WITH ZEROCONCEPT_DETAIL
AS (
	SELECT 'PROCEDURE_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, PROCEDURE_OCCURRENCE_ID AS CDT_ID
	FROM CDM.PROCEDURE_OCCURRENCE
	WHERE (PROCEDURE_CONCEPT_ID = 0)
	
	UNION ALL
	
	SELECT 'PROCEDURE_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, PROCEDURE_OCCURRENCE_ID AS CDT_ID
	FROM CDM.PROCEDURE_OCCURRENCE
	WHERE (PROCEDURE_TYPE_CONCEPT_ID = 0)
	
	UNION ALL
	
	--MODIFIER_CONCEPT_ID
	--IF THERE IS A VALUE IN 'MODIFIER_SOURCE_VALUE' THERE SHOULD NOT BE A ZERO IN 'MODIFIER_CONCEPT_ID'
	SELECT 'MODIFIER_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, PROCEDURE_OCCURRENCE_ID AS CDT_ID
	FROM CDM.PROCEDURE_OCCURRENCE
	WHERE (MODIFIER_CONCEPT_ID = 0 AND MODIFIER_SOURCE_VALUE IS NOT NULL)
	
	UNION ALL
	
	--MODIFIER_CONCEPT_ID
	--IF THERE IS NOT A VALUE IN 'MODIFIER_SOURCE_VALUE' THERE SHOULD BE A ZERO IN 'MODIFIER_CONCEPT_ID'
	SELECT 'MODIFIER_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE
		, PROCEDURE_OCCURRENCE_ID AS CDT_ID
	FROM CDM.PROCEDURE_OCCURRENCE
	WHERE (MODIFIER_CONCEPT_ID = 0 AND MODIFIER_SOURCE_VALUE IS NULL)
	
	UNION ALL
	
	SELECT 'PROCEDURE_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, PROCEDURE_OCCURRENCE_ID AS CDT_ID
	FROM CDM.PROCEDURE_OCCURRENCE
	WHERE (PROCEDURE_SOURCE_CONCEPT_ID = 0)
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'PROCEDURE_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM ZEROCONCEPT_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
 );
 