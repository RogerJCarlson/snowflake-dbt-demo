--QA_MEASUREMENT_NOVISIT_DETAIL
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH NOVISIT_DETAIL
AS (
	SELECT 'VISIT_OCCURRENCE_ID' AS METRIC_FIELD, 'NO VISIT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, MEASUREMENT_ID AS CDT_ID		
	FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
	LEFT JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
		ON MEASUREMENT.VISIT_OCCURRENCE_ID = VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID
	WHERE (VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID IS NULL)
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NOVISIT_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'					

