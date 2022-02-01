--Structure: (if your structure is different, you will have to modify the code to match)
--    Databases:SH_OMOP_DB_PROD, SH_CLINICAL_DB_PROD
--    Schemas: SH_OMOP_DB_PROD.OMOP_CLARITY, SH_OMOP_DB_PROD.CDM, SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ

--USE ROLE SF_SH_OMOP_DEVELOPER;
----USE SCHEMA SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ;
--USE WAREHOUSE SH_OMOP_DATA_SCIENCE_WH;


CREATE OR REPLACE TABLE SH_OMOP_DB_PROD.OMOP_CLARITY.PROVIDER_Clarity_ALL 
AS  

SELECT DISTINCT CLARITY_SER.PROV_ID 

, CLARITY_SER.PROV_NAME 
, TRY_TO_NUMBER (CLARITY_SER.PROV_ID, '9999999999' ,38,0) AS TRYTONUMBER
, CLARITY_SER_2.NPI AS NPI
, DEA_NUMBER AS DEA
, ZC_SPECIALTY.SPECIALTY_C
, ZC_SPECIALTY.NAME AS ZC_SPECIALTY_NAME
, REV_LOC_ID    
, BIRTH_DATE
, CLARITY_SER.PROV_TYPE
, CLARITY_SER.SEX_C    
, ZC_SEX.NAME AS ZC_SEX_NAME 

--INTO SH_OMOP_DB_PROD.PROVIDER_Clarity_ALL
FROM SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER
    LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_EMP
        ON CLARITY_SER.PROV_ID = CLARITY_EMP.PROV_ID
        
    LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_DEP
        ON CLARITY_EMP.LGIN_DEPARTMENT_ID = CLARITY_DEP.DEPARTMENT_ID
        
    LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_SEX
        ON ZC_SEX.RCPT_MEM_SEX_C = CLARITY_SER.SEX_C
  
    LEFT JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.CLARITY_SER_2
        ON CLARITY_SER.PROV_ID = CLARITY_SER_2.PROV_ID

    LEFT OUTER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.D_PROV_PRIMARY_HIERARCHY
        ON CLARITY_SER.PROV_ID = D_PROV_PRIMARY_HIERARCHY.PROV_ID
        
    LEFT OUTER JOIN SH_CLINICAL_DB_PROD.EPIC_CLARITY_LZ.ZC_SPECIALTY
            ON D_PROV_PRIMARY_HIERARCHY.SPECIALTY_C = ZC_SPECIALTY.SPECIALTY_C
            
 
where   UPPER(CLARITY_SER.PROV_TYPE) not in('RESOURCE','LABORATORY')
--AND ISNUMERIC(CLARITY_SER.PROV_ID)=1  
--AND TRY_CAST (CLARITY_SER.PROV_ID AS NUMBER) <> 0 
AND TRY_TO_NUMBER (CLARITY_SER.PROV_ID, '9999999999',38,0) IS NOT NULL 


                        