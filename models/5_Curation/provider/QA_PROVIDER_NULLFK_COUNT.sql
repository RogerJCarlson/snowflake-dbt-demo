--QA_PROVIDER_NULLFK_COUNT
---------------------------------------------------------------------
WITH CTE_NULLFK_COUNT AS (
	SELECT 'PROVIDER_V' AS STANDARD_DATA_TABLE
		,'CARE_SITE_ID' AS METRIC_FIELD
		,'NULL FK' AS QA_METRIC
		,'WARNING' AS ERROR_TYPE
		,COUNT(*) AS CNT
	FROM {{ref('PROVIDER')}}  AS T1
	WHERE (CARE_SITE_ID IS NULL )

)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,STANDARD_DATA_TABLE
	, QA_METRIC	
	, METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('PROVIDER')}} ) AS TOTAL_RECORDS	
FROM CTE_NULLFK_COUNT
GROUP BY  STANDARD_DATA_TABLE, METRIC_FIELD, QA_METRIC, ERROR_TYPE

