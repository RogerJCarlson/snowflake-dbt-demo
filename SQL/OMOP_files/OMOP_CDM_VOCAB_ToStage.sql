-- load vocabulary files to OMOP internal stage

USE DATABASE SH_OMOP_DB_PROD;
USE SCHEMA OMOP;
USE ROLE SF_SH_OMOP_DEVELOPER;
USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;

--LIST @omop.OMOP_VOCABULARIES;
-- this replaces all of the below
REMOVE @OMOP_VOCABULARIES;
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/*.csv' @OMOP_VOCABULARIES;
put 'file://C:/SVN/SSIS/OMOP/aou_omop/SQL/OMOP_files/OMOP_vocabulary_load_current/*.csv' @OMOP_VOCABULARIES;

--REMOVE @OMOP_VOCABULARIES/CONCEPT.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/CONCEPT.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/CONCEPT.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--REMOVE @omop_vocabularies/CONCEPT_ANCESTOR.csv.gz;
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/CONCEPT_ANCESTOR.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/CONCEPT_ANCESTOR.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--REMOVE @OMOP_VOCABULARIES/CONCEPT_CLASS.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/CONCEPT_CLASS.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/CONCEPT_CLASS.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--
--REMOVE @OMOP_VOCABULARIES/CONCEPT_RELATIONSHIP.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/CONCEPT_RELATIONSHIP.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/CONCEPT_RELATIONSHIP.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--
--REMOVE @OMOP_VOCABULARIES/CONCEPT_SYNONYM.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/CONCEPT_SYNONYM.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/CONCEPT_SYNONYM.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--
--REMOVE @OMOP_VOCABULARIES/DOMAIN.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/DOMAIN.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/DOMAIN.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--
--REMOVE @OMOP_VOCABULARIES/DRUG_STRENGTH.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/DRUG_STRENGTH.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/DRUG_STRENGTH.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--
--REMOVE @OMOP_VOCABULARIES/RELATIONSHIP.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/RELATIONSHIP.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/RELATIONSHIP.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;
--
--
--REMOVE @OMOP_VOCABULARIES/VOCABULARY.csv.gz; 
--put 'file://X:/All of Us/OMOP_Working/OMOP files/OMOP_vocabulary_load_current/VOCABULARY.csv' @OMOP_VOCABULARIES;
----select t.$1, t.$2, t.$3, t.$4, t.$5, t.$6, t.$7, t.$8 from @OMOP_VOCABULARIES/VOCABULARY.csv.gz (file_format => 'OMOP.OMOP_VOCAB_FORMAT') t;















