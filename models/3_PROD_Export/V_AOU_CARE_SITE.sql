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