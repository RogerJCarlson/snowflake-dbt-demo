--V_AOU_VISIT_DETAIL

{{ config(materialized = 'view') }}

SELECT DISTINCT
    VISIT_DETAIL_ID AS "visit_detail_id"
    , PERSON_ID AS "person_id"
    , VISIT_DETAIL_CONCEPT_ID AS "visit_detail_concept_id"
    , to_char(VISIT_DETAIL_START_DATE) AS "visit_detail_start_date"
    , to_char(VISIT_DETAIL_START_DATETIME)  AS "visit_detail_start_datetime"
    , to_char(VISIT_DETAIL_END_DATE) AS "visit_detail_end_date"
    , to_char(VISIT_DETAIL_END_DATETIME)  AS "visit_detail_end_datetime"
    , VISIT_DETAIL_TYPE_CONCEPT_ID AS "visit_detail_type_concept_id"
    , ATTENDING_PROV AS "provider_id"
    , CARE_SITE_ID AS "care_site_id"
    , VISIT_DETAIL_SOURCE_VALUE AS "visit_detail_source_value"
    , VISIT_DETAIL_SOURCE_CONCEPT_ID AS "visit_detail_source_concept_id"
    , ADMITTING_SOURCE_VALUE AS "admitting_source_value"
    , ADMITTING_SOURCE_CONCEPT_ID AS "admitting_source_concept_id"
    , DISCHARGE_TO_SOURCE_VALUE AS "discharge_to_source_value"
    , DISCHARGE_TO_CONCEPT_ID AS "discharge_to_concept_id"
    , PRECEDING_VISIT_DETAIL_ID AS "preceding_visit_detail_id"
    , VISIT_DETAIL_PARENT_ID AS "visit_detail_parent_id"
    , VISIT_OCCURRENCE_ID AS "visit_occurrence_id"

FROM
    {{ref('VISIT_DETAIL')}} AS VISIT_DETAIL 
LEFT JOIN (
    SELECT CDT_ID
    FROM {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
        WHERE (STANDARD_DATA_TABLE = 'VISIT_DETAIL')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON VISIT_DETAIL.VISIT_DETAIL_ID = EXCLUSION_RECORDS.CDT_ID
WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL) 

