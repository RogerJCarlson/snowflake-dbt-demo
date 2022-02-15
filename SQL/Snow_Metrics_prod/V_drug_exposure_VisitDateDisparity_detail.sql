USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_DRUG_EXPOSURE_VISITDATEDISPARITY_DETAIL AS (
---------------------------------------------------------------------
--MEASUREMENT_VISITDATEDISPARITY_DETAIL
---------------------------------------------------------------------
WITH VISITDATEDISPARITY_DETAIL AS (
SELECT 'DRUG_EXPOSURE_START_DATE' AS METRIC_FIELD, 'VISIT_DATE_DISPARITY' AS QA_METRIC, 'WARNING' AS ERROR_TYPE, DRUG_EXPOSURE_ID AS CDT_ID
FROM CDM.DRUG_EXPOSURE DE
LEFT JOIN CDM.VISIT_OCCURRENCE VO
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

--INSERT INTO OMOP_QA.QA_ERR(    
--	 RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'DRUG_EXPOSURE' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM VISITDATEDISPARITY_DETAIL
);