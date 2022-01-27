--V_MEASUREMENT_LOINC_HSP

{{ config(materialized = 'view') }}

SELECT DISTINCT	--CDM.SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID
	MEASUREMENT_CLARITYHOSP_LOINC.PERSON_ID
	,T_CONCEPT.CONCEPT_ID AS MEASUREMENT_CONCEPT_ID
	,CAST( COALESCE(MEASUREMENT_CLARITYHOSP_LOINC.SPECIMN_TAKEN_TIME, MEASUREMENT_CLARITYHOSP_LOINC.ORDER_TIME )AS DATE) AS MEASUREMENT_DATE
	,COALESCE(MEASUREMENT_CLARITYHOSP_LOINC.SPECIMN_TAKEN_TIME, MEASUREMENT_CLARITYHOSP_LOINC.ORDER_TIME) AS MEASUREMENT_DATETIME
	,32817 AS MEASUREMENT_TYPE_CONCEPT_ID --LAB RESULT
	,CASE 
		WHEN ORD_VALUE LIKE '>=%'
			THEN 4171755
		WHEN ORD_VALUE LIKE '<=%'
			THEN 4171754
		WHEN ORD_VALUE LIKE '<%'
			THEN 4171756
		WHEN ORD_VALUE LIKE '>%'
			THEN 4172704
		ELSE 4172703
		END AS OPERATOR_CONCEPT_ID
	,CASE 
		WHEN TRY_TO_NUMERIC(REPLACE(REPLACE(REPLACE(REPLACE(ORD_VALUE, '=', ''), '<', ''), '>', ''), ',', '')) IS NULL
			THEN NULL
		ELSE REPLACE(REPLACE(REPLACE(REPLACE(ORD_VALUE, '=', ''), '<', ''), '>', ''), ',', '')
		END AS VALUE_AS_NUMBER
	,COALESCE(SOURCE_TO_CONCEPT_MAP_VALUE.TARGET_CONCEPT_ID, 0) AS VALUE_AS_CONCEPT_ID
	,COALESCE(SOURCE_TO_CONCEPT_MAP_UNIT.TARGET_CONCEPT_ID, 0) AS UNIT_CONCEPT_ID
	,CASE 
		WHEN TRY_TO_NUMERIC(REPLACE(REPLACE(REPLACE(REPLACE(MEASUREMENT_CLARITYHOSP_LOINC.REFERENCE_LOW, '=', ''), '<', ''), '>', ''), ',', '')) IS NULL
			THEN NULL
		ELSE CAST( REPLACE(REPLACE(REPLACE(REPLACE(MEASUREMENT_CLARITYHOSP_LOINC.REFERENCE_LOW, '=', ''), '<', ''), '>', ''), ',', '') AS FLOAT)
		END AS RANGE_LOW
	,CASE 
		WHEN TRY_TO_NUMERIC(REPLACE(REPLACE(REPLACE(REPLACE(MEASUREMENT_CLARITYHOSP_LOINC.REFERENCE_HIGH, '=', ''), '<', ''), '>', ''), ',', '')) IS NULL
			THEN NULL
		ELSE CAST( REPLACE(REPLACE(REPLACE(REPLACE(MEASUREMENT_CLARITYHOSP_LOINC.REFERENCE_HIGH, '=', ''), '<', ''), '>', ''), ',', '') AS FLOAT)
		END AS RANGE_HIGH
	,PROVIDER.PROVIDER_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,LEFT(MEASUREMENT_CLARITYHOSP_LOINC.LNC_CODE || ':' || MEASUREMENT_CLARITYHOSP_LOINC.LNC_COMPON, 50) AS MEASUREMENT_SOURCE_VALUE
	,T_SOURCE.CONCEPT_ID AS MEASUREMENT_SOURCE_CONCEPT_ID
	,LEFT(MEASUREMENT_CLARITYHOSP_LOINC.REFERENCE_UNIT, 49) AS UNIT_SOURCE_VALUE
	,LEFT(MEASUREMENT_CLARITYHOSP_LOINC.ORD_VALUE, 49) AS VALUE_SOURCE_VALUE
	,'MEASUREMENT--CLARITYHOSP--LOINC' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM {{ref('MEASUREMENT_CLARITYHOSP_LOINC')}} AS MEASUREMENT_CLARITYHOSP_LOINC

INNER  JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
	ON MEASUREMENT_CLARITYHOSP_LOINC.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

INNER JOIN {{ref('T_LOINC_SOURCE')}} AS T_SOURCE
	ON MEASUREMENT_CLARITYHOSP_LOINC.LNC_CODE = T_SOURCE.CONCEPT_CODE

INNER JOIN {{ref('T_LOINC_CONCEPT')}} AS T_CONCEPT
	ON T_CONCEPT.SOURCE_CONCEPT_ID = T_SOURCE.CONCEPT_ID

LEFT JOIN {{ref('PROVIDER')}} AS PROVIDER
	ON MEASUREMENT_CLARITYHOSP_LOINC.AUTHRZING_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS  SOURCE_TO_CONCEPT_MAP_UNIT
	ON MEASUREMENT_CLARITYHOSP_LOINC.REFERENCE_UNIT = SOURCE_TO_CONCEPT_MAP_UNIT.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_UNIT.SOURCE_VOCABULARY_ID) = 'SH_UNIT'

LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS  SOURCE_TO_CONCEPT_MAP_VALUE
	ON MEASUREMENT_CLARITYHOSP_LOINC.ORD_VALUE = SOURCE_TO_CONCEPT_MAP_VALUE.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_VALUE.SOURCE_VOCABULARY_ID) = 'VALUE_CONCEPT'

WHERE (MEASUREMENT_CLARITYHOSP_LOINC.ORDER_STATUS_C <> 4)

