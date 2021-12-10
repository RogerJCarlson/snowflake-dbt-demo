--*******************************************************************************
--# Copyright 2020 Spectrum Health 
--# http://www.spectrumhealth.org
--#
--# Unless required by applicable law or agreed to in writing, this software
--# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
--# either express or implied.
--#
--********************************************************************************/
/*******************************************************************************

Name: proc_1a_App_location_531

Author: Roger Carlson
        Spectrum Health
        roger.carlson@spectrumhealth.org

Last Revised: 27-Sept-2021
********************************************************************************/

USE ROLE SF_SH_OMOP_DEVELOPER;
USE SCHEMA SH_OMOP_DB_PROD.OMOP_CLARITY;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

CREATE OR REPLACE PROCEDURE proc_1a_App_location_531()
  RETURNS VARCHAR NOT NULL
  LANGUAGE JAVASCRIPT
  AS $$  
  
//  SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

  snowflake.execute( {sqlText: 
    `
    //---------------------------------------
    // PERSON LOCATIONS
    //---------------------------------------
    
    INSERT INTO CDM.LOCATION (
    
    	ADDRESS_1
    	,ADDRESS_2
    	,CITY
    	,STATE
    	,ZIP
    	,COUNTY
    	,LOCATION_SOURCE_VALUE
    	)
    SELECT DISTINCT 
        ADDRESS_1
    	,ADDRESS_2
    	,CITY
    	,STATE
    	,ZIP
    	,COUNTY
    	,LOCATION_SOURCE_VALUE
    FROM OMOP_CLARITY.LOCATION_CLARITY_ALL;
    `
} );
return "success";
  $$
  ;
--  CALL proc_1a_App_location_531();