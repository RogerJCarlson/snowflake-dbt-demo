
CREATE OR REPLACE VIEW OMOP_QA.V_AOU_DRIVER_PROD_DUPLICATES_COUNT AS (
---------------------------------------------------------------------
--care_site duplicates_count
---------------------------------------------------------------------
WITH TMP_DUPES AS (
                
SELECT EPIC_PAT_ID,
        COUNT(*) AS CNT
                FROM CDM.AOU_DRIVER_PROD AS Tmp
                GROUP BY EPIC_PAT_ID
                HAVING Count(*) > 1
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
    , 'AOU_DRIVER_PROD' AS STANDARD_DATA_TABLE
    , 'DUPLICATE' AS QA_METRIC
    , 'RECORDS'  AS METRIC_FIELD
    , COALESCE(SUM(CNT),0) AS QA_ERRORS
    , CASE WHEN SUM(CNT) IS NOT NULL THEN 'FATAL' ELSE NULL END   AS ERROR_TYPE
    , (SELECT COUNT(*) AS NUM_ROWS FROM CDM.AOU_DRIVER_PROD) AS TOTAL_RECORDS
FROM TMP_DUPES
);