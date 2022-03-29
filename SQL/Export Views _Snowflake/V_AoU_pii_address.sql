USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA OMOP;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.pii_address table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_pii_address
AS
SELECT distinct CDM.person.person_id AS "person_id"
	,location_id AS "location_id"
FROM CDM.person 
INNER JOIN CDM.AoU_Driver
	ON CDM.person.person_id = SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMERIC



