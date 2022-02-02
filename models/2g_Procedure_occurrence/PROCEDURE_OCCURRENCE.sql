--PROCEDURE_OCCURRENCE

{{ config(materialized = 'table') }} 

SELECT 
    SEQ_PROCEDURE_OCCURRENCE.NEXTVAL AS PROCEDURE_OCCURRENCE_ID,
    A.* 
FROM
(   
    SELECT * FROM {{ref('V_PROCEDURE_OCCURRENCE_CPT_AMB')}} 
    UNION
    SELECT * FROM {{ref('V_PROCEDURE_OCCURRENCE_CPT_HSP')}} 
    UNION
    SELECT * FROM {{ref('V_PROCEDURE_OCCURRENCE_CPT_SURG')}}
) AS A    