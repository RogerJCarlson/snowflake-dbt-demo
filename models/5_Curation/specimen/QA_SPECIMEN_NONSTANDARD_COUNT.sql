----QA_SPECIMEN_NONSTANDARD_COUNT
-------------------------------------------------------------------

WITH NONSTANDARD_COUNT
AS (
	SELECT 'SPECIMEN_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('SPECIMEN')}} AS P
	LEFT JOIN {{ source('CDM','CONCEPT')}} AS C
		ON P.SPECIMEN_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'SPECIMEN' AND upper(C.VOCABULARY_ID) =  ('SNOMED')
	WHERE SPECIMEN_CONCEPT_ID <> 0 AND SPECIMEN_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'SPECIMEN_TYPE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('SPECIMEN')}} AS P
	LEFT JOIN {{ source('CDM','CONCEPT')}} AS C
		ON P.SPECIMEN_TYPE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'TYPE CONCEPT' AND upper(C.VOCABULARY_ID) =  ('TYPE CONCEPT')
	WHERE SPECIMEN_TYPE_CONCEPT_ID <> 0 AND SPECIMEN_TYPE_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('SPECIMEN')}} AS P
	LEFT JOIN {{ source('CDM','CONCEPT')}} AS C
		ON P.UNIT_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'UNIT'
	WHERE UNIT_CONCEPT_ID <> 0 AND UNIT_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'ANATOMIC_SITE_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('SPECIMEN')}} AS P
	LEFT JOIN {{ source('CDM','CONCEPT')}} AS C
		ON P.ANATOMIC_SITE_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'SPEC ANATOMIC SITE' AND upper(C.VOCABULARY_ID) =  ('SNOMED')
	WHERE ANATOMIC_SITE_CONCEPT_ID <> 0 AND ANATOMIC_SITE_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
--	UNION ALL
--	
--	SELECT 'UNIT_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
--	FROM {{ref('SPECIMEN')}} AS P
--	LEFT JOIN {{ source('CDM','CONCEPT')}} AS C
--		ON P.UNIT_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'UNIT'
--	WHERE UNIT_CONCEPT_ID <> 0 AND UNIT_CONCEPT_ID IS NOT NULL AND (STANDARD_CONCEPT <> 'S' OR STANDARD_CONCEPT IS NULL)
	
	UNION ALL
	
	SELECT 'DISEASE_STATUS_CONCEPT_ID' AS METRIC_FIELD, 'NON-STANDARD' AS QA_METRIC, 'INVALID DATA' AS ERROR_TYPE, COUNT(*) AS CNT
	FROM {{ref('SPECIMEN')}} AS P
	LEFT JOIN {{ source('CDM','CONCEPT')}} AS C
		ON P.DISEASE_STATUS_CONCEPT_ID = C.CONCEPT_ID AND upper(C.DOMAIN_ID) = 'MEASUREMENT' AND upper(C.VOCABULARY_ID) IN  ('LOINC', 'SNOMED')
	WHERE DISEASE_STATUS_CONCEPT_ID <> 0 AND C.CONCEPT_ID IS NULL
)



SELECT CAST(GETDATE() AS DATE) AS RUN_DATE
	,'SPECIMEN' AS STANDARD_DATA_TABLE
	, QA_METRIC AS QA_METRIC	
	, METRIC_FIELD  AS METRIC_FIELD
	, COALESCE (SUM(CNT),0) AS QA_ERRORS
	, CASE WHEN SUM(CNT) <> 0 THEN ERROR_TYPE ELSE NULL END   AS ERROR_TYPE
	, (SELECT COUNT(*) AS NUM_ROWS FROM {{ref('SPECIMEN')}}) AS TOTAL_RECORDS
FROM NONSTANDARD_COUNT	
GROUP BY   METRIC_FIELD, QA_METRIC, ERROR_TYPE

	
