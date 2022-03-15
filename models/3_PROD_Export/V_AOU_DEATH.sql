--   V_AOU_DEATH

{{ config(materialized = 'view') }}

SELECT  PERSON_ID AS "person_id"
    , TO_CHAR(DEATH_DATE) AS  "death_date" 
    , TO_CHAR(DEATH_DATETIME)  AS  "death_datetime" 
    , DEATH_TYPE_CONCEPT_ID AS "death_type_concept_id"
    , CAUSE_CONCEPT_ID AS "cause_concept_id"
    , CAUSE_SOURCE_VALUE  AS "cause_source_value"
    , CAUSE_SOURCE_CONCEPT_ID AS "cause_source_concept_id"
FROM  {{ref('DEATH')}} AS DEATH


