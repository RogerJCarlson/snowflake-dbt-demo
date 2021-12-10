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
	to return standard concept ids, and append this data to CDM.procedure_occurrence.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:
	Schemas: OMOP, OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--CREATE OR REPLACE SEQUENCE CDM.SEQ_PROCEDURE_OCCURRENCE START = 1 INCREMENT = 1;

--DELETE FROM CDM.PROCEDURE_OCCURRENCE
--WHERE ETL_MODULE = 'PROCEDURE_OCCURRENCE_CLARITYANES_SNOMED_ALLSYSTEM';

INSERT INTO CDM.PROCEDURE_OCCURRENCE (
	PERSON_ID
	,PROCEDURE_CONCEPT_ID
	,PROCEDURE_DATE
	,PROCEDURE_DATETIME
	,PROCEDURE_TYPE_CONCEPT_ID
	,MODIFIER_CONCEPT_ID
	,QUANTITY
	,PROVIDER_ID
	,VISIT_OCCURRENCE_ID
	,VISIT_DETAIL_ID 
	,PROCEDURE_SOURCE_VALUE
	,PROCEDURE_SOURCE_CONCEPT_ID
	,MODIFIER_SOURCE_VALUE
	,ETL_MODULE
	,VISIT_SOURCE_VALUE
	)

SELECT DISTINCT 
--	CDM.SEQ_PROCEDURE_OCCURRENCE.NEXTVAL AS PROCEDURE_OCCURRENCE_ID
	VISIT_OCCURRENCE.PERSON_ID
	,SOURCE_TO_CONCEPT_MAP_ANES_PROC.TARGET_CONCEPT_ID AS PROCEDURE_CONCEPT_ID
	,CAST ( AN_START_DATETIME AS DATE) AS PROCEDURE_DATE
	,AN_START_DATETIME AS PROCEDURE_DATETIME

	,32817 AS PROCEDURE_TYPE_CONCEPT_ID

	,COALESCE(SOURCE_TO_CONCEPT_MAP_MODIFIER.TARGET_CONCEPT_ID, 0) AS MODIFIER_CONCEPT_ID
	,PAT_ENC_ANES.QUANTITY AS QUANTITY
	,PROVIDER.PROVIDER_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,PAT_ENC_ANES.PROC_CODE || ':' || LEFT(PAT_ENC_ANES.PROC_NAME, 49 - LEN(PAT_ENC_ANES.PROC_CODE)) AS PROCEDURE_SOURCE_VALUE
	,0 AS PROCEDURE_SOURCE_CONCEPT_ID
	,PAT_ENC_ANES.MODIFIER1_ID || ':' || MODIFIER_NAME AS MODIFIER_SOURCE_VALUE
	,'PROCEDURE_OCCURRENCE_CLARITYANES_SNOMED_ALLSYSTEM' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM OMOP_CLARITY.PROCEDURE_OCCURRENCE_CLARITYANES_SNOMED_ALLSYSTEM AS PAT_ENC_ANES

	INNER JOIN CDM.VISIT_OCCURRENCE
		ON PAT_ENC_ANES.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

	LEFT JOIN CDM.PROVIDER
		ON PAT_ENC_ANES.AN_RESP_PROV_ID = PROVIDER.PROVIDER_SOURCE_VALUE

INNER JOIN CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_ANES_PROC
		ON PAT_ENC_ANES.PROC_ID = SOURCE_TO_CONCEPT_MAP_ANES_PROC.SOURCE_CODE
			AND UPPER(SOURCE_TO_CONCEPT_MAP_ANES_PROC.SOURCE_VOCABULARY_ID) = 'SH_ANESTHESIA'

	LEFT JOIN CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_MODIFIER
		ON PAT_ENC_ANES.MODIFIER1_ID = SOURCE_TO_CONCEPT_MAP_MODIFIER.SOURCE_CODE
			AND UPPER(SOURCE_TO_CONCEPT_MAP_MODIFIER.SOURCE_VOCABULARY_ID) = 'SH_MODIFIER'

			WHERE AN_START_DATETIME IS NOT NULL