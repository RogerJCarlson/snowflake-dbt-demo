--MEASUREMENT 

{{ config(materialized = 'table') }} 

SELECT 
    SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID,
    A.* 
FROM
    (SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_BMI')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_BPD')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_BPS')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_MISC')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_TEMPERATURE')}} ) AS A
    {# UNION
    SELECT * FROM xxx
    UNION #}
