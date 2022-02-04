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
Name: app_drug_exposure_RXNORM_ANES_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) pull_drug_exposure_RXNORM_ANES_2. 

	Its purpose is to join the data in OMOP_Clarity.DRUG_EXPOSURE_ClarityANES_RXNORM to the OMOP concept table
	to return standard concept ids, and append this data to OMOP.drug_exposure.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:EpicCare
	Schemas: EpicCare.OMOP, EpicCare.OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--CREATE OR REPLACE SEQUENCE OMOP.SEQ_DRUG_EXPOSURE START = 1 INCREMENT = 1;

--DELETE FROM OMOP.drug_exposure
--WHERE ETL_Module = 'DRUG_EXPOSURE--ClarityANES--RXNORM';

-------MAIN---------------------

INSERT INTO OMOP.drug_exposure (
--	DRUG_EXPOSURE_ID
	person_id
	,drug_concept_id
	,drug_exposure_start_date
	,drug_exposure_start_datetime
	,drug_exposure_end_date
	,drug_exposure_end_datetime
	,verbatim_end_date
	,drug_type_concept_id
	,stop_reason
	,refills
	,quantity
	,days_supply
	,sig
	,route_concept_id
	,lot_number
	,provider_id
	,visit_occurrence_id
	,drug_source_value
	,drug_source_concept_id
	,route_source_value
	,dose_unit_source_value
	,ETL_Module
	,visit_source_value
	)


WITH Top_RXNORM
AS (
	SELECT DISTINCT DRUG_EXPOSURE_ClarityANES_RXNORM.MAR_ADMIN_INFO_LINE
		,MEDICATION_ID
		,c.concept_code
		,C.concept_class_id
		,c.TheOrder
	
	FROM OMOP_Clarity.DRUG_EXPOSURE_ClarityANES_RXNORM
	
	INNER JOIN (
		SELECT concept_code
			,concept_class_id
			--Currently used: Clinical Pack, Branded Drug, Clinical Drug, Brand Name, Quant Clinical Drug, Ingredient
			,CASE 
				WHEN concept_class_id = 'Ingredient'
					THEN 10
				WHEN concept_class_id = 'Clinical Drug Form'
					THEN 20
				WHEN concept_class_id = 'Branded Drug Form'
					THEN 30
				WHEN concept_class_id = 'Clinical Drug Comp'
					THEN 40
				WHEN concept_class_id = 'Branded Drug Comp' -- order not verified
					THEN 42
				WHEN concept_class_id = 'Brand Name' -- order not verified
					THEN 45
				WHEN concept_class_id = 'Quant Clinical Drug'
					THEN 50
				WHEN concept_class_id = 'Clinical Drug'
					THEN 60
				WHEN concept_class_id = 'Branded Drug Form'
					THEN 70
				WHEN concept_class_id = 'Branded Drug'
					THEN 80
				WHEN concept_class_id = 'Branded Pack'
					THEN 99
						--do not know the order of these
				WHEN concept_class_id = 'Quant Branded Drug'
					THEN 999
				WHEN concept_class_id = 'Dose Form Group'
					THEN 999
				WHEN concept_class_id = 'Dose Form'
					THEN 999
				WHEN concept_class_id = 'Branded Dose Group'
					THEN 999
				WHEN concept_class_id = 'Clinical Dose Group'
					THEN 999
				WHEN concept_class_id = 'Precise Ingredient'
					THEN 999
				WHEN concept_class_id = 'Quant Branded Drug'
					THEN 999
				ELSE 0
				END AS TheOrder
		
		FROM omop.concept
		
		WHERE vocabulary_id IN ('RxNorm')
			AND (
				invalid_reason IS NULL
				OR invalid_reason = ''
				)
			AND domain_id = 'Drug'
		) C
		ON OMOP_Clarity.DRUG_EXPOSURE_ClarityANES_RXNORM.RXNORM_CODE = concept_code
	
	WHERE OMOP_Clarity.DRUG_EXPOSURE_ClarityANES_RXNORM.RXNORM_TERM_TYPE_C <> 2 --2 - Precise Ingredient
	)
	,
	----------------------------
T_DRUG_SOURCE
AS (
	SELECT concept_id
		,concept_code
		,concept_class_id
		,concept_name
	
	FROM omop.concept AS C
	
	WHERE C.vocabulary_id IN ('RxNorm')
		AND (
			C.invalid_reason IS NULL
			OR C.invalid_reason = ''
			)
		AND C.domain_id = 'Drug'
	)
	,
	----------------------------	
T_DRUG_CONCEPT
AS (
	SELECT c2.concept_id AS drug_concept_id
		,C1.concept_id AS drug_concept_SOURCE_CONCEPT_ID
	
	FROM omop.concept c1
	
	INNER JOIN omop.concept_relationship cr
		ON c1.concept_id = cr.concept_id_1
			AND cr.relationship_id = 'Maps to'
	
	INNER JOIN omop.concept c2
		ON c2.concept_id = cr.concept_id_2
	
	WHERE c2.standard_concept = 'S'
		AND (
			c2.invalid_reason IS NULL
			OR c2.invalid_reason = ''
			)
		AND c2.domain_id = 'Drug'
	)


