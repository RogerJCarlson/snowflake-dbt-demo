-- NOTE_CLARITYANES_ALL

SELECT  SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMBER(28,0) AS PERSON_ID
	,AOU_DRIVER.AoU_ID
	,PAT_ENC_AMB.PAT_ID
	-----hospital encounter---------
	,PAT_ENC_HSP.PAT_ENC_CSN_ID
	--------------------------------
	,PAT_ENC_AMB.HSP_ACCOUNT_ID
	,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
	,PAT_ENC_AMB.ENC_TYPE_C
	,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
	,PAT_ENC_AMB.pat_or_adm_link_csn as pat_or_adm_link_PAT_ENC_CSN_ID
	,NOTE_ENC_INFO.ENTRY_INSTANT_DTTM
	,ZC_NOTE_TYPE_IP.NAME AS ZC_NOTE_TYPE_IP_NAME
	,HNO_INFO.IP_NOTE_TYPE_C
	,HNO_INFO.AMB_NOTE_YN
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
	,'PULL_NOTE--CLARITYANES--ALL' AS ETL_Module

--INTO OMOP_Clarity.NOTE_ClarityANES_ALL

FROM {{ref('AOU_DRIVER')}} AS AOU_DRIVER

INNER JOIN OMOP_Clarity.VISIT_OCCURRENCE_ClarityAMB_ALL AS PAT_ENC_AMB
	ON AOU_DRIVER.EPIC_PAT_ID = PAT_ENC_AMB.PAT_ID

-- associates anethesia EVENT to hospital encounter
  INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.F_AN_RECORD_SUMMARY on PAT_ENC_AMB.PAT_ENC_CSN_ID = F_AN_RECORD_SUMMARY.AN_53_ENC_CSN_ID
  inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.AN_HSB_LINK_INFO on F_AN_RECORD_SUMMARY.AN_EPISODE_ID=AN_HSB_LINK_INFO.SUMMARY_BLOCK_ID
  inner join SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC_HSP on AN_HSB_LINK_INFO.AN_BILLING_CSN_ID=PAT_ENC_HSP.PAT_ENC_CSN_ID

  
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

