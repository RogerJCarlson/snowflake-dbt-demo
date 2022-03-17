--DRUG_EXPOSURE_CLARITYHOSP_RXNORM

{{ config(materialized = 'view') }}

SELECT DISTINCT SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID)) AS PERSON_ID
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
	,RXNORM_CODES.LINE AS RXNORM_CODES_LINE
	,MAR_ADMIN_INFO.ORDER_MED_ID
	,CLARITY_MEDICATION.medication_ID
	,CLARITY_MEDICATION.NAME AS CLARITY_MEDICATION_NAME
	,ORDER_MED.MED_ROUTE_C
	,ZC_ADMIN_ROUTE.NAME AS ZC_ADMIN_ROUTE_NAME
	,ORDER_STATUS_C
	,'PULL_DRUG_EXPOSURE--CLARITYHOSP--RXNORM' AS ETL_Module

FROM {{ref('AOU_DRIVER')}} AS AOU_DRIVER

INNER JOIN {{ source('CLARITY','PAT_ENC_HSP')}} AS PAT_ENC_HSP
	ON AOU_DRIVER.EPIC_PAT_ID = PAT_ENC_HSP.PAT_ID

INNER JOIN {{ source('CLARITY','ORDER_MED')}} AS ORDER_MED
	ON ORDER_MED.PAT_ENC_CSN_ID = PAT_ENC_HSP.PAT_ENC_CSN_ID

INNER JOIN {{ source('CLARITY','CLARITY_MEDICATION')}} AS CLARITY_MEDICATION
	ON ORDER_MED.MEDICATION_ID = CLARITY_MEDICATION.MEDICATION_ID

INNER JOIN {{ source('CLARITY','MAR_ADMIN_INFO')}} AS MAR_ADMIN_INFO
	ON ORDER_MED.ORDER_MED_ID = MAR_ADMIN_INFO.ORDER_MED_ID

INNER JOIN {{ source('CLARITY','ZC_MED_UNIT')}} AS ZC_MED_UNIT
	ON ORDER_MED.HV_DOSE_UNIT_C = ZC_MED_UNIT.DISP_QTYUNIT_C

LEFT JOIN {{ source('CLARITY','ZC_RSN_FOR_DISCON')}} AS ZC_RSN_FOR_DISCON
	ON ORDER_MED.RSN_FOR_DISCON_C = ZC_RSN_FOR_DISCON.RSN_FOR_DISCON_C

LEFT JOIN {{ source('CLARITY','ZC_ADMIN_ROUTE')}} AS ZC_ADMIN_ROUTE
	ON ORDER_MED.MED_ROUTE_C = ZC_ADMIN_ROUTE.MED_ROUTE_C

INNER JOIN {{ source('CLARITY','RXNORM_CODES')}} AS RXNORM_CODES
	ON ORDER_MED.MEDICATION_ID = RXNORM_CODES.MEDICATION_ID

INNER JOIN {{ source('CLARITY','ZC_RXNORM_TERM_TYPE')}} AS ZC_RXNORM_TERM_TYPE
	ON RXNORM_CODES.RXNORM_TERM_TYPE_C = ZC_RXNORM_TERM_TYPE.RXNORM_TERM_TYPE_C

WHERE START_DATE IS NOT NULL

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
		)
