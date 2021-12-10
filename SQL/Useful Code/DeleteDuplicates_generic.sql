
USE SCHEMA SH_OMOP_DB_PROD.OMOP_DEMO
/*
CREATE OR REPLACE TABLE MY_TABLE (
    PK_ID VARCHAR(50) NOT NULL,
    FIRST_NAME VARCHAR(255) NOT NULL,
    LAST_NAME VARCHAR(255),
    BIRTH_DATE DATE NOT NULL,
    CONSTRAINT XPK_SOURCE_TO_CONCEPT_MAP PRIMARY KEY (PK_ID));



INSERT INTO MY_TABLE (PK_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE) 
    VALUES ('10', 'Roger', 'Carlson', '2001-01-01')
        , ('10', 'Roger', 'Carlson', '2001-01-01')
        , ('20', 'Roger', 'Carlson', '2001-01-01')
        , ('30', 'Sam', 'Martin', '2002-02-02')
        , ('40', 'Matt', 'Phad', '2003-03-03')
        , ('50', 'Matt', 'Phad', '2021-11-03');
--


SELECT PK_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE
FROM MY_TABLE;

*/
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--duplicates across ALL COLUMNS
--------------------------------------------------------------------------
--------------------------------------------------------------------------

SELECT PK_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE, COUNT(*) AS ROW_COUNT
FROM OMOP_DEMO.MY_TABLE
GROUP BY PK_ID, FIRST_NAME, LAST_NAME, BIRTH_DATE -- GROUP ALL fields
HAVING ROW_COUNT > 1;
-------------------------

-- IDENTIFY all but one of the duplicated rows
------------------------------------------------------------------------
SELECT  *  
FROM OMOP_DEMO.MY_TABLE    
         QUALIFY ROW_NUMBER () OVER (PARTITION BY PK_ID
                            , FIRST_NAME
                            , LAST_NAME
                            , BIRTH_DATE
                            ORDER BY PK_ID)  > 1; --TO RETURN all but one duplicate records
                         -- ORDER BY PK_ID) = 1; --TO RETURN non-duplicate records
    

-- DELETE all but one of the duplicated rows
------------------------------------------------------------------------
CREATE OR REPLACE TABLE  OMOP_DEMO.MY_TABLE_2   
AS
SELECT  *  
FROM OMOP_DEMO.MY_TABLE    
         QUALIFY ROW_NUMBER () OVER (PARTITION BY PK_ID -- ALL fields
                            , FIRST_NAME
                            , LAST_NAME
                            , BIRTH_DATE
                             ORDER BY PK_ID) = 1; --TO RETURN non-duplicate records 
-- swap                            
ALTER TABLE  OMOP_DEMO.MY_TABLE SWAP WITH OMOP_DEMO.MY_TABLE_2 ; 



------------------------------------------------------------------------
------------------------------------------------------------------------
--duplicates across NON-PRIMARY columns
------------------------------------------------------------------------
------------------------------------------------------------------------  
                          
SELECT FIRST_NAME, LAST_NAME, BIRTH_DATE, COUNT(*) AS ROW_COUNT
FROM OMOP_DEMO.MY_TABLE
GROUP BY FIRST_NAME, LAST_NAME, BIRTH_DATE  -- GROUP non-primary fields
HAVING ROW_COUNT > 1;

-- IDENTIFY all but one of the duplicated rows
------------------------------------------------------------------------
SELECT  *  
FROM OMOP_DEMO.MY_TABLE    
         QUALIFY ROW_NUMBER () OVER (PARTITION BY FIRST_NAME --non KEY fields
                            , LAST_NAME
                            , BIRTH_DATE
--                            ORDER BY PK_ID ASC)  > 1; --TO RETURN duplicate records leaving one records (SMALLEST PK_ID)
--                            ORDER BY PK_ID DESC) > 1; --TO RETURN duplicate records leaving one records (LARGEST PK_ID)
--                            ORDER BY PK_ID ASC) = 1; --TO RETURN non-duplicate records  (SMALLEST PK_ID)
                            ORDER BY PK_ID DESC) = 1; --TO RETURN non-duplicate records  (LARGEST PK_ID)


-- DELETE all but one of the duplicated rows
-- by creating second table
-- then SWAP WITH original table                            
------------------------------------------------------------------------
CREATE OR REPLACE TABLE  OMOP_DEMO.MY_TABLE_2   
AS
SELECT  *  
FROM OMOP_DEMO.MY_TABLE    
         QUALIFY ROW_NUMBER () OVER (PARTITION BY FIRST_NAME --non KEY fields
                            , LAST_NAME
                            , BIRTH_DATE
--                            ORDER BY PK_ID ASC) = 1; --TO RETURN non-duplicate records  (SMALLEST PK_ID)
                            ORDER BY PK_ID DESC) = 1; --TO RETURN non-duplicate records  (LARGEST PK_ID)
                            
ALTER TABLE  OMOP_DEMO.MY_TABLE SWAP WITH OMOP_DEMO.MY_TABLE_2 ;         

