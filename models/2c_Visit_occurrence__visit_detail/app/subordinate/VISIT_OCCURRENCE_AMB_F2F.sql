SELECT
	DISTINCT 

	VISIT_OCCURRENCE_CLARITYAMB_ALL.PERSON_ID ,
	COALESCE(SOURCE_TO_CONCEPT_MAP_AMB_VISIT.TARGET_CONCEPT_ID,	0) AS VISIT_CONCEPT_ID ,
	CAST(COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
	VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
	VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE) AS DATE) AS VISIT_START_DATE ,
	COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
	VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
	VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE) AS VISIT_START_DATETIME ,
	CASE
		WHEN COALESCE(CHECKOUT_TIME,
		COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE)) > COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE) 
		THEN CAST( COALESCE(CHECKOUT_TIME,
		COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE)) AS DATE)
		ELSE CAST( COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE) AS DATE)
	END AS VISIT_END_DATE ,
	CASE
		WHEN COALESCE(CHECKOUT_TIME,
		COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE)) > COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE) THEN COALESCE(CHECKOUT_TIME,
		COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE))
		ELSE COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
		VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE)
	END AS VISIT_END_DATETIME ,
	32817 AS VISIT_TYPE_CONCEPT_ID,
	COALESCE(PROVIDER.PROVIDER_ID,	PCP.PROVIDER_ID) AS PROVIDER_ID ,
	COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.PRIMARY_LOC_ID,1) AS CARE_SITE_ID ,
	VISIT_OCCURRENCE_CLARITYAMB_ALL.PAT_ENC_CSN_ID AS VISIT_SOURCE_VALUE ,
	0 AS VISIT_SOURCE_CONCEPT_ID ,
	0 AS ADMITTING_SOURCE_CONCEPT_ID ,
	NULL AS ADMITTING_SOURCE_VALUE ,
	0 AS DISCHARGE_TO_CONCEPT_ID ,
	NULL AS DISCHARGE_TO_SOURCE_VALUE ,
	NULL AS PRECEDING_VISIT_OCCURRENCE_ID ,
	'VISIT_OCCURRENCE--CLARITYAMB--ALL' AS ETL_MODULE
FROM
	 {{ref('VISIT_OCCURRENCE_CLARITYAMB_ALL')}} AS VISIT_OCCURRENCE_CLARITYAMB_ALL

left JOIN  {{ref('CARE_SITE')}} AS CARE_SITE ON
	VISIT_OCCURRENCE_CLARITYAMB_ALL.PRIMARY_LOC_ID =  CARE_SITE.CARE_SITE_ID
LEFT JOIN  {{ref('PROVIDER')}} AS PROVIDER ON
	VISIT_OCCURRENCE_CLARITYAMB_ALL.VISIT_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE
LEFT JOIN  {{ref('PROVIDER')}}  AS PCP ON
	VISIT_OCCURRENCE_CLARITYAMB_ALL.PCP_PROV_ID = PCP.PROVIDER_SOURCE_VALUE
LEFT JOIN
	--VISIT DATE CANNOT BE >30 DAYS AFTER DEATH_DATE
  {{ref('DEATH')}} AS DEATH ON
	 DEATH.PERSON_ID = VISIT_OCCURRENCE_CLARITYAMB_ALL.PERSON_ID
	
INNER JOIN    {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS   SOURCE_TO_CONCEPT_MAP_AMB_VISIT ON
	(SOURCE_TO_CONCEPT_MAP_AMB_VISIT.SOURCE_CODE = VISIT_OCCURRENCE_CLARITYAMB_ALL.ENC_TYPE_C
	AND UPPER(SOURCE_TO_CONCEPT_MAP_AMB_VISIT.SOURCE_VOCABULARY_ID) IN ('SH_AMB_F2F'))
	
WHERE
	CALCULATED_ENC_STAT_C <> 3
	AND CALCULATED_ENC_STAT_C <> 1
	AND
    -- FUTURE VISITS REMOVED
     CAST(COALESCE(VISIT_OCCURRENCE_CLARITYAMB_ALL.CHECKIN_TIME,
    	VISIT_OCCURRENCE_CLARITYAMB_ALL.APPT_TIME,
    	VISIT_OCCURRENCE_CLARITYAMB_ALL.CONTACT_DATE) AS DATE) < COALESCE(DATEADD(DAY,
    	30,
    	DEATH_DATE),
    	GETDATE())