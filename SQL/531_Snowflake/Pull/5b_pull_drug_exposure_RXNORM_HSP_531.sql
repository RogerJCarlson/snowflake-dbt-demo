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

Name: pull_drug_exposure_RXNORM_HSP_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_drug_exposure_RXNORM_HSP_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.DRUG_EXPOSURE_ClarityHosp_RXNORM
	which will be used later in app_drug_exposure_RXNORM_HSP_2.sql.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.DRUG_EXPOSURE_ClarityHosp_RXNORM may also be used in conjunction with other "APP_" scripts.

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

CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.DRUG_EXPOSURE_CLARITYHOSP_RXNORM 
AS  

SELECT DISTINCT SUBSTRING(CDM.AOU_DRIVER.AOU_ID, 2, LEN(CDM.AOU_DRIVER.AOU_ID)) AS PERSON_ID
	,AOU_ID
	,PAT_ENC_HSP.PAT_ENC_CSN_ID
	,ORDER_MED.AUTHRZING_PROV_ID

	,MAR_ADMIN_INFO.TAKEN_TIME

	,ORDER_MED.ORDER_END_TIME
	,ORDER_MED.ORDER_START_TIME
	,RXNORM_CODES.RXNORM_CODE
	,RXNORM_CODES.RXNORM_TERM_TYPE_C
	,ZC_RXNORM_TERM_TYPE.NAME AS ZC_RXNORM_TERM_TYPE_name
	,END_DATE
	,ORDER_MED.RSN_FOR_DISCON_C
	,ZC_RSN_FOR_DISCON.NAME AS ZC_RSN_FOR_DISCON_name
	,REFILLS
	,QUANTITY
	,ZC_MED_UNIT.NAME AS ZC_MED_UNIT_NAME
	,MAR_ADMIN_INFO.SIG
	,MAR_ADMIN_INFO.LINE AS MAR_ADMIN_INFO_LINE
	,EDITED_LINE
	,MAR_ACTION_C
	,REASON_C
	,MAR_ENC_CSN
	,MAR_ADMIN_INFO.ORDER_MED_ID
	,CLARITY_MEDICATION.medication_ID
	,CLARITY_MEDICATION.NAME AS CLARITY_MEDICATION_NAME
	,ORDER_MED.MED_ROUTE_C
	,ZC_ADMIN_ROUTE.NAME AS ZC_ADMIN_ROUTE_NAME
	,ORDER_STATUS_C
	,'PULL_DRUG_EXPOSURE--CLARITYHOSP--RXNORM' AS ETL_Module


--INTO OMOP_CLARITY.DRUG_EXPOSURE_CLARITYHOSP_RXNORM
FROM SH_OMOP_DB_PROD.CDM.AOU_DRIVER

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP
	ON AOU_DRIVER.EPIC_PAT_ID = PAT_ENC_HSP.PAT_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ORDER_MED
	ON ORDER_MED.PAT_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_MEDICATION
	ON ORDER_MED.MEDICATION_ID = CLARITY_MEDICATION.MEDICATION_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.MAR_ADMIN_INFO
	ON ORDER_MED.ORDER_MED_ID = MAR_ADMIN_INFO.ORDER_MED_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_MED_UNIT
	ON ORDER_MED.HV_DOSE_UNIT_C = ZC_MED_UNIT.DISP_QTYUNIT_C

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RSN_FOR_DISCON
	ON ORDER_MED.RSN_FOR_DISCON_C = ZC_RSN_FOR_DISCON.RSN_FOR_DISCON_C

LEFT JOIN OMOP.PROVIDER
	ON ORDER_MED.AUTHRZING_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_ADMIN_ROUTE
	ON ORDER_MED.MED_ROUTE_C = ZC_ADMIN_ROUTE.MED_ROUTE_C

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.RXNORM_CODES
	ON ORDER_MED.MEDICATION_ID = RXNORM_CODES.MEDICATION_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_RXNORM_TERM_TYPE
	ON RXNORM_CODES.RXNORM_TERM_TYPE_C = ZC_RXNORM_TERM_TYPE.RXNORM_TERM_TYPE_C

WHERE START_DATE IS NOT NULL
	--AND ZC_RXNORM_TERM_TYPE.RXNORM_TERM_TYPE_C <> 2 --2 - Precise Ingredient
	AND ORDER_STATUS_C NOT IN (
		4 --4 - CANCELED
		,6 --6 - HOLDING
		,7 --7 - DENIED
		,8 --8 - SUSPEND
		,9 --9 - DISCONTINUED
		)
	AND MAR_ACTION_C NOT IN (
		2 --2 - Missed
		,4 --4 - Canceled Entry
		,8 --8 - Stopped
		,15 --15 - See Alternative
		);
