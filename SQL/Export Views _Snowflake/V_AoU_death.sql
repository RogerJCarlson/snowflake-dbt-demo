USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.death table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AOU_DEATH
AS

     SELECT  PERSON_ID AS "person_id"
          , TO_CHAR(DEATH_DATE) AS  "death_date" 
          , TO_CHAR(DEATH_DATETIME)  AS  "death_datetime" 
          , DEATH_TYPE_CONCEPT_ID AS "death_type_concept_id"
          , CAUSE_CONCEPT_ID AS "cause_concept_id"
          , CAUSE_SOURCE_VALUE  AS "cause_source_value"
          , CAUSE_SOURCE_CONCEPT_ID AS "cause_source_concept_id"
      FROM  CDM.DEATH 

