--V_AOU_PERSON

{{ config(materialized = 'view') }}

SELECT person_id AS "person_id"
      ,gender_concept_id AS "gender_concept_id"
      ,year_of_birth AS "year_of_birth"
      ,month_of_birth AS "month_of_birth"
      ,day_of_birth AS "day_of_birth"
      ,to_char(birth_datetime)  as "birth_datetime"
      ,race_concept_id AS "race_concept_id"
      ,ethnicity_concept_id AS "ethnicity_concept_id"
      ,location_id AS "location_id"
      ,provider_id AS "provider_id"
      ,care_site_id AS "care_site_id"
      ,person_source_value AS "person_source_value"
      ,gender_source_value AS "gender_source_value"
      ,gender_source_concept_id AS "gender_source_concept_id"
      ,race_source_value AS "race_source_value"
      ,race_source_concept_id AS "race_source_concept_id"
      ,ethnicity_source_value AS "ethnicity_source_value"
      ,ethnicity_source_concept_id AS "ethnicity_source_concept_id"
  FROM
   {{ref('PERSON')}} AS PERSON