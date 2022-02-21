USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify OMOP.pii_validation table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_pii_validation
AS
SELECT person_id AS "person_id"
      ,first_name AS "first_name"
      ,last_name AS "last_name"
      ,DOB AS "dob"
      ,sex AS "sex"
      ,address AS "address"
      ,phone_number AS "phone_number"
      ,email AS "email"
      ,algorithm_validation AS "algorithm_validation"
      ,Manual_Validation AS "manual_validation"
  FROM CDM.AoU_PII_Validation


