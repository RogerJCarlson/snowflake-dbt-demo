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

Name: pull_measurement_FlowSheet_ANES_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) 
		app_measurement_FlowSheet_ANES_vitals_2.sql
		app_measurement_FlowSheet_ANES_BPS_2.sql
		app_measurement_FlowSheet_ANES_BPD_2.sql
		app_measurement_FlowSheet_ANES_BPM_2.sql
		app_measurement_FlowSheet_ANES_temperature_2.sql. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.MEASUREMENT_ClarityANES_FlowSheet
	which will be used later in the above "APP_" scripts.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.MEASUREMENT_ClarityANES_FlowSheet may also be used in conjunction with other "APP_" scripts.

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

    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.MEASUREMENT_CLARITYANES_FLOWSHEET 
AS  


SELECT  DISTINCT SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID)) AS PERSON_ID
	,AOU_DRIVER.AOU_ID
	,PAT_ENC_AMB.PAT_ID
	-----HOSPITAL ENCOUNTER---------
	,PAT_ENC_HSP.PAT_ENC_CSN_ID
	--------------------------------
	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
	,PAT_ENC_AMB.PAT_OR_ADM_LINK_CSN AS PAT_OR_ADM_LINK_PAT_ENC_CSN_ID

	,IP_FLWSHT_MEAS.RECORDED_TIME
	,IP_FLWSHT_MEAS.MEAS_VALUE
	,IP_FLO_GP_DATA.MINVALUE
	,IP_FLO_GP_DATA.MAX_VAL
	,IP_FLO_GP_DATA.FLO_MEAS_ID
	,IP_FLO_GP_DATA.FLO_MEAS_NAME
	,IP_FLO_GP_DATA.VAL_TYPE_C
	,ZC_VAL_TYPE.NAME AS ZC_VAL_TYPE_NAME
	,IP_FLO_GP_DATA.UNITS
	,IP_FLO_GP_DATA.DISP_NAME

	,IP_DATA_STORE.EPT_CSN
	,IP_DATA_STORE.INPATIENT_DATA_ID
	,IP_FLWSHT_REC.FSD_ID
	,PAT_ENC_AMB.visit_PROV_ID
	,'PULL_MEASUREMENT--CLARITYANES--FLOWSHEET' AS ETL_Module

--INTO SH_OMOP_DB_PROD.OMOP_CLARITY.MEASUREMENT_CLARITYANES_FLOWSHEET

FROM SH_OMOP_DB_PROD.CDM.AOU_DRIVER

INNER JOIN OMOP_CLARITY.VISIT_OCCURRENCE_CLARITYAMB_ALL AS PAT_ENC_AMB
	ON AOU_DRIVER.EPIC_PAT_ID = PAT_ENC_AMB.PAT_ID

-- ASSOCIATES ANETHESIA RECORD TO HOSPITAL ENCOUNTER
  INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.F_AN_RECORD_SUMMARY ON PAT_ENC_AMB.PAT_ENC_CSN_ID = F_AN_RECORD_SUMMARY.AN_52_ENC_CSN_ID
  INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.AN_HSB_LINK_INFO ON F_AN_RECORD_SUMMARY.AN_EPISODE_ID=AN_HSB_LINK_INFO.SUMMARY_BLOCK_ID
  INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP ON AN_HSB_LINK_INFO.AN_BILLING_CSN_ID=PAT_ENC_HSP.PAT_ENC_CSN_ID
---------------------------------------------------

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_DATA_STORE
	ON PAT_ENC_AMB.PAT_ENC_CSN_ID = IP_DATA_STORE.EPT_CSN

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_FLWSHT_REC
	ON IP_DATA_STORE.INPATIENT_DATA_ID = IP_FLWSHT_REC.INPATIENT_DATA_ID

LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_FLWSHT_MEAS
	ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_FLO_GP_DATA
	ON IP_FLWSHT_MEAS.FLO_MEAS_ID = IP_FLO_GP_DATA.FLO_MEAS_ID

INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_VAL_TYPE
	ON IP_FLO_GP_DATA.VAL_TYPE_C = ZC_VAL_TYPE.VAL_TYPE_C
 
WHERE PAT_ENC_AMB.ENC_TYPE_C = 52 -- ANESTHESIA
