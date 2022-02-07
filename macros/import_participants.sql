{%- macro import_participants() -%}

  {%- set query -%}
    REMOVE @CDM.AOU_PARTICIPANTS
  {%- endset -%}
  {%- do run_query(query) -%}

  {%- set query -%}
    PUT 'FILE://X:/ALL OF US/OMOP_WORKING/EXPORT/ALLOFUSPARTICIPANT.CSV' @CDM.AOU_PARTICIPANTS
  {%- endset -%}
  {%- do run_query(query) -%}

  {%- set query -%}
    TRUNCATE TABLE OMOP.ALLOFUSPARTICIPANTS
  {%- endset -%}
  {%- do run_query(query) -%}

  {%- set query -%}
    COPY INTO OMOP.ALLOFUSPARTICIPANTS FROM '@CDM.AOU_PARTICIPANTS/AllOfUSParticipant.csv.gz' FILE_FORMAT = 'CDM.OMOP_CSV_FILE_FORMAT' ON_ERROR = 'ABORT_STATEMENT' PURGE = FALSE;
  {%- endset -%}
  {%- do run_query(query) -%}

{%- endmacro -%}