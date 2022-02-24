--V_AOU_PROCEDURE_OCCURRENCE

{{ config(materialized = 'view') }}

SELECT procedure_occurrence_id AS "procedure_occurrence_id"
    ,person_id AS "person_id"
    ,procedure_concept_id AS "procedure_concept_id"
    ,to_char(procedure_date) as "procedure_date"
    ,to_char(procedure_datetime)  as "procedure_datetime"
    ,procedure_type_concept_id AS "procedure_type_concept_id"
    ,modifier_concept_id AS "modifier_concept_id"
    ,quantity AS "quantity"
    ,provider_id AS "provider_id"
    ,visit_occurrence_id AS "visit_occurrence_id"
    ,VISIT_DETAIL_ID AS "visit_detail_id"
    ,procedure_source_value AS "procedure_source_value"
    ,procedure_source_concept_id AS "procedure_source_concept_id"
    ,modifier_source_value AS "modifier_source_value"

FROM 
    {{ref('PROCEDURE_OCCURRENCE')}} AS PROCEDURE_OCCURRENCE
