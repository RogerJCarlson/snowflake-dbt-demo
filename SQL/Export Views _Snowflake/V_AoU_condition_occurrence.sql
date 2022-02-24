USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.condition_occurrence table for export to AoU
-- =============================================
CREATE
	OR REPLACE VIEW CDM.V_AoU_condition_occurrence AS
    SELECT condition_occurrence_id AS  "condition_occurrence_id"
        , person_id AS  "person_id"
        , to_char(condition_concept_id) AS  "condition_concept_id"
        , to_char(condition_start_date, 'YYYY-MM-DD') AS "condition_start_date"
        , to_char(condition_start_datetime, 'YYYY-MM-DD HH24:MI:SS')  AS "condition_start_datetime"
        , to_char(condition_start_datetime, 'YYYY-MM-DD') AS "condition_end_date"
        , to_char(condition_start_datetime, 'YYYY-MM-DD HH24:MI:SS')  AS "condition_end_datetime"
        , to_char(condition_type_concept_id) AS "condition_type_concept_id"
        , condition_status_concept_id  AS "condition_status_concept_id"        
        , stop_reason AS "stop_reason"
        , provider_id AS "provider_id"
        , visit_occurrence_id AS  "visit_occurrence_id"
        , visit_detail_id AS "visit_detail_id"
        , condition_source_value AS "condition_source_value"
        , condition_source_concept_id AS  "condition_source_concept_id"
        , condition_status_source_value AS "condition_status_source_value"

    FROM CDM.condition_occurrence


