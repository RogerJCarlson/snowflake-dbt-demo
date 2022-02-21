USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.drug_exposure table for export to AoU
-- Removes records where EndDate < StartDate 
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AOU_DRUG_EXPOSURE
AS

-- automatically exclude 'invalid data' and 'fatal'
SELECT CDM.DRUG_EXPOSURE.DRUG_EXPOSURE_ID AS "drug_exposure_id"
        , CDM.DRUG_EXPOSURE.PERSON_ID AS "person_id"
        , CDM.DRUG_EXPOSURE.DRUG_CONCEPT_ID AS "drug_concept_id"
        , TO_CHAR(CDM.DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE) AS "drug_exposure_start_date"
        , TO_CHAR(CDM.DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATETIME)  AS "drug_exposure_start_datetime"
        , TO_CHAR(CDM.DRUG_EXPOSURE.DRUG_EXPOSURE_END_DATE) AS "drug_exposure_end_date"
        , TO_CHAR(CDM.DRUG_EXPOSURE.DRUG_EXPOSURE_END_DATETIME)  AS "drug_exposure_end_datetime"
        , TO_CHAR(CDM.DRUG_EXPOSURE.VERBATIM_END_DATE) AS "verbatim_end_date"
        , CDM.DRUG_EXPOSURE.DRUG_TYPE_CONCEPT_ID AS "drug_type_concept_id"
        , CDM.DRUG_EXPOSURE.STOP_REASON AS "stop_reason"
        , CDM.DRUG_EXPOSURE.REFILLS AS "refills"
        , CDM.DRUG_EXPOSURE.QUANTITY AS "quantity"
        , CDM.DRUG_EXPOSURE.DAYS_SUPPLY AS "days_supply"
        , REPLACE(CDM.DRUG_EXPOSURE.SIG, '"', '') AS "sig"
        , CDM.DRUG_EXPOSURE.ROUTE_CONCEPT_ID AS "route_concept_id"
        , CDM.DRUG_EXPOSURE.LOT_NUMBER AS "lot_number"
        , CDM.DRUG_EXPOSURE.PROVIDER_ID AS "provider_id"
        , CDM.DRUG_EXPOSURE.VISIT_OCCURRENCE_ID AS "visit_occurrence_id"
        , CDM.DRUG_EXPOSURE.VISIT_DETAIL_ID AS "visit_detail_id"
        , REPLACE(CDM.DRUG_EXPOSURE.DRUG_SOURCE_VALUE, '"', '') AS "drug_source_value"
        , CDM.DRUG_EXPOSURE.DRUG_SOURCE_CONCEPT_ID AS "drug_source_concept_id"
        , CDM.DRUG_EXPOSURE.ROUTE_SOURCE_VALUE AS "route_source_value"
        , CDM.DRUG_EXPOSURE.DOSE_UNIT_SOURCE_VALUE AS "dose_unit_source_value"
    FROM CDM.DRUG_EXPOSURE
    LEFT JOIN (
        SELECT CDT_ID
        FROM OMOP_QA.QA_ERR
        WHERE (STANDARD_DATA_TABLE = 'DRUG_EXPOSURE')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON CDM.DRUG_EXPOSURE.DRUG_EXPOSURE_ID = EXCLUSION_RECORDS.CDT_ID
    WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL)

