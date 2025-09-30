--************************************************************************************************
-- Script:        03_WLGP_Interactions_LK_Others.sql
-- About:         Assign assign care provider, access level and interaction type/detail - this script
--                covers EMIS categories and rules implemented based on code description
--                based on description of codes
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
-- EMIS categories
-- ***********************************************************************************************
-- Assigning access mode and interaction type based on EMIS categories:
-- For those codes that are already assigned based on their parent code, if access mode based on
-- EMIS category is F2F, then 'access_mode' is overwritten. Also if Interaction type is one of
-- known types, then 'interaction_type' and 'interaction_type_detail' will be replaced with the
-- known type.
--------------------------------------------------------------------------------------------------
-- Patient demographic data
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Patient sociodemographic or registration data',
    applied_rule = 'EMIS - Patient demographic data'
WHERE code_type = 'EMIS'
AND emis_category IN ('Ethnicity', 'Nationality', 'Marital status', 'Regiment', 'Religion', 'Trade/Branch');

--------------------------------------------------------------------------------------------------
-- Dental service
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Dental service',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Dental service'
WHERE code_type = 'EMIS'
AND emis_category IN ('Dental disorder', 'Dental finding', 'Dental procedure',
                      'Planned dental intervention', 'Body structure');

--------------------------------------------------------------------------------------------------
-- Radiology
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Radiology/physics in medicine'
WHERE code_type = 'EMIS'
AND emis_category = 'Radiology'
AND NOT REGEXP_LIKE(code_description, 'requested|refused|not|awaited|declined', 'i');

--------------------------------------------------------------------------------------------------
-- Lab procedures or results
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Laboratory test request or result',
    applied_rule = 'EMIS - Lab test request/result'
WHERE code_type IN ('EMIS')
AND (emis_category IN ('Cytology', 'Histology', 'Biochemistry', 'Microbiology', 'Immunology', 'Pathology specimen', 'Investigation requests')
     OR code IN ('EMISNQWC8')
    );

-- EMISNQWC8   WCCG pathology request receipt
-- EMISREQ|42B6.   Test request : ESR

--------------------------------------------------------------------------------------------------
-- Allergy
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'History or symptoms',
    applied_rule = 'EMIS - Allergy and adverse reactions'
WHERE code_type IN ('EMIS')
AND emis_category IN ('Allergy and adverse drug reactions', 'Allergy and adverse reactions');

--------------------------------------------------------------------------------------------------
-- Biological values (e.g. BP readings)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'EMIS - Biological values'
WHERE code_type IN ('EMIS')
AND emis_category IN ('Biological values');

--------------------------------------------------------------------------------------------------
-- Prescribed items
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Drug therapy or prescription',
    applied_rule = 'EMIS - prescription'
WHERE code_type IN ('Other EMIS')
AND (code LIKE 'DEGRADE%'
     OR REGEXP_LIKE(code_description, 'grams|Tablet|Capsule|Ointment|Pills|Lotion|Powder|Cream |Injection', 'i')
     OR REGEXP_LIKE(code_description, 'Liquid|Oil|Gel|Dressing|drops|Bandage|Balm|Catheter|cm x|', 'i')
     )
AND NOT REGEXP_LIKE(code_description, 'Test Request', 'i');

--------------------------------------------------------------------------------------------------
-- Vaccination
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Immunisation/vaccination',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Immunisanion/vaccination'
WHERE code_type IN ('EMIS', 'Other EMIS')
AND REGEXP_LIKE(code_description, 'vaccine|vaccination', 'i')
AND REGEXP_LIKE(code_description, 'administration| dose', 'i')
AND NOT REGEXP_LIKE(code_description, 'Did not attend|not given|declined', 'i');

--------------------------------------------------------------------------------------------------
-- Referral
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Referral',
    applied_rule = 'EMIS - Referral'
WHERE code_type IN ('EMIS', 'Other EMIS')
AND emis_category = 'Referral'
AND NOT REGEXP_LIKE(code_description, 'discharge', 'i');

--------------------------------------------------------------------------------------------------
-- Other EMIS categories
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = CASE WHEN access_mode IS NULL THEN 'Clinical data with unmatched access mode' ELSE access_mode END,
    interaction_type = CASE WHEN interaction_type IS NULL THEN 'Clinical activities' ELSE interaction_type END,
    interaction_type_detail = CASE WHEN interaction_type IS NULL THEN 'Other clinical documentation' ELSE interaction_type_detail END,
    applied_rule = CASE WHEN applied_rule IS NULL THEN 'EMIS - Other clinical documentation' ELSE applied_rule END
WHERE code_type IN ('EMIS')
AND emis_category IN ('Immunisations', 'Care episode outcome', 'Personal Health and Social',
                      'Family history', 'Health management, screening and monitoring',
                      'Reason for care', 'Intervention target', 'Care episode outcome',
                      'Problem rating scale for outcomes');

-- ***********************************************************************************************
-- Additional rules formulated based on text search
-- ***********************************************************************************************
-- Community health services
-- ***********************************************************************************************
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Community',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Text search - community'
WHERE REGEXP_LIKE(code_description, 'by community|community dental service', 'i');

