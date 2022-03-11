 {%- macro append_er_log_history() -%}

{%- set query -%}

--QA_LOG_HISTORY_DBT
--clear current date records from QA_LOG_HISTORY_DBT
DELETE
 FROM OMOP_QA.QA_LOG_HISTORY_DBT
WHERE  run_date IN (Select run_date from OMOP_QA.QA_LOG_DBT);

{%- endset -%}
{%- do run_query(query) -%}


{%- set query -%}
  INSERT INTO OMOP_QA.QA_LOG_HISTORY_DBT
            (Run_date, Standard_Data_Table, QA_Metric, Metric_field, QA_Errors, Error_Type, Total_Records)
  SELECT     Run_date, Standard_Data_Table, QA_Metric, Metric_field, QA_Errors, Error_Type, Total_Records
  FROM      OMOP_QA.QA_LOG_DBT

  {%- endset -%}
  {%- do run_query(query) -%}

{%- endmacro -%}