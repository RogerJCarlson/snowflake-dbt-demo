-- OMOP_QA.COUNT_DRUG 

SELECT DRUG_EXPOSURE.VISIT_OCCURRENCE_ID 
    , COUNT(DRUG_EXPOSURE.PERSON_ID) AS COUNTOFDRUG
    , DRUG_EXPOSURE.PERSON_ID 

FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE

GROUP BY DRUG_EXPOSURE.VISIT_OCCURRENCE_ID
    , DRUG_EXPOSURE.PERSON_ID