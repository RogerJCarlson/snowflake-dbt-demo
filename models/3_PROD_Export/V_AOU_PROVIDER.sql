--V_AOU_PROVIDER

{{ config(materialized = 'view') }}

    WITH providers_referenced
    AS (
        SELECT PROVIDER_ID
        FROM {{ref('CONDITION_OCCURRENCE')}} AS CONDITION_OCCURRENCE
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('DEVICE_EXPOSURE')}} AS DEVICE_EXPOSURE
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('DRUG_EXPOSURE')}} AS DRUG_EXPOSURE
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('MEASUREMENT')}} AS MEASUREMENT
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('NOTE')}} AS NOTE
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('OBSERVATION')}} AS OBSERVATION
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('PERSON')}} AS PERSON
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('PROCEDURE_OCCURRENCE')}} AS PROCEDURE_OCCURRENCE
        UNION
        SELECT PROVIDER_ID
        FROM {{ref('VISIT_OCCURRENCE')}} AS VISIT_OCCURRENCE
        )
    SELECT provider.provider_id AS "provider_id"
        , provider_name AS "provider_name"
        , NPI AS "npi"
        , DEA AS "dea"
        , specialty_concept_id AS "specialty_concept_id"
        , care_site_id AS "care_site_id"
        , year_of_birth AS "year_of_birth"
        , gender_concept_id AS "gender_concept_id"
        , provider_source_value AS "provider_source_value"
        , specialty_source_value AS "specialty_source_value"
        , specialty_source_concept_id AS "specialty_source_concept_id"
        , gender_source_value AS "gender_source_value"
        , gender_source_concept_id AS "gender_source_concept_id"
    FROM {{ref('PROVIDER')}} AS PROVIDER
    INNER JOIN providers_referenced
        ON providers_referenced.provider_id = provider.provider_id


