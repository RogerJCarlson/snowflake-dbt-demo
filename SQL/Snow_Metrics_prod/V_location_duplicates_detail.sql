USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE VIEW OMOP_QA.V_LOCATION_DUPLICATES_DETAIL AS (
---------------------------------------------------------------------
--LOCATION_DUPLICATES_DETAIL
---------------------------------------------------------------------
WITH TMP_DUPES AS (
SELECT LOCATION_ID
      ,ADDRESS_1
      ,ADDRESS_2
      ,CITY
      ,STATE
      ,ZIP
      ,COUNTY
      ,LOCATION_SOURCE_VALUE
	  ,COUNT(*) AS CNT

FROM CDM.LOCATION AS T1
GROUP BY  LOCATION_ID
      ,ADDRESS_1
      ,ADDRESS_2
      ,CITY
      ,STATE
      ,ZIP
      ,COUNTY
      ,LOCATION_SOURCE_VALUE
HAVING COUNT(*) > 1
)

--INSERT INTO OMOP_QA.QA_ERR(
--	RUN_DATE
--	,STANDARD_DATA_TABLE
--	,QA_METRIC
--	,METRIC_FIELD
--	,ERROR_TYPE
--	,CDT_ID	)
SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'LOCATION' AS STANDARD_DATA_TABLE
	, 'DUPLICATE' AS QA_METRIC
	, 'RECORDS'  AS METRIC_FIELD
	, 'FATAL' AS ERROR_TYPE
	, LO.LOCATION_ID

FROM TMP_DUPES AS D
INNER JOIN CDM.LOCATION AS LO ON 
	 COALESCE(D.ADDRESS_1, '0') = COALESCE(LO.ADDRESS_1, '0')
	AND COALESCE(D.ADDRESS_2, '0') = COALESCE(LO.ADDRESS_2, '0')
	AND COALESCE(D.CITY, '0') = COALESCE(LO.CITY, '0')
	AND COALESCE(D.STATE, '0') = COALESCE(LO.STATE, '0')
	AND COALESCE(D.COUNTY, '0') = COALESCE(LO.COUNTY, '0')
	AND COALESCE(D.LOCATION_SOURCE_VALUE, '0') = COALESCE(LO.LOCATION_SOURCE_VALUE, '0')
	
);
