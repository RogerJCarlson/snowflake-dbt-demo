CREATE OR REPLACE
TABLE test4 AS
SELECT
    PMI_ID
    , REDCAP_REPEAT_INSTRUMENT
    , REDCAP_REPEAT_INSTANCE
    , CPI
    , 'roger' AS FIRST_NAME
    , 'carlson' AS LAST_NAME
    , '2000-01-01' AS DATE_OF_BIRTH
    , SEX
    , PHONE
    , STREET_ADDRESS
    , CITY
    , STATE
    , ZIP
    , EMAIL
    , EHR_EXPORT_PT_MATCH_PASS
FROM
    ALLOFUSPARTICIPANTS;

SELECT * FROM test4;
