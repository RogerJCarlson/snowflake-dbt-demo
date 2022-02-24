--V_AOU_PII_ADDRESS

{{ config(materialized = 'view') }}

SELECT distinct person.person_id AS "person_id"
	,location_id AS "location_id"
FROM {{ref('PERSON')}} AS PERSON 
INNER JOIN {{ref('AOU_DRIVER')}} AS AOU_DRIVER
	ON person.person_id = SUBSTRING(AOU_DRIVER.AoU_ID, 2, LEN(AOU_DRIVER.AoU_ID))
