--T_PROC_CODES

{{ config(materialized='ephemeral') }}

AS (
    SELECT DISTINCT EAP.PROC_ID
        ,EAP.PROC_CODE
        ,EAP.PROC_NAME
    FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EAP AS EAP