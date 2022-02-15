USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE VIEW OMOP_QA.V_NOTE_DUPLICATES_DETAIL AS (
---------------------------------------------------------------------
--NOTE_DUPLICATES_DETAIL
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT        PERSON_ID
            , NOTE_DATE
            , NOTE_DATETIME
            , NOTE_TYPE_CONCEPT_ID
            , NOTE_CLASS_CONCEPT_ID
            , NOTE_TITLE
            , NOTE_TEXT
            , ENCODING_CONCEPT_ID
            , LANGUAGE_CONCEPT_ID
            , PROVIDER_ID
            , VISIT_OCCURRENCE_ID
            , NOTE_SOURCE_VALUE
        ,COUNT(*) AS CNT

FROM CDM.NOTE AS T1
GROUP BY  PERSON_ID
            , NOTE_DATE
            , NOTE_DATETIME
            , NOTE_TYPE_CONCEPT_ID
            , NOTE_CLASS_CONCEPT_ID
            , NOTE_TITLE
            , NOTE_TEXT
            , ENCODING_CONCEPT_ID
            , LANGUAGE_CONCEPT_ID
            , PROVIDER_ID
            , VISIT_OCCURRENCE_ID
            , NOTE_SOURCE_VALUE
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
	,'NOTE' AS STANDARD_DATA_TABLE
	,'DUPLICATE' AS QA_METRIC
	,'RECORDS'  AS METRIC_FIELD
	,'FATAL' AS ERROR_TYPE
	,NT.NOTE_ID

FROM TMP_DUPES AS D
INNER JOIN CDM.NOTE AS NT ON D.PERSON_ID = NT.PERSON_ID
	AND D.NOTE_DATE = NT.NOTE_DATE
	AND COALESCE(D.NOTE_DATETIME,'1900-01-01') = COALESCE(NT.NOTE_DATETIME,'1900-01-01')
	AND COALESCE(D.NOTE_TYPE_CONCEPT_ID, 0) = COALESCE(NT.NOTE_TYPE_CONCEPT_ID, 0)
	AND COALESCE(D.NOTE_CLASS_CONCEPT_ID, 0) = COALESCE(NT.NOTE_CLASS_CONCEPT_ID, 0)
	AND COALESCE(D.NOTE_TITLE, '0') = COALESCE(NT.NOTE_TITLE, '0')
	AND COALESCE(D.NOTE_TEXT, '0') = COALESCE(NT.NOTE_TEXT, '0')
	AND COALESCE(D.ENCODING_CONCEPT_ID, 0) = COALESCE(NT.ENCODING_CONCEPT_ID, 0)
	AND COALESCE(D.LANGUAGE_CONCEPT_ID, 0) = COALESCE(NT.LANGUAGE_CONCEPT_ID, 0)
	AND COALESCE(D.PROVIDER_ID, 0) = COALESCE(NT.PROVIDER_ID, 0)
	AND COALESCE(D.VISIT_OCCURRENCE_ID, 0) = COALESCE(NT.VISIT_OCCURRENCE_ID, 0)
	AND COALESCE(D.NOTE_SOURCE_VALUE, '0') = COALESCE(NT.NOTE_SOURCE_VALUE, '0')
	
);