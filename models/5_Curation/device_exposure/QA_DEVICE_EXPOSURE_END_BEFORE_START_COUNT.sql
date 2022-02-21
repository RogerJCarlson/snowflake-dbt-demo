--QA_DEVICE_EXPOSURE_END_BEFORE_START_COUNT
---------------------------------------------------------------------
WITH END_BEFORE_START_COUNT AS (
SELECT  'DEVICE_EXPOSURE_END_DATE' AS METRIC_FIELD, 'END_BEFORE_START' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
FROM {{ref('DEVICE_EXPOSURE')}} AS  DE
WHERE DE.DEVICE_EXPOSURE_END_DATETIME < DE.DEVICE_EXPOSURE_START_DATETIME
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC
	, METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	,(SELECT COUNT(*) AS NUM_ROWS FROM {{ref('DEVICE_EXPOSURE')}}) AS TOTAL_RECORDS	
FROM END_BEFORE_START_COUNT
GROUP BY  METRIC_FIELD, QA_METRIC, ERROR_TYPE	