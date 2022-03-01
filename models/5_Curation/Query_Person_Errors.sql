--Query_Person_Errors

SELECT
    QA_ERR.RUN_DATE
    , QA_ERR.STANDARD_DATA_TABLE
    , QA_ERR.QA_METRIC
    , QA_ERR.METRIC_FIELD
    , QA_ERR.ERROR_TYPE
    , PERSON.*
FROM
    {{ref('QA_ERR')}} AS QA_ERR
INNER JOIN {{ref('PERSON')}} AS PERSON ON
    QA_ERR.CDT_ID = PERSON.PERSON_ID
    AND QA_ERR.CDT_ID = PERSON.PERSON_ID
WHERE
    QA_ERR.STANDARD_DATA_TABLE = 'PERSON'
