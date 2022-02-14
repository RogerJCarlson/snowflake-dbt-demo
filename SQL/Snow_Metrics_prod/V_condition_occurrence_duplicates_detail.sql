USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE VIEW OMOP_QA.V_CONDITION_OCCURRENCE_DUPLICATES_DETAIL AS (
---------------------------------------------------------------------
--CONDITION_OCCURRENCE_DUPLICATES_DETAIL
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT PERSON_ID
	,CONDITION_CONCEPT_ID
	,CONDITION_START_DATE
	,CONDITION_START_DATETIME
	,CONDITION_END_DATE
	,CONDITION_END_DATETIME
	,CONDITION_TYPE_CONCEPT_ID
	,STOP_REASON
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,CONDITION_SOURCE_VALUE
	,CONDITION_SOURCE_CONCEPT_ID
	,CONDITION_STATUS_SOURCE_VALUE
	,CONDITION_STATUS_CONCEPT_ID
	,COUNT(*) AS CNT
FROM CDM.CONDITION_OCCURRENCE AS T1
WHERE T1.CONDITION_CONCEPT_ID <> 0
	AND T1.CONDITION_CONCEPT_ID IS NOT NULL
	AND T1.PERSON_ID <> 0
	AND T1.PERSON_ID IS NOT NULL
GROUP BY PERSON_ID
	,CONDITION_CONCEPT_ID
	,CONDITION_START_DATE
	,CONDITION_START_DATETIME
	,CONDITION_END_DATE
	,CONDITION_END_DATETIME
	,CONDITION_TYPE_CONCEPT_ID
	,STOP_REASON
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,CONDITION_SOURCE_VALUE
	,CONDITION_SOURCE_CONCEPT_ID
	,CONDITION_STATUS_SOURCE_VALUE
	,CONDITION_STATUS_CONCEPT_ID
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
	, CO.CONDITION_OCCURRENCE_ID

FROM TMP_DUPES AS D
INNER JOIN CDM.CONDITION_OCCURRENCE AS CO ON D.PERSON_ID = CO.PERSON_ID
	AND D.CONDITION_CONCEPT_ID =CO.CONDITION_CONCEPT_ID
	AND D.CONDITION_START_DATE = CO.CONDITION_START_DATE
	AND D.CONDITION_START_DATETIME = CO.CONDITION_START_DATETIME
	AND D.CONDITION_END_DATE = CO.CONDITION_END_DATE
	AND COALESCE(D.CONDITION_END_DATETIME,'1900-01-01') = COALESCE(CO.CONDITION_END_DATETIME,'1900-01-01')
	AND COALESCE(D.CONDITION_TYPE_CONCEPT_ID, 0) = COALESCE(CO.CONDITION_TYPE_CONCEPT_ID, 0)
	AND COALESCE(D.STOP_REASON, '0') = COALESCE(CO.STOP_REASON, '0')
	AND COALESCE(D.PROVIDER_ID, 0) = COALESCE(CO.PROVIDER_ID, 0)
	AND COALESCE(D.VISIT_OCCURRENCE_ID, 0) = COALESCE(CO.VISIT_OCCURRENCE_ID, 0)
	AND COALESCE(D.CONDITION_SOURCE_VALUE, '0') = COALESCE(CO.CONDITION_SOURCE_VALUE, '0')
	AND COALESCE(D.CONDITION_SOURCE_CONCEPT_ID, 0) = COALESCE(CO.CONDITION_SOURCE_CONCEPT_ID, 0)
	AND COALESCE(D.CONDITION_STATUS_SOURCE_VALUE, '0') = COALESCE(CO.CONDITION_STATUS_SOURCE_VALUE, '0')
	AND COALESCE(D.CONDITION_STATUS_CONCEPT_ID, 0) = COALESCE(CO.CONDITION_STATUS_CONCEPT_ID, 0)
);