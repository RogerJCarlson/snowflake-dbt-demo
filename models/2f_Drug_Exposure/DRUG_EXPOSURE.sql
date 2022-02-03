--DRUG_EXPOSURE 

{{ config(materialized = 'table') }} 

SELECT 
    SEQ_DRUG_EXPOSURE.NEXTVAL AS DRUG_EXPOSURE_ID,
    A.* 
FROM
(   
    SELECT * FROM {{ref('V_DRUG_EXPOSURE_RXNORM_AMB')}} 
    {# UNION
    SELECT * FROM {{ref('V_DRUG_EXPOSURE_RXNORM_ANES')}}  #}
    UNION
    SELECT * FROM {{ref('V_DRUG_EXPOSURE_RXNORM_HSP')}}
) AS A    