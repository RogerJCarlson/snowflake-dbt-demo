--CONDITION_OCCURRENCE 

{{ config(materialized = 'table') }} 

SELECT
    DISTINCT SEQ_CONDITION_OCCURRENCE.NEXTVAL AS CONDITION_OCCURRENCE_ID
    , A.*
FROM
(SELECT *
FROM
     {{ref('V_CONDITION_OCCURRENCE_AMB')}} AS V_CONDITION_OCCURRENCE_AMB    
UNION
SELECT *
FROM 
     {{ref('V_CONDITION_OCCURRENCE_HSP')}} AS V_CONDITION_OCCURRENCE_HSP ) A