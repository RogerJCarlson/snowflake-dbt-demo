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

Name: Pull_procedure_occurrence_CPT_AMB_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_procedure_occurrence_CPT_AMB_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to SH_OMOP_DB_PROD.OMOP_CLARITY.PROCEDURE_OCCURRENCE_ClarityAMB_CPT
	which will be used later in app_procedure_occurrence_CPT_AMB_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	SH_OMOP_DB_PROD.OMOP_CLARITY.PROCEDURE_OCCURRENCE_ClarityAMB_CPT may also be used in conjunction with other "APP_" scripts.


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


CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.PROCEDURE_OCCURRENCE_ClarityAMB_CPT 
AS  

WITH T_CPT_CODES
AS (
	SELECT DISTINCT EAP.PROC_ID
		,CASE
			WHEN EAP2.PROC_CODE IS NULL THEN
			EAP.PROC_CODE
			ELSE
			EAP2.PROC_CODE 
		END AS PROC_CODE
		,CASE
			WHEN EAP2.PROC_NAME IS NULL THEN
			EAP.PROC_NAME
			ELSE
			EAP2.PROC_NAME 
		END AS PROC_NAME

	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS EAP
	
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LINKED_PERFORMABLE
		ON EAP.PROC_ID = LINKED_PERFORMABLE.PROC_ID
	
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS EAP2
		ON LINKED_PERFORMABLE.LINKED_PERFORM_ID = EAP2.PROC_ID
	
	UNION
	
	SELECT DISTINCT EAP.PROC_ID AS PROC_ID
		,CASE
			WHEN EAP2.PROC_CODE IS NULL THEN
			EAP.PROC_CODE
			ELSE
			EAP2.PROC_CODE 
		END AS PROC_CODE
		,CASE
			WHEN EAP2.PROC_NAME IS NULL THEN
			EAP.PROC_NAME
			ELSE
			EAP2.PROC_NAME 
		END AS PROC_NAME
	
	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS EAP
	
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LINKED_CHARGEABLES
		ON EAP.PROC_ID = LINKED_CHARGEABLES.PROC_ID
	
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS EAP2
		ON LINKED_CHARGEABLES.LINKED_CHRG_ID = EAP2.PROC_ID
	
	)

SELECT  --NULL AS  PROCEDURE_OCCURRENCE_ID,
	SUBSTRING(PAT_ENC_AMB.AOU_ID, 2, LEN(PAT_ENC_AMB.AOU_ID)) AS PERSON_ID
	,PAT_ENC_AMB.AOU_ID
	,PAT_ENC_AMB.PAT_ID
	,PAT_ENC_AMB.PAT_ENC_CSN_ID
	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
	,PAT_OR_ADM_LINK_CSN AS PAT_OR_ADM_LINK_PAT_ENC_CSN_ID

	,ORDER_PROC.INSTANTIATED_TIME AS OP_INSTANTIATED_TIME
	,ORDER_PROC.ORDER_TIME AS OP_ORDER_TIME
	,ORDER_PROC.PROC_START_TIME AS OP_PROC_START_TIME
	,ORDER_PROC.PROC_BGN_TIME AS OP_PROC_BGN_TIME
	,ORDER_PROC.PROC_END_TIME AS OP_PROC_END_TIME

	,ORDER_PROC_CHILD.ORDER_TIME AS OP_CHILD_ORDER_TIME
	,ORDER_PROC_CHILD.PROC_START_TIME AS OP_CHILD_START_TIME
	,ORDER_PROC_CHILD.INSTANTIATED_TIME AS OP_CHILD_INSTANTIATED_TIME
	,ORDER_PROC_CHILD.PROC_BGN_TIME AS OP_CHILD_PROC_BGN_TIME
	,ORDER_PROC_CHILD.PROC_END_TIME AS OP_CHILD_PROC_END_TIME
	,ORDER_PROC.MODIFIER1_ID
	,MODIFIER_NAME
	,ORDER_PROC.QUANTITY
	,ORDER_PROC.AUTHRZING_PROV_ID
	,ORDER_PROC.FUTURE_OR_STAND

	, ORDER_PROC.PROC_ID
	,ORDER_DX_PROC.LINE AS ORDER_DX_LINE
	,ORDER_DX_PROC.DX_ID AS ORDER_DX_ID

	,T_CPT_CODES.PROC_CODE
	,T_CPT_CODES.PROC_NAME

	,ORDER_PROC.ORDER_STATUS_C
	,ZC_ORDER_STATUS.NAME AS ZC_ORDER_STATUS_NAME
	, ORDER_PROC.ORDER_PROC_ID

	, ORDER_PROC.ORDER_TYPE_C
	, ZC_ORDER_TYPE.NAME AS ZC_ORDER_TYPE_NAME

	,ORDER_PROC.ORDER_CLASS_C
	,ZC_ORDER_CLASS.NAME AS ZC_ORDER_CLASS_NAME

	,ORDER_PROC.LAB_STATUS_C
	,ZC_LAB_STATUS.NAME AS ZC_LAB_STATUS_NAME

