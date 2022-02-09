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
Name: app_measurement_FlowSheet_HSP_vitals_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) pull_measurement_FlowSheet_HSP_2. 

	Its purpose is to join the data in OMOP_Clarity.MEASUREMENT_ClarityHosp_FlowSheet to the OMOP concept table
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

--CREATE OR REPLACE SEQUENCE OMOP.SEQ_MEASUREMENT START = 1 INCREMENT = 1;

--DELETE FROM OMOP.measurement
--WHERE ETL_Module = 'MEASUREMENT--ClarityHosp--FlowSheet_bmi';


INSERT INTO OMOP.MEASUREMENT
( --MEASUREMENT_ID 
      person_id
      ,measurement_concept_id
      ,measurement_date
      ,measurement_datetime
      ,measurement_type_concept_id
      ,operator_concept_id
      ,value_as_number
      ,value_as_concept_id
      ,unit_concept_id
      ,range_low
      ,range_high
      ,provider_id
      ,visit_occurrence_id
      ,measurement_source_value
      ,measurement_source_concept_id
      ,unit_source_value
      ,value_source_value
   , ETL_Module
   ,visit_source_value
)
SELECT DISTINCT --OMOP.SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID
	MEASUREMENT_ClarityHosp_FlowSheet.person_id
	,COALESCE(source_to_concept_map_flowsheet_meas.target_concept_id, 0) AS measurement_concept_id
	,CAST(MEASUREMENT_ClarityHosp_FlowSheet.recorded_time AS DATE ) AS measurement_date
	,MEASUREMENT_ClarityHosp_FlowSheet.recorded_time AS measurement_datetime
	,32817 AS measurement_type_concept_id --EHR
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
		END AS operator_concept_id
	,REPLACE(REPLACE(REPLACE(MEAS_VALUE, '=', ''), '<', ''), '>', '') AS value_as_number
	,0 AS value_as_concept_id
	,9531 AS unit_concept_id -- bmi unit kg/m2
	,MEASUREMENT_ClarityHosp_FlowSheet.MINVALUE AS range_low
	,MEASUREMENT_ClarityHosp_FlowSheet.MAX_VAL AS range_high
	,Attend.provider_id AS provider_id
	,visit_occurrence.visit_occurrence_id AS visit_occurrence_id
	,CAST( MEASUREMENT_ClarityHosp_FlowSheet.flo_meas_id AS VARCHAR) 
		|| ':' || LEFT(MEASUREMENT_ClarityHosp_FlowSheet.FLO_MEAS_NAME, 49 
		- LEN(MEASUREMENT_ClarityHosp_FlowSheet.flo_meas_id)) 
		AS measurement_source_value
	,0 AS measurement_source_concept_id
	, 'kg/m2 (inferred)' AS unit_source_value -- bmi unit kg/m2 inferred
	,MEAS_VALUE AS value_source_value
	,'MEASUREMENT--ClarityHosp--FlowSheet_bmi' AS ETL_Module
	,visit_source_value

FROM OMOP_Clarity.MEASUREMENT_ClarityHosp_FlowSheet

INNER JOIN OMOP.source_to_concept_map AS source_to_concept_map_flowsheet_meas
	ON MEASUREMENT_ClarityHosp_FlowSheet.FLO_MEAS_ID = source_to_concept_map_flowsheet_meas.source_code
		AND source_to_concept_map_flowsheet_meas.source_vocabulary_id = 'sh_flwsht_meas_bmi'

INNER JOIN omop.visit_occurrence
	ON MEASUREMENT_ClarityHosp_FlowSheet.PAT_ENC_CSN_ID = visit_occurrence.visit_source_value

LEFT JOIN omop.provider as Attend
	ON MEASUREMENT_ClarityHosp_FlowSheet.CALC_ATTEND_PROV_ID = Attend.provider_source_value

WHERE MEAS_VALUE is not null
