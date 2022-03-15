--   V_AOU_CARE_SITE

{{ config(materialized = 'view') }}

SELECT
    CARE_SITE_ID AS "care_site_id"
    , CARE_SITE_NAME AS "care_site_name"
    , PLACE_OF_SERVICE_CONCEPT_ID AS "place_of_service_concept_id"
    , LOCATION_ID AS "location_id"
    , CARE_SITE_SOURCE_VALUE AS "care_site_source_value"
    , PLACE_OF_SERVICE_SOURCE_VALUE AS "place_of_service_source_value"
FROM
   {{ref('CARE_SITE')}} AS CARE_SITE
LEFT JOIN (
    SELECT CDT_ID
    FROM {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
        WHERE (STANDARD_DATA_TABLE = 'CARE_SITE')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON CARE_SITE.CARE_SITE_ID = EXCLUSION_RECORDS.CDT_ID
WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL)