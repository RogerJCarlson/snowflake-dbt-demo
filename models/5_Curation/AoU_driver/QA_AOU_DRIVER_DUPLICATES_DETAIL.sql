--QA_AOU_DRIVER_DUPLICATES_DETAIL 
---------------------------------------------------------------------

{{ config(materialized = 'view', schema='OMOP_QA') }}

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
    , 'AOU_DRIVER' AS STANDARD_DATA_TABLE
    , 'DUPLICATE ' AS QA_METRIC 
    , 'RECORDS'  AS METRIC_FIELD
    , 'FATAL' AS ERROR_TYPE
    , SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID)) AS CDT_ID

    
FROM {{ref('AOU_DRIVER')}} AS AOU_DRIVER 

WHERE (
        (
            (AOU_DRIVER.EPIC_PAT_ID) IN (
                SELECT EPIC_PAT_ID
                
                FROM {{ref('AOU_DRIVER')}} AS Tmp
                
                GROUP BY EPIC_PAT_ID
                
                HAVING Count(*) > 1
                )
            )
        )

ORDER BY AOU_DRIVER.EPIC_PAT_ID
