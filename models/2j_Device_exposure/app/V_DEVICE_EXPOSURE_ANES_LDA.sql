--V_DEVICE_EXPOSURE_ANES_LDA

SELECT DISTINCT 
--	CDM.SEQ_DEVICE_EXPOSURE.NEXTVAL AS DEVICE_EXPOSURE_ID
	DEVICE_EXPOSURE_CLARITYANES_LDA.PERSON_ID
	,T_SOURCE_TO_CONCEPT_MAP_DEVICE_LDA.TARGET_CONCEPT_ID AS DEVICE_CONCEPT_ID
	,CAST( DEVICE_EXPOSURE_CLARITYANES_LDA.PLACEMENT_INSTANT AS DATE) AS DEVICE_EXPOSURE_START_DATE
	,DEVICE_EXPOSURE_CLARITYANES_LDA.PLACEMENT_INSTANT AS DEVICE_EXPOSURE_START_DATETIME
	,CAST(DEVICE_EXPOSURE_CLARITYANES_LDA.REMOVAL_INSTANT AS DATE) AS DEVICE_EXPOSURE_END_DATE
	,DEVICE_EXPOSURE_CLARITYANES_LDA.REMOVAL_INSTANT AS DEVICE_EXPOSURE_END_DATETIME
	,32817 AS DEVICE_TYPE_CONCEPT_ID --EHR DETAIL
	,NULL AS UNIQUE_DEVICE_ID
	,NULL AS QUANTITY
	,DEVICE_EXPOSURE_CLARITYANES_LDA.BILL_ATTEND_PROV_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,CAST( DEVICE_EXPOSURE_CLARITYANES_LDA.FLO_MEAS_ID AS VARCHAR) || ': ' || DEVICE_EXPOSURE_CLARITYANES_LDA.FLO_MEAS_NAME AS DEVICE_SOURCE_VALUE
	,0 AS DEVICE_SOURCE_CONCEPT_ID
	,'DEVICE_EXPOSURE--CLARITYANES--LDA' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM {{ref('DEVICE_EXPOSURE_CLARITYANES_LDA')}} AS DEVICE_EXPOSURE_CLARITYANES_LDA

--INNER JOIN T_SOURCE_TO_CONCEPT_MAP_DEVICE_LDA
--	ON DEVICE_EXPOSURE_CLARITYANES_LDA.FLO_MEAS_ID = T_SOURCE_TO_CONCEPT_MAP_DEVICE_LDA.SOURCE_CODE
	
    INNER JOIN {{ source('CDM','SOURCE_TO_CONCEPT_MAP')}} AS T_SOURCE_TO_CONCEPT_MAP_DEVICE_LDA
      ON DEVICE_EXPOSURE_CLARITYANES_LDA.FLO_MEAS_ID::VARCHAR = T_SOURCE_TO_CONCEPT_MAP_DEVICE_LDA.SOURCE_CODE
      AND UPPER(SOURCE_VOCABULARY_ID) = 'SH_DEVICE_LDA'

INNER JOIN {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
	ON DEVICE_EXPOSURE_CLARITYANES_LDA.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

LEFT JOIN {{ref('PROVIDER')}} AS PROVIDER
	ON DEVICE_EXPOSURE_CLARITYANES_LDA.BILL_ATTEND_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

WHERE PLACEMENT_INSTANT IS NOT NULL
ORDER BY PERSON_ID