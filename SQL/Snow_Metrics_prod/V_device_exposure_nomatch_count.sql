USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE VIEW OMOP_QA.V_DEVICE_EXPOSURE_NOMATCH_COUNT AS (
---------------------------------------------------------------------
--DEVICE_EXPOSURE_NOMATCH_COUNT
---------------------------------------------------------------------
WITH CTE_NO_MATCH_COUNT AS (
    SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
    ,'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
        ,'DEVICE_CONCEPT_ID' AS METRIC_FIELD
        ,'NO-MATCH' AS QA_METRIC
        ,'FATAL' AS ERROR_TYPE
      ,COUNT(*) AS CNT
      ,(SELECT COUNT(*) AS NUM_ROWS FROM CDM.DEVICE_EXPOSURE) AS TOTAL_RECORDS 
    FROM CDM.DEVICE_EXPOSURE AS P
    LEFT JOIN CDM.CONCEPT AS C ON P.DEVICE_CONCEPT_ID = C.CONCEPT_ID
    WHERE DEVICE_CONCEPT_ID <> 0
        AND CONCEPT_ID IS NULL

    UNION ALL

    SELECT 
    CAST(GETDATE() AS DATE) AS RUN_DATE
    ,'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
        ,'DEVICE_TYPE_CONCEPT_ID' AS METRIC_FIELD
        ,'NO-MATCH' AS QA_METRIC
        ,'FATAL' AS ERROR_TYPE
      ,COUNT(*) AS CNT
      ,(SELECT COUNT(*) AS NUM_ROWS FROM CDM.DEVICE_EXPOSURE) AS TOTAL_RECORDS         
    FROM CDM.DEVICE_EXPOSURE AS P
    LEFT JOIN CDM.CONCEPT AS C ON P.DEVICE_TYPE_CONCEPT_ID = C.CONCEPT_ID
    WHERE DEVICE_TYPE_CONCEPT_ID <> 0
        AND CONCEPT_ID IS NULL

    UNION ALL

    SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
    ,'DEVICE_EXPOSURE' AS STANDARD_DATA_TABLE
        ,'DEVICE_SOURCE_CONCEPT_ID' AS METRIC_FIELD
        ,'NO-MATCH' AS QA_METRIC
        ,'FATAL' AS ERROR_TYPE
      ,COUNT(*) AS CNT
      ,(SELECT COUNT(*) AS NUM_ROWS FROM CDM.DEVICE_EXPOSURE) AS TOTAL_RECORDS         
    FROM CDM.DEVICE_EXPOSURE AS P
    LEFT JOIN CDM.CONCEPT AS C ON P.DEVICE_SOURCE_CONCEPT_ID = C.CONCEPT_ID
    WHERE DEVICE_SOURCE_CONCEPT_ID <> 0
        AND CONCEPT_ID IS NULL
)
----INSERT INTO OMOP_QA.QA_LOG(RUN_DATE, STANDARD_DATA_TABLE, QA_METRIC, METRIC_FIELD, QA_ERRORS, ERROR_TYPE,TOTAL_RECORDS)
SELECT  RUN_DATE, STANDARD_DATA_TABLE, QA_METRIC, METRIC_FIELD
  , COALESCE(SUM(CNT),0) AS QA_ERRORS
  , CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END AS ERROR_TYPE 
  ,TOTAL_RECORDS
FROM CTE_NO_MATCH_COUNT   
GROUP BY RUN_DATE,  STANDARD_DATA_TABLE , METRIC_FIELD,  QA_METRIC ,  ERROR_TYPE ,TOTAL_RECORDS
);