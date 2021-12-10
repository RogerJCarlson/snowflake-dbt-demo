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

Name: Pull_procedure_occurrence_ANES_SNOMED_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_procedure_occurrence_ANES_SNOMED_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityANES_SNOMED
	which will be used later in app_procedure_occurrence_ANES_SNOMED_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityANES_SNOMED may also be used in conjunction with other "APP_" scripts.

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
  
    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.PROCEDURE_OCCURRENCE_ClarityANES_SNOMED 
AS  
WITH
 T_PROC_CODES
AS (
	SELECT DISTINCT eap.proc_id
		,eap.PROC_CODE
		,eap.PROC_NAME
	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS eap
-----------------------
	--SELECT DISTINCT eap.proc_id
	--	,
	--	case
	--		when eap2.PROC_CODE is null then
	--		eap.PROC_CODE
	--		else
	--		eap2.PROC_CODE 
	--	end AS PROC_CODE
	--	,
	--	case
	--		when eap2.PROC_NAME is null then
	--		eap.PROC_NAME
	--		else
	--		eap2.PROC_NAME 
	--	end AS PROC_NAME

	--FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS eap
	
	--LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LINKED_PERFORMABLE
	--	ON eap.PROC_ID = LINKED_PERFORMABLE.PROC_ID
	
	--LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS eap2
	--	ON LINKED_PERFORMABLE.LINKED_PERFORM_ID = eap2.PROC_ID
	
	--UNION
	
	----select * from SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LINKED_PERFORMABLE
	--SELECT DISTINCT eap.proc_id as PROC_ID
	--	,case
	--		when eap2.PROC_CODE is null then
	--		eap.PROC_CODE
	--		else
	--		eap2.PROC_CODE 
	--	end AS PROC_CODE
	--	,case
	--		when eap2.PROC_NAME is null then
	--		eap.PROC_NAME
	--		else
	--		eap2.PROC_NAME 
	--	end AS PROC_NAME
	
	--FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS eap
	
	--LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LINKED_CHARGEABLES
	--	ON eap.PROC_ID = LINKED_CHARGEABLES.PROC_ID
	
	--LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS eap2
	--	ON LINKED_CHARGEABLES.LINKED_CHRG_ID = eap2.PROC_ID
	
	)

SELECT DISTINCT --null as  procedure_occurrence_id,
	SUBSTRING(PAT_ENC_AMB.AoU_ID, 2, LEN(PAT_ENC_AMB.AoU_ID)) AS person_id
		-----hospital encounter---------
	,pat_enc_hsp.PAT_ENC_CSN_ID
	--------------------------------
	,AN_PAT_ID
	,AN_53_ENC_CSN_ID
	,F_AN_RECORD_SUMMARY.AN_52_ENC_CSN_ID
	,AN_INPATIENT_DATA_ID
	,AN_LOG_ID
	,F_AN_RECORD_SUMMARY.AN_RESP_PROV_ID

	,F_AN_RECORD_SUMMARY.AN_START_DATETIME
	,F_AN_RECORD_SUMMARY.AN_STOP_DATETIME
	,F_AN_RECORD_SUMMARY.AN_PROC_NAME

	,PAT_ENC_AMB.AoU_ID
	,PAT_ENC_AMB.PAT_ID

	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME

	,ORDER_PROC.MODIFIER1_ID
	,MODIFIER_NAME
	,ORDER_PROC.QUANTITY
	,ORDER_PROC.AUTHRZING_PROV_ID
	,ORDER_PROC.FUTURE_OR_STAND

	, ORDER_PROC.PROC_ID
	,ORDER_DX_PROC.LINE as order_dx_line
	,ORDER_DX_PROC.DX_ID as order_dx_id

	,T_PROC_CODES.PROC_CODE
	,T_PROC_CODES.PROC_NAME
	--,T_PROC_CODES.LINKED_PROC_CODE
	--,T_PROC_CODES.LINKED_PROC_NAME

	,order_proc.ORDER_STATUS_C
	,ZC_ORDER_STATUS.name as ZC_ORDER_STATUS_name
	, ORDER_PROC.ORDER_PROC_ID

	, ORDER_PROC.ORDER_TYPE_C
	, ZC_ORDER_TYPE.NAME AS ZC_ORDER_TYPE_NAME

	,ORDER_PROC.ORDER_CLASS_C
	,ZC_ORDER_CLASS.NAME AS ZC_ORDER_CLASS_NAME

	,ORDER_PROC.LAB_STATUS_C
	,ZC_LAB_STATUS.NAME AS ZC_LAB_STATUS_NAME
		--, ORDER_PROC.*

--INTO OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityANES_SNOMED

FROM SH_OMOP_DB_PROD.OMOP_Clarity.VISIT_OCCURRENCE_ClarityAMB_ALL AS PAT_ENC_AMB

-- associates anethesia EVENT to hospital encounter
  INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.F_AN_RECORD_SUMMARY on PAT_ENC_AMB.pat_enc_csn_id = F_AN_RECORD_SUMMARY.AN_52_ENC_CSN_ID
  inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.AN_HSB_LINK_INFO on F_AN_RECORD_SUMMARY.AN_EPISODE_ID=AN_HSB_LINK_INFO.SUMMARY_BLOCK_ID
  inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.pat_enc_hsp on AN_HSB_LINK_INFO.AN_BILLING_CSN_ID=pat_enc_hsp.pat_enc_csn_id


	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC
		ON PAT_ENC_AMB.PAT_ENC_CSN_ID = ORDER_PROC.PAT_ENC_CSN_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC AS OP_CHILD
		ON PAT_ENC_AMB.PAT_ENC_CSN_ID = OP_CHILD.PAT_ENC_CSN_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_INSTANTIATED
		ON ORDER_PROC.ORDER_PROC_ID = ORDER_INSTANTIATED.ORDER_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC AS ORDER_PROC_child
		ON ORDER_INSTANTIATED.INSTNTD_ORDER_ID = ORDER_PROC_child.ORDER_proc_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_DX_PROC on ORDER_PROC.ORDER_PROC_ID = ORDER_DX_PROC.ORDER_PROC_ID

	LEFT
	 JOIN T_PROC_CODES
		ON ORDER_PROC.PROC_ID = T_PROC_CODES.PROC_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_MOD
		ON ORDER_PROC.MODIFIER1_ID = CLARITY_MOD.MODIFIER_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_ORDER_STATUS on ORDER_PROC.ORDER_STATUS_C = ZC_ORDER_STATUS.ORDER_STATUS_C
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_LAB_STATUS on ORDER_PROC.LAB_STATUS_C = ZC_LAB_STATUS.LAB_STATUS_C
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.	ZC_ORDER_CLASS on ORDER_PROC.ORDER_CLASS_C = ZC_ORDER_CLASS.ORDER_CLASS_C
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.	ZC_ORDER_TYPE	 on ORDER_PROC.ORDER_TYPE_C = ZC_ORDER_TYPE.ORDER_TYPE_C

WHERE 	ORDER_PROC.FUTURE_OR_STAND is null
	AND
		(
		PAT_ENC_AMB.CALCULATED_ENC_STAT_C = 2
		OR PAT_ENC_AMB.CALCULATED_ENC_STAT_C IS NULL
		)
	AND (
		PAT_ENC_AMB.APPT_STATUS_C = 2
		OR PAT_ENC_AMB.APPT_STATUS_C IS NULL
		)
	AND 
		order_proc.ORDER_STATUS_C = 5 -- COMPLETE


		--order by an_start_datetime
