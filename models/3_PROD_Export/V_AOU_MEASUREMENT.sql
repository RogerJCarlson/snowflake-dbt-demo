--   V_AOU_MEASUREMENT

{{ config(materialized = 'view') }}

SELECT  measurement_id AS "measurement_id"
        , person_id  AS "person_id"
        , measurement_concept_id AS "measurement_concept_id"
        , to_char(measurement_date) as "measurement_date"
        , to_char(measurement_datetime)  as "measurement_datetime"
        , NULL AS "measurement_time"
        , measurement_type_concept_id  AS "measurement_type_concept_id"
        , operator_concept_id AS "operator_concept_id"
        , value_as_number AS "value_as_number"
        , value_as_concept_id AS "value_as_concept_id"
        , unit_concept_id AS "unit_concept_id"
        , range_low AS "range_low"
        , range_high AS "range_high"
        , provider_id AS "provider_id"
        , visit_occurrence_id AS "visit_occurrence_id"
        , visit_detail_id AS "visit_detail_id"
        , measurement_source_value AS "measurement_source_value"
        , measurement_source_concept_id AS "measurement_source_concept_id"
        , unit_source_value AS "unit_source_value"
        , value_source_value AS "value_source_value"
    FROM  
    {{ref('MEASUREMENT')}} AS MEASUREMENT 