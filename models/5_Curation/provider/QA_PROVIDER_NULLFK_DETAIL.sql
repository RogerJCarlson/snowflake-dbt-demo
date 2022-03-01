--QA_PROVIDER_NULLFK_DETAIL
---------------------------------------------------------------------
WITH CTE_NULLFK_DETAIL AS (
	SELECT 'PROVIDER' AS STANDARD_DATA_TABLE
		,'CARE_SITE_ID' AS METRIC_FIELD
		,'NULL FK' AS QA_METRIC
		,'WARNING' AS ERROR_TYPE
		,PROVIDER_ID AS CDT_ID
	FROM {{ref('PROVIDER')}}  AS T1
	WHERE (CARE_SITE_ID IS NULL )
	)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM CTE_NULLFK_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
