USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.procedure_occurrence table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_procedure_occurrence
AS
    SELECT procedure_occurrence_id AS "procedure_occurrence_id"
          ,person_id AS "person_id"
          ,procedure_concept_id AS "procedure_concept_id"
          ,to_char(procedure_date) as "procedure_date"
          ,to_char(procedure_datetime)  as "procedure_datetime"
          ,procedure_type_concept_id AS "procedure_type_concept_id"
          ,modifier_concept_id AS "modifier_concept_id"
          ,quantity AS "quantity"
          ,provider_id AS "provider_id"
          ,visit_occurrence_id AS "visit_occurrence_id"
          ,VISIT_DETAIL_ID AS "visit_detail_id"
          ,procedure_source_value AS "procedure_source_value"
          ,procedure_source_concept_id AS "procedure_source_concept_id"
          ,modifier_source_value AS "modifier_source_value"
    FROM CDM.procedure_occurrence