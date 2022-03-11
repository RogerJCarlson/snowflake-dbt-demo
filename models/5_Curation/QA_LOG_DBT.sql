  
--QA_LOG_DBT

{{ config(materialized = 'table', schema='OMOP_QA') }}

--CARE_SITE
SELECT  * FROM 
{{ref('QA_CARE_SITE_DUPLICATES_COUNT')}} AS QA_CARE_SITE_DUPLICATES_COUNT 
{# UNION SELECT  * FROM
{{ref('QA_CARE_SITE_NOMATCH_COUNT')}} AS QA_CARE_SITE_NOMATCH_COUNT  #}
UNION SELECT  * FROM
{{ref('QA_CARE_SITE_NON_STANDARD_COUNT')}} AS QA_CARE_SITE_NON_STANDARD_COUNT 
UNION SELECT  * FROM
{{ref('QA_CARE_SITE_NULLFK_COUNT')}} AS QA_CARE_SITE_NULLFK_COUNT 
UNION SELECT  * FROM
{{ref('QA_CARE_SITE_NULL_CONCEPT_COUNT')}} AS QA_CARE_SITE_NULL_CONCEPT_COUNT 
UNION SELECT  * FROM
{{ref('QA_CARE_SITE_ZERO_CONCEPT_COUNT')}} AS QA_CARE_SITE_ZERO_CONCEPT_COUNT 

--CONDITION
UNION SELECT  * FROM
{{ref('QA_CONDITION_30AFTERDEATH_COUNT')}} AS QA_CONDITION_30AFTERDEATH_COUNT
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_DATEVDATETIME_COUNT')}} AS QA_CONDITION_OCCURRENCE_DATEVDATETIME_COUNT
UNION SELECT  * FROM
 {{ref('QA_CONDITION_OCCURRENCE_DUPLICATES_COUNT')}} AS QA_CONDITION_OCCURRENCE_DUPLICATES_COUNT
UNION SELECT  * FROM
 {{ref('QA_CONDITION_OCCURRENCE_END_BEFORE_START_COUNT')}} AS QA_CONDITION_OCCURRENCE_END_BEFORE_START_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_CONDITION_OCCURRENCE_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_NONSTANDARD_COUNT')}} AS QA_CONDITION_OCCURRENCE_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_NOVISIT_COUNT')}} AS QA_CONDITION_OCCURRENCE_NOVISIT_COUNT
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_NULLCONCEPT_COUNT')}} AS QA_CONDITION_OCCURRENCE_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_NULLFK_COUNT')}} AS QA_CONDITION_OCCURRENCE_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_VISITDATEDISPARITY_COUNT')}} AS QA_CONDITION_OCCURRENCE_VISITDATEDISPARITY_COUNT 
UNION SELECT  * FROM
{{ref('QA_CONDITION_OCCURRENCE_ZEROCONCEPT_COUNT')}} AS QA_CONDITION_OCCURRENCE_ZEROCONCEPT_COUNT

--DEATH
UNION SELECT  * FROM
{{ref('QA_DEATH_DUPLICATES_COUNT')}} AS QA_DEATH_DUPLICATES_COUNT
UNION SELECT  * FROM
{{ref('QA_DEATH_NULL_CONCEPT_COUNT')}} AS QA_DEATH_NULL_CONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_DEATH_ZERO_CONCEPT_COUNT')}} AS QA_DEATH_ZERO_CONCEPT_COUNT

--DEVICE_EXPOSURE
UNION SELECT  * FROM
{{ref('QA_DEVICE_CONCEPT_DUPLICATES_COUNT')}} AS QA_DEVICE_CONCEPT_DUPLICATES_COUNT 
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_DATEVDATETIME_COUNT')}} AS QA_DEVICE_EXPOSURE_DATEVDATETIME_COUNT 
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_END_BEFORE_START_COUNT')}} AS QA_DEVICE_EXPOSURE_END_BEFORE_START_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_DEVICE_EXPOSURE_NOMATCH_COUNT  #}
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_NONSTANDARD_COUNT')}} AS QA_DEVICE_EXPOSURE_NONSTANDARD_COUNT 
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_NOVISIT_COUNT')}} AS QA_DEVICE_EXPOSURE_NOVISIT_COUNT
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_NULLFK_COUNT')}} AS QA_DEVICE_EXPOSURE_NULLFK_COUNT 
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_NULL_CONCEPT_COUNT')}} AS QA_DEVICE_EXPOSURE_NULL_CONCEPT_COUNT 
UNION SELECT  * FROM
{{ref('QA_DEVICE_EXPOSURE_ZERO_CONCEPT_COUNT')}} AS QA_DEVICE_EXPOSURE_ZERO_CONCEPT_COUNT 

