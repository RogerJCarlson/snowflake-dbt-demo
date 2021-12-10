--Structure: (if your structure is different, you will have to modify the code to match)
--    Databases:SH_OMOP_DB_PROD, SH_CLINICAL_DB_PROD
--    Schemas: SH_OMOP_DB_PROD.OMOP_CLARITY, SH_OMOP_DB_PROD.CDM, SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

--USE DATABASE SH_OMOP_DB_PROD;
--USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--TRUNCATE TABLE SH_OMOP_DB_PROD.CDM.SPECIMEN;

 INSERT
	INTO	SH_OMOP_DB_PROD.CDM.SPECIMEN ( 
	PERSON_ID ,
	SPECIMEN_CONCEPT_ID ,
	SPECIMEN_TYPE_CONCEPT_ID ,
	SPECIMEN_DATE ,
	SPECIMEN_DATETIME ,
	QUANTITY ,
	UNIT_CONCEPT_ID ,
	ANATOMIC_SITE_CONCEPT_ID ,
	DISEASE_STATUS_CONCEPT_ID ,
	SPECIMEN_SOURCE_ID ,
	SPECIMEN_SOURCE_VALUE ,
	UNIT_SOURCE_VALUE ,
	ANATOMIC_SITE_SOURCE_VALUE ,
	DISEASE_STATUS_SOURCE_VALUE ,
	ETL_MODULE )
SELECT
	DISTINCT PERSON_ID 
    , COALESCE(SOURCE_TO_CONCEPT_MAP_SPECIMEN.TARGET_CONCEPT_ID,0)                              AS SPECIMEN_CONCEPT_ID
    , 0                                                                                         AS SPECIMEN_TYPE_CONCEPT_ID
--    , CAST(COALESCE(SPEC_DB_MAIN.SPEC_DTM_COLLECTED, SPEC_DB_MAIN.SPEC_DTM_RECEIVED)AS DATE )  AS SPECIMEN_DATE
    , COALESCE(SPEC_DTM_COLLECTED, SPEC_DTM_RECEIVED)::DATE                                     AS SPECIMEN_DATE
    , COALESCE(SPEC_DTM_COLLECTED, SPEC_DTM_RECEIVED)                                           AS SPECIMEN_DATETIME
	, SPECIMEN_SIZE                                                                             AS QUANTITY -- MISSING FROM HSC_SPEC_INFO 
    , 0                                                                                         AS UNIT_CONCEPT_ID -- MISSING FROM HSC_SPEC_INFO
    , COALESCE(SOURCE_TO_CONCEPT_MAP_ANATOMIC_SITE.TARGET_CONCEPT_ID,0)                         AS ANATOMIC_SITE_CONCEPT_ID
    , 0                                                                                         AS DISEASE_STATUS_CONCEPT_ID -- UNKNOWN
	,SPECIMEN_TYPE_C                                                                            AS SPECIMEN_SOURCE_ID
	,ZC_SPECIMEN_TYPE_NAME                                                                      AS SPECIMEN_SOURCE_VALUE
    , NULL                                                                                      AS UNIT_SOURCE_VALUE -- MISSING FROM HSC_SPEC_INFO
	,ZC_SPEC_SOURCE_NAME                                                                        AS ANATOMIC_SITE_SOURCE_VALUE
    , NULL                                                                                      AS DISEASE_STATUS_SOURCE_VALUE  -- UNKNOWN
	   ,'SPECIMEN--CLARITYHOSP--ALL'                                                            AS ETL_MODULE

FROM
	SH_OMOP_DB_PROD.OMOP_CLARITY.SPECIMEN_CLARITY_ALL
	
	   ------- SOURCE TO CONCEPT MAPPINGS BEGIN---------
    LEFT JOIN SH_OMOP_DB_PROD.CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_SPECIMEN
        ON SPECIMEN_TYPE_C::varchar = SOURCE_TO_CONCEPT_MAP_SPECIMEN.SOURCE_CODE
            AND upper(SOURCE_TO_CONCEPT_MAP_SPECIMEN.SOURCE_VOCABULARY_ID) = 'SH_SPECIMEN'
    LEFT JOIN SH_OMOP_DB_PROD.CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_ANATOMIC_SITE
        ON SPEC_SOURCE_C::varchar = SOURCE_TO_CONCEPT_MAP_ANATOMIC_SITE.SOURCE_CODE
            AND upper(SOURCE_TO_CONCEPT_MAP_ANATOMIC_SITE.SOURCE_VOCABULARY_ID) = 'SH_ANATOMIC_SITE'
------- SOURCE TO CONCEPT MAPPINGS END ---------