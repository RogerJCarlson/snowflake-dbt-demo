USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.fact_relationship table for export to AoU
-- =============================================
CREATE
	OR REPLACE VIEW CDM.V_AoU_fact_relationship AS
SELECT domain_concept_id_1 AS "domain_concept_id_1"
	, fact_id_1 AS "fact_id_1"
	, domain_concept_id_2 AS "domain_concept_id_2"
	, fact_id_2 AS "fact_id_2"
	, relationship_concept_id AS "relationship_concept_id"
FROM CDM.fact_relationship