--DRUG_EXPOSURE
UNION SELECT  * FROM
{{ref('QA_DRUG_30AFTERDEATH_COUNT')}} AS QA_DRUG_30AFTERDEATH_COUNT 
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_DATEVDATETIME_COUNT')}} AS QA_DRUG_EXPOSURE_DATEVDATETIME_COUNT 
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_DUPLICATES_COUNT')}} AS QA_DRUG_EXPOSURE_DUPLICATES_COUNT 
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_END_BEFORE_START_COUNT')}} AS QA_DRUG_EXPOSURE_END_BEFORE_START_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_DRUG_EXPOSURE_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_NONSTANDARD_COUNT')}} AS QA_DRUG_EXPOSURE_NONSTANDARD_COUNT 
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_NOVISIT_COUNT')}} AS QA_DRUG_EXPOSURE_NOVISIT_COUNT 
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_NULLCONCEPT_COUNT')}} AS QA_DRUG_EXPOSURE_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_NULLFK_COUNT')}} AS QA_DRUG_EXPOSURE_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_VISITDATEDISPARITY_COUNT')}} AS QA_DRUG_EXPOSURE_VISITDATEDISPARITY_COUNT
UNION SELECT  * FROM
{{ref('QA_DRUG_EXPOSURE_ZEROCONCEPT_COUNT')}} AS QA_DRUG_EXPOSURE_ZEROCONCEPT_COUNT

--LOCATION
UNION SELECT  * FROM
{{ref('QA_LOCATION_DUPLICATES_COUNT')}} AS QA_LOCATION_DUPLICATES_COUNT

--MEASUREMENT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_30AFTERDEATH_COUNT')}} AS QA_MEASUREMENT_30AFTERDEATH_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_DATEVDATETIME_COUNT')}} AS QA_MEASUREMENT_DATEVDATETIME_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_DUPLICATES_COUNT')}} AS QA_MEASUREMENT_DUPLICATES_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_MEASUREMENT_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_NONSTANDARD_COUNT')}} AS QA_MEASUREMENT_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_NOVISIT_COUNT')}} AS QA_MEASUREMENT_NOVISIT_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_NULLCONCEPT_COUNT')}} AS QA_MEASUREMENT_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_NULLFK_COUNT')}} AS QA_MEASUREMENT_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_VISITDATEDISPARITY_COUNT')}} AS QA_MEASUREMENT_VISITDATEDISPARITY_COUNT
UNION SELECT  * FROM
{{ref('QA_MEASUREMENT_ZEROCONCEPT_COUNT')}} AS QA_MEASUREMENT_ZEROCONCEPT_COUNT 

--NOTE
UNION SELECT  * FROM
{{ref('QA_NOTE_DATEVDATETIME_COUNT')}} AS QA_NOTE_DATEVDATETIME_COUNT
UNION SELECT  * FROM
{{ref('QA_NOTE_DUPLICATES_COUNT')}} AS QA_NOTE_DUPLICATES_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_NOTE_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_NOTE_NONSTANDARD_COUNT')}} AS QA_NOTE_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_NOTE_NOVISIT_COUNT')}} AS QA_NOTE_NOVISIT_COUNT
UNION SELECT  * FROM
{{ref('QA_NOTE_NULLCONCEPT_COUNT')}} AS QA_NOTE_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_NOTE_NULLFK_COUNT')}} AS QA_NOTE_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_NOTE_ZEROCONCEPT_COUNT')}} AS QA_NOTE_ZEROCONCEPT_COUNT

--OBSERVATION
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_30AFTERDEATH_COUNT')}} AS QA_OBSERVATION_30AFTERDEATH_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_DATEVDATETIME_COUNT')}} AS QA_OBSERVATION_DATEVDATETIME_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_DUPLICATES_COUNT')}} AS QA_OBSERVATION_DUPLICATES_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_OBSERVATION_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_NONSTANDARD_COUNT')}} AS QA_OBSERVATION_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_NOVISIT_COUNT')}} AS QA_OBSERVATION_NOVISIT_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_NULLCONCEPT_COUNT')}} AS QA_OBSERVATION_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_NULLFK_COUNT')}} AS QA_OBSERVATION_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_VISITDATEDISPARITY_COUNT')}} AS QA_OBSERVATION_VISITDATEDISPARITY_COUNT
UNION SELECT  * FROM
{{ref('QA_OBSERVATION_ZEROCONCEPT_COUNT')}} AS QA_OBSERVATION_ZEROCONCEPT_COUNT

