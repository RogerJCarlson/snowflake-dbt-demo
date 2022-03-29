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

Name: pull_measurement_FlowSheet_HSP_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with (and before)
		app_measurement_FlowSheet_HSP_BPM_2
		app_measurement_FlowSheet_HSP_BPD_2
		app_measurement_FlowSheet_HSP_BPS_2
		app_measurement_FlowSheet_HSP_vitals_2
		app_measurement_FlowSheet_HSP_temperature_2. 

	Its purpose is to query data from Epic Clarity and append this data to OMOP_Clarity.MEASUREMENT_ClarityHosp_FlowSheet
	which will be used later in the above "APP_" scripts.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	OMOP_Clarity.MEASUREMENT_ClarityHosp_FlowSheet may also be used in conjunction with other "APP_" scripts.

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

    
    
CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.MEASUREMENT_ClarityHosp_FlowSheet 
AS  

SELECT SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMBER(28,0) AS PERSON_ID
	,AoU_Driver.AoU_ID
	,IP_FLWSHT_MEAS.recorded_time
	,IP_FLWSHT_MEAS.MEAS_VALUE
	,IP_FLO_GP_DATA.MINVALUE
	,IP_FLO_GP_DATA.MAX_VAL
	,IP_FLO_GP_DATA.flo_meas_id
	,IP_FLO_GP_DATA.FLO_MEAS_NAME
	,IP_FLO_GP_DATA.VAL_TYPE_C
	,ZC_VAL_TYPE.NAME AS ZC_VAL_TYPE_NAME
	,IP_FLO_GP_DATA.UNITS
	,IP_FLO_GP_DATA.DISP_NAME
	,PAT_ENC_HSP.PAT_ID
	,PAT_ENC_HSP.PAT_ENC_CSN_ID
	,IP_DATA_STORE.EPT_CSN
	,IP_DATA_STORE.INPATIENT_DATA_ID
	,IP_FLWSHT_REC.FSD_ID
	,PAT_ENC_HSP.BILL_ATTEND_PROV_ID
	, HSP_ACCOUNT.ATTENDING_PROV_ID
	, HSP_ACCOUNT.REFERRING_PROV_ID
	, HSP_ACCOUNT.ADM_DATE_TIME
	, HSP_ACCOUNT.DISCH_DATE_TIME
	,ATTEND_FROM_DATE
	,ATTEND_TO_DATE
	,HSP_ATND_PROV.PROV_ID
	,COALESCE(ATTENDING_PROV_ID,HSP_ATND_PROV.PROV_ID) AS  CALC_ATTEND_PROV_ID
	,'PULL_MEASUREMENT--CLARITYHOSP--FLOWSHEET_ALL' AS ETL_Module

--INTO OMOP_Clarity.MEASUREMENT_ClarityHosp_FlowSheet

FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP

	INNER JOIN SH_OMOP_DB_PROD.CDM.AoU_Driver
		ON PAT_ENC_HSP.PAT_ID = SH_OMOP_DB_PROD.CDM.AoU_Driver.Epic_Pat_id

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_DATA_STORE
		ON PAT_ENC_HSP.PAT_ENC_CSN_ID = IP_DATA_STORE.EPT_CSN

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_FLWSHT_REC
		ON IP_DATA_STORE.INPATIENT_DATA_ID = IP_FLWSHT_REC.INPATIENT_DATA_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_FLWSHT_MEAS
		ON IP_FLWSHT_REC.FSD_ID = IP_FLWSHT_MEAS.FSD_ID

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.IP_FLO_GP_DATA
		ON IP_FLWSHT_MEAS.FLO_MEAS_ID = IP_FLO_GP_DATA.FLO_MEAS_ID

	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_VAL_TYPE
		ON IP_FLO_GP_DATA.VAL_TYPE_C = ZC_VAL_TYPE.VAL_TYPE_C

	--INNER JOIN SH_OMOP_DB_PROD.CDM.visit_occurrence
	--	ON PAT_ENC_HSP.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

	--LEFT JOIN SH_OMOP_DB_PROD.CDM.provider
	--	ON PAT_ENC_HSP.BILL_ATTEND_PROV_ID = provider.provider_source_value
		
	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HSP_ACCOUNT
		on PAT_ENC_HSP.HSP_ACCOUNT_ID = HSP_ACCOUNT.HSP_ACCOUNT_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.HSP_ATND_PROV
		ON PAT_ENC_HSP.PAT_ENC_CSN_ID = HSP_ATND_PROV.PAT_ENC_CSN_ID
			AND IP_FLWSHT_MEAS.recorded_time BETWEEN ATTEND_FROM_DATE
				AND COALESCE(ATTEND_TO_DATE, GETDATE())


	
	


