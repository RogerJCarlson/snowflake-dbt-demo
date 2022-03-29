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

Name: pull_observation_ICD_SNOMED_HSP_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_observation_ICD_HSP_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.OBSERVATION_ClarityHosp_ICD
	which will be used later in app_observation_ICD_SNOMED_HSP_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.OBSERVATION_ClarityHosp_ICD may also be used in conjunction with other "APP_" scripts.

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

CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.OBSERVATION_CLARITYHOSP_ICD 
AS  

WITH T_DIAGNOSIS
AS (
	SELECT DISTINCT CLARITY_EDG.DX_ID
		,CLARITY_EDG.DX_NAME
		,EDG_CURRENT_ICD10.CODE AS ICD10_CODE
		,EDG_CURRENT_ICD9.CODE AS ICD9_CODE
	
	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EDG
	
		LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.EDG_CURRENT_ICD10
			ON CLARITY_EDG.DX_ID = EDG_CURRENT_ICD10.DX_ID
		
		LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.EDG_CURRENT_ICD9
			ON CLARITY_EDG.DX_ID = EDG_CURRENT_ICD9.DX_ID
	)

SELECT DISTINCT SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMBER(28,0) AS PERSON_ID
	,AOU_ID
	,PAT_ENC_DX.CONTACT_DATE
	,PAT_ENC_DX.PAT_ENC_CSN_ID
	,T_DIAGNOSIS.DX_ID
	,T_DIAGNOSIS.DX_NAME

	,T_DIAGNOSIS.ICD10_CODE
	,T_DIAGNOSIS.ICD9_CODE
	,PAT_ENC_HSP.BILL_ATTEND_PROV_ID
	,'OBSERVATION--CLARITYHOSP--ICD' AS ETL_MODULE

--INTO OMOP_CLARITY.OBSERVATION_CLARITYHOSP_ICD

FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_DX

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP
		ON PAT_ENC_DX.PAT_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID

		LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HSP_ATND_PROV
		ON PAT_ENC_HSP.PAT_ENC_CSN_ID = HSP_ATND_PROV.PAT_ENC_CSN_ID
			AND HOSP_DISCH_TIME BETWEEN ATTEND_FROM_DATE
				AND COALESCE(ATTEND_TO_DATE, GETDATE())

	INNER JOIN SH_OMOP_DB_PROD.CDM.AOU_DRIVER
		ON PAT_ENC_DX.PAT_ID = CDM.AOU_DRIVER.EPIC_PAT_ID

	--------CONCEPT MAPPING--------------------
	INNER JOIN T_DIAGNOSIS
		ON PAT_ENC_DX.DX_ID = T_DIAGNOSIS.DX_ID

