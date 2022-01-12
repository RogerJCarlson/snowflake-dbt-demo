--SPECIMEN_CLARITY_ALL

SELECT DISTINCT 
    SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))   AS PERSON_ID
    , SPEC_DB_MAIN.SPEC_DTM_COLLECTED
    , SPEC_DB_MAIN.SPEC_DTM_RECEIVED
    , HSC_SPEC_INFO.SPECIMEN_SIZE    -- MISSING FROM HSC_SPEC_INFO
    , HSC_SPEC_INFO.SPECIMEN_TYPE_C 
    , SPEC_DB_MAIN.SPEC_SOURCE_C
    , ZC_SPECIMEN_TYPE.NAME  AS ZC_SPECIMEN_TYPE_NAME 
    , ZC_SPEC_SOURCE.NAME    AS  ZC_SPEC_SOURCE_NAME 

FROM  {{ref('PERSON')}} AS PERSON

	INNER JOIN   {{ source('CDM','AOU_DRIVER')}} AS AOU_DRIVER 
		ON PERSON.PERSON_ID = SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))
		
	INNER JOIN   {{ source('CLARITY','SPEC_DB_MAIN')}} AS SPEC_DB_MAIN
		ON SPEC_DB_MAIN.SPEC_EPT_PAT_ID = AOU_DRIVER.EPIC_PAT_ID
		
	INNER JOIN  {{ source('CLARITY','ZC_SPEC_SOURCE')}} AS ZC_SPEC_SOURCE
		ON SPEC_DB_MAIN.SPEC_SOURCE_C = ZC_SPEC_SOURCE.SPEC_SOURCE_C

	INNER JOIN   {{ source('CLARITY','HSC_SPEC_INFO')}} AS HSC_SPEC_INFO
		ON SPEC_DB_MAIN.SPECIMEN_COL_ID = HSC_SPEC_INFO.RECORD_ID
		
	LEFT JOIN   {{ source('CLARITY','ZC_SPECIMEN_TYPE')}} AS ZC_SPECIMEN_TYPE
		ON HSC_SPEC_INFO.SPECIMEN_TYPE_C = ZC_SPECIMEN_TYPE.SPECIMEN_TYPE_C
		
	LEFT JOIN   {{ source('CLARITY','ZC_SPECIMEN_UNIT')}} AS ZC_SPECIMEN_UNIT
		ON HSC_SPEC_INFO.SPECIMEN_UNIT_C = ZC_SPECIMEN_UNIT.SPECIMEN_UNIT_C

WHERE COALESCE(SPEC_DB_MAIN.SPEC_DTM_COLLECTED, SPEC_DB_MAIN.SPEC_DTM_RECEIVED) IS NOT NULL