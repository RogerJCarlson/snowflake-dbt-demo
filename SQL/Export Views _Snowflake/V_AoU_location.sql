USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify EpicCare.CDM.location table for export to AoU
-- =============================================
CREATE
	OR REPLACE VIEW CDM.V_AoU_location AS
    SELECT location_id AS "location_id"
        , replace(address_1, '"', '') AS "address_1"
        , replace(address_2, '"', '') AS "address_2"
        , replace(city, '"', '') AS "city"
        , replace(STATE, '"', '') AS "state"
        , replace(zip, '"', '') AS "zip"
        , replace(county, '"', '') AS "county"
        , replace(location_source_value, '"', '') AS "location_source_value"
    FROM CDM.location


