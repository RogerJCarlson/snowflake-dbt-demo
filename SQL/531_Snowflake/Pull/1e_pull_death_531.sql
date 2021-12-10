/*******************************************************************************
# Copyright 2020 Spectrum Health 
# http://www.spectrumhealth.org
#
# Unless required by applicable law or agreed to in writing, this software
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
# either express or implied.
#
********************************************************************************/

/*******************************************************************************

Name: pull_death_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 12-January-2021
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_death_2. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.DEATH_Clarity_ALL
	which will be used later in app_death_2.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

Structure: (if your structure is different, you will have to modify the code to match)
	Databases:SH_OMOP_DB_PROD, SH_CLINICAL_DB_PROD
	Schemas: SH_OMOP_DB_PROD.OMOP_CLARITY, SH_OMOP_DB_PROD.CDM, SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.DEATH_Clarity_ALL 
AS  

SELECT DISTINCT SUBSTRING(CDM.AoU_Driver.AoU_ID, 2, LEN(CDM.AoU_Driver.AoU_ID)) AS person_id
--      ,convert(date,DEATH_DATE) as death_date
      ,DEATH_DATE::date as death_date
      ,DEATH_DATE as death_datetime
      --,--need cause OF death
      
--INTO OMOP_Clarity.DEATH_Clarity_ALL
  FROM SH_OMOP_DB_PROD.CDM.AoU_Driver 
 inner JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PATIENT ON CDM.AoU_Driver.Epic_Pat_id = PATIENT.PAT_ID AND PAT_STATUS_C = 2


