USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA CDM;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DROP VIEW CDM.V_PERSON_NONSTANDARD_DETAIL;
CREATE OR REPLACE VIEW OMOP_QA.V_PERSON_NONSTANDARD_DETAIL AS (
---------------------------------------------------------------------
-- PERSON_NONSTANDARD_DETAIL
---------------------------------------------------------------------
WITH NO_MATCH_DETAIL AS (
    SELECT
        'GENDER_CONCEPT_ID' AS METRIC_FIELD , 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE,
		PERSON_ID AS CDT_ID
    FROM
       CDM.PERSON AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.GENDER_CONCEPT_ID=C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'GENDER' AND upper(C.CONCEPT_CLASS_ID) =  'GENDER'
	WHERE GENDER_CONCEPT_ID <> 0 AND GENDER_CONCEPT_ID IS NOT NULL
		AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
UNION ALL
    SELECT
        'RACE_CONCEPT_ID' AS METRIC_FIELD , 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE,
		PERSON_ID AS CDT_ID
    FROM
       CDM.PERSON AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.RACE_CONCEPT_ID=C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'RACE' AND upper(C.CONCEPT_CLASS_ID) =  'RACE'
	WHERE RACE_CONCEPT_ID <> 0 AND RACE_CONCEPT_ID IS NOT NULL
		AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
UNION ALL
    SELECT
        'ETHNICITY_CONCEPT_ID' AS METRIC_FIELD , 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE,
		PERSON_ID AS CDT_ID
    FROM
       CDM.PERSON AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.ETHNICITY_CONCEPT_ID=C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'ETHNICITY' AND upper(C.CONCEPT_CLASS_ID) =  'ETHNICITY'
	WHERE ETHNICITY_CONCEPT_ID <> 0 AND ETHNICITY_CONCEPT_ID IS NOT NULL
		AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
UNION ALL
    SELECT
        'GENDER_SOURCE_CONCEPT_ID' AS METRIC_FIELD , 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE,
		PERSON_ID AS CDT_ID
    FROM
       CDM.PERSON AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.GENDER_SOURCE_CONCEPT_ID=C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'GENDER' AND upper(C.CONCEPT_CLASS_ID) =  'GENDER'
	WHERE GENDER_SOURCE_CONCEPT_ID <> 0 AND GENDER_SOURCE_CONCEPT_ID IS NOT NULL
		AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
UNION ALL
    SELECT
        'RACE_SOURCE_CONCEPT_ID' AS METRIC_FIELD , 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE,
		PERSON_ID AS CDT_ID
    FROM
       CDM.PERSON AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.RACE_SOURCE_CONCEPT_ID=C.CONCEPT_ID  AND upper(C.DOMAIN_ID) =  'RACE' AND upper(C.CONCEPT_CLASS_ID) =  'RACE'
	WHERE RACE_SOURCE_CONCEPT_ID <> 0 AND RACE_SOURCE_CONCEPT_ID IS NOT NULL
		AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
UNION ALL
    SELECT
        'ETHNICITY_SOURCE_CONCEPT_ID' AS METRIC_FIELD , 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE,
		PERSON_ID AS CDT_ID
    FROM
       CDM.PERSON AS P
    LEFT JOIN
        CDM.CONCEPT AS C
        ON
            P.ETHNICITY_SOURCE_CONCEPT_ID=C.CONCEPT_ID AND upper(C.DOMAIN_ID) =  'ETHNICITY' AND upper(C.CONCEPT_CLASS_ID) =  'ETHNICITY'
	WHERE ETHNICITY_SOURCE_CONCEPT_ID <> 0
		AND  C.STANDARD_CONCEPT IS NULL 
)
--INSERT INTO OMOP_QA.QA_ERR(    
--	RUN_DATE
--    ,STANDARD_DATA_TABLE
--    ,QA_METRIC
--	,METRIC_FIELD
--    ,ERROR_TYPE
--	,CDT_ID)
	
SELECT CAST(GETDATE() AS DATE ) AS RUN_DATE
	,'PERSON' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC
	, METRIC_FIELD  AS METRIC_FIELD
	, ERROR_TYPE
	, CDT_ID
FROM NO_MATCH_DETAIL	
  WHERE ERROR_TYPE <>'EXPECTED'	
 );
 