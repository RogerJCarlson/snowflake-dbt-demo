USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_care_site_nomatch_detail AS (
---------------------------------------------------------------------
--care_site_nomatch_detail
---------------------------------------------------------------------
WITH CTE_NO_MATCH_DETAIL AS 
(
	SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
		,'CARE_SITE' AS  STANDARD_DATA_TABLE 
		,'NO-MATCH' AS  QA_METRIC 	
		,'PLACE_OF_SERVICE_CONCEPT_ID' AS METRIC_FIELD
		,'FATAL' AS ERROR_TYPE
		,CARE_SITE_ID AS CDT_ID
    FROM
       CDM.CARE_SITE AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.PLACE_OF_SERVICE_CONCEPT_ID=C.CONCEPT_ID
	WHERE (PLACE_OF_SERVICE_CONCEPT_ID <> 0 AND  STANDARD_CONCEPT IS NULL)
)

--INSERT INTO OMOP_QA.QA_ERR (RUN_DATE,STANDARD_DATA_TABLE,QA_METRIC, METRIC_FIELD,ERROR_TYPE,CDT_ID)
	SELECT  RUN_DATE, STANDARD_DATA_TABLE, QA_METRIC,  METRIC_FIELD,ERROR_TYPE, CDT_ID
	FROM CTE_NO_MATCH_DETAIL		
  WHERE ERROR_TYPE <>'EXPECTED'	
);
