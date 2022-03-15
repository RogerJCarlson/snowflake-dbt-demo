--V_AOU_CONDITION_OCCURRENCE

{{ config(materialized = 'view') }}

SELECT condition_occurrence_id AS  "condition_occurrence_id"
    , person_id AS  "person_id"
    , to_char(condition_concept_id) AS  "condition_concept_id"
    , to_char(condition_start_date, 'YYYY-MM-DD') AS "condition_start_date"
    , to_char(condition_start_datetime, 'YYYY-MM-DD HH24:MI:SS')  AS "condition_start_datetime"
    , to_char(condition_start_datetime, 'YYYY-MM-DD') AS "condition_end_date"
    , to_char(condition_start_datetime, 'YYYY-MM-DD HH24:MI:SS')  AS "condition_end_datetime"
    , to_char(condition_type_concept_id) AS "condition_type_concept_id"
    , condition_status_concept_id  AS "condition_status_concept_id"        
    , stop_reason AS "stop_reason"
    , provider_id AS "provider_id"
    , visit_occurrence_id AS  "visit_occurrence_id"
    , visit_detail_id AS "visit_detail_id"
    , condition_source_value AS "condition_source_value"
    , condition_source_concept_id AS  "condition_source_concept_id"
    , condition_status_source_value AS "condition_status_source_value"

FROM 
   {{ref('CONDITION_OCCURRENCE')}} CONDITION_OCCURRENCE
LEFT JOIN (
    SELECT CDT_ID
    FROM {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
        WHERE (STANDARD_DATA_TABLE = 'CONDITION_OCCURRENCE')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON CONDITION_OCCURRENCE.CONDITION_OCCURRENCE_ID = EXCLUSION_RECORDS.CDT_ID
WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL)