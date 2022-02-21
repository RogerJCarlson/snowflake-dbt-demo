-- V_AOU_DRUG_EXPOSURE

{{ config(materialized = 'view') }}

-- automatically exclude 'invalid data' and 'fatal'
SELECT DRUG_EXPOSURE.DRUG_EXPOSURE_ID AS "drug_exposure_id"
        , DRUG_EXPOSURE.PERSON_ID AS "person_id"
        , DRUG_EXPOSURE.DRUG_CONCEPT_ID AS "drug_concept_id"
        , TO_CHAR(DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATE) AS "drug_exposure_start_date"
        , TO_CHAR(DRUG_EXPOSURE.DRUG_EXPOSURE_START_DATETIME)  AS "drug_exposure_start_datetime"
        , TO_CHAR(DRUG_EXPOSURE.DRUG_EXPOSURE_END_DATE) AS "drug_exposure_end_date"
        , TO_CHAR(DRUG_EXPOSURE.DRUG_EXPOSURE_END_DATETIME)  AS "drug_exposure_end_datetime"
        , TO_CHAR(DRUG_EXPOSURE.VERBATIM_END_DATE) AS "verbatim_end_date"
        , DRUG_EXPOSURE.DRUG_TYPE_CONCEPT_ID AS "drug_type_concept_id"
        , DRUG_EXPOSURE.STOP_REASON AS "stop_reason"
        , DRUG_EXPOSURE.REFILLS AS "refills"
        , DRUG_EXPOSURE.QUANTITY AS "quantity"
        , DRUG_EXPOSURE.DAYS_SUPPLY AS "days_supply"
        , REPLACE(DRUG_EXPOSURE.SIG, '"', '') AS "sig"
        , DRUG_EXPOSURE.ROUTE_CONCEPT_ID AS "route_concept_id"
        , DRUG_EXPOSURE.LOT_NUMBER AS "lot_number"
        , DRUG_EXPOSURE.PROVIDER_ID AS "provider_id"
        , DRUG_EXPOSURE.VISIT_OCCURRENCE_ID AS "visit_occurrence_id"
        , DRUG_EXPOSURE.VISIT_DETAIL_ID AS "visit_detail_id"
        , REPLACE(DRUG_EXPOSURE.DRUG_SOURCE_VALUE, '"', '') AS "drug_source_value"
        , DRUG_EXPOSURE.DRUG_SOURCE_CONCEPT_ID AS "drug_source_concept_id"
        , DRUG_EXPOSURE.ROUTE_SOURCE_VALUE AS "route_source_value"
        , DRUG_EXPOSURE.DOSE_UNIT_SOURCE_VALUE AS "dose_unit_source_value"

    FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE
    LEFT JOIN (
        SELECT CDT_ID
        FROM {{ref('QA_ERR')}} AS QA_ERR
        WHERE (STANDARD_DATA_TABLE = 'DRUG_EXPOSURE')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON DRUG_EXPOSURE.DRUG_EXPOSURE_ID = EXCLUSION_RECORDS.CDT_ID
    WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL)