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

CREATE OR REPLACE PROCEDURE proc_1a_Pull_location_531()
  RETURNS VARCHAR NOT NULL
  LANGUAGE JAVASCRIPT
  AS $$  
  
//  SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

  snowflake.execute( {sqlText: 
        `
        INSERT OVERWRITE INTO SH_OMOP_DB_PROD.OMOP_CLARITY.LOCATION_CLARITY_ALL
            (ADDRESS_1
            ,ADDRESS_2
            ,CITY
            ,STATE
            ,ZIP
            ,COUNTY
            ,LOCATION_SOURCE_VALUE)
        SELECT 
        	ADDRESS_1
        	,ADDRESS_2
        	,CITY
        	,STATE
        	,ZIP
        	,COUNTY
        	,LOCATION_SOURCE_VALUE
        FROM
        //-----------------------------------------------
        //-- PERSON LOCATIONS
        // -----------------------------------------------
        (
        SELECT
            DISTINCT MIN(PATIENT.ADD_LINE_1) AS ADDRESS_1
            , MIN(PATIENT.ADD_LINE_2) AS ADDRESS_2
            , MIN(PATIENT.CITY) AS CITY
            , MIN(LEFT(ZC_STATE.ABBR, 2)) AS STATE
            , MIN(LEFT(PATIENT.ZIP, 5)) AS ZIP
            , MIN(ZC_COUNTY.NAME) AS COUNTY
        	,LEFT(COALESCE (PATIENT.ADD_LINE_1, '') 
        		|| COALESCE(PATIENT.ADD_LINE_2, '') 
        		|| COALESCE(PATIENT.CITY, '') 
        		|| COALESCE(LEFT(ZC_STATE.ABBR, 2), '') 
        		|| COALESCE(PATIENT.ZIP, '') 
        		|| COALESCE(ZC_COUNTY.COUNTY_C, ''), 50) 
        	AS LOCATION_SOURCE_VALUE
         FROM SH_OMOP_DB_PROD.CDM.AOU_DRIVER AS AOU
        	INNER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PATIENT 
        		ON PATIENT.PAT_ID = AOU.EPIC_PAT_ID
        	LEFT OUTER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_STATE
        		ON PATIENT.STATE_C = ZC_STATE.STATE_C
        	LEFT OUTER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_COUNTY
        		ON PATIENT.COUNTY_C = ZC_COUNTY.COUNTY_C
        GROUP BY LEFT(COALESCE(PATIENT.ADD_LINE_1, '') 
        		|| COALESCE(PATIENT.ADD_LINE_2, '') 
        		|| COALESCE(PATIENT.CITY, '') 
        		|| COALESCE(LEFT(ZC_STATE.ABBR, 2), '') 
        		|| COALESCE(PATIENT.ZIP, '') 
        		|| COALESCE(ZC_COUNTY.COUNTY_C, ''), 50) 
        UNION 
        //-----------------------------------------------
        //-- CARE SITE LOCATIONS
        //-----------------------------------------------
        SELECT DISTINCT CLARITY_POS.ADDRESS_LINE_1 AS ADDRESS_1
        	,CLARITY_POS.ADDRESS_LINE_2 AS ADDRESS_2
        	,CLARITY_POS.CITY AS CITY
        	,LEFT(ZC_STATE.ABBR, 2) AS STATE
        	,LEFT(CLARITY_POS.ZIP, 5) AS ZIP
        	,ZC_COUNTY.NAME AS county
        	,LEFT(COALESCE(CLARITY_POS.ADDRESS_LINE_1, '') 
        		|| COALESCE(CLARITY_POS.ADDRESS_LINE_2, '') 
        		|| COALESCE(CLARITY_POS.CITY, '') 
        		|| COALESCE(LEFT(ZC_STATE.ABBR, 2), '') 
        		|| COALESCE(CLARITY_POS.ZIP, '') 
        		|| COALESCE(ZC_COUNTY.COUNTY_C, ''), 50) 
        	AS LOCATION_SOURCE_VALUE
         FROM SH_OMOP_DB_PROD.CDM.AOU_DRIVER AS AOU
        	INNER JOIN  SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.PAT_ENC
        		ON PAT_ENC.PAT_ID = AOU.EPIC_PAT_ID
        	INNER JOIN  SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_DEP
        		ON PAT_ENC.DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
        	INNER JOIN  SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_POS 
        		ON CLARITY_DEP.REV_LOC_ID = CLARITY_POS.POS_ID
        	INNER JOIN  SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_STATE
        		ON CLARITY_POS.STATE_C = ZC_STATE.STATE_C
        	LEFT OUTER JOIN  SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_COUNTY
        		ON CLARITY_POS.COUNTY_C = ZC_COUNTY.COUNTY_C
        ) AS LOCATION

        ` 

} );
return "success";
  $$
  ;
--  CALL proc_1a_Pull_location_531();