--INTO SH_OMOP_DB_PROD.OMOP_CLARITY.PROCEDURE_OCCURRENCE_CLARITYAMB_CPT

FROM SH_OMOP_DB_PROD.OMOP_CLARITY.VISIT_OCCURRENCE_CLARITYAMB_ALL AS PAT_ENC_AMB

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC
		ON PAT_ENC_AMB.PAT_ENC_CSN_ID = ORDER_PROC.PAT_ENC_CSN_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC AS OP_CHILD
		ON PAT_ENC_AMB.PAT_ENC_CSN_ID = OP_CHILD.PAT_ENC_CSN_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_INSTANTIATED
		ON ORDER_PROC.ORDER_PROC_ID = ORDER_INSTANTIATED.ORDER_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC AS ORDER_PROC_CHILD
		ON ORDER_INSTANTIATED.INSTNTD_ORDER_ID = ORDER_PROC_CHILD.ORDER_PROC_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_DX_PROC 
	   ON ORDER_PROC.ORDER_PROC_ID = ORDER_DX_PROC.ORDER_PROC_ID

	LEFT JOIN T_CPT_CODES
		ON ORDER_PROC.PROC_ID = T_CPT_CODES.PROC_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_MOD
		ON ORDER_PROC.MODIFIER1_ID = CLARITY_MOD.MODIFIER_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_ORDER_STATUS 
	   ON ORDER_PROC.ORDER_STATUS_C = ZC_ORDER_STATUS.ORDER_STATUS_C
	   
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_LAB_STATUS 
	   ON ORDER_PROC.LAB_STATUS_C = ZC_LAB_STATUS.LAB_STATUS_C
	   
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.	ZC_ORDER_CLASS 
	   ON ORDER_PROC.ORDER_CLASS_C = ZC_ORDER_CLASS.ORDER_CLASS_C
	   
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.	ZC_ORDER_TYPE	 
	   ON ORDER_PROC.ORDER_TYPE_C = ZC_ORDER_TYPE.ORDER_TYPE_C

WHERE  (
		PAT_ENC_AMB.CALCULATED_ENC_STAT_C = 2
		OR PAT_ENC_AMB.CALCULATED_ENC_STAT_C IS NULL
		)
	AND (
		PAT_ENC_AMB.APPT_STATUS_C = 2
		OR PAT_ENC_AMB.APPT_STATUS_C IS NULL
		)
	AND 
		ORDER_PROC.ORDER_STATUS_C = 5 -- COMPLETE

--ADDED 11/6/2020 TO REMOVE FUTURE OR STANDING ORDERS
	AND
		ORDER_PROC.LAB_STATUS_C = 3 -- FINAL		






