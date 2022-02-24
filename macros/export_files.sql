 {%- macro export_files() -%}
 
 
  {%- set query -%}
  -- allows multiple statements
    alter session set multi_statement_count = 0
  {%- endset -%}
  {%- do run_query(query) -%}


  {%- set query -%}
  -- import participant list
    REMOVE @AOU_EXPORT/;
    --LIST @AOU_EXPORT/;
    
    --CARE_SITE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/care_site.csv.gz'  FROM 
    (SELECT * FROM  SH_OMOP_DB_PROD.CDM.V_AOU_CARE_SITE 
        ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv') HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    --CONDITION_OCCURRENCE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/condition_occurrence.csv.gz'  FROM 
    ( SELECT * FROM SH_OMOP_DB_PROD.CDM.V_AOU_CONDITION_OCCURRENCE
        ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    --DEATH (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/death.csv.gz'  FROM 
    (SELECT  *    FROM  CDM.V_AOU_DEATH
       ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv' ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
       
    --DEVICE_EXPOSURE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/device_exposure.csv.gz'  FROM 
    (SELECT * FROM CDM.V_AoU_device_exposure
    ) 
    FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
    
    
    --DRUG_EXPOSURE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/drug_exposure.csv.gz'  FROM 
    (SELECT * FROM CDM.V_AoU_drug_exposure
    )
    FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    --LOCATION (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/location.csv.gz'  FROM 
    (SELECT *    FROM CDM.V_AoU_location
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    --MEASUREMENT (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/measurement.csv.gz'  FROM 
    (SELECT  *     FROM  CDM.V_AoU_measurement 
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    --NOTE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/note.csv.gz'  FROM 
    ( SELECT * FROM CDM.V_AoU_note
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --OBSERVATION (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/observation.csv.gz'  FROM 
    ( SELECT *  FROM CDM.V_AoU_observation
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --PERSON (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/person.csv.gz'  FROM 
    (SELECT *  FROM CDM.V_AoU_person
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --PROCEDURE_OCCURRENCE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/procedure_occurrence.csv.gz'  FROM 
    ( SELECT * FROM CDM.V_AoU_procedure_occurrence
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --PROVIDER (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/provider.csv.gz'  FROM 
    (  SELECT  *  FROM CDM.V_AoU_provider
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    --SPECIMEN (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/specimen.csv.gz'  FROM 
    (  SELECT  *  FROM CDM.V_AoU_specimen
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --VISIT_OCCURRENCE (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/visit_occurrence.csv.gz'  FROM 
    ( SELECT * FROM CDM.V_AoU_visit_occurrence
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --VISIT_DETAIL (5.3)
    COPY INTO '@CDM.AOU_EXPORT/dbt/visit_detail.csv.gz'  FROM 
    (SELECT * FROM CDM.V_AoU_visit_detail
    ) FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE;
    
    
    
    --PARTICIPANT_MATCH (PII_VALIDATION) (5.3)
    
    COPY INTO '@AOU_EXPORT/participant_match.csv.gz'  FROM 
    ( SELECT * FROM SH_OMOP_DB_PROD.CDM.V_AOU_PARTICIPANT_MATCH
     )
     FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
    
    --PII_NAME (5.3)
    
    COPY INTO '@AOU_EXPORT/pii_name.csv.gz'  FROM 
    ( SELECT * FROM SH_OMOP_DB_PROD.CDM.V_AOU_PII_NAME 
     )
     FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
            
    --PII_PHONE (5.3)
    
    COPY INTO '@AOU_EXPORT/pii_phone_number.csv.gz'  FROM 
    ( SELECT * FROM SH_OMOP_DB_PROD.CDM.V_AOU_PII_PHONE_NUMBER
    )
    FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
            
    --PII_ADDRESS (5.3)
    
    COPY INTO '@AOU_EXPORT/pii_address.csv.gz'  FROM 
    ( SELECT * FROM CDM.V_AOU_PII_ADDRESS
    )
    FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
            
    --PII_EMAIL (5.3)
    
    COPY INTO '@AOU_EXPORT/pii_email.csv.gz'  FROM 
    ( SELECT * FROM SH_OMOP_DB_PROD.CDM.V_AOU_PII_EMAIL 
     )
     FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
            
    --PII_MRN (5.3)
    
    COPY INTO '@AOU_EXPORT/pii_mrn.csv.gz'  FROM 
    ( SELECT * FROM CDM.V_AOU_PII_MRN 
     )
     FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
            
    --fact_relationship (5.3)
            
    COPY INTO '@AOU_EXPORT/fact_relationship.csv.gz'  FROM 
    ( SELECT * FROM CDM.V_AoU_fact_relationship 
    )
    FILE_FORMAT = (format_name='CDM.AOU_EXPORT_FORMAT'  FILE_EXTENSION = 'csv'  ) HEADER = TRUE MAX_FILE_SIZE = 5000000000 SINGLE = TRUE OVERWRITE = TRUE ;
 
  {%- endset -%}
  {%- do run_query(query) -%}

{%- endmacro -%}