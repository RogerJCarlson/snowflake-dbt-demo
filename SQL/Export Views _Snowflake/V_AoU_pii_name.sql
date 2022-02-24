USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.pii_name table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_pii_name
AS

SELECT distinct CDM.person.person_id AS "person_id"
	,first_name AS "first_name"
	,NULL AS "middle_name"
	,last_name AS "last_name"
	,NULL AS "suffix"
	,NULL AS "prefix"
FROM CDM.person
INNER JOIN CDM.AoU_Driver
	ON CDM.person.person_id = SUBSTRING(CDM.AoU_Driver.AoU_ID, 2, LEN(CDM.AoU_Driver.AoU_ID))


