USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_DRUG_EXPOSURE_NULLCONCEPT_DETAIL;
CREATE OR REPLACE VIEW OMOP_QA.V_DRUG_EXPOSURE_NULLCONCEPT_DETAIL AS (
---------------------------------------------------------------------
------ DRUG_EXPOSURE_NULLCONCEPT_DETAIL
--------------------------------------------------------------------- 
WITH NULLCONCEPT_DETAIL
AS (
	SELECT 'DRUG_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM CDM.DRUG_EXPOSURE
	WHERE (DRUG_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'DRUG_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM CDM.DRUG_EXPOSURE
	WHERE (DRUG_TYPE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'ROUTE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM CDM.DRUG_EXPOSURE
	WHERE (ROUTE_CONCEPT_ID IS NULL)
	
	UNION ALL
	
	SELECT 'DRUG_SOURCE_CONCEPT_ID' AS METRIC_FIELD, 'NULL CONCEPT' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DRUG_EXPOSURE_ID AS CDT_ID
	FROM CDM.DRUG_EXPOSURE
	WHERE (DRUG_SOURCE_CONCEPT_ID IS NULL)
	)
--
--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST( GETDATE() AS DATE) AS RUN_DATE
	,'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLCONCEPT_DETAIL
  WHERE ERROR_TYPE <>'EXPECTED'	
 );
 