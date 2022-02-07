--AOU_DRIVER
-- This JOINS AOU_DRIVER_PROD to AOU_PII_VALIDATION to limit AOU_DRIVER to only those participants who have been validated

{{ config(materialized = 'table') }}

SELECT CPI
	, EPIC_PAT_ID
	, AOU_ID
	, FLAG
	, NULL AS DATE_1
	, NULL AS DATE_2
	, AOU_DRIVER_PROD.FIRST_NAME
	, AOU_DRIVER_PROD.LAST_NAME
	, DATE_OF_BIRTH
	, AOU_DRIVER_PROD.SEX
	, PHONE
	, STREET_ADDRESS
	, CITY
	, STATE
	, ZIP
	, AOU_DRIVER_PROD.EMAIL
	, "MANUAL VALIDATION" AS MANUAL_VALIDATION
	, ALGORITHM_VALIDATION

FROM {{ref('AOU_DRIVER_PROD') }} AS AOU_DRIVER_PROD

INNER JOIN {{ref('AOU_PII_VALIDATION') }} AS AOU_PII_VALIDATION
	ON UPPER(AOU_ID) = 'P' || PID

WHERE EPIC_PAT_ID IS NOT NULL
	AND (	UPPER(ALGORITHM_VALIDATION) = 'YES'
			OR UPPER(MANUAL_VALIDATION) = 'YES'
        )
