--V_AOU_SPECIMEN

{{ config(materialized = 'view') }}


    SELECT  SPECIMEN_ID AS "specimen_id"
          ,PERSON_ID AS "person_id"
          ,SPECIMEN_CONCEPT_ID AS "specimen_concept_id"
          ,SPECIMEN_TYPE_CONCEPT_ID AS "specimen_type_concept_id"
          ,TO_CHAR(SPECIMEN_DATE) AS "specimen_date"
          ,TO_CHAR(SPECIMEN_DATETIME)  AS "specimen_datetime"
          ,QUANTITY AS "quantity"
          ,UNIT_CONCEPT_ID AS "unit_concept_id"
          ,ANATOMIC_SITE_CONCEPT_ID AS "anatomic_site_concept_id"
          ,DISEASE_STATUS_CONCEPT_ID AS "disease_status_concept_id"
          ,SPECIMEN_SOURCE_ID AS "specimen_source_id"
          ,SPECIMEN_SOURCE_VALUE AS "specimen_source_value"
          ,UNIT_SOURCE_VALUE AS "unit_source_value"
          ,ANATOMIC_SITE_SOURCE_VALUE AS "anatomic_site_source_value"
          ,DISEASE_STATUS_SOURCE_VALUE AS "disease_status_source_value"
    FROM {{ref('SPECIMEN')}}

