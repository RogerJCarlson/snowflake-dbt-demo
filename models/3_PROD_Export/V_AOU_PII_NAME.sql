--V_AOU_PII_NAME

{{ config(materialized = 'view') }}

SELECT distinct person.person_id AS "person_id"
	,first_name AS "first_name"
	,NULL AS "middle_name"
	,last_name AS "last_name"
	,NULL AS "suffix"
	,NULL AS "prefix"
FROM {{ref('PERSON')}} AS PERSON
INNER JOIN {{ref('AOU_DRIVER')}} AS AOU_DRIVER
	ON person.person_id = SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMERIC
