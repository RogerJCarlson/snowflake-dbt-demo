--QA_DEVICE_EXPOSURE_NULLFK_DETAIL
---------------------------------------------------------------------
WITH NULLFK_DETAIL
AS (
	SELECT 'PROVIDER_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, DEVICE_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (PROVIDER_ID IS NULL)
	
	UNION ALL
	
	SELECT 'VISIT_OCCURRENCE_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'WARNING' AS ERROR_TYPE
		, DEVICE_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (VISIT_OCCURRENCE_ID IS NULL)
	
	UNION ALL
	
	SELECT 'PERSON_ID' AS METRIC_FIELD, 'NULL FK' AS QA_METRIC, 'FATAL' AS ERROR_TYPE
		, DEVICE_EXPOSURE_ID AS CDT_ID
	FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
	WHERE (PERSON_ID IS NULL)

	)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NULLFK_DETAIL
  WHERE ERROR_TYPE <>'EXPECTED'