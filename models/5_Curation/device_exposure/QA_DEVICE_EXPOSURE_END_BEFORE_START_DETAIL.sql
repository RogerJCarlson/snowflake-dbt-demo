--QA_DEVICE_EXPOSURE_END_BEFORE_START_DETAIL
---------------------------------------------------------------------
WITH END_BEFORE_START_DETAIL AS (
SELECT 'DEVICE_EXPOSURE_END_DATE' AS METRIC_FIELD, 'END_BEFORE_START' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, DEVICE_EXPOSURE_ID AS CDT_ID
FROM {{ref('DEVICE_EXPOSURE')}} AS  DE
WHERE DE.DEVICE_EXPOSURE_END_DATETIME < DE.DEVICE_EXPOSURE_START_DATETIME
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	,CDT_ID
FROM END_BEFORE_START_DETAIL