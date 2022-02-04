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
Name: app_observation_ICD_HSP_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) pull_observation_ICD_HSP_2.sql. 

	Its purpose is to join the data in OMOP_Clarity.OBSERVATION_ClarityHosp_ICD to the OMOP concept table
	to return standard concept ids, and append this data to OMOP.observation.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:EpicCare
	Schemas: EpicCare.OMOP, EpicCare.OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--CREATE OR REPLACE SEQUENCE OMOP.SEQ_OBSERVATION START = 1 INCREMENT = 1;

--DELETE FROM OMOP.OBSERVATION
--WHERE ETL_Module = 'OBSERVATION--ClarityHosp--ICD';


INSERT INTO OMOP.OBSERVATION
(	--OBSERVATION_id, ----IDENTITY
	person_id
      ,OBSERVATION_concept_id
      ,OBSERVATION_date
      ,OBSERVATION_datetime
      ,OBSERVATION_type_concept_id
      ,value_as_number
      ,value_as_string
      ,value_as_concept_id
	  ,qualifier_concept_id
      ,unit_concept_id
      ,provider_id
      ,visit_occurrence_id
      ,OBSERVATION_source_value
      ,OBSERVATION_source_concept_id
      ,unit_source_value
      ,qualifier_source_value
	  ,ETL_module
	,visit_source_value
)

WITH T_ICD_SOURCE
AS (
	SELECT concept_id
		,concept_code
		,concept_name
	
	FROM omop.concept AS C
	
	WHERE C.vocabulary_id IN (
			'ICD9CM'
			,'ICD10CM'
			)
		AND (
			C.invalid_reason IS NULL
			OR C.invalid_reason = ''
			)
		AND C.domain_id = 'Observation'
	)
	,T_CONCEPT
AS (
	SELECT c2.concept_id AS CONCEPT_ID
		,C1.concept_id AS SOURCE_CONCEPT_ID
	
	FROM omop.concept c1
	
		INNER JOIN omop.concept_relationship cr
			ON c1.concept_id = cr.concept_id_1
				--AND cr.relationship_id = 'Maps to'
				AND cr.relationship_id = 'Maps to value'
		
		INNER JOIN omop.concept c2
			ON c2.concept_id = cr.concept_id_2
	
	WHERE c2.standard_concept = 'S'
		AND (
			c2.invalid_reason IS NULL
			OR c2.invalid_reason = ''
			)
		AND c2.domain_id = 'Observation'
	)

SELECT DISTINCT
	
--	OMOP.SEQ_OBSERVATION.NEXTVAL AS OBSERVATION_ID
	OBSERVATION_ClarityHosp_ICD.person_id
	--,t_icd10_concept.CONCEPT_ID AS OBSERVATION_concept_id

	,CASE 
		WHEN OBSERVATION_ClarityHosp_ICD.CONTACT_DATE >= '2015-10-01'
			THEN t_icd10_concept.CONCEPT_ID
		ELSE t_icd9_concept.CONCEPT_ID
		END AS OBSERVATION_concept_id

	,cast( OBSERVATION_ClarityHosp_ICD.CONTACT_DATE AS DATE) AS OBSERVATION_date
	,OBSERVATION_ClarityHosp_ICD.CONTACT_DATE AS OBSERVATION_datetime
	,32817 AS OBSERVATION_type_concept_id --EHR
	,NULL AS value_as_number
	-- returns ICD10 codes after switch date-----
	,CASE 
		WHEN OBSERVATION_ClarityHosp_ICD.CONTACT_DATE >= '2015-10-01'
			THEN t_icd10_source.concept_code
		ELSE t_icd9_source.concept_code
		END AS value_as_string
	,CASE 
		WHEN OBSERVATION_ClarityHosp_ICD.CONTACT_DATE >= '2015-10-01'
			THEN t_icd10_concept.CONCEPT_ID
		ELSE t_icd9_concept.CONCEPT_ID
		END AS value_as_concept_id
	--------------------------------------------
	,0 AS unit_concept_id
	,0 AS qualifier_concept_id
	,provider.provider_id AS provider_id
	,visit_occurrence.visit_occurrence_id AS visit_occurrence_id
	-- returns ICD10 codes after switch date-----
	,CASE 
		WHEN OBSERVATION_ClarityHosp_ICD.CONTACT_DATE >= '2015-10-01'
			THEN left(t_icd10_source.concept_code || ':' || t_icd10_source.concept_NAME, 50)
		ELSE left(t_icd9_source.concept_code || ':' || t_icd9_source.concept_NAME, 50)
		END AS OBSERVATION_source_value
	,CASE 
		WHEN OBSERVATION_ClarityHosp_ICD.CONTACT_DATE >= '2015-10-01'
			THEN t_icd10_source.CONCEPT_ID
		ELSE t_icd9_source.CONCEPT_ID
		END AS OBSERVATION_source_concept_id
	--------------------------------------------
	,NULL AS unit_source_value
	,NULL AS qualifier_source_value
	,'OBSERVATION--ClarityHosp--ICD' AS ETL_Module
,visit_source_value

FROM OMOP_Clarity.OBSERVATION_ClarityHosp_ICD

	INNER JOIN omop.visit_occurrence
		ON OBSERVATION_ClarityHosp_ICD.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

	--------Concept Mapping--------------------

	LEFT JOIN T_ICD_SOURCE AS t_icd9_source
		ON OBSERVATION_ClarityHosp_ICD.icd9_code = t_icd9_source.concept_code

	LEFT JOIN T_ICD_SOURCE AS t_icd10_source
		ON OBSERVATION_ClarityHosp_ICD.icd10_code = t_icd10_source.concept_code


	LEFT JOIN T_CONCEPT AS t_icd9_concept
		ON t_icd9_concept.SOURCE_CONCEPT_ID = t_icd9_source.concept_ID

	LEFT JOIN T_CONCEPT AS t_icd10_concept
		ON t_icd10_concept.SOURCE_CONCEPT_ID = t_icd10_source.concept_ID

	--------Concept Mapping end --------------------
	LEFT JOIN omop.provider
		ON OBSERVATION_ClarityHosp_ICD.BILL_ATTEND_PROV_ID = provider.provider_source_value


-------------------------------------------
WHERE 	
	(OBSERVATION_ClarityHosp_ICD.CONTACT_DATE >= '2015-10-01' and t_icd10_concept.CONCEPT_ID IS NOT NULL)   
	or 
	(OBSERVATION_ClarityHosp_ICD.CONTACT_DATE < '2015-10-01' and t_icd9_concept.CONCEPT_ID IS NOT NULL   )