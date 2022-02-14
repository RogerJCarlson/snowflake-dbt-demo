USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_MEASUREMENT_NOVISIT_COUNT AS (
---------------------------------------------------------------------
--MEASUREMENT_NOVISIT_COUNT
---------------------------------------------------------------------
WITH NOVISIT_COUNT
AS (
	SELECT 'VISIT_OCCURRENCE_ID' AS METRIC_FIELD, 'NO VISIT' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM CDM.MEASUREMENT
	LEFT JOIN CDM.VISIT_OCCURRENCE
		ON MEASUREMENT.VISIT_OCCURRENCE_ID = VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID
	WHERE (VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID IS NULL)
)

--INSERT INTO OMOP_QA.QA_LOG   (    
--	RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,QA_ERRORS
--    ,ERROR_TYPE
--	,TOTAL_RECORDS)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'MEASUREMENT' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE(SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) IS NOT NULL AND SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM CDM.MEASUREMENT) AS TOTAL_RECORDS
FROM NOVISIT_COUNT
GROUP BY   METRIC_FIELD, QA_METRIC, ERROR_TYPE	
);
