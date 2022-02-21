USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.observation table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_observation
AS
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
      FROM CDM.observation