--USE DATABASE SH_OMOP_DB_PROD;
--USE SCHEMA CDM;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
--
--TRUNCATE TABLE CDM.PERSON;

INSERT INTO CDM.PERSON
       (  PERSON_ID
     ,GENDER_CONCEPT_ID
    , YEAR_OF_BIRTH
    , MONTH_OF_BIRTH
    , DAY_OF_BIRTH
    , BIRTH_DATETIME
    , RACE_CONCEPT_ID
    , ETHNICITY_CONCEPT_ID
    , LOCATION_ID
    , PROVIDER_ID
    , CARE_SITE_ID
    , PERSON_SOURCE_VALUE
    , GENDER_SOURCE_VALUE
    , GENDER_SOURCE_CONCEPT_ID
    , RACE_SOURCE_VALUE
    , RACE_SOURCE_CONCEPT_ID
    , ETHNICITY_SOURCE_VALUE
    , ETHNICITY_SOURCE_CONCEPT_ID                                 

)
SELECT DISTINCT PERSON_ID                AS PERSON_ID
            , COALESCE(source_to_concept_map_gender.target_concept_id,0)         AS gender_concept_id
            , PERSON_CLARITY_ALL.YEAR_OF_BIRTH
            , MONTH_OF_BIRTH
            , DAY_OF_BIRTH
            , BIRTH_DATETIME
            , COALESCE(source_to_concept_map_race.target_concept_id,0)           AS race_concept_id
            , COALESCE(source_to_concept_map_ethnicity.target_concept_id,0)      AS ethnicity_concept_id

            , CDM.location.LOCATION_ID
            , PROVIDER_ID
            
            , CDM.CARE_SITE.CARE_SITE_ID
            , AOU_ID AS PERSON_SOURCE_VALUE
            
            , CAST( SEX_C AS VARCHAR) || ':' || zc_sex_NAME                AS gender_source_value
    , 0                                                                AS gender_source_concept_id
    , CAST(PATIENT_RACE_C AS VARCHAR) || ':' || ZC_PATIENT_RACE_NAME   AS race_source_value
    , 0                                                                AS race_source_concept_id
    , CAST(ETHNIC_GROUP_C AS VARCHAR) || ':' || ZC_ETHNIC_GROUP_NAME AS ethnicity_source_value
    , 0                                                                AS ethnicity_source_concept_id


       
FROM OMOP_CLARITY.PERSON_CLARITY_ALL
    LEFT JOIN CDM.provider
        ON PERSON_CLARITY_ALL.CUR_PCP_PROV_ID = provider.provider_source_value
        
    LEFT JOIN SH_OMOP_DB_PROD.CDM.location
    ON PERSON_CLARITY_ALL.location_source_value = CDM.location.location_source_value
        
    LEFT JOIN SH_OMOP_DB_PROD.CDM.CARE_SITE
    ON PERSON_CLARITY_ALL.CUR_PRIM_LOC_ID = CDM.CARE_SITE.CARE_SITE_ID
    
    LEFT JOIN CDM.source_to_concept_map AS source_to_concept_map_gender
        ON PERSON_CLARITY_ALL.SEX_C::varchar = source_to_concept_map_gender.source_code
            AND UPPER(source_to_concept_map_gender.source_vocabulary_id) = 'SH_GENDER'
            
    LEFT JOIN CDM.source_to_concept_map AS source_to_concept_map_race
        ON PERSON_CLARITY_ALL.PATIENT_RACE_C::varchar = source_to_concept_map_race.source_code
--            AND source_to_concept_map_race.source_vocabulary_id = 'SH_Race'
            AND upper(source_to_concept_map_race.source_vocabulary_id) = 'SH_RACE'
            
    LEFT JOIN CDM.source_to_concept_map AS source_to_concept_map_ethnicity
        ON PERSON_CLARITY_ALL.ETHNIC_GROUP_C::varchar = source_to_concept_map_ethnicity.source_code 
            AND upper(source_to_concept_map_ethnicity.source_vocabulary_id) = 'SH_ETHNICITY'
            
