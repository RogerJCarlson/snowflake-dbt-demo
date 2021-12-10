-- identify rows with duplicates
SELECT
    count(*) AS row_count
    , SOURCE_CODE
    , SOURCE_CONCEPT_ID
    , SOURCE_VOCABULARY_ID
    , SOURCE_CODE_DESCRIPTION
    , TARGET_CONCEPT_ID
    , TARGET_VOCABULARY_ID
    , VALID_START_DATE
    , VALID_END_DATE
    , INVALID_REASON
FROM
    SH_OMOP_DB_PROD.CDM.SOURCE_TO_CONCEPT_MAP
GROUP BY
    SOURCE_CODE
    , SOURCE_CONCEPT_ID
    , SOURCE_VOCABULARY_ID
    , SOURCE_CODE_DESCRIPTION
    , TARGET_CONCEPT_ID
    , TARGET_VOCABULARY_ID
    , VALID_START_DATE
    , VALID_END_DATE
    , INVALID_REASON
HAVING
    count(*) >1;
    
    
-- identify and/or delete all but one of the duplicated rows
SELECT * FROM -- OR DELETE FROM
(SELECT
    SOURCE_CODE
    , SOURCE_CONCEPT_ID
    , SOURCE_VOCABULARY_ID
    , SOURCE_CODE_DESCRIPTION
    , TARGET_CONCEPT_ID
    , TARGET_VOCABULARY_ID
    , VALID_START_DATE
    , VALID_END_DATE
    , INVALID_REASON
    , ROW_NUMBER () OVER (PARTITION BY SOURCE_CODE
                        , SOURCE_CONCEPT_ID
                        , SOURCE_VOCABULARY_ID
                        , SOURCE_CODE_DESCRIPTION
                        , TARGET_CONCEPT_ID
                        , TARGET_VOCABULARY_ID
                        , VALID_START_DATE
                        , VALID_END_DATE
                        , INVALID_REASON ORDER BY SOURCE_CODE) AS A_ROW_NUMBER
FROM
    SH_OMOP_DB_PROD.CDM.SOURCE_TO_CONCEPT_MAP)  
HAVING   
    A_ROW_NUMBER  > 1;


