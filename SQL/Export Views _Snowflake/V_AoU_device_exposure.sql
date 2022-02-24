USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
-- =============================================
-- Author:		Roger Carlson
-- Create date: 05-21-2021
-- Description:	Modify CDM.device_exposure table for export to AoU
-- =============================================
CREATE OR REPLACE VIEW CDM.V_AoU_device_exposure
AS
SELECT CDM.device_exposure.device_exposure_id AS "device_exposure_id"
    , CDM.device_exposure.person_id AS "person_id"
    , CDM.device_exposure.device_concept_id AS "device_concept_id"
    , to_char(CDM.device_exposure.device_exposure_start_date) AS "device_exposure_start_date"
    , to_char(CDM.device_exposure.device_exposure_start_datetime)  AS "device_exposure_start_datetime"
    , to_char(CDM.device_exposure.device_exposure_end_date) AS "device_exposure_end_date"
    , to_char(CDM.device_exposure.device_exposure_end_datetime)  AS "device_exposure_end_datetime"
    , CDM.device_exposure.device_type_concept_id AS "device_type_concept_id"
    , CDM.device_exposure.unique_device_id AS "unique_device_id"
    , CDM.device_exposure.quantity AS "quantity"
    , CDM.device_exposure.provider_id AS "provider_id"
    , CDM.device_exposure.visit_occurrence_id AS "visit_occurrence_id"
    , CDM.device_exposure.visit_detail_id AS "visit_detail_id"
    , CDM.device_exposure.device_source_value AS "device_source_value"
    , CDM.device_exposure.device_source_concept_id AS "device_source_concept_id"
FROM CDM.DEVICE_EXPOSURE
LEFT JOIN (
    SELECT CDT_ID
    FROM OMOP_QA.QA_ERR
    WHERE (STANDARD_DATA_TABLE = 'DEVICE_EXPOSURE')
        AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
    ) AS EXCLUSION_RECORDS
    ON CDM.DEVICE_EXPOSURE.DEVICE_EXPOSURE_ID = EXCLUSION_RECORDS.CDT_ID
WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL)

