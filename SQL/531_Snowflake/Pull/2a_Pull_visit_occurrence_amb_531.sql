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

Name: Pull_amb_visit_occurrence_3

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
	
Description: This script is the 1st it a two-part process.  It is used in conjunction with 
	(and before) app_visit_occurrence_amb_f2f_3. 

	Its purpose is to query data from Epic Clarity and append this data to VISIT_OCCURRENCE_ClarityAMB_ALL
	which will be used later in app_visit_occurrence_amb_f2f_3.  The table may have numerous
	extraneous fields which can be used for verifying the base data returned from Clarity. 

	VISIT_OCCURRENCE_ClarityAMB_ALL may also be used in conjunction with other "APP_" scripts.

Structure: (if your structure is different, you will have to modify the code to match)
    Databases:SH_OMOP_DB_PROD, SH_CLINICAL_DB_PROD
    Schemas: SH_OMOP_DB_PROD.OMOP_CLARITY, SH_OMOP_DB_PROD.CDM, SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/
--USE ROLE SF_SH_OMOP_DEVELOPER;
--
--USE SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ;
----USE SCHEMA SH_OMOP_DB_PROD.OMOP_CLARITY;
----USE SCHEMA SH_OMOP_DB_PROD.CDM;
--
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.VISIT_OCCURRENCE_ClarityAMB_ALL
AS  
SELECT DISTINCT SUBSTRING(CDM.AoU_Driver.AoU_ID, 2, LEN(CDM.AoU_Driver.AoU_ID)) AS person_id
	,AoU_ID
	,PAT_ENC.PAT_ID
	,PAT_ENC.PAT_ENC_CSN_ID
 
	,PAT_ENC.ENC_TYPE_C
	,ZC_DISP_ENC_TYPE.NAME AS ZC_DISP_ENC_TYPE_NAME

	,PAT_ENC.CHECKIN_TIME
	,PAT_ENC.APPT_TIME
	,PAT_ENC.ENC_INSTANT
	,PAT_ENC.CONTACT_DATE

	,PAT_ENC.CHECKOUT_TIME
	,PAT_ENC.ENC_CLOSE_TIME

	,PAT_ENC.ACCOUNT_ID
	,PAT_ENC.HSP_ACCOUNT_ID
	,PAT_ENC.INPATIENT_DATA_ID
	,PAT_ENC_2.IP_DOC_CONTACT_CSN
	,pat_or_adm_link.PAT_ENC_CSN_ID as pat_or_adm_link_csn

	,PAT_ENC.VISIT_PROV_ID
	,Visit_Provider.PROV_NAME AS Visit_Provider_NAME
	,Visit_Provider.PROV_TYPE AS Visit_Provider_Type

	,PAT_ENC.PCP_PROV_ID
	,PCP_Provider.PROV_NAME AS PCP_Provider_NAME
	,PCP_Provider.PROV_TYPE AS PCP_Provider_Type

	,PAT_ENC.PRIMARY_LOC_ID
	,CLARITY_LOC.LOC_NAME

	,PAT_ENC.CALCULATED_ENC_STAT_C
	,ZC_CALCULATED_ENC_STAT.NAME AS CALCULATED_ENC_STAT_NAME
	,PAT_ENC.APPT_STATUS_C
	,ZC_APPT_STATUS.NAME AS APPT_STATUS_NAME


--INTO SH_OMOP_DB_PROD.OMOP_CLARITY.VISIT_OCCURRENCE_ClarityAMB_ALL
FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP --hosp

		right join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_2 --hod_2
						on PAT_ENC_HSP.PAT_ENC_CSN_ID = PAT_ENC_2.IP_DOC_CONTACT_CSN

		inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC --hod
						on PAT_ENC_2.PAT_ENC_CSN_ID = PAT_ENC.PAT_ENC_CSN_ID
		LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.pat_or_adm_link
		ON PAT_ENC.PAT_ENC_CSN_ID = pat_or_adm_link.PAT_ENC_CSN_ID

	INNER JOIN SH_OMOP_DB_PROD.CDM.AoU_Driver
		ON SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC.PAT_ID = CDM.AoU_Driver.Epic_Pat_id

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_LOC
		ON PAT_ENC.PRIMARY_LOC_ID = CLARITY_LOC.LOC_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER AS Visit_Provider
		ON PAT_ENC.VISIT_PROV_ID = Visit_Provider.PROV_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER AS PCP_Provider
		ON PAT_ENC.PCP_PROV_ID = PCP_Provider.PROV_ID

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_DISP_ENC_TYPE
		ON PAT_ENC.ENC_TYPE_C = ZC_DISP_ENC_TYPE.DISP_ENC_TYPE_C

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_CALCULATED_ENC_STAT
		ON PAT_ENC.CALCULATED_ENC_STAT_C = ZC_CALCULATED_ENC_STAT.CALCULATED_ENC_STAT_C

	LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_APPT_STATUS
		ON PAT_ENC.APPT_STATUS_C = ZC_APPT_STATUS.APPT_STATUS_C

WHERE enc_type_c <> 3

	--AND (
	--	PAT_ENC.CALCULATED_ENC_STAT_C = 2
	--	OR PAT_ENC.CALCULATED_ENC_STAT_C IS NULL
	--	)
	--AND (
	--	PAT_ENC.APPT_STATUS_C = 2
	--	OR PAT_ENC.APPT_STATUS_C IS NULL
	--	)