--PERSON
UNION SELECT  * FROM
{{ref('QA_PERSON_AGE_ERR_COUNT')}} AS QA_PERSON_AGE_ERR_COUNT
UNION SELECT  * FROM
{{ref('QA_PERSON_DUPLICATES_COUNT')}} AS QA_PERSON_DUPLICATES_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_PERSON_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_PERSON_NONSTANDARD_COUNT')}} AS QA_PERSON_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_PERSON_NULLCONCEPT_COUNT')}} AS QA_PERSON_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_PERSON_NULLFK_COUNT')}} AS QA_PERSON_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_PERSON_ZEROCONCEPT_COUNT')}} AS QA_PERSON_ZEROCONCEPT_COUNT

--PROCEDURE_OCCURRENCE
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_30AFTERDEATH_COUNT')}} AS QA_PROCEDURE_30AFTERDEATH_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_DATEVDATETIME_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_DATEVDATETIME_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_DUPLICATES_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_DUPLICATES_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_PROCEDURE_OCCURRENCE_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_NONSTANDARD_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_NOVISIT_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_NOVISIT_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_NULLCONCEPT_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_NULLFK_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_VISITDATEDISPARITY_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_VISITDATEDISPARITY_COUNT
UNION SELECT  * FROM
{{ref('QA_PROCEDURE_OCCURRENCE_ZEROCONCEPT_COUNT')}} AS QA_PROCEDURE_OCCURRENCE_ZEROCONCEPT_COUNT 

--PROVIDER
UNION SELECT  * FROM
{{ref('QA_PROVIDER_DUPLICATES_COUNT')}} AS QA_PROVIDER_DUPLICATES_COUNT
{# UNION SELECT  * FROM
{{ref('xxx')}} AS QA_PROVIDER_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_PROVIDER_NONSTANDARD_COUNT')}} AS QA_PROVIDER_NONSTANDARD_COUNT 
UNION SELECT  * FROM
{{ref('QA_PROVIDER_NULLFK_COUNT')}} AS QA_PROVIDER_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_PROVIDER_NULL_CONCEPT_COUNT')}} AS QA_PROVIDER_NULL_CONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_PROVIDER_ZEROCONCEPT_COUNT')}} AS QA_PROVIDER_ZEROCONCEPT_COUNT 

--SPECIMEN
UNION SELECT  * FROM
{{ref('QA_SPECIMEN_DATEVDATETIME_COUNT')}} AS QA_SPECIMEN_DATEVDATETIME_COUNT
UNION SELECT  * FROM
{{ref('QA_SPECIMEN_DUPLICATES_COUNT')}} AS QA_SPECIMEN_DUPLICATES_COUNT
{#UNION SELECT  * FROM
{{ref('xxx')}} AS QA_SPECIMEN_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_SPECIMEN_NONSTANDARD_COUNT')}} AS QA_SPECIMEN_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_SPECIMEN_NULLCONCEPT_COUNT')}} AS QA_SPECIMEN_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_SPECIMEN_ZEROCONCEPT_COUNT')}} AS QA_SPECIMEN_ZEROCONCEPT_COUNT

--VISIT_OCCURRENCE
UNION SELECT  * FROM
{{ref('QA_VISIT_30AFTERDEATH_COUNT')}} AS QA_VISIT_30AFTERDEATH_COUNT
UNION SELECT  * FROM
{{ref('QA_VISIT_DATEVDATETIME_COUNT')}} AS QA_VISIT_DATEVDATETIME_COUNT
UNION SELECT  * FROM
{{ref('QA_VISIT_OCCURRENCE_DUPLICATES_COUNT')}} AS QA_VISIT_OCCURRENCE_DUPLICATES_COUNT
UNION SELECT  * FROM
{{ref('QA_VISIT_OCCURRENCE_END_BEFORE_START_COUNT')}} AS QA_VISIT_OCCURRENCE_END_BEFORE_START_COUNT
{#UNION SELECT  * FROM
{{ref('xxx')}} AS QA_VISIT_OCCURRENCE_NOMATCH_COUNT #}
UNION SELECT  * FROM
{{ref('QA_VISIT_OCCURRENCE_NONSTANDARD_COUNT')}} AS QA_VISIT_OCCURRENCE_NONSTANDARD_COUNT
UNION SELECT  * FROM
{{ref('QA_VISIT_OCCURRENCE_NULLCONCEPT_COUNT')}} AS QA_VISIT_OCCURRENCE_NULLCONCEPT_COUNT
UNION SELECT  * FROM
{{ref('QA_VISIT_OCCURRENCE_NULLFK_COUNT')}} AS QA_VISIT_OCCURRENCE_NULLFK_COUNT
UNION SELECT  * FROM
{{ref('QA_VISIT_OCCURRENCE_ZEROCONCEPT_COUNT')}} AS QA_VISIT_OCCURRENCE_ZEROCONCEPT_COUNT 

-- DUP PAT_IDs
UNION SELECT  * FROM
{{ref('QA_AOU_DRIVER_DUPLICATES_COUNT')}} AS QA_AOU_DRIVER_DUPLICATES_COUNT



