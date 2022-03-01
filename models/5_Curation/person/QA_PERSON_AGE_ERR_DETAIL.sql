--QA_PERSON_AGE_ERR_DETAIL
---------------------------------------------------------------------

{{ config(materialized = 'view') }}

WITH AGE_ERR_DETAIL AS (
	SELECT
        'UNDER18' AS AGE,
		PERSON_ID AS CDT_ID
    FROM
       {{ref('PERSON')}} AS T1       
	WHERE  (DATEDIFF(YEAR,  BIRTH_DATETIME, GETDATE())<18)
UNION ALL
    SELECT
        'OVER120' AS AGE,
		PERSON_ID AS CDT_ID
    FROM
       {{ref('PERSON')}} AS T1
	WHERE  (DATEDIFF(YEAR,  BIRTH_DATETIME, GETDATE())>120)
)

SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'PERSON' AS STANDARD_DATA_TABLE
	, 'WRONG AGE:'|| AGE AS QA_METRIC
	, 'BIRTH_DATETIME'  AS METRIC_FIELD
	, 'WARNING' AS ERROR_TYPE
	, CDT_ID
FROM AGE_ERR_DETAIL
