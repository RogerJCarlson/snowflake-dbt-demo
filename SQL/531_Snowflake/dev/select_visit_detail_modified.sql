--SELECT
--	visit_detail_id									AS visit_detail_id,
--    person_id						AS person_id,
--	ra,
--    CONVERT(INT, visit_detail_concept_id)			AS visit_detail_concept_id,
--    CONVERT(DATE, visit_start_date)					AS visit_detail_start_date,
--    CONVERT(DATETIME2, visit_start_datetime)		AS visit_detail_start_datetime,
--    CONVERT(DATE, visit_end_date)					AS visit_detail_end_date,
--    CONVERT(DATETIME2, visit_end_datetime)			AS visit_detail_end_datetime,
--    CONVERT(INT, visit_type_concept_id)				AS visit_detail_type_concept_id,
--    NULL											AS provider_id,
--    CONVERT(INT, care_site_id)						AS care_site_id,
--    CONVERT(INT, admitting_source_concept_id)		AS admitted_from_concept_id,
--    CONVERT(INT, discharge_to_concept_id)			AS discharge_to_concept_id,
--	CASE 
--	WHEN ra = 1	THEN NULL
--	ELSE visit_detail_id - 1
--	END												AS preceding_visit_detail_id, -- A foreign key to the VISIT_DETAIL table of the visit immediately preceding this visit
--    CONVERT(VARCHAR(50), visit_source_value)		AS visit_detail_source_value,
--    CONVERT(INT, visit_source_concept_id)			AS visit_detail_source_concept_id,
--    CONVERT(VARCHAR(50), admitting_source_value)	AS admitted_from_source_value,	
--    CONVERT(VARCHAR(50), discharge_to_source_value) AS discharge_to_source_value,		
--	CASE 
--	WHEN ra = 1	THEN visit_detail_id
--	ELSE visit_detail_id - ra + 1
--	END												AS visit_detail_parent_id,
--	visit_occurrence_id								AS visit_occurrence_id,
--	--CASE WHEN SERV_AREA_ID = 50 THEN 'CUMC' 
--	--ELSE 
--	SERV_AREA_NAME  AS FACILITY_ID
--FROM
--(
    SELECT DISTINCT
	  RANK() OVER (PARTITION BY E.PAT_ENC_CSN_ID ORDER BY A.SEQ_NUM_IN_ENC, A.EFFECTIVE_TIME) AS ra,
	  ROW_NUMBER() OVER (ORDER BY E.PAT_ENC_CSN_ID, A.SEQ_NUM_IN_ENC, A.EFFECTIVE_TIME)       AS visit_detail_id,
      E.PAT_ENC_CSN_ID												AS visit_occurrence_id,
      P.AoU_ID 									AS person_id,
--	  CASE 
--		WHEN A.PAT_LVL_OF_CARE_C = 3 THEN 32037			-- ICU
--		WHEN DP.DEPARTMENT_NAME LIKE '%ICU%' THEN 32037	-- ICU
--		WHEN ENC_TYPE_C = 3 AND H.HOSP_ADMSN_TYPE_C = 3 AND ED_DISPOSITION_C = 3 AND H.ADT_PAT_CLASS_C = 101 THEN 262 -- E-I
--		WHEN H.ADT_PAT_CLASS_C=102 THEN	9202			-- Outpatient
--		WHEN H.ADT_PAT_CLASS_C=103 THEN	9203			-- Emergency
--		WHEN H.ADT_PAT_CLASS_C=109 THEN	32036			-- Specimen
--		WHEN H.ADT_PAT_CLASS_C=101 THEN	9201			-- Inpatient
--		WHEN H.ADT_PAT_CLASS_C=106 THEN	9202			-- Hospital Outpatient Surgery
--		WHEN H.ADT_PAT_CLASS_C=108 THEN	9201			-- Surgery Admit
--		WHEN H.ADT_PAT_CLASS_C=107 THEN	9201			-- Newborn
--		WHEN H.ADT_PAT_CLASS_C=129 THEN	9203			-- ED Psych
--		WHEN H.ADT_PAT_CLASS_C=125 THEN	9201			-- Inpatient Psych
--		WHEN H.ADT_PAT_CLASS_C=128 THEN	9201			-- Inpatient Rehab
--		WHEN H.ADT_PAT_CLASS_C=123 THEN	9201			-- Hospice - Inpatient
--		WHEN E.ENC_TYPE_C IN (100311, 100312, 101, 1214)
--									THEN 581477			-- Office visit
--		WHEN E.ENC_TYPE_C = 100315 	THEN 0				-- TELEPHONE SERVICE?
--		WHEN E.ENC_TYPE_C = 121		THEN 0				-- PROCEDURE
--		WHEN E.ENC_TYPE_C = 200		THEN 0				-- NURSE VISIT
--		WHEN E.ENC_TYPE_C = 210		THEN 0				-- Treatment 
--		WHEN E.ENC_TYPE_C = 2501	THEN 32693			-- Evaluation
--		WHEN E.ENC_TYPE_C = 3		THEN 9201			-- HOSPITAL ENCOUNTER
--		WHEN E.ENC_TYPE_C = 309		THEN 0				-- Social Work
--		WHEN E.ENC_TYPE_C = 315		THEN 9201			-- Nutrition
--		WHEN E.ENC_TYPE_C = 320	    THEN 0				-- Anticoag Visit
--		WHEN E.ENC_TYPE_C = 323		THEN 581476			-- Home Visit
--	ELSE 0 END															AS visit_detail_concept_id
       E.ENC_TYPE_C
      ,H.ADT_PAT_CLASS_C
      ,H.HOSP_ADMSN_TYPE_C
      ,DP.DEPARTMENT_NAME
      ,A.PAT_LVL_OF_CARE_C
      
	, CONVERT(DATE, COALESCE(A.EFFECTIVE_TIME, E.CHECKIN_TIME, E.APPT_TIME, E.CONTACT_DATE))					AS visit_start_date
	
	, COALESCE(A.EFFECTIVE_TIME, E.CHECKIN_TIME, E.APPT_TIME, E.CONTACT_DATE)									AS visit_start_datetime
	, CASE 
	    WHEN COALESCE(B.EFFECTIVE_TIME, E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME) IS NOT NULL 
			AND COALESCE(B.EFFECTIVE_TIME, E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME) 
			>= COALESCE(A.EFFECTIVE_TIME, E.CHECKIN_TIME, E.APPT_TIME, E.CONTACT_DATE)
		THEN CONVERT(DATE, COALESCE(B.EFFECTIVE_TIME, E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME))
		WHEN COALESCE(E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME) 
			>= COALESCE(A.EFFECTIVE_TIME, E.CHECKIN_TIME, E.APPT_TIME, E.CONTACT_DATE)
		THEN CONVERT(DATE, COALESCE(E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME)) 
		ELSE NULL
		END																										AS visit_end_date
--	,CASE 
--	    WHEN COALESCE(B.EFFECTIVE_TIME, E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME) IS NOT NULL 
--			AND COALESCE(B.EFFECTIVE_TIME, E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME) 
--			>= COALESCE(A.EFFECTIVE_TIME, E.CHECKIN_TIME, E.APPT_TIME, E.CONTACT_DATE)
--		THEN CONVERT(DATETIME, COALESCE(B.EFFECTIVE_TIME, E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME))
--		WHEN COALESCE(E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME) 
--			>= COALESCE(A.EFFECTIVE_TIME, E.CHECKIN_TIME, E.APPT_TIME, E.CONTACT_DATE)
--		THEN CONVERT(DATETIME, COALESCE(E.HOSP_DISCHRG_TIME, E.CHECKOUT_TIME)) 
--		ELSE NULL
--		END																AS visit_end_datetime  
,B.EFFECTIVE_TIME
,E.HOSP_DISCHRG_TIME
,E.CHECKOUT_TIME
,E.CHECKIN_TIME
,E.APPT_TIME
,E.CONTACT_DATE


    , E.EFFECTIVE_DEPT_ID												AS EFFECTIVE_DEPT_ID


    , CASE
		WHEN PRC_NAME IS NOT NULL THEN CONVERT(VARCHAR(50), DP.DEPARTMENT_NAME + '_' + PRC_NAME)
		WHEN A.ROOM_ID IS NOT NULL AND S.NAME IS NOT NULL THEN 
			DP.DEPARTMENT_NAME + '_' + A.ROOM_ID + '_' + A.BED_ID + '_' + S.NAME
		ELSE CONVERT(VARCHAR(50), DP.DEPARTMENT_NAME) END				    AS visit_source_value


    , H.ADMIT_SOURCE_C													AS ADMIT_SOURCE_C
    , D.DISCH_DISP_C                                                    AS DISCH_DISP_C
--    , CASE
--		--WHEN D.DISCH_DISP_C IN (20, 40, 41, 42 ) OR H.DISCH_DISP_C = 'EXP'			THEN 4216643	-- Patient died
--        WHEN D.DISCH_DISP_C IN (1, 81)  OR H.DISCH_DISP_C = 'HOM'					THEN 8536		-- Home
--		WHEN D.DISCH_DISP_C IN (6, 86)  OR H.DISCH_DISP_C IN ('HH', 'HHS') 			THEN 38004519 	-- Home Health
--		WHEN D.DISCH_DISP_C IN (50, 51)				 								THEN 8546		-- Hospice
--        WHEN D.DISCH_DISP_C IN (3)  OR H.DISCH_DISP_C = 'SNF'						THEN 8863		-- Skilled Nursing Facility
--        WHEN D.DISCH_DISP_C IN (62, 90)  											THEN 8920		-- Rehabilitation Facility
--        WHEN D.DISCH_DISP_C IN (65, 93) OR H.DISCH_DISP_C = 'PSY'					THEN 8971		-- Inpatient Psychiatric Facility 
--        WHEN D.DISCH_DISP_C IN (2, 201, 202, 203, 43, 5, 66, 82, 85, 88, 9, 94)		THEN 8717		-- Inpatient Hospital
--		WHEN D.DISCH_DISP_C IN (4, 205, 84)											THEN 8827		-- Custodial Care Facility
--		WHEN D.DISCH_DISP_C IN (21, 87) OR H.DISCH_DISP_C = 'PRS'					THEN 38003619	-- Prison/Correctional Facility
--		--WHEN D.DISCH_DISP_C IN (7) OR H.DISCH_DISP_C = 'AMA'						THEN 4021968 	-- Patient Self-Discharge Leave Against Medical Advice
--		--WHEN D.DISCH_DISP_C IN (100, 200) 											THEN 4146681 	-- ED DISMISS - NEVER ARRIVED
--       -- WHEN D.DISCH_DISP_C IN (63, 91)												THEN 8970		-- Inpatient Long-term care
--		WHEN D.DISCH_DISP_C IN (206, 64, 83, 92)									THEN 8676		-- Nursing Facility
--		ELSE 0 --44814650 -- No Information
--	END                    												AS discharge_to_concept_id
    , CONVERT(VARCHAR(20), D.NAME)										AS discharge_to_source_value
	, E.SERV_AREA_ID
	, SA.SERV_AREA_NAME									
	FROM  EpicClarity.dbo.PAT_ENC AS E (NOLOCK)
	INNER JOIN [OMOP].[AoU_Driver] P (NOLOCK) ON (P.[Epic_Pat_id] = E.PAT_ID)
	INNER JOIN EpicClarity.dbo.SD_F2F_ENC_TYPE VT (NOLOCK) ON (VT.SD_F2F_ENC_TYPE_C = E.ENC_TYPE_C)
	LEFT JOIN EpicClarity.dbo.CLARITY_SA (NOLOCK) SA ON (SA.SERV_AREA_ID = E.SERV_AREA_ID)
	LEFT JOIN EpicClarity.dbo.PAT_ENC_HSP H (NOLOCK) ON (E.PAT_ENC_CSN_ID = H.PAT_ENC_CSN_ID)
	LEFT JOIN EpicClarity.dbo.CLARITY_ADT A (NOLOCK) ON E.PAT_ENC_CSN_ID = A.PAT_ENC_CSN_ID AND A.EVENT_TYPE_C NOT IN (4, 5, 6) AND A.SEQ_NUM_IN_ENC IS NOT NULL
	JOIN EpicClarity.dbo.CLARITY_ADT B (NOLOCK) ON A.PAT_ID = B.PAT_ID AND A.PAT_ENC_CSN_ID = B.PAT_ENC_CSN_ID AND B.EVENT_TYPE_C IN (2, 4)
		AND B.EVENT_ID IN (A.NEXT_OUT_EVENT_ID)
	LEFT JOIN EpicClarity.dbo.ZC_DISCH_DISP D (NOLOCK) ON (D.DISCH_DISP_C = H.DISCH_DISP_C AND ISNUMERIC(H.DISCH_DISP_C) = 1)
	LEFT JOIN EpicClarity.dbo.ZC_PAT_CLASS PC (NOLOCK) ON (PC.ADT_PAT_CLASS_C = H.ADT_PAT_CLASS_C)
	LEFT JOIN EpicClarity.dbo.CLARITY_DEP DP ON E.EFFECTIVE_DEPT_ID = DP.DEPARTMENT_ID
	LEFT JOIN EpicClarity.dbo.ZC_PAT_SERVICE S ON A.PAT_SERVICE_C = S.HOSP_SERV_C
	LEFT JOIN EpicClarity.dbo.CLARITY_PRC PR ON PR.PRC_ID = E.APPT_PRC_ID
	WHERE ([APPT_STATUS_C] = 2 OR APPT_STATUS_C IS NULL)
		AND (H.ADT_PAT_CLASS_C IS NULL OR H.ADT_PAT_CLASS_C <> 109) --Specimen 
		AND CONVERT(DATE, E.CONTACT_DATE) >= '2015-01-01'	

order by visit_detail_id