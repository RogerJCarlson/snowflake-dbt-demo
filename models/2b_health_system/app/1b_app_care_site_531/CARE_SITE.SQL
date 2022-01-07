{{ config(materialized='table') }}

SELECT DISTINCT POS_ID AS care_site_id
    , POS_NAME AS care_site_name
  , COALESCE(source_to_concept_map_pos.target_concept_id, 0) AS place_of_service_concept_id
    , location_id AS location_id
  , left(cast(POS_ID AS VARCHAR) || ':' || POS_NAME, 50) AS care_site_source_value
    , POS_TYPE AS place_of_service_source_value
    
FROM {{ ref('CARE_SITE_CLARITY_ALL')}} AS CARE_SITE_CLARITY_ALL   
  LEFT JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}}	AS SOURCE_TO_CONCEPT_MAP_POS
      ON SOURCE_TO_CONCEPT_MAP_POS.SOURCE_CODE = CARE_SITE_CLARITY_ALL.POS_TYPE
          AND SOURCE_TO_CONCEPT_MAP_POS.SOURCE_VOCABULARY_ID IN ('sh_pos')



