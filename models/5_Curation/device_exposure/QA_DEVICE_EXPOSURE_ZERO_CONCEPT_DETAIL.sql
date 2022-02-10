--QA_DEVICE_EXPOSURE_ZERO_CONCEPT_DETAIL
--------------------------------------------------------------------- 
WITH CTE_ERROR_DETAIL AS (
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		, 'DEVICE_CONCEPT_ID' AS METRIC_FIELD
		, 'ZERO CONCEPT' AS QA_METRIC
		, 'WARNING' AS ERROR_TYPE
		, DEVICE_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE 
	WHERE (DEVICE_CONCEPT_ID = 0 )
	UNION ALL
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		, 'DEVICE_TYPE_CONCEPT_ID' AS METRIC_FIELD
		, 'ZERO CONCEPT' AS QA_METRIC
		, 'WARNING' AS ERROR_TYPE
		, DEVICE_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (DEVICE_TYPE_CONCEPT_ID = 0 )
	UNION ALL
	SELECT 'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
		, 'DEVICE_SOURCE_CONCEPT_ID' AS METRIC_FIELD
		, 'ZERO CONCEPT' AS QA_METRIC
		, 'EXPECTED' AS ERROR_TYPE
		, DEVICE_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE 
	WHERE (DEVICE_SOURCE_CONCEPT_ID = 0 )
	)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM CTE_ERROR_DETAIL	
  WHERE ERROR_TYPE <>'EXPECTED'	