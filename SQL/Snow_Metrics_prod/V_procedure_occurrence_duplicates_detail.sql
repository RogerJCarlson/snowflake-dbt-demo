USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE VIEW OMOP_QA.V_PROCEDURE_OCCURRENCE_DUPLICATES_DETAIL AS (
---------------------------------------------------------------------
--PROCEDURE_OCCURRENCE_DUPLICATES_DETAIL
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT PERSON_ID
	,PROCEDURE_CONCEPT_ID
	,PROCEDURE_DATE
	,PROCEDURE_DATETIME
	,PROCEDURE_TYPE_CONCEPT_ID
	,MODIFIER_CONCEPT_ID
	,QUANTITY
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,PROCEDURE_SOURCE_VALUE
	,PROCEDURE_SOURCE_CONCEPT_ID
	,MODIFIER_SOURCE_VALUE
	,COUNT(*) AS CNT

FROM CDM.PROCEDURE_OCCURRENCE AS T1
WHERE T1.PROCEDURE_CONCEPT_ID <> 0
	AND T1.PROCEDURE_CONCEPT_ID IS NOT NULL
	AND T1.PERSON_ID <> 0
	AND T1.PERSON_ID IS NOT NULL
GROUP BY PERSON_ID
	,PROCEDURE_CONCEPT_ID
	,PROCEDURE_DATE
	,PROCEDURE_DATETIME
	,PROCEDURE_TYPE_CONCEPT_ID
	,MODIFIER_CONCEPT_ID
	,QUANTITY
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,PROCEDURE_SOURCE_VALUE
	,PROCEDURE_SOURCE_CONCEPT_ID
	,MODIFIER_SOURCE_VALUE
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
	,'PROCEDURE_OCCURRENCE' AS STANDARD_DATA_TABLE
	,'DUPLICATE' AS QA_METRIC
	,'RECORDS'  AS METRIC_FIELD
	,'FATAL' AS ERROR_TYPE
	,PO.PROCEDURE_OCCURRENCE_ID

FROM TMP_DUPES AS D
INNER JOIN CDM.PROCEDURE_OCCURRENCE AS PO ON D.PERSON_ID = PO.PERSON_ID
	AND D.PROCEDURE_CONCEPT_ID =PO.PROCEDURE_CONCEPT_ID
	AND D.PROCEDURE_DATE = PO.PROCEDURE_DATE
	AND COALESCE(D.PROCEDURE_DATETIME,'1900-01-01') = COALESCE(PO.PROCEDURE_DATETIME,'1900-01-01')
	AND COALESCE(D.PROCEDURE_TYPE_CONCEPT_ID, 0) = COALESCE(PO.PROCEDURE_TYPE_CONCEPT_ID, 0)
	AND COALESCE(D.MODIFIER_CONCEPT_ID, 0) = COALESCE(PO.MODIFIER_CONCEPT_ID, 0)
	AND COALESCE(D.QUANTITY, 0) = COALESCE(PO.QUANTITY, 0)
	AND COALESCE(D.PROVIDER_ID, 0) = COALESCE(PO.PROVIDER_ID, 0)
	AND COALESCE(D.VISIT_OCCURRENCE_ID, 0) = COALESCE(PO.VISIT_OCCURRENCE_ID, 0)
	AND COALESCE(D.PROCEDURE_SOURCE_VALUE, '0') = COALESCE(PO.PROCEDURE_SOURCE_VALUE, '0')
	AND COALESCE(D.PROCEDURE_SOURCE_CONCEPT_ID, 0) = COALESCE(PO.PROCEDURE_SOURCE_CONCEPT_ID, 0)
	AND COALESCE(D.MODIFIER_SOURCE_VALUE, '0') = COALESCE(PO.MODIFIER_SOURCE_VALUE, '0')
 );
 