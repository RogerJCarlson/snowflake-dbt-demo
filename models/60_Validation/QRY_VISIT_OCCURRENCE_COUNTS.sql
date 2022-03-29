-- OMOP_CS.QRY_VISIT_OCCURRENCE_COUNTS 
{{ config(materialized = 'table', schema='OMOP_CS') }}

SELECT
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID
    , QRY_VISIT_OCCURRENCE.PERSON_ID
    , COALESCE(COUNTOFCONDITION   , 0) AS C
    , COALESCE(COUNTOFPROCEDURE   , 0) AS P
    , COALESCE(COUNTOFMEASUREMENT , 0) AS M
    , COALESCE(COUNTOFDRUG        , 0) AS RX
    , COALESCE(COUNTOFOBSERVATION , 0) AS O
    , COALESCE(COUNTOFDEVICE      , 0) AS D
    , COALESCE(COUNTOFNOTE        , 0) AS N
    , QRY_VISIT_OCCURRENCE.VISIT_START_DATETIME
    , QRY_VISIT_OCCURRENCE.VISIT_END_DATETIME
    , QRY_VISIT_OCCURRENCE.VISIT_TYPE
    , QRY_VISIT_OCCURRENCE.PROVIDER
    , QRY_VISIT_OCCURRENCE.CARE_SITE
    , QRY_VISIT_OCCURRENCE.VISIT_SOURCE_VALUE
    , QRY_VISIT_OCCURRENCE.VISIT
    , QRY_VISIT_OCCURRENCE.ADMITTING_SOURCE
    , QRY_VISIT_OCCURRENCE.ADMITTING_SOURCE_VALUE
    , QRY_VISIT_OCCURRENCE.ADMITTING_SOURCE_CONCEPT_ID
    , QRY_VISIT_OCCURRENCE.DISCHARGE
    , QRY_VISIT_OCCURRENCE.DISCHARGE_TO_SOURCE_VALUE
    , QRY_VISIT_OCCURRENCE.VISIT_SOURCE_CONCEPT_ID
    , QRY_VISIT_OCCURRENCE.DISCHARGE_TO_CONCEPT_ID
    , QRY_VISIT_OCCURRENCE.PRECEDING_VISIT_OCCURRENCE_ID
    , QRY_VISIT_OCCURRENCE.SDT_TAB
    , QRY_VISIT_OCCURRENCE.NK
    , QRY_VISIT_OCCURRENCE.ETL_MODULE
FROM
    (((((({{ref('QRY_VISIT_OCCURRENCE')}} AS QRY_VISIT_OCCURRENCE
LEFT JOIN {{ref('COUNT_CONDITIONS')}} AS COUNT_CONDITIONS ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_CONDITIONS.VISIT_OCCURRENCE_ID)
LEFT JOIN {{ref('COUNT_PROCEDURE')}} AS COUNT_PROCEDURE ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_PROCEDURE.VISIT_OCCURRENCE_ID)
LEFT JOIN {{ref('COUNT_MEASUREMENT')}} AS COUNT_MEASUREMENT ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_MEASUREMENT.VISIT_OCCURRENCE_ID)
LEFT JOIN {{ref('COUNT_DRUG')}} AS COUNT_DRUG ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_DRUG.VISIT_OCCURRENCE_ID)
LEFT JOIN {{ref('COUNT_OBSERVATION')}} AS COUNT_OBSERVATION ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_OBSERVATION.VISIT_OCCURRENCE_ID)
LEFT JOIN {{ref('COUNT_DEVICE')}} AS COUNT_DEVICE ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_DEVICE.VISIT_OCCURRENCE_ID)
LEFT JOIN {{ref('COUNT_NOTE')}} AS COUNT_NOTE ON
    QRY_VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID = COUNT_NOTE.VISIT_OCCURRENCE_ID
ORDER BY
    QRY_VISIT_OCCURRENCE.VISIT_START_DATETIME DESC
    