--CONDITION_OCCURRENCE_ClarityAMB_ICD

{{ config(materialized = 'view') }}

SELECT DISTINCT SUBSTRING(AOU_DRIVER.AOU_ID, 2, LEN(AOU_DRIVER.AOU_ID))::NUMBER(28,0) AS PERSON_ID
    ,AOU_DRIVER.AOU_ID
    ,PAT_ENC_AMB.PAT_ID
    ,PAT_ENC_AMB.PAT_ENC_CSN_ID
    ,PAT_ENC_AMB.HSP_ACCOUNT_ID
    ,PAT_ENC_AMB.IP_DOC_CONTACT_CSN
    ,PAT_ENC_AMB.ENC_TYPE_C
    ,PAT_ENC_AMB.ZC_DISP_ENC_TYPE_NAME
    ,PAT_ENC_AMB.PAT_OR_ADM_LINK_CSN AS PAT_OR_ADM_LINK_PAT_ENC_CSN_ID
    ,PAT_ENC_AMB.CONTACT_DATE
    ,PAT_ENC_AMB.VISIT_PROV_ID
    ,VISIT_PROVIDER_NAME
    ,VISIT_PROVIDER_TYPE
    ,PAT_ENC_AMB.PCP_PROV_ID
    ,PCP_PROVIDER_NAME
    ,PCP_PROVIDER_TYPE
    ,PRIMARY_DX_YN
    ,T_DIAGNOSIS.DX_ID
    ,T_DIAGNOSIS.DX_NAME
    ,T_DIAGNOSIS.ICD10_CODE
    ,T_DIAGNOSIS.ICD9_CODE
    ,'PULL_CONDITION_OCCURRENCE_CLARITYAMB_ICD' AS ETL_MODULE

FROM  {{ref('AOU_DRIVER')}} AS AOU_DRIVER

INNER JOIN  {{ref('VISIT_OCCURRENCE_CLARITYAMB_ALL')}} AS PAT_ENC_AMB
    ON AOU_DRIVER.EPIC_PAT_ID = PAT_ENC_AMB.PAT_ID

    INNER JOIN   {{ source('CLARITY','PAT_ENC_DX')}} AS PAT_ENC_DX

        ON PAT_ENC_AMB.PAT_ENC_CSN_ID = PAT_ENC_DX.PAT_ENC_CSN_ID

    INNER JOIN  {{ref('T_DIAGNOSIS')}} AS T_DIAGNOSIS
        ON PAT_ENC_DX.DX_ID = T_DIAGNOSIS.DX_ID

WHERE PAT_ENC_AMB.ENC_TYPE_C <> 3