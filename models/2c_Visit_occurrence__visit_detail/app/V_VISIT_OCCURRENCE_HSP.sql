SELECT DISTINCT  
	 VISIT_OCCURRENCE_CLARITYHOSP_ALL.PERSON_ID AS PERSON_ID
	, COALESCE(SOURCE_TO_CONCEPT_MAP_VISIT.TARGET_CONCEPT_ID, 0) AS VISIT_CONCEPT_ID
	, cast(VISIT_OCCURRENCE_CLARITYHOSP_ALL.HOSP_ADMSN_TIME AS DATE) AS VISIT_START_DATE
	, VISIT_OCCURRENCE_CLARITYHOSP_ALL.HOSP_ADMSN_TIME AS VISIT_START_DATETIME
	, cast(VISIT_OCCURRENCE_CLARITYHOSP_ALL.HOSP_DISCH_TIME AS DATE) AS VISIT_END_DATE
	, VISIT_OCCURRENCE_CLARITYHOSP_ALL.HOSP_DISCH_TIME AS VISIT_END_DATETIME
	, 32817 AS VISIT_TYPE_CONCEPT_ID
	, COALESCE(ATTENDING.PROVIDER_ID,REFFERING.PROVIDER_ID)  AS PROVIDER_ID
	, VISIT_OCCURRENCE_CLARITYHOSP_ALL.HOSPITAL_AREA_ID AS CARE_SITE_ID
	, VISIT_OCCURRENCE_CLARITYHOSP_ALL.PAT_ENC_CSN_ID AS VISIT_SOURCE_VALUE
	, COALESCE(SOURCE_TO_CONCEPT_MAP_VISIT.TARGET_CONCEPT_ID, 0) AS VISIT_SOURCE_CONCEPT_ID
	, COALESCE(SOURCE_TO_CONCEPT_MAP_ADMIT.TARGET_CONCEPT_ID, 0) AS ADMITTING_SOURCE_CONCEPT_ID
	, cast( VISIT_OCCURRENCE_CLARITYHOSP_ALL.ADMIT_SOURCE_C AS VARCHAR(10)) || ':' || LEFT(ADMIT_SOURCE_NAME, 45) AS ADMITTING_SOURCE_VALUE
	, COALESCE(SOURCE_TO_CONCEPT_MAP_DISCHARGE.TARGET_CONCEPT_ID, 0) AS DISCHARGE_TO_CONCEPT_ID
	, cast( VISIT_OCCURRENCE_CLARITYHOSP_ALL.DISCH_DISP_C AS VARCHAR(10)) || ':' || LEFT(DISCH_DISP_NAME, 45) AS DISCHARGE_TO_SOURCE_VALUE
	, NULL AS PRECEDING_VISIT_OCCURRENCE_ID
	, 'VISIT_OCCURRENCE--CLARITYHOSP--ALL' AS ETL_MODULE

FROM  {{ref('VISIT_OCCURRENCE_CLARITYHOSP_ALL')}} AS VISIT_OCCURRENCE_CLARITYHOSP_ALL

LEFT JOIN  {{ref('PROVIDER')}} AS PROVIDER
	ON VISIT_OCCURRENCE_CLARITYHOSP_ALL.BILL_ATTEND_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

LEFT JOIN  {{ref('PROVIDER')}} AS ATTENDING
	ON VISIT_OCCURRENCE_CLARITYHOSP_ALL.ATTENDING_PROV_ID = ATTENDING.PROVIDER_SOURCE_VALUE

LEFT JOIN  {{ref('PROVIDER')}} AS REFFERING
	ON VISIT_OCCURRENCE_CLARITYHOSP_ALL.REFERRING_PROV_ID = REFFERING.PROVIDER_SOURCE_VALUE

left JOIN  {{ref('CARE_SITE')}} AS CARE_SITE
	ON VISIT_OCCURRENCE_CLARITYHOSP_ALL.HOSPITAL_AREA_ID = CARE_SITE.CARE_SITE_ID

INNER JOIN   {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS   SOURCE_TO_CONCEPT_MAP_VISIT
	ON SOURCE_TO_CONCEPT_MAP_VISIT.SOURCE_CODE = VISIT_OCCURRENCE_CLARITYHOSP_ALL.ADT_PAT_CLASS_C
		AND UPPER(SOURCE_TO_CONCEPT_MAP_VISIT.SOURCE_VOCABULARY_ID) = 'SH_VISIT'
		
LEFT JOIN   {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS   SOURCE_TO_CONCEPT_MAP_ADMIT
	ON SOURCE_TO_CONCEPT_MAP_ADMIT.SOURCE_CODE = VISIT_OCCURRENCE_CLARITYHOSP_ALL.ADMIT_SOURCE_C
		AND UPPER(SOURCE_TO_CONCEPT_MAP_ADMIT.SOURCE_VOCABULARY_ID) = 'SH_ADMIT'
		
LEFT JOIN   {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS  SOURCE_TO_CONCEPT_MAP_DISCHARGE
	ON SOURCE_TO_CONCEPT_MAP_DISCHARGE.SOURCE_CODE = VISIT_OCCURRENCE_CLARITYHOSP_ALL.DISCH_DISP_C
		AND UPPER(SOURCE_TO_CONCEPT_MAP_DISCHARGE.SOURCE_VOCABULARY_ID) = 'SH_DISCHARGE'
		
LEFT JOIN --VISIT DATE CANNOT BE >30 DAYS AFTER DEATH_DATE
	 {{ref('DEATH')}} AS DEATH
	ON DEATH.PERSON_ID = VISIT_OCCURRENCE_CLARITYHOSP_ALL.PERSON_ID
	
WHERE HOSP_DISCH_TIME IS NOT NULL
	AND HOSP_ADMSN_TIME IS NOT NULL
	AND -- FUTURE VISITS REMOVED
	HOSP_ADMSN_TIME < COALESCE(DATEADD(DAY, 30, DEATH_DATE), GETDATE())
