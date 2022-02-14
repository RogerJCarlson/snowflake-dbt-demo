--NOTE 

{{ config(materialized = 'view') }} 

SELECT
    DISTINCT SEQ_NOTE.NEXTVAL AS NOTE_ID
    , A.*
FROM
(SELECT *
FROM
     {{ref('V_NOTE_AMB')}}  AS V_NOTE_AMB    
UNION ALL
SELECT *
FROM 
     {{ref('V_NOTE_HSP')}} AS V_NOTE_HSP 
UNION ALL
SELECT *
FROM 
     {{ref('V_NOTE_ANES')}} AS V_NOTE_ANES ) A