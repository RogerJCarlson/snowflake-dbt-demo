USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE VIEW OMOP_QA.V_DEATH_DUPLICATES_DETAIL AS (
---------------------------------------------------------------------
--DEATH_DUPLICATES_DETAIL
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT DEATH_DATE
	,DEATH_DATETIME
	,DEATH_TYPE_CONCEPT_ID
	,CAUSE_CONCEPT_ID
	,CAUSE_SOURCE_VALUE
	,CAUSE_SOURCE_CONCEPT_ID
	,COUNT(*) AS CNT
FROM CDM.DEATH AS T1
GROUP BY DEATH_DATE
	,DEATH_DATETIME
	,DEATH_TYPE_CONCEPT_ID
	,CAUSE_CONCEPT_ID
	,CAUSE_SOURCE_VALUE
	,CAUSE_SOURCE_CONCEPT_ID
HAVING COUNT(*) > 1
)

--INSERT INTO OMOP_QA.QA_ERR(
--	RUN_DATE
--	,STANDARD_DATA_TABLE
--	,QA_METRIC
--	,METRIC_FIELD
--	,ERROR_TYPE
--	,CDT_ID	)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, 'FATAL' AS ERROR_TYPE
	, DE.PERSON_ID

FROM TMP_DUPES AS D
INNER JOIN CDM.DEATH AS DE ON D.DEATH_DATE = DE.DEATH_DATE
	AND COALESCE(D.DEATH_DATETIME,'1900-01-01') = COALESCE(DE.DEATH_DATETIME,'1900-01-01')
	AND COALESCE(D.DEATH_TYPE_CONCEPT_ID, 0) = COALESCE(DE.DEATH_TYPE_CONCEPT_ID, 0)
	AND COALESCE(D.CAUSE_CONCEPT_ID, 0) = COALESCE(DE.CAUSE_CONCEPT_ID, 0)
	AND COALESCE(D.CAUSE_SOURCE_VALUE, '0') = COALESCE(DE.CAUSE_SOURCE_VALUE, '0')
	AND COALESCE(D.CAUSE_SOURCE_CONCEPT_ID, 0) = COALESCE(DE.CAUSE_SOURCE_CONCEPT_ID, 0)
	
);