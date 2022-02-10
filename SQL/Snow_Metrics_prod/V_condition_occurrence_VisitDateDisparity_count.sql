USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_CONDITION_OCCURRENCE_VISITDATEDISPARITY_COUNT AS (
---------------------------------------------------------------------
--CONDITION_OCCURRENCE_VISITDATEDISPARITY_COUNT
---------------------------------------------------------------------
WITH VISITDATEDISPARITY_COUNT AS (
SELECT 'CONDITION_START_DATE' AS METRIC_FIELD, 'VISIT_DATE_DISPARITY' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.CONDITION_OCCURRENCE CO
	LEFT JOIN CDM.VISIT_OCCURRENCE VO
		ON CO.VISIT_OCCURRENCE_ID = VO.VISIT_OCCURRENCE_ID
	WHERE
		-- MUST HAVE POPULATED VISIT OCCURRENCE ID
		(	CO.VISIT_OCCURRENCE_ID IS NOT NULL
			AND CO.VISIT_OCCURRENCE_ID <> 0
			AND VO.VISIT_OCCURRENCE_ID IS NOT NULL
			AND VO.VISIT_OCCURRENCE_ID <> 0	)
		AND (
			-- PROBLEM WITH PROCEDURE DATE
			(	CO.CONDITION_START_DATE < VO.VISIT_START_DATE
				OR CO.CONDITION_START_DATE > VO.VISIT_END_DATE)
			OR
			-- PROBLEM WITH DATETIME
			(	CAST(CO.CONDITION_START_DATETIME AS DATE) < CAST(VO.VISIT_START_DATETIME AS DATE)
				OR CAST(CO.CONDITION_START_DATETIME AS DATE) > CAST(VO.VISIT_END_DATETIME AS DATE))
			OR
			-- PROBLEM WITH THE DATETIME (EXTRACTING DATE FOR COMPARISON)
			(	CO.CONDITION_START_DATE < CAST(VO.VISIT_START_DATETIME AS DATE)
				OR CO.CONDITION_START_DATE > CAST(VO.VISIT_END_DATETIME AS DATE))
			OR
			--PROBLEM WITH THE DATETIME
			(	CAST(CO.CONDITION_START_DATETIME AS DATE) < VO.VISIT_START_DATE
				OR CAST(CO.CONDITION_START_DATETIME AS DATE) > VO.VISIT_END_DATE))
)

--INSERT INTO OMOP_QA.QA_LOG   (    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,QA_ERRORS
--	,ERROR_TYPE
--	,TOTAL_RECORDS)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	, 'CONDITION_OCCURRENCE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.CONDITION_OCCURRENCE) AS TOTAL_RECORDS
FROM VISITDATEDISPARITY_COUNT
GROUP BY METRIC_FIELD, QA_METRIC, ERROR_TYPE
);
