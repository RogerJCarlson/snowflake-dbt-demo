USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA OMOP;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

create or replace procedure app_location_2()
  returns varchar not null
  language javascript
  as     
  $$  
  snowflake.execute( {sqlText: `CREATE OR REPLACE SEQUENCE LOCATION START = 1 INCREMENT = 1;`} );
  snowflake.execute( {sqlText: `INSERT INTO OMOP.LOCATION (
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
FROM OMOP_CLARITY.LOCATION_CLARITY_ALL`} );
return "success";
  $$
  ;
  call app_location_2();