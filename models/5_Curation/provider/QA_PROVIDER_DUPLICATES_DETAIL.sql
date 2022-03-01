--QA_PROVIDER_DUPLICATES_DETAIL
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
	, 'FATAL' AS ERROR_TYPE
	, PR.PROVIDER_ID
FROM TMP_DUPES AS D
INNER JOIN {{ref('PROVIDER')}} AS PR ON  COALESCE(D.PROVIDER_NAME, '0') = COALESCE(PR.PROVIDER_NAME, '0')
	AND COALESCE(D.NPI, '0') = COALESCE(PR.NPI, '0')
	AND COALESCE(D.DEA, '0') = COALESCE(PR.DEA, '0')
	AND COALESCE(D.SPECIALTY_CONCEPT_ID, 0) = COALESCE(PR.SPECIALTY_CONCEPT_ID, 0)
	AND COALESCE(D.CARE_SITE_ID, 0) = COALESCE(PR.CARE_SITE_ID, 0)
	AND COALESCE(D.YEAR_OF_BIRTH, 0) = COALESCE(PR.YEAR_OF_BIRTH, 0)
	AND COALESCE(D.GENDER_CONCEPT_ID, 0) = COALESCE(PR.GENDER_CONCEPT_ID, 0)
	AND COALESCE(D.PROVIDER_SOURCE_VALUE, '0') = COALESCE(PR.PROVIDER_SOURCE_VALUE, '0')
	AND COALESCE(D.SPECIALTY_SOURCE_VALUE, '0') = COALESCE(PR.SPECIALTY_SOURCE_VALUE, '0')
	AND COALESCE(D.SPECIALTY_SOURCE_CONCEPT_ID, 0) = COALESCE(PR.SPECIALTY_SOURCE_CONCEPT_ID, 0)
	AND COALESCE(D.GENDER_SOURCE_VALUE, '0') = COALESCE(PR.GENDER_SOURCE_VALUE, '0')
	AND COALESCE(D.GENDER_SOURCE_CONCEPT_ID, 0) = COALESCE(PR.GENDER_SOURCE_CONCEPT_ID, 0)
