--T_CPT_CODES

{{ config(materialized='ephemeral') }}

SELECT DISTINCT EAP.PROC_ID
    ,CASE
        WHEN EAP2.PROC_CODE IS NULL THEN
        EAP.PROC_CODE
        ELSE
        EAP2.PROC_CODE 
    END AS PROC_CODE
    ,CASE
        WHEN EAP2.PROC_NAME IS NULL THEN
        EAP.PROC_NAME
        ELSE
        EAP2.PROC_NAME 
    END AS PROC_NAME

FROM {{ source('CLARITY','CLARITY_EAP')}} AS EAP

LEFT JOIN {{ source('CLARITY','LINKED_PERFORMABLE')}} AS LINKED_PERFORMABLE
    ON EAP.PROC_ID = LINKED_PERFORMABLE.PROC_ID

LEFT JOIN {{ source('CLARITY','CLARITY_EAP')}} AS EAP2
    ON LINKED_PERFORMABLE.LINKED_PERFORM_ID = EAP2.PROC_ID

UNION

SELECT DISTINCT EAP.PROC_ID AS PROC_ID
    ,CASE
        WHEN EAP2.PROC_CODE IS NULL THEN
        EAP.PROC_CODE
        ELSE
        EAP2.PROC_CODE 
    END AS PROC_CODE
    ,CASE
        WHEN EAP2.PROC_NAME IS NULL THEN
        EAP.PROC_NAME
        ELSE
        EAP2.PROC_NAME 
    END AS PROC_NAME

FROM {{ source('CLARITY','CLARITY_EAP')}} AS EAP

LEFT JOIN {{ source('CLARITY','LINKED_CHARGEABLES')}} AS LINKED_CHARGEABLES
    ON EAP.PROC_ID = LINKED_CHARGEABLES.PROC_ID

LEFT JOIN {{ source('CLARITY','CLARITY_EAP')}} AS EAP2
    ON LINKED_CHARGEABLES.LINKED_CHRG_ID = EAP2.PROC_ID