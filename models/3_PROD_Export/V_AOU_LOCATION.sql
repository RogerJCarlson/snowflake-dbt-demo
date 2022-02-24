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