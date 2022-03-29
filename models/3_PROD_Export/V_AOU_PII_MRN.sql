--V_AOU_PII_MRN

{{ config(materialized = 'view') }}

SELECT distinct person.person_id AS "person_id"
	,'trans_am_spectrum' AS "health_system"
	,CPI AS "MRN"
FROM {{ref('PERSON')}} AS PERSON
INNER JOIN {{ref('AOU_DRIVER')}} AS AOU_DRIVER
	ON person.person_id = SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMERIC
