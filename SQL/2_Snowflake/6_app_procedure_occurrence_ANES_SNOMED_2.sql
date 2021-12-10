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
Name: app_procedure_occurrence_ANES_SNOMED_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) Pull_procedure_occurrence_ANES_SNOMED_2.sql. 

	Its purpose is to join the data in OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityANES_SNOMED to the OMOP concept table
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

--CREATE OR REPLACE SEQUENCE OMOP.SEQ_PROCEDURE_OCCURRENCE START = 1 INCREMENT = 1;

--DELETE FROM OMOP.PROCEDURE_OCCURRENCE
--WHERE ETL_MODULE = 'PROCEDURE_OCCURRENCE--ClarityANES--SNOMED';

INSERT INTO OMOP.procedure_occurrence (
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

SELECT DISTINCT 
--	OMOP.SEQ_PROCEDURE_OCCURRENCE.NEXTVAL AS PROCEDURE_OCCURRENCE_ID
	PAT_ENC_ANES.person_id
	,source_to_concept_map_anes_proc.target_concept_id AS procedure_concept_id
	,CAST ( AN_START_DATETIME AS DATE) AS procedure_date
	,AN_START_DATETIME AS procedure_datetime

	,32817 AS procedure_type_concept_id

	,COALESCE(source_to_concept_map_modifier.target_concept_id, 0) AS modifier_concept_id
	,PAT_ENC_ANES.QUANTITY AS quantity
	,provider.provider_id AS provider_id
	,visit_occurrence.visit_occurrence_id AS visit_occurrence_id
	,PAT_ENC_ANES.PROC_CODE || ':' || LEFT(PAT_ENC_ANES.PROC_NAME, 49 - LEN(PAT_ENC_ANES.PROC_CODE)) AS procedure_source_value
	,0 AS procedure_source_concept_id
	,PAT_ENC_ANES.MODIFIER1_ID || ':' || MODIFIER_NAME AS MODIFIER_SOURCE_VALUE
	,'PROCEDURE_OCCURRENCE--ClarityANES--SNOMED' AS ETL_Module
	,visit_source_value



FROM OMOP_Clarity.PROCEDURE_OCCURRENCE_ClarityANES_SNOMED AS PAT_ENC_ANES

	left JOIN OMOP.visit_occurrence
		ON PAT_ENC_ANES.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

	LEFT JOIN OMOP.provider
		ON PAT_ENC_ANES.AN_RESP_PROV_ID = provider.provider_source_value

INNER JOIN OMOP.source_to_concept_map AS source_to_concept_map_anes_proc
		ON PAT_ENC_ANES.PROC_ID = source_to_concept_map_anes_proc.source_code
			AND source_to_concept_map_anes_proc.source_vocabulary_id = 'sh_anesthesia'

	LEFT JOIN OMOP.source_to_concept_map AS source_to_concept_map_modifier
		ON PAT_ENC_ANES.MODIFIER1_ID = source_to_concept_map_modifier.source_code
			AND source_to_concept_map_modifier.source_vocabulary_id = 'SH_modifier'

			where AN_START_DATETIME is not null