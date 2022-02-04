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
Name: app_observation_Allergy_ALL_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 15-January-2021
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) pull_observation_Allergy_ALL_2.sql. 

	Its purpose is to join the data in OMOP_Clarity.OBSERVATION_ClarityALL_Allergy to the OMOP concept table
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
--WHERE ETL_Module = 'OBSERVATION--ClarityALL--Allergy';

INSERT INTO OMOP.OBSERVATION

(	    OBSERVATION_ID
		,person_id
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
)

WITH T_SOURCE
AS (
	SELECT concept_id
		,concept_code
		,concept_name
	FROM omop.concept AS C
	WHERE C.vocabulary_id IN ('SNOMED')
		AND (C.invalid_reason IS NULL
			OR C.invalid_reason = '')
		AND C.domain_id = 'Observation'
		and concept_name like 'Allergy to %'
)
,
	
T_CONCEPT
AS (
	SELECT c2.concept_id AS CONCEPT_ID
		,C1.concept_id AS SOURCE_CONCEPT_ID
	FROM omop.concept c1
	INNER JOIN omop.concept_relationship cr
		ON c1.concept_id = cr.concept_id_1
				AND cr.relationship_id = 'Maps to'
	INNER JOIN omop.concept c2
		ON c2.concept_id = cr.concept_id_2
	WHERE c2.standard_concept = 'S'
		AND (c2.invalid_reason IS NULL
			OR c2.invalid_reason = '')
		AND c2.domain_id = 'Observation'
)


SELECT DISTINCT OMOP.SEQ_OBSERVATION.NEXTVAL AS OBSERVATION_ID
	,OBSERVATION_ClarityALL_Allergy.person_id
	, CASE 
		WHEN ALLERGEN_NAME = 'PENICILLINS'
			THEN 4240903
		ELSE COALESCE(T_CONCEPT.concept_id, 0)
	  END AS observation_concept_id
	, cast( COALESCE(ALRGY_ENTERED_DTTM, DATE_NOTED, CONTACT_DATE) AS DATE) AS observation_date
	, cast( COALESCE(ALRGY_ENTERED_DTTM, DATE_NOTED, CONTACT_DATE) AS DATETIME) AS observation_datetime
	--, 38000280 AS observation_type_concept_id
	, 32817 AS observation_type_concept_id -- new type_id
	, NULL AS value_as_number
	, left(ALLERGEN_NAME,60) AS value_as_string
	, 0 AS value_as_concept_id
	, 0 AS qualifier_concept_id
	, 0 AS unit_concept_id
	, provider.provider_id AS provider_id
	, visit_occurrence.visit_occurrence_id AS visit_occurrence_id
	, left('ALLERGY:' || ALLERGEN_NAME,50) AS observation_source_value
	, 0 AS observation_source_concept_id
	, null as unit_source_value
	, NULL AS qualifier_source_value
	,'OBSERVATION--ClarityALL--Allergy' AS ETL_Module

FROM OMOP_Clarity.OBSERVATION_ClarityALL_Allergy 
	left JOIN T_SOURCE
		ON OBSERVATION_ClarityALL_Allergy.CONCEPT_NAME = T_SOURCE.CONCEPT_NAME
	left JOIN T_CONCEPT
		ON T_CONCEPT.SOURCE_CONCEPT_ID = T_SOURCE.concept_ID
	left  JOIN omop.visit_occurrence
		ON OBSERVATION_ClarityALL_Allergy.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value
	LEFT JOIN omop.provider
		ON OBSERVATION_ClarityALL_Allergy.PROV_ID = provider.provider_source_value

