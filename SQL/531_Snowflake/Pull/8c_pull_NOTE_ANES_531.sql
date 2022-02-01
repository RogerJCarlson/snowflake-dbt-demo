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

Name: pull_NOTE_ANES_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_NOTE_ANES_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.NOTE_ClarityANES_ALL
	which will be used later in app_NOTE_ANES_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.NOTE_ClarityANES_ALL may also be used in conjunction with other "APP_" scripts.

Structure: (if your structure is different, you will have to modify the code to match)
	Databases:EpicCare, EpicClarity
	Schemas: EpicClarity.dbo, EpicCare.OMOP, EpicCare.OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE ROLE SF_SH_OMOP_DEVELOPER;

--USE SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ;
--USE SCHEMA SH_OMOP_DB_PROD.OMOP_CLARITY;
--USE SCHEMA SH_OMOP_DB_PROD.CDM;

--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
    
    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.NOTE_ClarityANES_ALL 
AS  


SELECT  SUBSTRING(AoU_Driver.AoU_ID, 2, LEN(AoU_Driver.AoU_ID)) AS person_id
	,AoU_Driver.AoU_ID
	,PAT_ENC_AMB.PAT_ID
	-----hospital encounter---------
	,pat_enc_hsp.PAT_ENC_CSN_ID
	--------------------------------
	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
	,PAT_ENC_AMB.pat_or_adm_link_csn as pat_or_adm_link_PAT_ENC_CSN_ID
	,NOTE_ENC_INFO.ENTRY_INSTANT_DTTM
	,ZC_NOTE_TYPE_IP.NAME AS ZC_NOTE_TYPE_IP_NAME
	,hno_info.IP_NOTE_TYPE_C
	,hno_info.AMB_NOTE_YN
	,NOTE_ENC_INFO.NOTE_ID
	,NOTE_ENC_INFO.CONTACT_DATE_REAL
	,PAT_ENC_AMB.visit_PROV_ID
--	,HNO_INFO.IP_NOTE_TYPE_C
	,HNO_NOTE_TEXT.LINE
	,HNO_NOTE_TEXT.NOTE_CSN_ID
	,HNO_NOTE_TEXT.CONTACT_DATE
	,HNO_NOTE_TEXT.CM_CT_OWNER_ID
	,HNO_NOTE_TEXT.CHRON_ITEM_NUM
	,HNO_NOTE_TEXT.NOTE_TEXT
	,HNO_NOTE_TEXT.IS_ARCHIVED_YN
	,'pull_NOTE--ClarityANES--ALL' AS ETL_Module

--INTO OMOP_Clarity.NOTE_ClarityANES_ALL

FROM SH_OMOP_DB_PROD.CDM.AoU_Driver

INNER JOIN OMOP_Clarity.VISIT_OCCURRENCE_ClarityAMB_ALL AS PAT_ENC_AMB
	ON AoU_Driver.Epic_Pat_id = PAT_ENC_AMB.PAT_ID

-- associates anethesia EVENT to hospital encounter
  INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.F_AN_RECORD_SUMMARY on PAT_ENC_AMB.pat_enc_csn_id = F_AN_RECORD_SUMMARY.AN_53_ENC_CSN_ID
  inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.AN_HSB_LINK_INFO on F_AN_RECORD_SUMMARY.AN_EPISODE_ID=AN_HSB_LINK_INFO.SUMMARY_BLOCK_ID
  inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.pat_enc_hsp on AN_HSB_LINK_INFO.AN_BILLING_CSN_ID=pat_enc_hsp.pat_enc_csn_id

  
INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HNO_INFO
	ON  PAT_ENC_AMB.PAT_ENC_CSN_ID= hno_info.PAT_ENC_CSN_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_NOTE_TYPE_IP
	ON HNO_INFO.IP_NOTE_TYPE_C = ZC_NOTE_TYPE_IP.TYPE_IP_C

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.NOTE_ENC_INFO
	ON HNO_INFO.NOTE_ID = NOTE_ENC_INFO.NOTE_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HNO_NOTE_TEXT
	ON NOTE_ENC_INFO.NOTE_ID = SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HNO_NOTE_TEXT.NOTE_ID
		AND NOTE_ENC_INFO.CONTACT_DATE_REAL = HNO_NOTE_TEXT.CONTACT_DATE_REAL

WHERE
	PAT_ENC_AMB.ENC_TYPE_C = 53 -- Anesthesia EVENT
