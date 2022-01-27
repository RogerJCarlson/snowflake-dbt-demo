--MEASUREMENT 

{{ config(materialized = 'table') }} 

SELECT 
    SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID,
    A.* 
FROM
(   --HSP
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_BMI')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_BPD')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_BPS')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_MISC')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_TEMPERATURE')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_HSP_VITALS')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_LOINC_HSP')}}

    --AMB
    {# UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_AMB_BMI')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_AMB_BPD')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_AMB_BPS')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_AMB_MISC')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_AMB_TEMPERATURE')}}  
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_AMB_VITALS')}} #}
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_LOINC_AMB')}}

    --ANES
    {# UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_BMI')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_BPD')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_BPM')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_BPS')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_MISC')}} 
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_TEMPERATURE')}}
    UNION
    SELECT * FROM {{ref('V_MEASUREMENT_FLOWSHEET_ANES_VITALS')}}  #}        
) AS A
