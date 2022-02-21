USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.visit_occurrence table for export to AoU
--		UPDATE: 9/25/2020 Exclude visits with Visit_Concept_ID = 0		
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_visit_occurrence
AS
    SELECT visit_occurrence_id AS "visit_occurrence_id"
          ,person_id AS "person_id"
          ,visit_concept_id AS "visit_concept_id"
          ,to_char(visit_start_date) as "visit_start_date"
          ,to_char(visit_start_datetime)  as "visit_start_datetime"
          ,to_char(visit_end_date) as "visit_end_date"
          ,to_char(visit_end_datetime)  as "visit_end_datetime"
          ,visit_type_concept_id AS "visit_type_concept_id"
          ,provider_id AS "provider_id"
          ,care_site_id AS "care_site_id"
          ,visit_source_value AS "visit_source_value"
          ,visit_source_concept_id AS "visit_source_concept_id"
          ,admitting_source_concept_id AS "admitting_source_concept_id"
          ,admitting_source_value AS "admitting_source_value"
          ,discharge_to_concept_id AS "discharge_to_concept_id"
          ,discharge_to_source_value AS "discharge_to_source_value"
          ,preceding_visit_occurrence_id AS "preceding_visit_occurrence_id"
    FROM CDM.visit_occurrence


