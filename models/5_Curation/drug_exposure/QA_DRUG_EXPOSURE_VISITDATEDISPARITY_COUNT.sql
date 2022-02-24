--QA_DRUG_EXPOSURE_VISITDATEDISPARITY_COUNT
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH VISITDATEDISPARITY_COUNT AS (
SELECT 'DRUG_EXPOSURE_START_DATE' AS METRIC_FIELD, 'VISIT_DATE_DISPARITY' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
FROM {{ref('DRUG_EXPOSURE')}} AS DE
LEFT JOIN {{ref('VISIT_OCCURRENCE')}} AS VO
	ON DE.VISIT_OCCURRENCE_ID = VO.VISIT_OCCURRENCE_ID
WHERE
	-- MUST HAVE POPULATED VISIT OCCURRENCE ID
	(	DE.VISIT_OCCURRENCE_ID IS NOT NULL
		AND DE.VISIT_OCCURRENCE_ID <> 0
		AND VO.VISIT_OCCURRENCE_ID IS NOT NULL
		AND VO.VISIT_OCCURRENCE_ID <> 0	)
	AND (
		-- PROBLEM WITH PROCEDURE DATE
		(DE.DRUG_EXPOSURE_START_DATE < VO.VISIT_START_DATE
			OR DE.DRUG_EXPOSURE_START_DATE > VO.VISIT_END_DATE)
		OR
		-- PROBLEM WITH DATETIME
		(CAST(DE.DRUG_EXPOSURE_START_DATETIME AS DATE) < CAST(VO.VISIT_START_DATETIME AS DATE)
			OR CAST(DE.DRUG_EXPOSURE_START_DATETIME AS DATE) > CAST(VO.VISIT_END_DATETIME AS DATE))
		OR
		-- PROBLEM WITH THE DATETIME (EXTRACTING DATE FOR COMPARISON)
		(DE.DRUG_EXPOSURE_START_DATE < CAST(VO.VISIT_START_DATETIME AS DATE)
			OR DE.DRUG_EXPOSURE_START_DATE > CAST(VO.VISIT_END_DATETIME AS DATE))
		OR
		--PROBLEM WITH THE DATETIME
		(CAST(DE.DRUG_EXPOSURE_START_DATETIME AS DATE) < VO.VISIT_START_DATE
			OR CAST(DE.DRUG_EXPOSURE_START_DATETIME AS DATE) > VO.VISIT_END_DATE))
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('DRUG_EXPOSURE')}}) AS TOTAL_RECORDS
FROM VISITDATEDISPARITY_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
