-- V_AOU_VISIT_OCCURRENCE

{{ config(materialized = 'view') }}

SELECT visit_occurrence_id AS "visit_occurrence_id"
    ,person_id AS "person_id"
    ,visit_concept_id AS "visit_concept_id"
    ,to_char(visit_start_date) as "visit_start_date"
    ,to_char(visit_start_datetime)  as "visit_start_datetime"
    ,to_char(visit_end_date) as "visit_end_date"
    ,to_char(visit_end_datetime)  as "visit_end_datetime"
    ,visit_type_concept_id AS "visit_type_concept_id"
    ,provider_id AS "provider_id"
    ,care_site_id AS "care_site_id"
    ,visit_source_value AS "visit_source_value"
    ,visit_source_concept_id AS "visit_source_concept_id"
    ,admitting_source_concept_id AS "admitting_source_concept_id"
    ,admitting_source_value AS "admitting_source_value"
    ,discharge_to_concept_id AS "discharge_to_concept_id"
    ,discharge_to_source_value AS "discharge_to_source_value"
    ,preceding_visit_occurrence_id AS "preceding_visit_occurrence_id"

FROM {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
