{{ config(materialized='ephemeral') }}

SELECT C2.CONCEPT_ID AS CONCEPT_ID
    ,C1.CONCEPT_ID AS SOURCE_CONCEPT_ID

    FROM {{ source('CDM','CONCEPT')}} AS  C1
    
    INNER JOIN {{ source('CDM','CONCEPT_RELATIONSHIP')}} AS CR
        ON C1.CONCEPT_ID = CR.CONCEPT_ID_1
            AND CR.RELATIONSHIP_ID = 'Maps to'
    
    INNER JOIN {{ source('CDM','CONCEPT')}} AS C2
        ON C2.CONCEPT_ID = CR.CONCEPT_ID_2

WHERE C2.STANDARD_CONCEPT = 'S'
    AND (
        C2.INVALID_REASON IS NULL
        OR C2.INVALID_REASON = ''
        )
    AND C2.DOMAIN_ID = 'Condition'