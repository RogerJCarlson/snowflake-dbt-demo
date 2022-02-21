---------------------------------------------------------------------
--QA_CONDITION_OCCURRENCE_DUPLICATES_COUNT
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

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
FROM {{ref('CONDITION_OCCURRENCE')}}  AS T1
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

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'CONDITION_OCCURRENCE' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('CONDITION_OCCURRENCE')}} ) AS TOTAL_RECORDS
FROM TMP_DUPES
