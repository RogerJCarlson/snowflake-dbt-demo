--NOTE 

{{ config(materialized = 'table') }} 

SELECT
     SEQ_NOTE.NEXTVAL::NUMBER(28,0)          AS NOTE_ID
    , PERSON_ID::NUMBER(28,0)                AS PERSON_ID
    , NOTE_DATE::DATE                        AS NOTE_DATE
    , NOTE_DATETIME::DATETIME                AS NOTE_DATETIME
    , NOTE_TYPE_CONCEPT_ID::NUMBER(28,0)     AS NOTE_TYPE_CONCEPT_ID
    , NOTE_CLASS_CONCEPT_ID::NUMBER(28,0)    AS NOTE_CLASS_CONCEPT_ID
    , NOTE_TITLE::VARCHAR(250)               AS NOTE_TITLE
    , NOTE_TEXT::VARCHAR                     AS NOTE_TEXT
    , ENCODING_CONCEPT_ID::NUMBER(28,0)      AS ENCODING_CONCEPT_ID
    , LANGUAGE_CONCEPT_ID::NUMBER(28,0)      AS LANGUAGE_CONCEPT_ID
    , PROVIDER_ID::NUMBER(28,0)              AS PROVIDER_ID
    , VISIT_OCCURRENCE_ID::NUMBER(28,0)      AS VISIT_OCCURRENCE_ID
    , VISIT_DETAIL_ID::NUMBER(28,0)          AS VISIT_DETAIL_ID
    , NOTE_SOURCE_VALUE::VARCHAR(50)         AS NOTE_SOURCE_VALUE
    , ETL_MODULE::VARCHAR(100)               AS ETL_MODULE
    , VISIT_SOURCE_VALUE::VARCHAR(50)        AS VISIT_SOURCE_VALUE
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