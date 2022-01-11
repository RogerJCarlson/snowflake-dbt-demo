  {{ config(materialized='ephemeral') }}

SELECT *
FROM
(
	SELECT *	
	-- PCP PHYSICIAN POINTOFSERVICE	
	FROM {{ref('PCP_PHYSICIAN_POINTOFSERVICE')}}
	UNION
	SELECT *
	--Encounter physician PointOfService	
	FROM   {{ref('ENC_PHYSICIAN_POINTOFSERVICE')}}
) AS T_POS