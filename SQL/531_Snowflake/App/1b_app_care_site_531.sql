/*******************************************************************************
# Copyright 2021 Spectrum Health 
# http://www.spectrumhealth.org
#
# Unless required by applicable law or agreed to in writing, this software
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
# either express or implied.
#
********************************************************************************/

/*******************************************************************************
Name: 'app_care_site_2'

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 12-January-2021
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) 'pull care_site_2'. 

	Its purpose is to join the data in CARE_SITE_Clarity_ALL to the OMOP concept table
	to return standard concept ids, and append this data to care_site.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:EpicCare
	Schemas: EpicCare.OMOP, EpicCare.OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/
--USE DATABASE SH_OMOP_DB_PROD;
--USE SCHEMA OMOP;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


INSERT OVERWRITE INTO CDM.CARE_SITE (
	CARE_SITE_ID 
	,CARE_SITE_NAME
	, PLACE_OF_SERVICE_CONCEPT_ID
	, LOCATION_ID
	, CARE_SITE_SOURCE_VALUE
	, PLACE_OF_SERVICE_SOURCE_VALUE
	)
SELECT DISTINCT POS_ID AS care_site_id
    , POS_NAME AS care_site_name
  , COALESCE(source_to_concept_map_pos.target_concept_id, 0) AS place_of_service_concept_id
    , location_id AS location_id
  , left(cast(POS_ID AS VARCHAR) || ':' || POS_NAME, 50) AS care_site_source_value
    , POS_TYPE AS place_of_service_source_value
    
FROM SH_OMOP_DB_PROD.OMOP_CLARITY.CARE_SITE_CLARITY_ALL   
  LEFT JOIN SH_OMOP_DB_PROD.CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_POS
      ON SOURCE_TO_CONCEPT_MAP_POS.SOURCE_CODE = CARE_SITE_CLARITY_ALL.POS_TYPE
          AND SOURCE_TO_CONCEPT_MAP_POS.SOURCE_VOCABULARY_ID IN ('sh_pos');

