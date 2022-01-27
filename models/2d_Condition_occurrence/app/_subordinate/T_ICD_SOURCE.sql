{{ config(materialized='ephemeral') }}

SELECT CONCEPT_ID
    ,CONCEPT_CODE
    ,REPLACE(CONCEPT_NAME, '"', '') AS CONCEPT_NAME

FROM {{ source('CDM','CONCEPT')}} AS C

WHERE C.VOCABULARY_ID IN ('ICD9CM','ICD10CM')
    AND (
        C.INVALID_REASON IS NULL
        OR C.INVALID_REASON = ''
        )
    AND C.DOMAIN_ID = 'Condition'