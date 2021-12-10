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
Name: app_procedure_occurrence_CPT_SURG_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) Pull_procedure_occurrence_CPT_SURG_2.sql. 

	Its purpose is to join the data in OMOP_Clarity.PROCEDURE_OCCURRENCE_ClaritySURG_CPT to the OMOP concept table
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

--DELETE FROM CDM.PROCEDURE_OCCURRENCE
--WHERE ETL_MODULE = 'PROCEDURE_OCCURRENCE--ClaritySURG--CPT';

INSERT INTO  CDM.PROCEDURE_OCCURRENCE(	
--		PROCEDURE_OCCURRENCE_ID
		PERSON_ID
		, PROCEDURE_CONCEPT_ID
		, PROCEDURE_DATE
		, PROCEDURE_DATETIME
		, PROCEDURE_TYPE_CONCEPT_ID
		, MODIFIER_CONCEPT_ID
		, QUANTITY
		, PROVIDER_ID
		, VISIT_OCCURRENCE_ID
		, VISIT_DETAIL_ID 
		, PROCEDURE_SOURCE_VALUE
		, PROCEDURE_SOURCE_CONCEPT_ID
		, MODIFIER_SOURCE_VALUE
		, ETL_MODULE
		,VISIT_SOURCE_VALUE
)

WITH 	T_SOURCE
AS (
	SELECT CONCEPT_ID
		,CONCEPT_CODE
		,DOMAIN_ID
		,VOCABULARY_ID
	
	FROM CDM.CONCEPT AS C
	
	WHERE C.VOCABULARY_ID IN ('CPT4')
		AND UPPER(C.DOMAIN_ID) = 'PROCEDURE'
	)

,
T_CONCEPT
AS (
	SELECT C2.CONCEPT_ID AS CONCEPT_ID
		,C1.CONCEPT_ID AS SOURCE_CONCEPT_ID
	
	FROM CDM.CONCEPT C1
	
	INNER JOIN CDM.CONCEPT_RELATIONSHIP CR
		ON C1.CONCEPT_ID = CR.CONCEPT_ID_1
			AND UPPER(CR.RELATIONSHIP_ID) = 'MAPS TO'
	
	INNER JOIN CDM.CONCEPT C2
		ON C2.CONCEPT_ID = CR.CONCEPT_ID_2
	
	WHERE C2.STANDARD_CONCEPT = 'S'
		AND UPPER(C2.DOMAIN_ID) = 'PROCEDURE'
	)

SELECT DISTINCT  
--	CDM.SEQ_PROCEDURE_OCCURRENCE.NEXTVAL AS PROCEDURE_OCCURRENCE_ID
	PAT_ENC_HSP.PERSON_ID
	,T_CONCEPT.CONCEPT_ID AS PROCEDURE_CONCEPT_ID
	,CAST (PAT_ENC_HSP.CALC_START_TIME AS DATE ) AS PROCEDURE_DATE
	,PAT_ENC_HSP.CALC_START_TIME AS PROCEDURE_DATETIME
	,32817 AS PROCEDURE_TYPE_CONCEPT_ID
	, 0 AS MODIFIER_CONCEPT_ID
	,1 AS QUANTITY
	,PROVIDER.PROVIDER_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,PAT_ENC_HSP.PROC_CODE || ':' || LEFT(PAT_ENC_HSP.PROC_NAME, 49 - LEN(PAT_ENC_HSP.PROC_CODE)) AS PROCEDURE_SOURCE_VALUE
	,T_SOURCE.CONCEPT_ID AS PROCEDURE_SOURCE_CONCEPT_ID
	,NULL AS MODIFIER_SOURCE_VALUE
	,'PROCEDURE_OCCURRENCE--CLARITYSURG--CPT' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM OMOP_CLARITY.PROCEDURE_OCCURRENCE_CLARITYSURG_CPT AS PAT_ENC_HSP

INNER JOIN T_SOURCE
	ON PAT_ENC_HSP.PROC_CODE = T_SOURCE.CONCEPT_CODE

INNER JOIN T_CONCEPT
	ON T_SOURCE.CONCEPT_ID = T_CONCEPT.CONCEPT_ID

-------------------------------------------
INNER JOIN CDM.VISIT_OCCURRENCE
	ON PAT_ENC_HSP.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

LEFT JOIN CDM.PROVIDER
	ON PAT_ENC_HSP.CALC_PERFORM_PHYS = PROVIDER.PROVIDER_SOURCE_VALUE


