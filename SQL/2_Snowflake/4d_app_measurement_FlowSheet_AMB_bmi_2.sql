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
Name: app_measurement_FlowSheet_AMB_bmi_2.sql

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) pull_measurement_FlowSheet_AMB_ALL_2.sql. 

	Its purpose is to join the data in OMOP_Clarity.MEASUREMENT_ClarityAMB_FlowSheet to the OMOP concept table
	to return standard concept ids, and append this data to OMOP.measurement.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:EpicCare
	Schemas: EpicCare.OMOP, EpicCare.OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DELETE FROM OMOP.measurement
--WHERE ETL_Module = 'MEASUREMENT--ClarityAMB--FlowSheet_bmi';

INSERT INTO OMOP.MEASUREMENT
( 
--      MEASUREMENT_ID 
      PERSON_ID
      ,MEASUREMENT_CONCEPT_ID
      ,MEASUREMENT_DATE
      ,MEASUREMENT_DATETIME
      ,MEASUREMENT_TYPE_CONCEPT_ID
      ,OPERATOR_CONCEPT_ID
      ,VALUE_AS_NUMBER
      ,VALUE_AS_CONCEPT_ID
      ,UNIT_CONCEPT_ID
      ,RANGE_LOW
      ,RANGE_HIGH
      ,PROVIDER_ID
      ,VISIT_OCCURRENCE_ID
      ,MEASUREMENT_SOURCE_VALUE
      ,MEASUREMENT_SOURCE_CONCEPT_ID
      ,UNIT_SOURCE_VALUE
      ,VALUE_SOURCE_VALUE
   , ETL_MODULE
   ,VISIT_SOURCE_VALUE
)
SELECT DISTINCT
	
--	OMOP.SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID
	MEASUREMENT_CLARITYAMB_FLOWSHEET.PERSON_ID
	,COALESCE(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.TARGET_CONCEPT_ID, 0) AS MEASUREMENT_CONCEPT_ID
	,CAST ( MEASUREMENT_CLARITYAMB_FLOWSHEET.RECORDED_TIME AS DATE) AS MEASUREMENT_DATE
	,MEASUREMENT_CLARITYAMB_FLOWSHEET.RECORDED_TIME AS MEASUREMENT_DATETIME
	,32817 AS MEASUREMENT_TYPE_CONCEPT_ID --EHR
	,CASE 
		WHEN MEAS_VALUE LIKE '>=%'
			THEN 4171755
		WHEN MEAS_VALUE LIKE '<=%'
			THEN 4171754
		WHEN MEAS_VALUE LIKE '<%'
			THEN 4171756
		WHEN MEAS_VALUE LIKE '>%'
			THEN 4172704
		ELSE 4172703
		END AS OPERATOR_CONCEPT_ID
	,REPLACE(REPLACE(REPLACE(MEAS_VALUE, '=', ''), '<', ''), '>', '') AS VALUE_AS_NUMBER
	,0 AS VALUE_AS_CONCEPT_ID
	,9531 AS UNIT_CONCEPT_ID -- BMI UNIT KG/M2
	,MEASUREMENT_CLARITYAMB_FLOWSHEET.MINVALUE AS RANGE_LOW
	,MEASUREMENT_CLARITYAMB_FLOWSHEET.MAX_VAL AS RANGE_HIGH
	,COALESCE(VST.PROVIDER_ID, PCP.PROVIDER_ID) AS PROVIDER_ID

	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	,CAST ( MEASUREMENT_CLARITYAMB_FLOWSHEET.FLO_MEAS_ID AS VARCHAR) || ':' || LEFT(MEASUREMENT_CLARITYAMB_FLOWSHEET.FLO_MEAS_NAME, 49 - LEN(MEASUREMENT_CLARITYAMB_FLOWSHEET.FLO_MEAS_ID)) AS MEASUREMENT_SOURCE_VALUE
	,0 AS MEASUREMENT_SOURCE_CONCEPT_ID
	, 'kg/m2 (inferred)' AS unit_source_value -- bmi unit kg/m2 inferred
	,MEAS_VALUE AS value_source_value
	,'MEASUREMENT--ClarityAMB--FlowSheet_bmi' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM OMOP_CLARITY.MEASUREMENT_CLARITYAMB_FLOWSHEET

	INNER JOIN OMOP.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS
		ON MEASUREMENT_CLARITYAMB_FLOWSHEET.FLO_MEAS_ID = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_CODE
			AND SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_VOCABULARY_ID = 'sh_flwsht_meas_bmi'

    INNER JOIN
                OMOP.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_AMB_VISIT
                ON
                            SOURCE_TO_CONCEPT_MAP_AMB_VISIT.SOURCE_CODE   = MEASUREMENT_CLARITYAMB_FLOWSHEET.ENC_TYPE_C
                            AND SOURCE_TO_CONCEPT_MAP_AMB_VISIT.SOURCE_VOCABULARY_ID  IN ('SH_amb_f2f')

	INNER JOIN OMOP.VISIT_OCCURRENCE
		ON MEASUREMENT_CLARITYAMB_FLOWSHEET.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

LEFT JOIN
            OMOP.PROVIDER AS VST
            ON
                        MEASUREMENT_CLARITYAMB_FLOWSHEET.VISIT_PROV_ID = VST.PROVIDER_SOURCE_VALUE         
LEFT JOIN
            OMOP.PROVIDER AS PCP
            ON
                        MEASUREMENT_CLARITYAMB_FLOWSHEET.PCP_PROV_ID = PCP.PROVIDER_SOURCE_VALUE 
						
WHERE MEAS_VALUE IS NOT NULL
