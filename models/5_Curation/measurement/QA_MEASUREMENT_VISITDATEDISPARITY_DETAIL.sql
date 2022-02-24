--QA_MEASUREMENT_VISITDATEDISPARITY_DETAIL
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH VISITDATEDISPARITY_DETAIL AS (
SELECT 'MEASUREMENT_DATE' AS METRIC_FIELD, 'VISIT_DATE_DISPARITY' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, MEASUREMENT_ID AS CDT_ID
	FROM {{ref('MEASUREMENT')}} AS M
	LEFT JOIN {{ref('VISIT_OCCURRENCE')}} AS VO
		ON M.VISIT_OCCURRENCE_ID = VO.VISIT_OCCURRENCE_ID
	WHERE
		-- MUST HAVE POPULATED VISIT OCCURRENCE ID
		(M.VISIT_OCCURRENCE_ID IS NOT NULL
			AND M.VISIT_OCCURRENCE_ID <> 0
			AND VO.VISIT_OCCURRENCE_ID IS NOT NULL
			AND VO.VISIT_OCCURRENCE_ID <> 0)
		AND (
			-- PROBLEM WITH PROCEDURE DATE
			(M.MEASUREMENT_DATE < VO.VISIT_START_DATE
				OR M.MEASUREMENT_DATE > VO.VISIT_END_DATE)
			OR
			-- PROBLEM WITH DATETIME
			(CAST(M.MEASUREMENT_DATETIME AS DATE) < CAST(VO.VISIT_START_DATETIME AS DATE)
				OR CAST(M.MEASUREMENT_DATETIME AS DATE) > CAST(VO.VISIT_END_DATETIME AS DATE))
			OR
			-- PROBLEM WITH THE DATETIME (EXTRACTING DATE FOR COMPARISON)
			(M.MEASUREMENT_DATE < CAST(VO.VISIT_START_DATETIME AS DATE)
				OR M.MEASUREMENT_DATE > CAST(VO.VISIT_END_DATETIME AS DATE))
			OR
			--PROBLEM WITH THE DATETIME
			(CAST(M.MEASUREMENT_DATETIME AS DATE) < VO.VISIT_START_DATE
				OR CAST(M.MEASUREMENT_DATETIME AS DATE) > VO.VISIT_END_DATE))
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM VISITDATEDISPARITY_DETAIL
