--V_AOU_NOTE

{{ config(materialized = 'view') }}

SELECT note_id AS "note_id"
    , person_id AS "person_id"
    , to_char(note_date) AS "note_date"
    , to_char(note_datetime)  AS "note_datetime"
    , note_type_concept_id AS "note_type_concept_id"
    , note_class_concept_id AS "note_class_concept_id"
    , note_title AS "note_title"
    , note_text AS "note_text"
    , encoding_concept_id AS "encoding_concept_id"
    , language_concept_id AS "language_concept_id"
    , provider_id AS "provider_id"
    , visit_occurrence_id AS "visit_occurrence_id"
    , visit_detail_id AS "visit_detail_id"
    , note_source_value AS "note_source_value"
FROM 
    {{ref('NOTE')}} AS NOTE
