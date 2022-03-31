--LOCATION

{{ config(materialized='table') }}

SELECT DISTINCT
      SEQ_LOCATION.NEXTVAL::NUMBER(28,0) AS LOCATION_ID
    , ADDRESS_1::VARCHAR(50) AS ADDRESS_1
    , ADDRESS_2::VARCHAR(50) AS ADDRESS_2
    , CITY::VARCHAR(50) AS CITY
    , STATE::VARCHAR(2) AS STATE
    , ZIP::VARCHAR(9) AS ZIP
    , COUNTY::VARCHAR(20) AS COUNTY
    , LOCATION_SOURCE_VALUE::VARCHAR(50) AS LOCATION_SOURCE_VALUE
FROM 	
 {{ref('LOCATION_CLARITY_ALL')}} 