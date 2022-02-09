/*******************************************************************************
# Copyright 2020 Spectrum Health 
# http://www.spectrumhealth.org
#
# Unless required by applicable law or agreed to in writing, this software
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
# either express or implied.
#
********************************************************************************/

/*******************************************************************************
Name: app_procedure_occurrence_CPT_HSP_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) Pull_procedure_occurrence_CPT_HSP_2.sql. 

	Its purpose is to join the data in OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityHSP_CPT to the OMOP concept table
	to return standard concept ids, and append this data to OMOP.procedure_occurrence.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:
	Schemas: OMOP, OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;
--
--CREATE OR REPLACE SEQUENCE OMOP.SEQ_PROCEDURE_OCCURRENCE START = 1 INCREMENT = 1;

--DELETE FROM OMOP.PROCEDURE_OCCURRENCE
--WHERE ETL_MODULE = 'PROCEDURE_OCCURRENCE--ClarityHosp--CPT';


INSERT INTO OMOP.procedure_occurrence	(	
--		PROCEDURE_OCCURRENCE_ID
		 person_id
		, procedure_concept_id
		, procedure_date
		, procedure_datetime
		, procedure_type_concept_id
		, modifier_concept_id
		, quantity
		, provider_id
		, visit_occurrence_id
		, procedure_source_value
		, procedure_source_concept_id
		, MODIFIER_SOURCE_VALUE
		, ETL_Module
		,visit_source_value
)


WITH T_SOURCE
AS (
	SELECT concept_id
		,concept_code
		,domain_id
		,vocabulary_id
	
	FROM omop.concept AS C
	
	WHERE C.vocabulary_id IN ('CPT4')--,'hcpcs','snomed')
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
	PAT_ENC_HSP.person_id
	,T_CONCEPT.concept_id AS procedure_concept_id
	,cast( PAT_ENC_HSP.OP_PROC_START_TIME AS DATE) AS procedure_date
	,PAT_ENC_HSP.OP_PROC_START_TIME AS procedure_datetime

	,32817 AS procedure_type_concept_id

	,COALESCE(source_to_concept_map_modifier.target_concept_id, 0) AS modifier_concept_id
	,PAT_ENC_HSP.QUANTITY AS quantity
	,provider.provider_id AS provider_id
	,visit_occurrence.visit_occurrence_id AS visit_occurrence_id
	,PAT_ENC_HSP.PROC_CODE || ':' || LEFT(PAT_ENC_HSP.PROC_NAME, 49 - LEN(PAT_ENC_HSP.PROC_CODE)) AS procedure_source_value
	,T_SOURCE.concept_id AS procedure_source_concept_id
	,PAT_ENC_HSP.MODIFIER1_ID || ':' || MODIFIER_NAME AS MODIFIER_SOURCE_VALUE
	,'PROCEDURE_OCCURRENCE--ClarityHosp--CPT' AS ETL_Module
	,visit_source_value

FROM OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityHSP_CPT as PAT_ENC_HSP

INNER JOIN T_SOURCE
	ON PAT_ENC_HSP.PROC_CODE = T_SOURCE.concept_code

INNER JOIN T_CONCEPT
	ON T_SOURCE.CONCEPT_ID = T_CONCEPT.concept_id

-------------------------------------------
INNER JOIN omop.visit_occurrence
	ON PAT_ENC_HSP.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

LEFT JOIN omop.provider
	ON PAT_ENC_HSP.AUTHRZING_PROV_ID = provider.provider_source_value

LEFT JOIN OMOP.source_to_concept_map AS source_to_concept_map_modifier
	ON PAT_ENC_HSP.MODIFIER1_ID = source_to_concept_map_modifier.source_code
		AND source_to_concept_map_modifier.source_vocabulary_id = 'SH_modifier'

WHERE PAT_ENC_HSP.OP_PROC_START_TIME IS NOT NULL