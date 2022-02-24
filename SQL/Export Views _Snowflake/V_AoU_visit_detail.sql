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
CREATE OR REPLACE VIEW CDM.V_AoU_visit_detail
AS
    SELECT DISTINCT
    VISIT_DETAIL_ID AS "visit_detail_id"
    , PERSON_ID AS "person_id"
    , VISIT_DETAIL_CONCEPT_ID AS "visit_detail_concept_id"
    , to_char(VISIT_DETAIL_START_DATE) AS "visit_detail_start_date"
    , to_char(VISIT_DETAIL_START_DATETIME)  AS "visit_detail_start_datetime"
    , to_char(VISIT_DETAIL_END_DATE) AS "visit_detail_end_date"
    , to_char(VISIT_DETAIL_END_DATETIME)  AS "visit_detail_end_datetime"
    , VISIT_DETAIL_TYPE_CONCEPT_ID AS "visit_detail_type_concept_id"
    , PROVIDER_ID AS "provider_id"
    , CARE_SITE_ID AS "care_site_id"
    , VISIT_DETAIL_SOURCE_VALUE AS "visit_detail_source_value"
    , VISIT_DETAIL_SOURCE_CONCEPT_ID AS "visit_detail_source_concept_id"
    , ADMITTING_SOURCE_VALUE AS "admitting_source_value"
    , ADMITTING_SOURCE_CONCEPT_ID AS "admitting_source_concept_id"
    , DISCHARGE_TO_SOURCE_VALUE AS "discharge_to_source_value"
    , DISCHARGE_TO_CONCEPT_ID AS "discharge_to_concept_id"
    , PRECEDING_VISIT_DETAIL_ID AS "preceding_visit_detail_id"
    , VISIT_DETAIL_PARENT_ID AS "visit_detail_parent_id"
    , VISIT_OCCURRENCE_ID AS "visit_occurrence_id"

FROM
    CDM.VISIT_DETAIL 


