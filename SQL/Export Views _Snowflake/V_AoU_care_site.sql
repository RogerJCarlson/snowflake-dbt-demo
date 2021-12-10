USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify EpicCare.CDM.care_site table for export to AoU
-- =============================================

CREATE
	OR REPLACE VIEW CDM.V_AOU_CARE_SITE AS
SELECT
    CARE_SITE_ID AS "care_site_id"
    , CARE_SITE_NAME AS "care_site_name"
    , PLACE_OF_SERVICE_CONCEPT_ID AS "place_of_service_concept_id"
    , LOCATION_ID AS "location_id"
    , CARE_SITE_SOURCE_VALUE AS "care_site_source_value"
    , PLACE_OF_SERVICE_SOURCE_VALUE AS "place_of_service_source_value"
FROM
    CDM.CARE_SITE
