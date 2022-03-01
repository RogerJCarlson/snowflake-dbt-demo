--QA_NOTE_DUPLICATES_COUNT
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

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

FROM {{ref('NOTE')}} AS T1
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

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'NOTE' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('NOTE')}}) AS TOTAL_RECORDS
FROM TMP_DUPES

