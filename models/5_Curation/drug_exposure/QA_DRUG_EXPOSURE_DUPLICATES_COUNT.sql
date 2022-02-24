--QA_DRUG_EXPOSURE_DUPLICATES_COUNT
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH TMP_DUPES AS (
SELECT PERSON_ID
	,DRUG_CONCEPT_ID
	,DRUG_EXPOSURE_START_DATE
	,DRUG_EXPOSURE_START_DATETIME
	,DRUG_EXPOSURE_END_DATE
	,DRUG_EXPOSURE_END_DATETIME
	,VERBATIM_END_DATE
	,DRUG_TYPE_CONCEPT_ID
	,STOP_REASON
	,REFILLS
	,QUANTITY
	,DAYS_SUPPLY
	,SIG
	,ROUTE_CONCEPT_ID
	,LOT_NUMBER
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,DRUG_SOURCE_VALUE
	,DRUG_SOURCE_CONCEPT_ID
	,ROUTE_SOURCE_VALUE
	,DOSE_UNIT_SOURCE_VALUE
	,COUNT(*) AS CNT
FROM {{ref('DRUG_EXPOSURE')}}  AS T1
WHERE T1.DRUG_CONCEPT_ID != 0
	AND T1.DRUG_CONCEPT_ID IS NOT NULL
	AND T1.PERSON_ID != 0
	AND T1.PERSON_ID IS NOT NULL
GROUP BY PERSON_ID
	,DRUG_CONCEPT_ID
	,DRUG_EXPOSURE_START_DATE
	,DRUG_EXPOSURE_START_DATETIME
	,DRUG_EXPOSURE_END_DATE
	,DRUG_EXPOSURE_END_DATETIME
	,VERBATIM_END_DATE
	,DRUG_TYPE_CONCEPT_ID
	,STOP_REASON
	,REFILLS
	,QUANTITY
	,DAYS_SUPPLY
	,SIG
	,ROUTE_CONCEPT_ID
	,LOT_NUMBER
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,DRUG_SOURCE_VALUE
	,DRUG_SOURCE_CONCEPT_ID
	,ROUTE_SOURCE_VALUE
	,DOSE_UNIT_SOURCE_VALUE
HAVING COUNT(*) > 1
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('DRUG_EXPOSURE')}}) AS TOTAL_RECORDS
FROM TMP_DUPES
