USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_MEASUREMENT_ZEROCONCEPT_DETAIL;
CREATE OR REPLACE VIEW OMOP_QA.V_MEASUREMENT_ZEROCONCEPT_DETAIL AS (
--------------------------------------------------------------------- 
------ MEASUREMENT_ZEROCONCEPT_DETAIL
--------------------------------------------------------------------- 
WITH ZEROCONCEPT_DETAIL
AS (
	SELECT 'MEASUREMENT_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT 
	WHERE (MEASUREMENT_CONCEPT_ID = 0)
	
	UNION ALL
	
	SELECT 'OPERATOR_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT
	WHERE (OPERATOR_CONCEPT_ID = 0)
	
	UNION ALL
	
	--IF THERE IS A VALUE IN 'VALUE_AS_NUMBER' THERE SHOULD BE A ZERO IN 'VALUE_AS_CONCEPT_ID'
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT
	WHERE (VALUE_AS_NUMBER IS NOT NULL AND VALUE_AS_CONCEPT_ID <> 0 )
	
	UNION ALL
	
	--IF THERE IS NOT A VALUE IN 'VALUE_AS_NUMBER' THERE SHOULD BE A ZERO IN 'VALUE_AS_CONCEPT_ID'
	SELECT 'VALUE_AS_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT
	WHERE (VALUE_AS_NUMBER IS NULL AND VALUE_AS_CONCEPT_ID = 0)
	
	UNION ALL
	
	--IF THERE IS A VALUE IN 'UNIT_SOURCE_VALUE' THERE SHOULD NOT BE A ZERO IN 'UNIT_CONCEPT_ID'
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT
	WHERE (UNIT_SOURCE_VALUE IS NOT NULL AND UNIT_CONCEPT_ID = 0)
	
	UNION ALL
	
	--IF THERE IS NOT A VALUE IN 'UNIT_SOURCE_VALUE' THERE SHOULD BE A ZERO IN 'UNIT_CONCEPT_ID'
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT
	WHERE (UNIT_SOURCE_VALUE IS NULL AND UNIT_CONCEPT_ID = 0)
	
	UNION ALL
	
	SELECT 'MEASUREMENT_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'ZERO CONCEPT' AS QA_METRIC, 'EXPECTED' AS ERROR_TYPE
		, MEASUREMENT_ID AS CDT_ID
	FROM CDM.MEASUREMENT
	WHERE (MEASUREMENT_SOURCE_CONCEPT_ID = 0)
)

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM ZEROCONCEPT_DETAIL	
WHERE ERROR_TYPE <>'EXPECTED'	
 );
 