SELECT DISTINCT 
--	OMOP.SEQ_DRUG_EXPOSURE.NEXTVAL AS DRUG_EXPOSURE_ID
	 DRUG_EXPOSURE_ClarityANES_RXNORM.person_id
	,T_DRUG_CONCEPT.drug_concept_id
	,CAST ( TAKEN_TIME AS DATE) AS drug_exposure_start_date
	,TAKEN_TIME AS drug_exposure_start_datetime
	,CAST( coalesce(AN_STOP_DATETIME, TAKEN_TIME)AS DATE) AS drug_exposure_end_date
	,CASE 
		WHEN (CAST( coalesce(AN_STOP_DATETIME, TAKEN_TIME)AS DATE) = CAST( TAKEN_TIME AS DATE))
			AND (coalesce(AN_STOP_DATETIME, TAKEN_TIME) < TAKEN_TIME)
			THEN TAKEN_TIME
			ELSE
			coalesce(AN_STOP_DATETIME, TAKEN_TIME)
		END AS drug_exposure_end_datetime

	,AN_STOP_DATETIME AS verbatim_end_date
	,32817 AS drug_type_concept_id -- EHR
	,LEFT(ZC_RSN_FOR_DISCON_name, 20) AS stop_reason
	,NULL AS refills
	,CASE 
		WHEN TRY_TO_NUMERIC(LEFT(QUANTITY, CHARINDEX(' ', QUANTITY))) IS NULL 
			THEN 1
		ELSE cast( LEFT(QUANTITY, CHARINDEX(' ', QUANTITY)) AS FLOAT)
		END AS quantity
	,NULL AS days_supply
	,SIG AS sig
	,COALESCE(source_to_concept_map_route.target_concept_id, 0) AS route_concept_id
	,NULL AS lot_number

	--,provider.provider_id AS provider_id
	,coalesce(AN_RESP_PROV_ID,AUTHRZING_PROV_ID) AS provider_id

	,visit_occurrence_id AS visit_occurrence_id
	,CAST( DRUG_EXPOSURE_ClarityANES_RXNORM.medication_ID AS VARCHAR) || ':' || LEFT(CLARITY_MEDICATION_NAME, 49 - LEN(DRUG_EXPOSURE_ClarityANES_RXNORM.medication_ID)) AS drug_source_value
	,T_DRUG_SOURCE.concept_id AS drug_source_concept_id
	,cast( DRUG_EXPOSURE_ClarityANES_RXNORM.ROUTE_C AS VARCHAR) || ':' || LEFT(ZC_ADMIN_ROUTE_NAME, 49 - LEN(DRUG_EXPOSURE_ClarityANES_RXNORM.ROUTE_C)) AS route_source_value
	,DOSE_UNIT_C AS dose_unit_source_value
	,'DRUG_EXPOSURE--ClarityANES--RXNORM' AS ETL_Module
	,visit_source_value

FROM OMOP_Clarity.DRUG_EXPOSURE_ClarityANES_RXNORM

INNER JOIN omop.visit_occurrence
	ON DRUG_EXPOSURE_ClarityANES_RXNORM.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

LEFT JOIN omop.provider as RESP_PROV
	ON DRUG_EXPOSURE_ClarityANES_RXNORM.AN_RESP_PROV_ID = RESP_PROV.provider_source_value

LEFT JOIN omop.provider AUTH_PROV
	ON DRUG_EXPOSURE_ClarityANES_RXNORM.AN_RESP_PROV_ID = AUTH_PROV.provider_source_value

INNER JOIN Top_RXNORM
	ON DRUG_EXPOSURE_ClarityANES_RXNORM.MEDICATION_ID = Top_RXNORM.MEDICATION_ID

INNER JOIN T_DRUG_SOURCE
	ON Top_RXNORM.concept_code = T_DRUG_SOURCE.concept_code

INNER JOIN T_DRUG_CONCEPT
	ON T_DRUG_SOURCE.concept_id = T_DRUG_CONCEPT.drug_concept_SOURCE_CONCEPT_ID

LEFT JOIN OMOP.source_to_concept_map AS source_to_concept_map_route
	ON source_to_concept_map_route.source_code = DRUG_EXPOSURE_ClarityANES_RXNORM.ROUTE_C
		AND source_to_concept_map_route.source_vocabulary_id = 'SH_route'

INNER JOIN -- this removes the duplicates 
	(
	SELECT MIN(MAR_ADMIN_INFO_LINE) AS FirstLine
		,Top_RXNORM.MEDICATION_ID
		,min(concept_code) AS concept_code
		,concept_class_id
		,TheOrder
	
	FROM Top_RXNORM
	
	GROUP BY MEDICATION_ID
		,concept_class_id
		,TheOrder
				
	    qualify row_number() over (partition by TOP_RXNORM.MEDICATION_ID order by THEORDER, FIRSTLINE) = 1
			
--	HAVING Top_RXNORM.TheOrder IN (
--			SELECT TOP 1 TheOrder
--			
--			FROM Top_RXNORM T2
--			
--			WHERE Top_RXNORM.MEDICATION_ID = T2.MEDICATION_ID
--			
--			ORDER BY T2.TheOrder
--				,T2.MAR_ADMIN_INFO_LINE
--			)
	) x
	ON x.concept_code = Top_RXNORM.concept_code
		AND x.MEDICATION_ID = Top_RXNORM.MEDICATION_ID