-- ***********************************************************************************************
-- Pharmacy health services
-- ***********************************************************************************************
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Pharmacy',
    interaction_type_detail = NULL,
    applied_rule = 'Text search - pharmacy'
WHERE REGEXP_LIKE(code_description, 'by pharmacist|Pharmacy managed|by pharmacy|by clinical pharmacist', 'i')
AND NOT REGEXP_LIKE(code_description, 'vaccin', 'i');

-- ***********************************************************************************************
-- Dental service
-- ***********************************************************************************************
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Dental service',
    interaction_type_detail = NULL,
    applied_rule = 'Text search - dental service'
WHERE (REGEXP_LIKE(code_description, 'by dentist|by paediatric dentist|by restorative dentist', 'i')
OR REGEXP_LIKE(code_description, 'dental clearance|dental extraction|dental filling|dental crown|dental injection|dental swab|dental treatment', 'i'))
AND NOT REGEXP_LIKE(code_description, 'reffered to dental|adverse reaction|community', 'i')
AND NOT REGEXP_LIKE(code, '^[a-z]')
AND access_mode != 'F2F';

-- ***********************************************************************************************
-- Remote interactions
-- ***********************************************************************************************
-- Telehealth
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Other remote interactions',
    interaction_type_detail = NULL,
    applied_rule = 'Text search - Telehealth'
WHERE REGEXP_LIKE(code_description, 'telehealth|tlhlth|telh', 'i')
AND NOT REGEXP_LIKE(code_description, 'referral to|declined|not appr', 'i');

--------------------------------------------------------------------------------------------------
-- Telephone call
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Phone call with patient',
    interaction_type_detail = NULL,
    applied_rule = 'Text search - Telephone encounter'
WHERE REGEXP_LIKE(code_description, 'tel adv|telephone|phone call|advice line call', 'i')
AND NOT REGEXP_LIKE(code_description, 'number|use|planned|able|ability|difficulty|activities', 'i')
AND NOT REGEXP_LIKE(code_description, 'provision|decline|require|consent|community|failed|unsuccessful|no.', 'i')
AND code NOT LIKE '0%' AND code NOT LIKE '1%'
AND code NOT LIKE '0%'
AND code NOT LIKE '1%';

-- ***********************************************************************************************
-- F2F interactions
-- ***********************************************************************************************
-- Examination or sign
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'Text search - F2F interactions'
WHERE (REGEXP_LIKE(code_description, 'BP reading|blood pressure reading|verbal consent for examination', 'i') AND code NOT LIKE '2%')
OR REGEXP_LIKE(code_description, 'child exam', 'i');

--------------------------------------------------------------------------------------------------
-- The following are consultations but as no specific info is avaiable within the description,
-- these are categorise as observation!
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'Text search - seen by gp or nurse'
WHERE REGEXP_LIKE(code_description, 'seen by gp|seen by nurse|seen by assistant gp|seen by associate gp|seen by deputising gp|seen by locum doctor|seen by partner of gp|seen by gp locum', 'i')
OR REGEXP_LIKE(code_description, 'seen in primary care|seen prim car|seen in gp|seen in general practitioner|seen gp|out of hours consultation', 'i')
OR (REGEXP_LIKE(code_description, 'Chaperone', 'i') AND NOT REGEXP_LIKE(code_description, 'not avaiable', 'i'));

--------------------------------------------------------------------------------------------------
-- Other F2F interactions within practice setting
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'Text search - F2F interactions'
WHERE access_mode NOT IN ('F2F')
AND (REGEXP_LIKE(code_description, 'verb invit|verbal invite|verbal inv|verbal advice|vrbl invtn', 'i')
     OR REGEXP_LIKE(code_description, 'signed by patient', 'i')
     );

-- ***********************************************************************************************
-- Failed encounter
-- ***********************************************************************************************
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Other admin data',
    interaction_type_detail = 'Failed encounter',
    applied_rule = 'Text search - patient did not attend'
WHERE REGEXP_LIKE(code_description, 'did not attend|DNA-|DNA -|not attended|not replied|not reached', 'i')
AND NOT REGEXP_LIKE(code_description, 'test request', 'i');

-- ***********************************************************************************************
-- Other activities with unmatched access mode
-- ***********************************************************************************************
-- Laboratory test request or result
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Laboratory test request or result',
    applied_rule = 'Text search - test result'
WHERE access_mode IS NULL -- Excluding chapter 5
AND (REGEXP_LIKE(code_description, 'test normal|result borderline|screen normal|result normal', 'i')
     OR REGEXP_LIKE(code_description, 'test abnormal|test result unclear|screen abnormal|result abnormal', 'i')
    );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Laboratory test request or result',
    applied_rule = 'Text search - External EMIS - test request'
WHERE access_mode IS NULL
AND code_type = 'Other EMIS'
AND code LIKE 'OLT%'
AND REGEXP_LIKE(code_description, 'test request', 'i');

-- ***********************************************************************************************
-- Additional COVID-19 codes
-- ***********************************************************************************************
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Diagnosis',
    applied_rule = 'Text search - Disease caused by 2019-nCoV'
WHERE REGEXP_LIKE(code_description, 'caused by 2019-nCoV', 'i');
