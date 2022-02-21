USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.provider table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_provider
AS
    WITH providers_referenced
    AS (
        SELECT PROVIDER_ID
        FROM CDM.CONDITION_OCCURRENCE
        UNION
        SELECT PROVIDER_ID
        FROM CDM.DEVICE_EXPOSURE
        UNION
        SELECT PROVIDER_ID
        FROM CDM.DRUG_EXPOSURE
        UNION
        SELECT PROVIDER_ID
        FROM CDM.MEASUREMENT
        UNION
        SELECT PROVIDER_ID
        FROM CDM.NOTE
        UNION
        SELECT PROVIDER_ID
        FROM CDM.OBSERVATION
        UNION
        SELECT PROVIDER_ID
        FROM CDM.PERSON
        UNION
        SELECT PROVIDER_ID
        FROM CDM.PROCEDURE_OCCURRENCE
        UNION
        SELECT PROVIDER_ID
        FROM CDM.VISIT_OCCURRENCE
        )
    SELECT provider.provider_id AS "provider_id"
        , provider_name AS "provider_name"
        , NPI AS "npi"
        , DEA AS "dea"
        , specialty_concept_id AS "specialty_concept_id"
        , care_site_id AS "care_site_id"
        , year_of_birth AS "year_of_birth"
        , gender_concept_id AS "gender_concept_id"
        , provider_source_value AS "provider_source_value"
        , specialty_source_value AS "specialty_source_value"
        , specialty_source_concept_id AS "specialty_source_concept_id"
        , gender_source_value AS "gender_source_value"
        , gender_source_concept_id AS "gender_source_concept_id"
    FROM CDM.provider
    INNER JOIN providers_referenced
        ON providers_referenced.provider_id = provider.provider_id



