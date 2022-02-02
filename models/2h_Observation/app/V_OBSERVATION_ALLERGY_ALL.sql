--V_OBSERVATION_ALLERGY_ALL

{{ config(materialized = 'view') }}

SELECT DISTINCT --CDM.SEQ_OBSERVATION.NEXTVAL AS OBSERVATION_ID
	OBSERVATION_CLARITYALL_ALLERGY.PERSON_ID
	, CASE 
		WHEN UPPER(ALLERGEN_NAME) = 'PENICILLINS'
			THEN 4240903
		ELSE COALESCE(T_CONCEPT.CONCEPT_ID, 0)
	  END AS OBSERVATION_CONCEPT_ID
	, CAST( COALESCE(ALRGY_ENTERED_DTTM, DATE_NOTED, CONTACT_DATE) AS DATE) AS OBSERVATION_DATE
	, CAST( COALESCE(ALRGY_ENTERED_DTTM, DATE_NOTED, CONTACT_DATE) AS DATETIME) AS OBSERVATION_DATETIME
	--, 38000280 AS OBSERVATION_TYPE_CONCEPT_ID
	, 32817 AS OBSERVATION_TYPE_CONCEPT_ID -- NEW TYPE_ID
	, NULL AS VALUE_AS_NUMBER
	, LEFT(ALLERGEN_NAME,60) AS VALUE_AS_STRING
	, 0 AS VALUE_AS_CONCEPT_ID
	, 0 AS UNIT_CONCEPT_ID
	, 0 AS QUALIFIER_CONCEPT_ID
	, PROVIDER.PROVIDER_ID AS PROVIDER_ID
	, VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	, LEFT('ALLERGY:' || ALLERGEN_NAME,50) AS OBSERVATION_SOURCE_VALUE
	, 0 AS OBSERVATION_SOURCE_CONCEPT_ID
	, NULL AS UNIT_SOURCE_VALUE
	, NULL AS QUALIFIER_SOURCE_VALUE
	,'OBSERVATION--CLARITYALL--ALLERGY' AS ETL_MODULE
	,VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

FROM {{ref('OBSERVATION_CLARITYALL_ALLERGY')}} AS OBSERVATION_CLARITYALL_ALLERGY 
	LEFT JOIN {{ref('T_SOURCE_OBSERVATION')}} AS T_SOURCE
		ON OBSERVATION_CLARITYALL_ALLERGY.CONCEPT_NAME = T_SOURCE.CONCEPT_NAME
	LEFT JOIN {{ref('T_CONCEPT_OBSERVATION')}} AS T_CONCEPT
		ON T_CONCEPT.SOURCE_CONCEPT_ID = T_SOURCE.CONCEPT_ID
	LEFT  JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
		ON OBSERVATION_CLARITYALL_ALLERGY.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE
	LEFT JOIN {{ref('PROVIDER')}} AS PROVIDER
		ON OBSERVATION_CLARITYALL_ALLERGY.PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE
