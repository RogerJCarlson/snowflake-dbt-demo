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

Name: pull_NOTE_AMB_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_NOTE_AMB_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.NOTE_ClarityAMB_ALL
	which will be used later in app_NOTE_AMB_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.NOTE_ClarityAMB_ALL may also be used in conjunction with other "APP_" scripts.

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
--
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.NOTE_CLARITYAMB_ALL 
AS  

SELECT  SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMBER(28,0) AS PERSON_ID
	,AOU_DRIVER.AOU_ID
	,PAT_ENC_AMB.PAT_ID
	,PAT_ENC_AMB.PAT_ENC_CSN_ID
	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
	,PAT_ENC_AMB.PAT_OR_ADM_LINK_CSN AS PAT_OR_ADM_LINK_PAT_ENC_CSN_ID
	,NOTE_ENC_INFO.ENTRY_INSTANT_DTTM
	
	,ZC_NOTE_TYPE_IP.NAME AS ZC_NOTE_TYPE_IP_NAME
--	,NULL AS ZC_NOTE_TYPE_IP_NAME

	,HNO_INFO.IP_NOTE_TYPE_C
--	,NULL AS TYPE_IP_C
	
	,HNO_INFO.AMB_NOTE_YN
	,NOTE_ENC_INFO.NOTE_ID
	,NOTE_ENC_INFO.CONTACT_DATE_REAL
	--,PAT_ENC_AMB.VISIT_PROV_ID
		--ADDED 3/3/2021 
	,PAT_ENC_AMB.VISIT_PROV_ID
	,VISIT_PROVIDER_NAME
	,VISIT_PROVIDER_TYPE

	,PAT_ENC_AMB.PCP_PROV_ID
	,PCP_PROVIDER_NAME
	, PCP_PROVIDER_TYPE
--	,HNO_INFO.IP_NOTE_TYPE_C
	,HNO_NOTE_TEXT.LINE
	,HNO_NOTE_TEXT.NOTE_CSN_ID
	,HNO_NOTE_TEXT.CONTACT_DATE
	,HNO_NOTE_TEXT.CM_CT_OWNER_ID
	,HNO_NOTE_TEXT.CHRON_ITEM_NUM
	,HNO_NOTE_TEXT.NOTE_TEXT
	,HNO_NOTE_TEXT.IS_ARCHIVED_YN
	,'PULL_NOTE--CLARITYAMB--ALL' AS ETL_MODULE

--INTO SH_OMOP_DB_PROD.OMOP_CLARITY.NOTE_CLARITYAMB_ALL

FROM SH_OMOP_DB_PROD.OMOP_CLARITY.VISIT_OCCURRENCE_CLARITYAMB_ALL AS PAT_ENC_AMB

INNER JOIN SH_OMOP_DB_PROD.CDM.AOU_DRIVER
	ON PAT_ENC_AMB.PAT_ID = CDM.AOU_DRIVER.EPIC_PAT_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HNO_INFO
	ON  PAT_ENC_AMB.PAT_ENC_CSN_ID= HNO_INFO.PAT_ENC_CSN_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_NOTE_TYPE_IP
	ON HNO_INFO.IP_NOTE_TYPE_C = ZC_NOTE_TYPE_IP.TYPE_IP_C

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.NOTE_ENC_INFO
	ON HNO_INFO.NOTE_ID = NOTE_ENC_INFO.NOTE_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HNO_NOTE_TEXT
	ON NOTE_ENC_INFO.NOTE_ID = HNO_NOTE_TEXT.NOTE_ID
		AND NOTE_ENC_INFO.CONTACT_DATE_REAL = HNO_NOTE_TEXT.CONTACT_DATE_REAL

WHERE ENTRY_INSTANT_DTTM IS NOT NULL 
	AND 
	PAT_ENC_AMB.ENC_TYPE_C <> 3 

