--QA_DEVICE_EXPOSURE_ZERO_CONCEPT_COUNT
--------------------------------------------------------------------- 
WITH CTE_ERROR_COUNT AS (
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		, 'DEVICE_CONCEPT_ID' AS METRIC_FIELD
		, 'ZERO CONCEPT' AS QA_METRIC
		, 'WARNING' AS ERROR_TYPE
		, COUNT(*) AS CNT
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE 
	WHERE (DEVICE_CONCEPT_ID = 0 )
	UNION ALL
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		, 'DEVICE_TYPE_CONCEPT_ID' AS METRIC_FIELD
		, 'ZERO CONCEPT' AS QA_METRIC
		, 'WARNING' AS ERROR_TYPE
		, COUNT(*) AS CNT
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE 
	WHERE (DEVICE_TYPE_CONCEPT_ID = 0 )
	UNION ALL
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		, 'DEVICE_SOURCE_CONCEPT_ID' AS METRIC_FIELD
		, 'ZERO CONCEPT' AS QA_METRIC
		, 'EXPECTED' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE 
	WHERE (DEVICE_SOURCE_CONCEPT_ID = 0 )
	)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('DEVICE_EXPOSURE')}}) AS TOTAL_RECORDS	
FROM CTE_ERROR_COUNT
GROUP BY STANDARD_DATA_TABLE, METRIC_FIELD, QA_METRIC, ERROR_TYPE