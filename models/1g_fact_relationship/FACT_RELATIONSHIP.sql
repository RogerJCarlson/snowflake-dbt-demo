--FACT_RELATIONSHIP 
-- this is just a place holder model
-- we currently do not do fact relationships, but this table is necessary for export

{{ config(materialized = 'table') }} 

SELECT DOMAIN_CONCEPT_ID_1, FACT_ID_1, DOMAIN_CONCEPT_ID_2, FACT_ID_2, RELATIONSHIP_CONCEPT_ID
FROM OMOP.FACT_RELATIONSHIP