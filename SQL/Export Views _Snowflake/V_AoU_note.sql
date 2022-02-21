USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.note table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_note
AS
    SELECT note_id AS "note_id"
        , person_id AS "person_id"
        , to_char(note_date) AS "note_date"
        , to_char(note_datetime)  AS "note_datetime"
        , note_type_concept_id AS "note_type_concept_id"
        , note_class_concept_id AS "note_class_concept_id"
        , note_title AS "note_title"
        , note_text AS "note_text"
        , encoding_concept_id AS "encoding_concept_id"
        , language_concept_id AS "language_concept_id"
        , provider_id AS "provider_id"
        , visit_occurrence_id AS "visit_occurrence_id"
        , visit_detail_id AS "visit_detail_id"
        , note_source_value AS "note_source_value"
    FROM CDM.note
