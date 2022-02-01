{{ config(materialized = 'table') }}

SELECT DISTINCT PERSON_ID AS PERSON_ID
	, COALESCE(SOURCE_TO_CONCEPT_MAP_GENDER.TARGET_CONCEPT_ID, 0) AS GENDER_CONCEPT_ID
	, PERSON_CLARITY_ALL.YEAR_OF_BIRTH
	, MONTH_OF_BIRTH
	, DAY_OF_BIRTH
	, BIRTH_DATETIME
	, COALESCE(SOURCE_TO_CONCEPT_MAP_RACE.TARGET_CONCEPT_ID, 0) AS RACE_CONCEPT_ID
	, COALESCE(SOURCE_TO_CONCEPT_MAP_ETHNICITY.TARGET_CONCEPT_ID, 0) AS ETHNICITY_CONCEPT_ID
	, LOCATION.LOCATION_ID
	, PROVIDER_ID
	, CARE_SITE.CARE_SITE_ID
	, AOU_ID AS PERSON_SOURCE_VALUE
	, CAST(SEX_C AS VARCHAR) || ':' || ZC_SEX_NAME AS GENDER_SOURCE_VALUE
	, 0 AS GENDER_SOURCE_CONCEPT_ID
	, CAST(PATIENT_RACE_C AS VARCHAR) || ':' || ZC_PATIENT_RACE_NAME AS RACE_SOURCE_VALUE
	, 0 AS RACE_SOURCE_CONCEPT_ID
	, CAST(ETHNIC_GROUP_C AS VARCHAR) || ':' || ZC_ETHNIC_GROUP_NAME AS ETHNICITY_SOURCE_VALUE
	, 0 AS ETHNICITY_SOURCE_CONCEPT_ID

FROM {{ref('PERSON_CLARITY_ALL') }} AS PERSON_CLARITY_ALL

LEFT JOIN {{ref('PROVIDER') }} AS PROVIDER
	ON PERSON_CLARITY_ALL.CUR_PCP_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

LEFT JOIN {{ref('LOCATION') }} AS LOCATION
	ON PERSON_CLARITY_ALL.LOCATION_SOURCE_VALUE = LOCATION.LOCATION_SOURCE_VALUE

LEFT JOIN {{ref('CARE_SITE') }} AS CARE_SITE
	ON PERSON_CLARITY_ALL.CUR_PRIM_LOC_ID = CARE_SITE.CARE_SITE_ID

LEFT JOIN {{ source('CDM', 'SOURCE_TO_CONCEPT_MAP') }} AS SOURCE_TO_CONCEPT_MAP_GENDER
	ON PERSON_CLARITY_ALL.SEX_C::VARCHAR = SOURCE_TO_CONCEPT_MAP_GENDER.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_GENDER.SOURCE_VOCABULARY_ID) = 'SH_GENDER'

LEFT JOIN {{ source('CDM', 'SOURCE_TO_CONCEPT_MAP') }} AS SOURCE_TO_CONCEPT_MAP_RACE
	ON PERSON_CLARITY_ALL.PATIENT_RACE_C::VARCHAR = SOURCE_TO_CONCEPT_MAP_RACE.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_RACE.SOURCE_VOCABULARY_ID) = 'SH_RACE'

LEFT JOIN {{ source('CDM', 'SOURCE_TO_CONCEPT_MAP') }} AS SOURCE_TO_CONCEPT_MAP_ETHNICITY
	ON PERSON_CLARITY_ALL.ETHNIC_GROUP_C::VARCHAR = SOURCE_TO_CONCEPT_MAP_ETHNICITY.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_ETHNICITY.SOURCE_VOCABULARY_ID) = 'SH_ETHNICITY'