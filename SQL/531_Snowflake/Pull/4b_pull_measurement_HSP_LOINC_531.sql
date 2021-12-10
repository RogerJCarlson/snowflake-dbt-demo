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

Name: pull_measurement_HSP_LOINC_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_measurement_HSP_LOINC_2. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.MEASUREMENT_ClarityAMB_LOINC
	which will be used later in app_measurement_HSP_LOINC_2.  The table may have numerous
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

    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_LOINC 
AS  

WITH T_LOINC_CODES
AS (
	SELECT RECORD_ID
		,LNC_CODE
		,LNC_COMPON
	
	FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.LNC_DB_MAIN
	)

SELECT DISTINCT
	--NULL   AS MEASUREMENT_ID, ----IDENTITY
	SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID)) AS PERSON_ID
	,AOU_DRIVER.AOU_ID
	,ORDER_PROC_2.SPECIMN_TAKEN_TIME
	,ORDER_PROC.ORDER_TIME
	,ORD_VALUE
	,ORDER_RESULTS.REFERENCE_LOW
	,ORDER_RESULTS.REFERENCE_HIGH
	,T_LOINC_CODES.LNC_CODE
	,T_LOINC_CODES.LNC_COMPON
	,T_LOINC_CODES.RECORD_ID
	,ORDER_RESULTS.REFERENCE_UNIT
	,ORDER_PROC.AUTHRZING_PROV_ID
	,AUTH_PROVIDER.PROV_NAME AS AUTH_PROVIDER_NAME
	,AUTH_PROVIDER.PROV_TYPE AS AUTH_PROVIDER_TYPE

	,PAT_ENC_HSP.BILL_ATTEND_PROV_ID
	,ATTEND_PROVIDER.PROV_NAME AS ATTEND_PROVIDER_NAME
	,ATTEND_PROVIDER.PROV_TYPE AS ATTEND_PROVIDER_TYPE

	,PAT_ENC_HSP.PAT_ID
	,PAT_ENC_HSP.PAT_ENC_CSN_ID
	,ORDER_PROC.ORDER_PROC_ID
	,ORDER_RESULTS.COMPON_LNC_ID
	,ORDER_RESULTS.RESULT_FLAG_C
	,ZC_RESULT_FLAG.NAME AS ZC_RESULT_FLAG_NAME
	,ORDER_RESULTS.RESULT_STATUS_C
	,ZC_RESULT_STATUS.NAME AS ZC_RESULT_STATUS_NAME
	,ORDER_PROC.ORDER_STATUS_C
	,ZC_ORDER_STATUS.NAME AS ZC_ORDER_STATUS_NAME
	,'PULL_MEASUREMENT--CLARITYHOSP--LOINC' AS ETL_MODULE

--INTO OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_LOINC

FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP

INNER JOIN SH_OMOP_DB_PROD.CDM.AOU_DRIVER
	ON PAT_ENC_HSP.PAT_ID = AOU_DRIVER.EPIC_PAT_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC
	ON ORDER_PROC.PAT_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID

INNER JOIN SH_OMOP_DB_PROD.CDM.VISIT_OCCURRENCE
	ON ORDER_PROC.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_PROC_2
	ON ORDER_PROC.ORDER_PROC_ID = ORDER_PROC_2.ORDER_PROC_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_RESULTS
	ON ORDER_PROC.ORDER_PROC_ID = ORDER_RESULTS.ORDER_PROC_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER AS AUTH_PROVIDER
		ON ORDER_PROC.AUTHRZING_PROV_ID = AUTH_PROVIDER.PROV_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER AS ATTEND_PROVIDER
		ON PAT_ENC_HSP.BILL_ATTEND_PROV_ID = ATTEND_PROVIDER.PROV_ID

INNER JOIN T_LOINC_CODES
	ON ORDER_RESULTS.COMPON_LNC_ID = T_LOINC_CODES.RECORD_ID

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RESULT_FLAG
	ON ORDER_RESULTS.RESULT_FLAG_C = ZC_RESULT_FLAG.RESULT_FLAG_C

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RESULT_STATUS
	ON ORDER_RESULTS.RESULT_STATUS_C = ZC_RESULT_STATUS.RESULT_STATUS_C

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_ORDER_STATUS
	ON ORDER_PROC.ORDER_STATUS_C = ZC_ORDER_STATUS.ORDER_STATUS_C

WHERE (ORDER_PROC.ORDER_STATUS_C <> 4) 

