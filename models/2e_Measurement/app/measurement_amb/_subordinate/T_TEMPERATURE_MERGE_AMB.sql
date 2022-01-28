--T_TEMPERATURE_MERGE_AMB

{{ config(materialized='ephemeral') }}

SELECT T_TEMPERATURE.PERSON_ID
    ,T_TEMPERATURE.PAT_ENC_CSN_ID
    ,TARGET_CONCEPT_ID AS TARGET_CONCEPT_ID --TEMPERATURE SOURCE
    ,T_TEMPERATURE.RECORDED_TIME
    ,T_TEMPERATURE.MEAS_VALUE AS MEAS_VALUE
    ,T_TEMPERATURE.MINVALUE
    ,T_TEMPERATURE.MAX_VAL
    ,T_TEMPERATURE.FLO_MEAS_NAME
    ,SOURCE_TO_CONCEPT_MAP_FLOWSHEET_TEMP_SRC.SOURCE_CODE_DESCRIPTION
    ,T_TEMPERATURE.FLO_MEAS_ID
    ,T_TEMPERATURE.FSD_ID
    ,T_TEMPERATURE.VISIT_PROV_ID
    ,T_TEMPERATURE.PCP_PROV_ID
    ,ENC_TYPE_C

FROM {{ref('T_TEMPERATURE_AMB')}} AS T_TEMPERATURE

LEFT JOIN {{ref('T_TEMP_SOURCE_AMB')}} AS T_TEMP_SOURCE
    ON T_TEMPERATURE.PAT_ENC_CSN_ID = T_TEMP_SOURCE.PAT_ENC_CSN_ID
        AND T_TEMPERATURE.RECORDED_TIME = T_TEMP_SOURCE.RECORDED_TIME

LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS SOURCE_TO_CONCEPT_MAP_FLOWSHEET_TEMP_SRC
    ON COALESCE(T_TEMP_SOURCE.MEAS_VALUE,'99999') = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_TEMP_SRC.SOURCE_CODE
        AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_TEMP_SRC.SOURCE_VOCABULARY_ID) = 'SH_TEMPERATURE_SOURC'
			