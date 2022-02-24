--   V_AOU_PARTICIPANT_MATCH

{{ config(materialized = 'view') }}


SELECT PID AS "person_id"
      ,first_name AS "first_name"
      ,last_name AS "last_name"
      ,DOB AS "dob"
      ,sex AS "sex"
      ,address AS "address"
      ,phone_number AS "phone_number"
      ,email AS "email"
      ,algorithm_validation AS "algorithm_validation"
      ,Manual_Validation AS "manual_validation"
  FROM 
  {{ref('AOU_PII_VALIDATION')}} AS AOU_PII_VALIDATION