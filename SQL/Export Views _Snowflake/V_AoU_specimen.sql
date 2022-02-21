USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.specimen table for export to AoU
-- =============================================

CREATE OR REPLACE VIEW CDM.V_AoU_specimen
AS
    SELECT  specimen_id AS "specimen_id"
          ,person_id AS "person_id"
          ,specimen_concept_id AS "specimen_concept_id"
          ,specimen_type_concept_id AS "specimen_type_concept_id"
          ,to_char(specimen_date) as "specimen_date"
          ,to_char(specimen_datetime)  as "specimen_datetime"
          ,quantity AS "quantity"
          ,unit_concept_id AS "unit_concept_id"
          ,anatomic_site_concept_id AS "anatomic_site_concept_id"
          ,disease_status_concept_id AS "disease_status_concept_id"
          ,specimen_source_id AS "specimen_source_id"
          ,specimen_source_value AS "specimen_source_value"
          ,unit_source_value AS "unit_source_value"
          ,anatomic_site_source_value AS "anatomic_site_source_value"
          ,disease_status_source_value AS "disease_status_source_value"
    FROM CDM.specimen

