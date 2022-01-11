  {{ config(materialized='ephemeral') }}

SELECT PAT_ID
	, MAX(LINE) AS MAXOFLINE
FROM   {{ source('CLARITY','PATIENT_RACE')}} AS PATIENT_RACE
GROUP BY PAT_ID 
