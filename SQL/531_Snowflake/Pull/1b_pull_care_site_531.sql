/*******************************************************************************
# Copyright 2021 Spectrum Health 
# http://www.spectrumhealth.org
#
# Unless required by applicable law or agreed to in writing, this software
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
# either express or implied.
#

Name: 'pull_care_site_2'

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 12-January-2021
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) 'app_care_site_2'. 

	Its purpose is to query data from Epic Clarity and append this data to 'CARE_SITE_Clarity_ALL'
	which will be used later in 'app_care_site_2'.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

--Structure: (if your structure is different, you will have to modify the code to match)
--    Databases:SH_OMOP_DB_PROD, SH_CLINICAL_DB_PROD
--    Schemas: SH_OMOP_DB_PROD.OMOP_CLARITY, SH_OMOP_DB_PROD.CDM, SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/
--USE ROLE SF_SH_OMOP_DEVELOPER;
----USE SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

-- NOTE: !!! this is LIMITED to the patients in the AoU_Driver_prod table. It takes too long to execute without.
--DELETE FROM  OMOP.care_site;

CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.CARE_SITE_Clarity_ALL 
AS
WITH T_POS
AS (
	SELECT DISTINCT CLARITY_POS.*
	-- PCP PHYSICIAN POINTOFSERVICE
	FROM  SH_OMOP_DB_PROD.CDM.AOU_DRIVER
    	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PATIENT
    		ON PATIENT.PAT_ID = AOU_DRIVER.EPIC_PAT_ID
    	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_POS --AS POS
    		ON PATIENT.CUR_PRIM_LOC_ID = CLARITY_POS.POS_ID
	
	UNION
	
	--Encounter physician PointOfService
	SELECT DISTINCT CLARITY_POS.*
	FROM  SH_OMOP_DB_PROD.CDM.AOU_DRIVER
    	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC
    		ON PAT_ENC.PAT_ID = AOU_DRIVER.EPIC_PAT_ID
    	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_DEP
    		ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
    	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_POS 
    		ON CLARITY_DEP.REV_LOC_ID = CLARITY_POS.POS_ID
)

SELECT DISTINCT T_POS.POS_ID 
	, T_POS.POS_NAME 
	, location.location_id 
	, POS_TYPE 

FROM T_POS
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_STATE
		ON T_POS.STATE_C = ZC_STATE.STATE_C
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_COUNTY
		ON T_POS.COUNTY_C = ZC_COUNTY.COUNTY_C
	LEFT JOIN SH_OMOP_DB_PROD.CDM.location 
		ON location.location_source_value = LEFT(COALESCE(T_POS.ADDRESS_LINE_1, '') 
    										|| COALESCE(T_POS.ADDRESS_LINE_2, '') 
    										|| COALESCE(T_POS.CITY, '') 
    										|| COALESCE(LEFT(ZC_STATE.ABBR, 2), '') 
    										|| COALESCE(T_POS.ZIP, '') 
    										|| COALESCE(ZC_COUNTY.COUNTY_C, ''), 50)
WHERE T_POS.POS_ID IS NOT NULL;



