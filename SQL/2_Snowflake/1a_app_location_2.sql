--USE DATABASE SH_OMOP_DB_PROD;
--USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--CREATE OR REPLACE SEQUENCE LOCATION START = 1 INCREMENT = 1;

----DELETE FROM OMOP.LOCATION;
--TRUNCATE TABLE OMOP.LOCATION
-----------------------------------------------
-- PERSON LOCATIONS
-----------------------------------------------
INSERT INTO OMOP.LOCATION (
    LOCATION_ID 
	,ADDRESS_1
	,ADDRESS_2
	,CITY
	,STATE
	,ZIP
	,COUNTY
	,LOCATION_SOURCE_VALUE
	)
SELECT DISTINCT LOCATION.NEXTVAL AS LOCATION_ID
    ,ADDRESS_1
	,ADDRESS_2
	,CITY
	,STATE
	,ZIP
	,COUNTY
	,LOCATION_SOURCE_VALUE
FROM OMOP_CLARITY.LOCATION_CLARITY_ALL