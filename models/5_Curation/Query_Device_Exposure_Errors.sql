--Query_Device_Exposure_Errors

{{ config(materialized = 'view') }}

SELECT
    QA_ERR.RUN_DATE
    , QA_ERR.STANDARD_DATA_TABLE
    , QA_ERR.QA_METRIC
    , QA_ERR.METRIC_FIELD
    , QA_ERR.ERROR_TYPE
    , DEVICE_EXPOSURE.*
FROM
    {{ref('QA_ERR')}} AS QA_ERR
INNER JOIN {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE ON
    QA_ERR.CDT_ID = DEVICE_EXPOSURE.DEVICE_EXPOSURE_ID

WHERE
    QA_ERR.STANDARD_DATA_TABLE = 'DEVICE_EXPOSURE'