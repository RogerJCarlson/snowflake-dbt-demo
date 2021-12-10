--
--USE DATABASE SH_OMOP_DB_PROD;
--USE SCHEMA CDM;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--COPY INTO '@CDM.AOU_EXPORT/care_site.csv.gz'  FROM 
--(SELECT
--    CARE_SITE_ID AS "care_site_id"
--    , CARE_SITE_NAME AS "care_site_name"
--    , PLACE_OF_SERVICE_CONCEPT_ID AS "place_of_service_concept_id"
--    , LOCATION_ID AS "location_id"
--    , CARE_SITE_SOURCE_VALUE AS "care_site_source_value"
--    , PLACE_OF_SERVICE_SOURCE_VALUE AS "place_of_service_source_value"
--FROM
--    CDM.CARE_SITE
--    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv') HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;	
--    

COPY INTO '@CDM.AOU_EXPORT/care_site.csv.gz'  FROM 
(SELECT * FROM  SH_OMOP_DB_PROD.CDM.V_AOU_CARE_SITE 
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv') HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;  