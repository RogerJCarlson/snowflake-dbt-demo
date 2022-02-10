USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_PERSON_DUPLICATES_COUNT AS (
---------------------------------------------------------------------
--PERSON_DUPLICATES_COUNT
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT       
		GENDER_CONCEPT_ID
      ,YEAR_OF_BIRTH
      ,MONTH_OF_BIRTH
      ,DAY_OF_BIRTH
      ,BIRTH_DATETIME
      ,RACE_CONCEPT_ID
      ,ETHNICITY_CONCEPT_ID
      ,LOCATION_ID
      ,PROVIDER_ID
      ,CARE_SITE_ID
      ,PERSON_SOURCE_VALUE
      ,GENDER_SOURCE_VALUE
      ,GENDER_SOURCE_CONCEPT_ID
      ,RACE_SOURCE_VALUE
      ,RACE_SOURCE_CONCEPT_ID
      ,ETHNICITY_SOURCE_VALUE
      ,ETHNICITY_SOURCE_CONCEPT_ID
       , COUNT(*) AS CNT

FROM CDM.PERSON AS T1
GROUP BY  GENDER_CONCEPT_ID
      ,YEAR_OF_BIRTH
      ,MONTH_OF_BIRTH
      ,DAY_OF_BIRTH
      ,BIRTH_DATETIME
      ,RACE_CONCEPT_ID
      ,ETHNICITY_CONCEPT_ID
      ,LOCATION_ID
      ,PROVIDER_ID
      ,CARE_SITE_ID
      ,PERSON_SOURCE_VALUE
      ,GENDER_SOURCE_VALUE
      ,GENDER_SOURCE_CONCEPT_ID
      ,RACE_SOURCE_VALUE
      ,RACE_SOURCE_CONCEPT_ID
      ,ETHNICITY_SOURCE_VALUE
      ,ETHNICITY_SOURCE_CONCEPT_ID
HAVING COUNT(*) > 1
)
--
--INSERT INTO OMOP_QA.QA_LOG   (    
--		RUN_DATE
--      ,STANDARD_DATA_TABLE
--      ,QA_METRIC
--	  , METRIC_FIELD
--      ,QA_ERRORS
--      ,ERROR_TYPE
--	  ,TOTAL_RECORDS)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'PERSON' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.PERSON) AS TOTAL_RECORDS
FROM TMP_DUPES
);
