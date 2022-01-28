--V_MEASUREMENT_FLOWSHEET_AMB_TEMPERATURE

{{ config(materialized = 'view') }}

SELECT DISTINCT 
--CDM.SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID
	T_TEMPERATURE_MERGE.PERSON_ID
	,T_TEMPERATURE_MERGE.TARGET_CONCEPT_ID AS MEASUREMENT_CONCEPT_ID
	,CAST (T_TEMPERATURE_MERGE.RECORDED_TIME AS DATE ) AS MEASUREMENT_DATE
	,T_TEMPERATURE_MERGE.RECORDED_TIME AS MEASUREMENT_DATETIME
	,32817 AS MEASUREMENT_TYPE_CONCEPT_ID --EHR
	,4172703 AS OPERATOR_CONCEPT_ID
	,MEAS_VALUE AS VALUE_AS_NUMBER
	,0 AS VALUE_AS_CONCEPT_ID
	,COALESCE(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.TARGET_CONCEPT_ID, 0) AS UNIT_CONCEPT_ID
	,MINVALUE AS RANGE_LOW
	,MAX_VAL AS RANGE_HIGH
	,COALESCE(VST.PROVIDER_ID, PCP.PROVIDER_ID) AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,'FLWSHT: ' || T_TEMPERATURE_MERGE.FLO_MEAS_NAME || ': ' || T_TEMPERATURE_MERGE.SOURCE_CODE_DESCRIPTION AS MEASUREMENT_SOURCE_VALUE
	,0 AS MEASUREMENT_SOURCE_CONCEPT_ID
	,COALESCE(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_CODE_DESCRIPTION, '') AS UNIT_SOURCE_VALUE
	,MEAS_VALUE AS VALUE_SOURCE_VALUE
	,'MEASUREMENT--CLARITYAMB--FLOWSHEET_TEMP' AS ETL_MODULE
	,VISIT_SOURCE_VALUE	


FROM {{ref('T_TEMPERATURE_MERGE_AMB')}} AS T_TEMPERATURE_MERGE

    LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS  SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS
    	ON T_TEMPERATURE_MERGE.FLO_MEAS_ID = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_CODE
    		AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_VOCABULARY_ID) = 'SH_FLWSHT_MEAS_TEMP'
    
    LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS
    	ON T_TEMPERATURE_MERGE.FLO_MEAS_ID  = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_CODE 
    		AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_VOCABULARY_ID) = 'SH_FLOWSHT_MEAS_UNIT'

    LEFT JOIN  {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS SOURCE_TO_CONCEPT_MAP_AMB_VISIT
        ON  SOURCE_TO_CONCEPT_MAP_AMB_VISIT.SOURCE_CODE   = T_TEMPERATURE_MERGE.ENC_TYPE_C
            AND SOURCE_TO_CONCEPT_MAP_AMB_VISIT.SOURCE_VOCABULARY_ID  IN('SH_amb_f2f')

    INNER JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
    	ON T_TEMPERATURE_MERGE.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE
        
    LEFT JOIN {{ref('PROVIDER')}} AS VST
        ON  T_TEMPERATURE_MERGE.VISIT_PROV_ID = VST.PROVIDER_SOURCE_VALUE     
                
    LEFT JOIN {{ref('PROVIDER')}} AS PCP
        ON T_TEMPERATURE_MERGE.PCP_PROV_ID = PCP.PROVIDER_SOURCE_VALUE

	WHERE T_TEMPERATURE_MERGE.TARGET_CONCEPT_ID IS NOT NULL