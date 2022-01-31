--V_MEASUREMENT_FLOWSHEET_ANES_BPD

{{ config(materialized = 'view') }}

SELECT DISTINCT 	
--CDM.SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID
	MEASUREMENT_CLARITYANES_FLOWSHEET.PERSON_ID
	,COALESCE (SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.TARGET_CONCEPT_ID, 0) AS MEASUREMENT_CONCEPT_ID
	,CAST( MEASUREMENT_CLARITYANES_FLOWSHEET.RECORDED_TIME AS DATE) AS MEASUREMENT_DATE
	,MEASUREMENT_CLARITYANES_FLOWSHEET.RECORDED_TIME AS MEASUREMENT_DATETIME
	,32817 AS MEASUREMENT_TYPE_CONCEPT_ID --EHR
	,CASE 
		WHEN MEAS_VALUE LIKE '>=%'
			THEN 4171755
		WHEN MEAS_VALUE LIKE '<=%'
			THEN 4171754
		WHEN MEAS_VALUE LIKE '<%'
			THEN 4171756
		WHEN MEAS_VALUE LIKE '>%'
			THEN 4172704
		ELSE 4172703
		END AS OPERATOR_CONCEPT_ID

	,  CAST(SUBSTRING(MEAS_VALUE, CHARINDEX('/', MEAS_VALUE) + 1, 2) AS FLOAT ) AS VALUE_AS_NUMBER -- DIASTOLIC

	,0 AS VALUE_AS_CONCEPT_ID
	,8876 AS UNIT_CONCEPT_ID --MM HG
	,MEASUREMENT_CLARITYANES_FLOWSHEET.MINVALUE AS RANGE_LOW
	,MEASUREMENT_CLARITYANES_FLOWSHEET.MAX_VAL AS RANGE_HIGH
	,PROVIDER.PROVIDER_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,'FLWSHT: ' || MEASUREMENT_CLARITYANES_FLOWSHEET.FLO_MEAS_NAME AS MEASUREMENT_SOURCE_VALUE
	,0 AS MEASUREMENT_SOURCE_CONCEPT_ID
	,SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_CODE_DESCRIPTION AS UNIT_SOURCE_VALUE
	,MEASUREMENT_CLARITYANES_FLOWSHEET.MEAS_VALUE AS VALUE_SOURCE_VALUE
	,'MEASUREMENT--CLARITYANES--FLOWSHEET_BPD' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM {{ref('MEASUREMENT_CLARITYANES_FLOWSHEET')}} AS MEASUREMENT_CLARITYANES_FLOWSHEET

	INNER JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS
		ON MEASUREMENT_CLARITYANES_FLOWSHEET.FLO_MEAS_ID = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_CODE
			AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_VOCABULARY_ID) = 'SH_FLWSHT_MEAS_BPD'

	LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS  SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS
		ON 	MEASUREMENT_CLARITYANES_FLOWSHEET.FLO_MEAS_ID  = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_CODE 
			AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_VOCABULARY_ID) = 'SH_FLOWSHT_MEAS_UNIT'

	INNER JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
		ON MEASUREMENT_CLARITYANES_FLOWSHEET.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

	LEFT JOIN {{ref('PROVIDER')}} AS PROVIDER
		ON MEASUREMENT_CLARITYANES_FLOWSHEET.VISIT_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

