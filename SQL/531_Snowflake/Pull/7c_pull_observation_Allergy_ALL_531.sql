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

Name: pull_observation_Allergy_ALL_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 15-January-2021
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_observation_Allergy_ALL_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.OBSERVATION_ClarityALL_Allergy
	which will be used later in app_measurement_LOINC_AMB_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.OMOP_Clarity.OBSERVATION_ClarityALL_Allergy may also be used in conjunction with other "APP_" scripts.

Structure: (if your structure is different, you will have to modify the code to match)
    Databases:SH_OMOP_DB_PROD, SH_CLINICAL_DB_PROD
    Schemas: SH_OMOP_DB_PROD.OMOP_CLARITY, SH_OMOP_DB_PROD.CDM, SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE ROLE SF_SH_OMOP_DEVELOPER;

--USE SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ;
--USE SCHEMA SH_OMOP_DB_PROD.OMOP_CLARITY;
--USE SCHEMA SH_OMOP_DB_PROD.CDM;

--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.OBSERVATION_CLARITYALL_ALLERGY 
AS  

 WITH T_ALLERGY_CODES
AS (
	SELECT A.ALLERGEN_ID
		, A.ALLERGEN_NAME
		, CONCAT (
			'ALLERGY TO '
			, A.ALLERGEN_NAME
			) AS CONCEPT_NAME
	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CL_ELG A
	WHERE UPPER(ALLERGEN_NAME) NOT IN ('NO KNOWN ALLERGIES', 'NKA', 'NKDA', 'NONE')
	)

SELECT SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID)) AS PERSON_ID
	, AOU_DRIVER.AOU_ID
	, PAT_ENC.PAT_ID
	, PAT_ENC.PAT_ENC_CSN_ID
	, PAT_ENC.ENC_TYPE_C
	, T_ALLERGY_CODES.ALLERGEN_ID
	, T_ALLERGY_CODES.ALLERGEN_NAME
	, T_ALLERGY_CODES.CONCEPT_NAME
	, ALLERGY.ALRGY_ENTERED_DTTM
	, ALLERGY.DATE_NOTED
	, PAT_ENC.CONTACT_DATE
	, ALLERGY.DESCRIPTION AS VALUE_AS_STRING
	,COALESCE(PAT_ENC.VISIT_PROV_ID, PAT_ENC_hsp.BILL_ATTEND_PROV_ID) as PROV_ID

--INTO OMOP_CLARITY.OBSERVATION_CLARITYALL_ALLERGY

FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ALLERGIES 

	INNER JOIN CDM.AoU_Driver  
		ON (AoU_Driver.Epic_Pat_id = PAT_ALLERGIES.PAT_ID)

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ALLERGY  
		ON (PAT_ALLERGIES.ALLERGY_RECORD_ID = ALLERGY.ALLERGY_ID)

	LEFT JOIN T_ALLERGY_CODES
		ON (T_ALLERGY_CODES.ALLERGEN_ID = ALLERGY.ALLERGEN_ID)

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC  
		ON ALLERGY.ALLERGY_PAT_CSN = PAT_ENC.PAT_ENC_CSN_ID
	
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_hsp  
		ON ALLERGY.ALLERGY_PAT_CSN = PAT_ENC_hsp.PAT_ENC_CSN_ID		

WHERE UPPER(ALLERGY.DESCRIPTION) != 'NO KNOWN ALLERGIES' 
