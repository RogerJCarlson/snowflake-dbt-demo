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
Name: app_measurement_FlowSheet_HSP_misc_2

Author: Roger Carlson
		Spectrum Health
		roger.carlson@spectrumhealth.org

Last Revised: 14-June-2020
		
Description: This script is the 2nd it a two-part process.  It is used in conjunction with 
	(and following) pull_measurement_FlowSheet_HSP_2. 

	Its purpose is to join the data in OMOP_Clarity.MEASUREMENT_ClarityHosp_FlowSheet to the OMOP concept table
	to return standard concept ids, and append this data to CDM.measurement.

Structure: (if your structure is different, you will have to modify the code to match)
	Database:EpicCare
	Schemas: EpicCare.OMOP, EpicCare.OMOP_Clarity

Note: I don't use aliases unless necessary for joining. I find them more confusing than helpful.

********************************************************************************/

--USE DATABASE SH_OMOP_DB_PROD;
----USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--CREATE OR REPLACE SEQUENCE CDM.SEQ_MEASUREMENT START = 1 INCREMENT = 1;

--DELETE FROM CDM.MEASUREMENT
--WHERE ETL_MODULE =  'MEASUREMENT--CLARITYHOSP--FLOWSHEET_MISC' ;

INSERT INTO CDM.MEASUREMENT
( --MEASUREMENT_ID 
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
      ,VISIT_DETAIL_ID 
      ,MEASUREMENT_SOURCE_VALUE
      ,MEASUREMENT_SOURCE_CONCEPT_ID
      ,UNIT_SOURCE_VALUE
      ,VALUE_SOURCE_VALUE
   , ETL_MODULE
   ,VISIT_SOURCE_VALUE
)

SELECT DISTINCT 
	--CDM.SEQ_MEASUREMENT.NEXTVAL AS MEASUREMENT_ID
 	MEASUREMENT_CLARITYHOSP_FLOWSHEET.PERSON_ID
	,COALESCE(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.TARGET_CONCEPT_ID, 0) AS MEASUREMENT_CONCEPT_ID
	,CAST(OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.RECORDED_TIME AS DATE ) AS MEASUREMENT_DATE
	,OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.RECORDED_TIME AS MEASUREMENT_DATETIME
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
	,COALESCE(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.TARGET_CONCEPT_ID, 0) AS UNIT_CONCEPT_ID
	,OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.MINVALUE AS RANGE_LOW
	,OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.MAX_VAL AS RANGE_HIGH
	,ATTEND.PROVIDER_ID AS PROVIDER_ID
	,VISIT_OCCURRENCE.VISIT_OCCURRENCE_ID AS VISIT_OCCURRENCE_ID
	    
--    ,VISIT_DETAIL.VISIT_DETAIL_ID AS VISIT_DETAIL_ID
    ,0 AS VISIT_DETAIL_ID

	,CAST( OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.FLO_MEAS_ID AS VARCHAR) 
		|| ':' || LEFT(OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.FLO_MEAS_NAME, 49 
		- LEN(OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.FLO_MEAS_ID)) 
		AS MEASUREMENT_SOURCE_VALUE
	,0 AS MEASUREMENT_SOURCE_CONCEPT_ID
	,SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_CODE_DESCRIPTION AS UNIT_SOURCE_VALUE
	,MEAS_VALUE AS VALUE_SOURCE_VALUE
	,'MEASUREMENT--CLARITYHOSP--FLOWSHEET_MISC' AS ETL_MODULE
	,VISIT_SOURCE_VALUE

FROM OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET

INNER JOIN CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS
	ON OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.FLO_MEAS_ID = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS.SOURCE_VOCABULARY_ID) = 'SH_FLWSHT_MEAS_MISC'

LEFT JOIN CDM.SOURCE_TO_CONCEPT_MAP AS SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS
	ON 
		OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.FLO_MEAS_ID = SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_CODE
		AND UPPER(SOURCE_TO_CONCEPT_MAP_FLOWSHEET_MEAS_UNITS.SOURCE_VOCABULARY_ID) = 'SH_FLOWSHT_MEAS_UNIT'

INNER  JOIN CDM.VISIT_OCCURRENCE
	ON OMOP_CLARITY.MEASUREMENT_CLARITYHOSP_FLOWSHEET.PAT_ENC_CSN_ID = VISIT_OCCURRENCE.VISIT_SOURCE_VALUE

LEFT JOIN CDM.PROVIDER AS ATTEND
	ON MEASUREMENT_CLARITYHOSP_FLOWSHEET.CALC_ATTEND_PROV_ID = ATTEND.PROVIDER_SOURCE_VALUE


