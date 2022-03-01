--QA_PROVIDER_DUPLICATES_COUNT
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT PROVIDER_NAME
	,NPI
	,DEA
	,SPECIALTY_CONCEPT_ID
	,CARE_SITE_ID
	,YEAR_OF_BIRTH
	,GENDER_CONCEPT_ID
	,PROVIDER_SOURCE_VALUE
	,SPECIALTY_SOURCE_VALUE
	,SPECIALTY_SOURCE_CONCEPT_ID
	,GENDER_SOURCE_VALUE
	,GENDER_SOURCE_CONCEPT_ID
	,COUNT(*) AS CNT

FROM {{ref('PROVIDER')}} AS T1

GROUP BY PROVIDER_NAME
	,NPI
	,DEA
	,SPECIALTY_CONCEPT_ID
	,CARE_SITE_ID
	,YEAR_OF_BIRTH
	,GENDER_CONCEPT_ID
	,PROVIDER_SOURCE_VALUE
	,SPECIALTY_SOURCE_VALUE
	,SPECIALTY_SOURCE_CONCEPT_ID
	,GENDER_SOURCE_VALUE
	,GENDER_SOURCE_CONCEPT_ID

HAVING COUNT(*) > 1
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'PROVIDER' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('PROVIDER')}}) AS TOTAL_RECORDS
FROM TMP_DUPES
