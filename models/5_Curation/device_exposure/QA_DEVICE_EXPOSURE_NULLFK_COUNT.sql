--QA_DEVICE_EXPOSURE_NULLFK_COUNT
---------------------------------------------------------------------
WITH NULLFK_COUNT
AS (
	SELECT 'PROVIDER_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (PROVIDER_ID IS NULL)
	
	UNION ALL
	
	SELECT 'VISIT_OCCURRENCE_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (VISIT_OCCURRENCE_ID IS NULL)
	
	UNION ALL
	
	SELECT 'PERSON_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'FATAL' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (PERSON_ID IS NULL)
	
	)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE) AS TOTAL_RECORDS
FROM NULLFK_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE