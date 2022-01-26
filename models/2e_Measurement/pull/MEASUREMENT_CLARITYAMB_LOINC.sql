--MEASUREMENT_CLARITYAMB_LOINC

{{ config(materialized = 'view') }}

SELECT PAT_ENC_AMB.PERSON_ID AS PERSON_ID
    ,PAT_ENC_AMB.AOU_ID
    ,PAT_ENC_AMB.PAT_ID
    ,PAT_ENC_AMB.PAT_ENC_CSN_ID
    ,PAT_ENC_AMB.HSP_ACCOUNT_ID
    ,PAT_ENC_AMB.ENC_TYPE_C
    ,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
    ,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
    ,PAT_ENC_AMB.PAT_OR_ADM_LINK_CSN AS PAT_OR_ADM_LINK_PAT_ENC_CSN_ID
    ,ORDER_PROC_2.SPECIMN_TAKEN_TIME
    ,ORDER_PROC.ORDER_TIME
    ,ORDER_RESULTS.ORD_VALUE
    ,ORDER_RESULTS.REFERENCE_LOW
    ,ORDER_RESULTS.REFERENCE_HIGH
    ,LNC_DB_MAIN.LNC_CODE
    ,LNC_DB_MAIN.LNC_COMPON
    ,LNC_DB_MAIN.RECORD_ID
    ,ORDER_RESULTS.REFERENCE_UNIT
    ,ORDER_PROC.AUTHRZING_PROV_ID
    ,AUTH_PROVIDER.PROV_NAME AS AUTH_PROVIDER_NAME
    ,AUTH_PROVIDER.PROV_TYPE AS AUTH_PROVIDER_TYPE
    ,PAT_ENC_AMB.VISIT_PROV_ID
    ,VISIT_PROVIDER_NAME
    ,VISIT_PROVIDER_TYPE
    ,PAT_ENC_AMB.PCP_PROV_ID
    ,PCP_PROVIDER_NAME
    ,PCP_PROVIDER_TYPE
    ,ORDER_PROC.ORDER_PROC_ID
    ,ORDER_RESULTS.COMPON_LNC_ID
    ,ORDER_RESULTS.RESULT_FLAG_C
    ,ZC_RESULT_FLAG.NAME AS ZC_RESULT_FLAG_NAME
    ,ORDER_RESULTS.RESULT_STATUS_C
    ,ZC_RESULT_STATUS.NAME AS ZC_RESULT_STATUS_NAME
    ,ORDER_PROC.ORDER_STATUS_C
    ,ZC_ORDER_STATUS.NAME AS ZC_ORDER_STATUS_NAME
    ,'PULL_MEASUREMENT--CLARITYAMB--LOINC' AS ETL_MODULE

FROM   {{ref('VISIT_OCCURRENCE_CLARITYAMB_ALL')}} AS PAT_ENC_AMB

    INNER JOIN {{ source('CLARITY','ORDER_PROC')}} AS ORDER_PROC
        ON ORDER_PROC.PAT_ENC_CSN_ID = PAT_ENC_AMB.PAT_ENC_CSN_ID

    INNER JOIN {{ source('CLARITY','ORDER_PROC_2')}} AS ORDER_PROC_2
        ON ORDER_PROC.ORDER_PROC_ID = ORDER_PROC_2.ORDER_PROC_ID

    INNER JOIN {{ source('CLARITY','ORDER_RESULTS')}} AS ORDER_RESULTS
        ON ORDER_PROC.ORDER_PROC_ID = ORDER_RESULTS.ORDER_PROC_ID

    LEFT JOIN {{ source('CLARITY','CLARITY_SER')}} AS AUTH_PROVIDER
        ON ORDER_PROC.AUTHRZING_PROV_ID = AUTH_PROVIDER.PROV_ID

    INNER JOIN {{ source('CLARITY','LNC_DB_MAIN')}} AS LNC_DB_MAIN 
        ON ORDER_RESULTS.COMPON_LNC_ID = LNC_DB_MAIN.RECORD_ID

    LEFT JOIN {{ source('CLARITY','ZC_RESULT_FLAG')}} AS ZC_RESULT_FLAG
        ON ORDER_RESULTS.RESULT_FLAG_C = ZC_RESULT_FLAG.RESULT_FLAG_C

    LEFT JOIN {{ source('CLARITY','ZC_RESULT_STATUS')}} AS ZC_RESULT_STATUS
        ON ORDER_RESULTS.RESULT_STATUS_C = ZC_RESULT_STATUS.RESULT_STATUS_C

    LEFT JOIN {{ source('CLARITY','ZC_ORDER_STATUS')}} AS ZC_ORDER_STATUS
        ON ORDER_PROC.ORDER_STATUS_C = ZC_ORDER_STATUS.ORDER_STATUS_C

WHERE (      PAT_ENC_AMB.ENC_TYPE_C <> 3 AND
        ORDER_PROC.ORDER_STATUS_C <> 4 
        )