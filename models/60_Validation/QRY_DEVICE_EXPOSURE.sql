--OMOP_CS.QRY_DEVICE_EXPOSURE 

SELECT DEVICE_EXPOSURE.DEVICE_EXPOSURE_ID
    , DEVICE_EXPOSURE.PERSON_ID
    , LEFT(DEVICE_CONCEPT_ID || '::' || CONCEPT.CONCEPT_NAME, 100) AS DEVICE
    , DEVICE_EXPOSURE.DEVICE_EXPOSURE_START_DATETIME
    , DEVICE_EXPOSURE.DEVICE_EXPOSURE_END_DATETIME
    , DEVICE_TYPE_CONCEPT_ID || '::' || CONCEPT_1.CONCEPT_NAME AS DEVICE_TYPE
    , DEVICE_EXPOSURE.UNIQUE_DEVICE_ID
    , DEVICE_EXPOSURE.QUANTITY
    , PROVIDER.PROVIDER_NAME
    , DEVICE_EXPOSURE.VISIT_OCCURRENCE_ID
    , DEVICE_EXPOSURE.DEVICE_SOURCE_VALUE
    , DEVICE_SOURCE_CONCEPT_ID || '::' || CONCEPT_2.CONCEPT_NAME AS DEVICE_SOURCE_CONCEPT
    , DEVICE_EXPOSURE.PROVIDER_ID
    , 'DEVICE' AS SDT_TAB
    , VISIT_OCCURRENCE.PERSON_ID || DEVICE_SOURCE_VALUE || DEVICE_EXPOSURE_START_DATETIME AS NK
    , DEVICE_EXPOSURE.ETL_MODULE
    , VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

FROM (
    (
        (
            (
                {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE LEFT JOIN {{ref('PROVIDER')}} AS PROVIDER
                    ON DEVICE_EXPOSURE.PROVIDER_ID = PROVIDER.PROVIDER_ID
                ) LEFT JOIN {{ source('CDM','CONCEPT')}} AS CONCEPT
                ON DEVICE_EXPOSURE.DEVICE_CONCEPT_ID = CONCEPT.CONCEPT_ID
            ) LEFT JOIN {{ source('CDM','CONCEPT')}} AS CONCEPT_1
            ON DEVICE_EXPOSURE.DEVICE_TYPE_CONCEPT_ID = CONCEPT_1.CONCEPT_ID
        ) LEFT JOIN {{ source('CDM','CONCEPT')}} AS CONCEPT_2
        ON DEVICE_EXPOSURE.DEVICE_SOURCE_CONCEPT_ID = CONCEPT_2.CONCEPT_ID
    )

INNER JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
    ON DEVICE_EXPOSURE.VISIT_OCCURRENCE_ID = VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID