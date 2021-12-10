--USE DATABASE SH_OMOP_DB_PROD;
--USE SCHEMA OMOP_CLARITY;
--USE ROLE SF_SH_OMOP_DEVELOPER;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--DELETE FROM CDM.SPECIMEN;

INSERT INTO CDM.SPECIMEN (
	PERSON_ID
	, SPECIMEN_CONCEPT_ID
	, SPECIMEN_TYPE_CONCEPT_ID
	, SPECIMEN_DATE
	, SPECIMEN_DATETIME
	, QUANTITY
	, UNIT_CONCEPT_ID
	, ANATOMIC_SITE_CONCEPT_ID
	, DISEASE_STATUS_CONCEPT_ID
	, SPECIMEN_SOURCE_ID
	, SPECIMEN_SOURCE_VALUE
	, UNIT_SOURCE_VALUE
	, ANATOMIC_SITE_SOURCE_VALUE
	, DISEASE_STATUS_SOURCE_VALUE
	, ETL_MODULE
	)
SELECT DISTINCT PERSON_ID
	, SPECIMEN_CONCEPT_ID
	, 32817 AS SPECIMEN_TYPE_CONCEPT_ID
	, SPECIMEN_DATE
	, SPECIMEN_DATETIME
	, QUANTITY
	, UNIT_CONCEPT_ID
	, ANATOMIC_SITE_CONCEPT_ID
	, DISEASE_STATUS_CONCEPT_ID
	, SPECIMEN_SOURCE_ID
	, SPECIMEN_SOURCE_VALUE
	, UNIT_SOURCE_VALUE
	, ANATOMIC_SITE_SOURCE_VALUE
	, DISEASE_STATUS_SOURCE_VALUE
	, ETL_MODULE
FROM OMOP_CLARITY.SPECIMEN_CLARITY_ALL