--V_AOU_OBSERVATION

{{ config(materialized = 'view') }}

SELECT observation_id AS "observation_id"
        ,person_id AS "person_id"
        ,observation_concept_id AS "observation_concept_id"
        ,to_char(observation_date) as "observation_date"
        ,to_char(observation_datetime)  as "observation_datetime"
        ,observation_type_concept_id AS "observation_type_concept_id"
        ,value_as_number AS "value_as_number"
        ,value_as_string AS "value_as_string"
        ,value_as_concept_id AS "value_as_concept_id"
        ,qualifier_concept_id AS "qualifier_concept_id"
        ,unit_concept_id AS "unit_concept_id"
        ,provider_id AS "provider_id"
        ,visit_occurrence_id AS "visit_occurrence_id"
        ,visit_detail_id AS "visit_detail_id"
        ,observation_source_value AS "observation_source_value"
        ,observation_source_concept_id AS "observation_source_concept_id"
        ,unit_source_value AS "unit_source_value"
        ,qualifier_source_value AS "qualifier_source_value"
    FROM 
        {{ref('OBSERVATION')}} AS OBSERVATION
LEFT JOIN (
    SELECT CDT_ID
    FROM {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
        WHERE (STANDARD_DATA_TABLE = 'OBSERVATION')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON OBSERVATION.OBSERVATION_ID = EXCLUSION_RECORDS.CDT_ID
WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL) 