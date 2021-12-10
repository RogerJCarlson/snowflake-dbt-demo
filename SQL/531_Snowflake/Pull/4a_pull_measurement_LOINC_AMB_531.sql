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

Name: pull_measurement_LOINC_AMB_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_measurement_LOINC_AMB_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.MEASUREMENT_ClarityAMB_LOINC
	which will be used later in app_measurement_LOINC_AMB_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.MEASUREMENT_ClarityAMB_LOINC may also be used in conjunction with other "APP_" scripts.

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

    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.MEASUREMENT_ClarityAMB_LOINC 
AS  


WITH T_LOINC_CODES
AS (
	SELECT RECORD_ID
		,LNC_CODE
		,LNC_COMPON
	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LNC_DB_MAIN
	)

SELECT SUBSTRING(AoU_Driver.AoU_ID, 2, LEN(AoU_Driver.AoU_ID)) AS person_id
	,AoU_Driver.AoU_ID
	,TRY_TO_NUMBER (visit_occurrence.visit_source_value, '9999999999',38,0) AS TRYTONUMBER
	,PAT_ENC_AMB.PAT_ID
	,PAT_ENC_AMB.PAT_ENC_CSN_ID
	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
	,PAT_ENC_AMB.pat_or_adm_link_csn as pat_or_adm_link_PAT_ENC_CSN_ID
	,ORDER_PROC_2.SPECIMN_TAKEN_TIME
	,order_proc.ORDER_TIME
	,ORDER_RESULTS.ORD_VALUE
	,ORDER_RESULTS.REFERENCE_LOW
	,ORDER_RESULTS.REFERENCE_HIGH
	,T_LOINC_CODES.LNC_CODE
	,T_LOINC_CODES.LNC_COMPON
	,T_LOINC_CODES.RECORD_ID
	,ORDER_RESULTS.REFERENCE_UNIT
	,ORDER_PROC.AUTHRZING_PROV_ID
	,Auth_Provider.PROV_NAME AS Auth_Provider_NAME
	,Auth_Provider.PROV_TYPE AS Auth_Provider_Type

	,PAT_ENC_AMB.VISIT_PROV_ID
	,Visit_Provider_NAME
	,Visit_Provider_Type

	,PAT_ENC_AMB.PCP_PROV_ID
	,PCP_Provider_NAME
	, PCP_Provider_Type
	,ORDER_PROC.ORDER_PROC_ID
	,ORDER_RESULTS.COMPON_LNC_ID
	,ORDER_RESULTS.RESULT_FLAG_C
	,ZC_RESULT_FLAG.NAME AS ZC_RESULT_FLAG_NAME
	,ORDER_RESULTS.RESULT_STATUS_C
	,ZC_RESULT_STATUS.NAME AS ZC_RESULT_STATUS_NAME
	,ORDER_PROC.ORDER_STATUS_C
	,ZC_ORDER_STATUS.NAME AS ZC_ORDER_STATUS_NAME
	,'pull_MEASUREMENT--ClarityAMB--LOINC' AS ETL_Module

--INTO OMOP_Clarity.MEASUREMENT_ClarityAMB_LOINC

FROM  SH_OMOP_DB_PROD.CDM.AoU_Driver

INNER JOIN OMOP_Clarity.VISIT_OCCURRENCE_ClarityAMB_ALL AS PAT_ENC_AMB
	ON AoU_Driver.Epic_Pat_id = PAT_ENC_AMB.PAT_ID

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC.PAT_ENC_CSN_ID = PAT_ENC_AMB.PAT_ENC_CSN_ID

	INNER JOIN SH_OMOP_DB_PROD.CDM.visit_occurrence
		ON ORDER_PROC.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value
--		  AND TRY_TO_NUMBER (visit_occurrence.visit_source_value, '9999999999',38,0) IS NOT NULL
--			AND ISNUMERIC(visit_occurrence.visit_source_value) = 1 (replaced with try_to_number)

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC_2
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC.ORDER_PROC_ID = SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC_2.ORDER_PROC_ID

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_RESULTS
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC.ORDER_PROC_ID = SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_RESULTS.ORDER_PROC_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER AS Auth_Provider
		ON ORDER_PROC.AUTHRZING_PROV_ID = Auth_Provider.PROV_ID

	INNER JOIN T_LOINC_CODES
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_RESULTS.COMPON_LNC_ID = T_LOINC_CODES.RECORD_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RESULT_FLAG
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_RESULTS.RESULT_FLAG_C = SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RESULT_FLAG.RESULT_FLAG_C

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RESULT_STATUS
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_RESULTS.RESULT_STATUS_C = SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RESULT_STATUS.RESULT_STATUS_C

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_ORDER_STATUS
		ON ORDER_PROC.ORDER_STATUS_C = ZC_ORDER_STATUS.ORDER_STATUS_C

WHERE ( 	 PAT_ENC_AMB.ENC_TYPE_C <> 3 AND
		ORDER_PROC.ORDER_STATUS_C <> 4 
		)

