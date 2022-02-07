--CDM.AOU_DRIVER_PROD
-- This pulls patients from ALLOFUSPARTICIPANT_SEED, matches them to CLARITY.IDENTITY_ID
--  and writes it to a view called AOU_DRIVER_PROD

{{ config(materialized = 'ephemeral') }}

SELECT UPPER(CPI::VARCHAR) AS CPI
    , UPPER(IDENTITY_ID.PAT_ID) AS EPIC_PAT_ID
    , UPPER(PMI_ID) AS AOU_ID   
    , 1 AS FLAG
    , UPPER(FIRST_NAME) AS FIRST_NAME
    , UPPER(LAST_NAME) AS LAST_NAME
    , DATE_OF_BIRTH
    , UPPER(SEX) AS SEX
    , UPPER(PHONE) AS PHONE
    , UPPER(STREET_ADDRESS) AS STREET_ADDRESS
    , UPPER(CITY) AS CITY
    , UPPER(STATE) AS STATE
    , UPPER(ZIP) AS ZIP
    , UPPER(EMAIL) AS EMAIL
    , UPPER(EHR_EXPORT_PT_MATCH_PASS) AS EHR_EXPORT_PT_MATCH_PASS

FROM {{ source('CDM','ALLOFUSPARTICIPANTS')}} AS A

INNER JOIN {{ source('CLARITY','IDENTITY_ID')}} AS IDENTITY_ID
    ON A.CPI = IDENTITY_ID.IDENTITY_ID
        AND (IDENTITY_ID.IDENTITY_TYPE_ID = 49)