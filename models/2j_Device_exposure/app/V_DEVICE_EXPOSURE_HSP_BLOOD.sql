--V_DEVICE_EXPOSURE_HSP_BLOOD

SELECT DISTINCT 
--CDM.SEQ_DEVICE_EXPOSURE.NEXTVAL AS DEVICE_EXPOSURE_ID
	DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PERSON_ID
	,T_SOURCE_TO_CONCEPT_MAP_DEVICE_BLOOD.TARGET_CONCEPT_ID AS DEVICE_CONCEPT_ID
	,CAST( DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PROC_START_TIME AS DATE) AS DEVICE_EXPOSURE_START_DATE
	,DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PROC_START_TIME AS DEVICE_EXPOSURE_START_DATETIME
	,CAST( COALESCE(PROC_ENDING_TIME, PROC_START_TIME) AS DATE) AS DEVICE_EXPOSURE_END_DATE
	,COALESCE(PROC_ENDING_TIME, PROC_START_TIME) AS DEVICE_EXPOSURE_END_DATETIME
	,32817 AS DEVICE_TYPE_CONCEPT_ID --INFERRED FROM PROCEDURE CLAIM
	,DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.BLOOD_ADMIN_UNIT AS UNIQUE_DEVICE_ID
	,DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.QUANTITY AS QUANTITY
	,PROVIDER.PROVIDER_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,CAST( DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PROC_ID AS VARCHAR) || ' : ' || DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PROC_CODE || ' : ' || DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PROC_NAME AS DEVICE_SOURCE_VALUE
	,0 AS DEVICE_SOURCE_CONCEPT_ID
	,'DEVICE_EXPOSURE--CLARITYHOSP--BLOOD' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM {{ref('DEVICE_EXPOSURE_CLARITYHOSP_BLOOD')}} AS DEVICE_EXPOSURE_CLARITYHOSP_BLOOD

INNER JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS T_SOURCE_TO_CONCEPT_MAP_DEVICE_BLOOD
  ON DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PROC_ID::varchar = T_SOURCE_TO_CONCEPT_MAP_DEVICE_BLOOD.SOURCE_CODE
  AND UPPER(SOURCE_VOCABULARY_ID) = 'SH_DEVICE_BLOOD'

INNER JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
	ON DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

INNER JOIN {{ref('PROVIDER')}} AS PROVIDER
	ON DEVICE_EXPOSURE_CLARITYHOSP_BLOOD.AUTHRZING_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE