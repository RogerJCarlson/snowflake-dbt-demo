-- V_AOU_LOCATION

{{ config(materialized = 'view') }}

SELECT location_id AS "location_id"
    , replace(address_1, '"', '') AS "address_1"
    , replace(address_2, '"', '') AS "address_2"
    , replace(city, '"', '') AS "city"
    , replace(STATE, '"', '') AS "state"
    , replace(zip, '"', '') AS "zip"
    , replace(county, '"', '') AS "county"
    , replace(location_source_value, '"', '') AS "location_source_value"
FROM    
    {{ref('LOCATION')}} AS LOCATION
LEFT JOIN (
    SELECT CDT_ID
    FROM {{ref('QA_ERR_DBT')}} AS QA_ERR_DBT
        WHERE (STANDARD_DATA_TABLE = 'LOCATION')
            AND (ERROR_TYPE IN ('FATAL', 'INVALID DATA'))
        ) AS EXCLUSION_RECORDS
        ON LOCATION.LOCATION_ID = EXCLUSION_RECORDS.CDT_ID
WHERE (EXCLUSION_RECORDS.CDT_ID IS NULL) 
