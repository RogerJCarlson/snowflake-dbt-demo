
--DRUG_EXPOSURE_DATEVDATETIME_DETAIL
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH DATEVDATETIME_DETAIL AS (
SELECT 'DRUG_EXPOSURE_START_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	DRUG_EXPOSURE_ID AS CDT_ID
FROM {{ref('DRUG_EXPOSURE')}} AS T1
WHERE DRUG_EXPOSURE_START_DATE <> CAST(DRUG_EXPOSURE_START_DATETIME AS DATE)

UNION ALL

SELECT 'DRUG_EXPOSURE_END_DATE' AS METRIC_FIELD, 'DATEVDATETIME' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, 
	 DRUG_EXPOSURE_ID AS CDT_ID
FROM {{ref('DRUG_EXPOSURE')}} AS T1
WHERE DRUG_EXPOSURE_END_DATE <> CAST(DRUG_EXPOSURE_END_DATETIME AS DATE)
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM DATEVDATETIME_DETAIL

