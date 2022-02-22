--   V_AOU_FACT_RELATIONSHIP

{{ config(materialized = 'view') }}

SELECT domain_concept_id_1 AS "domain_concept_id_1"
	, fact_id_1 AS "fact_id_1"
	, domain_concept_id_2 AS "domain_concept_id_2"
	, fact_id_2 AS "fact_id_2"
	, relationship_concept_id AS "relationship_concept_id"
FROM    {{ref('FACT_RELATIONSHIP')}} AS FACT_RELATIONSHIP