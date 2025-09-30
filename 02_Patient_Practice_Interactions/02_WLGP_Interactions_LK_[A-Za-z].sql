--************************************************************************************************
-- Script:        02_WLGP_Interactions_LK_[A-Za-z].sql
-- About:         Assign assign care provider, access level and interaction type/detail - this script
--                covers chapter [A-Z] and [a-z] Read V2 & Vision codes + those EMIS codes whose
--                parent's code is a chapter [A-Z,a-z] Read code
-- Author:        Hoda Abbasizanjani
-- Date:          2025

-- ***********************************************************************************************
-- ***********************************************************************************************
-- Definitions:
-- Care provider: Primary care, Secondary care, Community, Unidentifiable
-- Access mode: F2F, Remote, Clinical data with unmatched access mode, Admin related data, Currently cannot be assigned
-- Interaction type: F2F -> In-practice visit, Immunisation/Vaccination, Dental service, Pharmacy visit, Home visit
--                   Remote -> Phone call with patient, Letter/email/SMS, Other remote interactions
--                   Clinical data with unmatched access mode -> Clinical activities
--                   Admin related data -> Patient admin data, Other admin data
-- ***********************************************************************************************
-- Assign access mode and interaction type/detail for Chapters A-Z
-- ***********************************************************************************************
-- Chapters A-Q (Diagnosis)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Diagnosis',
    applied_rule = 'Chapters A-Q - Diagnosis'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND regexp_like(code, '^[A-Q]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Diagnosis',
    applied_rule = 'EMIS - Chapters A-Q - Diagnosis'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND regexp_like(emis_parent, '^[A-Q]');

--------------------------------------------------------------------------------------------------
-- Chapter R ([D]Symptoms, signs and ill-defined conditions)
--------------------------------------------------------------------------------------------------
-- History or symptoms
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'History or symptoms',
    applied_rule = 'Chapter R - History or symptoms'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (regexp_like(code, '^R[0,1,3,z]') OR code LIKE 'Ryu%');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'History or symptoms',
    applied_rule = 'EMIS - Chapter R - History or symptoms'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (regexp_like(emis_parent, '^R[0,1,3,z]') OR emis_parent LIKE 'Ryu%');

--R0...   [D]Symptoms
--R1...   [D]Nonspecific abnormal findings
--R3...   [D]Specific abnormal findings
--Ryu..   [X]Additional symptom, signs and abnormal clinical and laboratory findings classification terms
--Rz...   [D]Symptoms, signs and ill-defined conditions NOS

--------------------------------------------------------------------------------------------------
-- Other clinical documentation
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter R - LOther clinical documentation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'R2%';

--R2...   [D]Cause of morbidity and mortality unsure and ill-DEFINED

--------------------------------------------------------------------------------------------------
-- Observed symptoms
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'Chapter R - Observation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,3) IN ('R01', 'Ry1');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'EMIS - Chapter R - Observation'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND LEFT(emis_parent,3) IN ('R01', 'Ry1');

--R01..   [D]Nervous and musculoskeletal symptoms
--Ry1..   [D]Symptoms and signs involving appearance and behaviour

--------------------------------------------------------------------------------------------------
-- Chapter S (Injury and poisoning)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'Chapter S - Injury and poisoning'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'S%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'EMIS - Chapter S - Injury and poisoning'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE 'S%';

--------------------------------------------------------------------------------------------------
-- Chapter T (Causes of injury and poisoning)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter T - Causes of injury and poisoning'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'T%';

--------------------------------------------------------------------------------------------------
-- Chapter U ([X]External causes of morbidity and mortality)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter U - External causes of morbidity and mortality'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'U%';

--------------------------------------------------------------------------------------------------
-- Chapter Z (Unspecified conditions - No EMIS code)
--------------------------------------------------------------------------------------------------
-- Maternal or child health
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Maternal or child health',
    applied_rule = 'Chapter Z - Maternal or child health'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^ZV[2,3]') OR code LIKE 'ZVu2%');

--ZV2..   [V]Encounter due to reproduction and development problems
--ZV3..   [V]Healthy liveborn infants according to type of birth
--ZVu2.   [X]Persons encountering health services in circumstances related to reproduction

--------------------------------------------------------------------------------------------------
-- History or symptoms
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'History or symptoms',
    applied_rule = 'Chapter Z - History or symptoms'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^ZV[1,4]') OR code LIKE 'ZVu1%');

--ZV1..   [V]Potential health hazards related to personal history (PH) and family history (FH)
--ZV4..   [V]Persons with a condition influencing their health status
--ZVu1.   [X]Persons with potential health hazards related to communicable diseases

--------------------------------------------------------------------------------------------------
-- Other clinical documentation
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter Z - Other clinical documentation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^ZV[0,6,y,z]') OR REGEXP_LIKE(code, '^ZVu[3-6]'));

--ZV0..   [V]Persons with potential health hazards related to communicable diseases
--ZV6..   [V]Other reasons for encounter
--ZVu3.   [X]Persons encountering health services for specific procedures and health care
--ZVu4.   [X]Persons with potential health hazards related to socioeconomic and psychosocial circumstances
--ZVu5.   [X]Persons encountering health services in other circumstances
--ZVu6.   [X]Persons with potential health hazards related to family and personal history and certain conditions influencing the health status
--ZVy..   [V]Other specified reasons for encounter
--ZVz..   [V]Unspecified reasons for encounter

--------------------------------------------------------------------------------------------------
-- Secondary care related codes
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter Z - Specified procedures and aftercare'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'ZV5%';

--ZV5..   [V]Specified procedures and aftercare

--------------------------------------------------------------------------------------------------
-- Other admin data
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Other admin data',
    applied_rule = 'Chapter Z - Other admin data'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'Zw%';

--Zw...   [Q] Temporary qualifying terms

--------------------------------------------------------------------------------------------------
-- Other F2F interactions
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'Chapter Z - Administrative encounters'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'ZV68%';

--ZV68.   [V]Administrative encounters

--------------------------------------------------------------------------------------------------
-- F2F (examination or sign, observation, screening)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = CASE WHEN LEFT(code, 4) IN ('ZV70', 'ZV72', 'ZVu0', 'ZV67', 'ZV6B') THEN 'Examination or sign'
                                   WHEN code LIKE 'ZV71%' THEN 'Observation'
                                   ELSE 'Screening' END,
    applied_rule = 'Chapter Z - F2F - Examination/observation/screening'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (LEFT(code, 4) IN ('ZV67', 'ZV6B',  'ZVu0') OR code LIKE 'ZV7%');

-- F2F
--ZV67.   [V]Follow-up examination
--ZV6B.   [V]Follow-up examination after treatment for conditions other than malignant neoplasms
--ZV7..   [V]Well persons examination, investigation and screening
--ZVu0.   [X]Persons encountering health services for examination and investigation

-- Examination or sign
--ZV70.   [V]General medical examination
--ZV72.   [V]Special investigations and examinations
--ZVu0.   [X]Persons encountering health services for examination and investigation
--ZV67.   [V]Follow-up examination
--ZV6B.   [V]Follow-up examination after treatment for conditions other than malignant neoplasms

--Observation
--ZV71.   [V]Observation and evaluation for suspected conditions

-- Any other code like 'ZV7%' is related to 'Screening'

--------------------------------------------------------------------------------------------------
-- Vaccination
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Immunisation/vaccination',
    applied_rule = 'Chapter Z - Immunisanion/vaccination'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'ZV06%';

--ZV06.   [V]Combined disease vaccination and inoculation

--------------------------------------------------------------------------------------------------
-- Chapter Z (Other Read or Vision)
--------------------------------------------------------------------------------------------------
-- Advice or counselling
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Counselling or health education/promotion',
    applied_rule =  'Other Read or Vision - Advice'
WHERE code_type IN ('Other Read or Vision')
AND regexp_like(code, '^Z[4G]');

--Z4...   Counselling
--ZG...   Advice

--------------------------------------------------------------------------------------------------
-- Pregnancy, childbirth and puerperium observations
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Maternal or child health',
    applied_rule =  'Other Read or Vision - Maternal or child health'
WHERE code_type IN ('Other Read or Vision')
AND regexp_like(code, '^Z[23]');

--Z2...   Pregnancy, childbirth and puerperium observations
--Z3...   Child health procedures

--------------------------------------------------------------------------------------------------
-- Observation
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule =  'Other Read or Vision - Observation'
WHERE code_type IN ('Other Read or Vision')
AND regexp_like(code, '^Z[8EF]');

--Z8...   Ability to perform personal care activity
--ZE...   Audiological observations
--ZF...   Audiological test observations

--------------------------------------------------------------------------------------------------
-- Sub-chapter ZC (Nutrition)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = CASE WHEN REGEXP_LIKE(code_description, 'advice', 'i') THEN 'Counselling or health education/promotion'
                                   WHEN REGEXP_LIKE(code_description, 'supplementation|prescribe', 'i') THEN 'Drug therapy or prescription'
                                   ELSE 'Other clinical documentation' END,
    applied_rule =  'Other Read or Vision - sub-chapter ZC'
WHERE code_type IN ('Other Read or Vision')
AND code like 'ZC%';

--ZC...   Nutrition

--------------------------------------------------------------------------------------------------
-- Sub-chapter ZL (Administrative statuses) -- genela rule
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule =  'Other Read or Vision - sub-chapters ZL - general rule'
WHERE code_type IN ('Other Read or Vision')
AND code like 'ZL%';

--ZL...   Administrative statuses

--------------------------------------------------------------------------------------------------
-- Sub-chapter ZLA (Seen by nurse)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule =  'Other Read or Vision - sub-chapters ZLA'
WHERE code_type IN ('Other Read or Vision')
AND code like 'ZLA%';

--ZLA..   Seen by nurse

--------------------------------------------------------------------------------------------------
-- Sub-chapters ZL[5-8] (Referral)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Referral',
    applied_rule =  'Other Read or Vision - sub-chapters ZL[5-8] referrals'
WHERE code_type IN ('Other Read or Vision')
AND regexp_like(code, '^ZL[5-8]');

--ZL5..   Referral to doctor
--ZL6..   Referral to nurse
--ZL7..   Referral to health worker
--ZL8..   Referral to professional allied to medicine

--------------------------------------------------------------------------------------------------
-- Sub-chapters ZR & AQ (Assessment regimes & assessment scales)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Screening or assessment',
    applied_rule =  'Other Read or Vision - sub-chapters ZQ & ZR'
WHERE code_type IN ('Other Read or Vision')
AND regexp_like(code, '^Z[QR]');

--ZQ...   Assessment regimes
--ZR...   Assessment scales

--------------------------------------------------------------------------------------------------
-- Patient sociodemographic or registration data
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Patient sociodemographic or registration data',
    applied_rule =  'Other Read or Vision - Patient demographic data'
WHERE code_type IN ('Other Read or Vision')
AND code LIKE 'ZU%';

--ZU...   Family details and household composition

-- ***********************************************************************************************
-- Assign access mode and interaction type/detail for chapters a-z (Prescribed items)
-- ***********************************************************************************************
-- Chapters a-m (Medications)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Drug therapy or prescription',
    applied_rule = 'Chapters a-m - Medications and appliances'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND regexp_like(code, '^[a-m]');

-- No EMIS codes

--------------------------------------------------------------------------------------------------
-- Chapter n (Immunology drugs and vaccines)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Immunisation/vaccination',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter n - Immunisanion/vaccination'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE 'n%'
AND NOT regexp_like(code, '^n[1-3,6,7]');

-- No EMIS codes

--------------------------------------------------------------------------------------------------
-- Chapters p-s (Medication and appliance)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Drug therapy or prescription',
    applied_rule = 'Chapters p-s - Medications and appliances'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND regexp_like(code, '^[p-s]');

-- No EMIS codes
