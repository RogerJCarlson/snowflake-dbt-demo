
--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--CREATE OR REPLACE SEQUENCE OMOP.SEQ_PROCEDURE_OCCURRENCE START = 1 INCREMENT = 1;

--DELETE FROM OMOP.PROCEDURE_OCCURRENCE
--WHERE ETL_MODULE = 'PROCEDURE_OCCURRENCE--ClarityAMB--CPT';

INSERT INTO OMOP.procedure_occurrence (
--	PROCEDURE_OCCURRENCE_ID
	person_id
	,procedure_concept_id
	,procedure_date
	,procedure_datetime
	,procedure_type_concept_id
	,modifier_concept_id
	,quantity
	,provider_id
	,visit_occurrence_id
	,procedure_source_value
	,procedure_source_concept_id
	,MODIFIER_SOURCE_VALUE
	,ETL_Module
,visit_source_value
	)

WITH	T_SOURCE
AS (
	SELECT concept_id
		,concept_code
		,domain_id
		,vocabulary_id
	
	FROM omop.concept AS C
	
	WHERE C.vocabulary_id IN ('CPT4')

		AND C.domain_id = 'Procedure'
	)
	,T_CONCEPT
AS (
	SELECT c2.concept_id AS concept_id
		,C1.concept_id AS SOURCE_CONCEPT_ID
	
	FROM omop.concept c1
	
	INNER JOIN omop.concept_relationship cr
		ON c1.concept_id = cr.concept_id_1
			AND cr.relationship_id = 'Maps to'
	
	INNER JOIN omop.concept c2
		ON c2.concept_id = cr.concept_id_2
	
	WHERE c2.standard_concept = 'S'

		AND c2.domain_id = 'Procedure'
	)

SELECT DISTINCT 
--	OMOP.SEQ_PROCEDURE_OCCURRENCE.NEXTVAL AS PROCEDURE_OCCURRENCE_ID
	PROCEDURE_OCCURRENCE_ClarityAMB_CPT.person_id
	,T_CONCEPT.concept_id AS procedure_concept_id
	,cast( coalesce(PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_child_INSTANTIATED_TIME
				, PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_INSTANTIATED_TIME
				, PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_PROC_START_TIME
				, PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_ORDER_TIME) AS DATE) AS procedure_date
	,coalesce(PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_child_INSTANTIATED_TIME
				, PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_INSTANTIATED_TIME
				, PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_PROC_START_TIME
				, PROCEDURE_OCCURRENCE_ClarityAMB_CPT.OP_ORDER_TIME) AS procedure_datetime

	,32817 AS procedure_type_concept_id
	,coalesce(source_to_concept_map_modifier.target_concept_id, 0) AS modifier_concept_id
	,PROCEDURE_OCCURRENCE_ClarityAMB_CPT.QUANTITY AS quantity
	,provider.provider_id AS provider_id
	,visit_occurrence.visit_occurrence_id AS visit_occurrence_id
	,PROCEDURE_OCCURRENCE_ClarityAMB_CPT.PROC_CODE || ':' 
		|| LEFT(PROCEDURE_OCCURRENCE_ClarityAMB_CPT.PROC_NAME, 49 
		- LEN(PROCEDURE_OCCURRENCE_ClarityAMB_CPT.PROC_CODE)) 
		AS procedure_source_value
	,T_SOURCE.concept_id AS procedure_source_concept_id
	,PROCEDURE_OCCURRENCE_ClarityAMB_CPT.MODIFIER1_ID || ':' || MODIFIER_NAME AS MODIFIER_SOURCE_VALUE
	,'PROCEDURE_OCCURRENCE--ClarityAMB--CPT' AS ETL_Module
	,visit_source_value



FROM OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityAMB_CPT

	INNER JOIN T_SOURCE
		ON PROCEDURE_OCCURRENCE_ClarityAMB_CPT.PROC_CODE = T_SOURCE.concept_code

	INNER JOIN T_CONCEPT
		ON T_SOURCE.CONCEPT_ID = T_CONCEPT.concept_id

	INNER JOIN OMOP.visit_occurrence
		ON PROCEDURE_OCCURRENCE_ClarityAMB_CPT.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

	LEFT JOIN OMOP.provider
		ON PROCEDURE_OCCURRENCE_ClarityAMB_CPT.AUTHRZING_PROV_ID = provider.provider_source_value

	LEFT JOIN OMOP.source_to_concept_map AS source_to_concept_map_modifier
		ON PROCEDURE_OCCURRENCE_ClarityAMB_CPT.MODIFIER1_ID = source_to_concept_map_modifier.source_code
			AND source_to_concept_map_modifier.source_vocabulary_id = 'SH_modifier'

