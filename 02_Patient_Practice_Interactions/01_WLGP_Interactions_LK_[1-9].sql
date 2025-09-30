--************************************************************************************************
-- Script:        01_WLGP_Interactions_LK_[1-9].sql
-- About:         Create a look up table of primary care clinical codes and assign care provider,
--                access level and interaction type/detail - this script covers chapter 0-9 Read V2
--                & Vision codes + those EMIS codes whose parent's code is a chapter 0-9 Read code
-- Author:        Hoda Abbasizanjani
-- Date:          2025

-- ***********************************************************************************************
-- ***********************************************************************************************
-- Definitions:
-- Care provider: Primary care, Secondary care, Community, Currently cannot be assigned
-- Access mode: F2F, Remote, Clinical data with unmatched access mode, Admin related data, Currently cannot be assigned
-- Interaction type: F2F -> In-practice visit, Immunisation/Vaccination, Dental service, Pharmacy visit, Home visit
--                   Remote -> Phone call with patient, Letter/email/SMS, Other remote interactions
--                   Clinical data with unmatched access mode -> Clinical activities
--                   Admin related data -> Patient admin data, Other admin data
-- ***********************************************************************************************
-- Create a copy of the WLGP RRDA clinical code LK & add columns for access mode & interaction type
-- ***********************************************************************************************
CREATE TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION LIKE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_ALL;

ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD care_provider char(30) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD access_mode char(60) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD interaction_type char(30) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD interaction_type_detail char(60) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD applied_rule char(70) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD emis_category char(50) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD emis_parent char(40) NULL;
ALTER TABLE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION ADD emis_parent_readv2 smallint NULL;

INSERT INTO SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION (code_id, code, code_description, sensitive, code_type, code_source)
    SELECT *
    FROM SAILW1151V.RRDA_WLGP_CLINICAL_CODES_ALL
    WHERE code_type IN ('Read V2', 'Vision', 'EMIS');

-----------------------------------------------------------------------------------------
-- Add EMIS category and parent code
-- Only avaiable for code_type = 'EMIS' (not for codes of type 'Other EMIS')
-----------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION l
SET emis_category = categorydescription,
    emis_parent = parentcode
FROM SAILW1151V.EMIS_CODES_SENSITIVE_VS_NONSENSITIVE e
WHERE code_type = 'EMIS'
AND l.code = e.code;

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION l
SET emis_parent_readv2 = 1
FROM (SELECT DISTINCT TRIM(TRAILING '.' FROM read_code) AS code
      FROM SAILUKHDV.READ_CD_CV2_SCD
     ) c
WHERE l.emis_parent = c.code;

-- ***********************************************************************************************
-- Assign access mode and interaction type/detail for chapters 1-9
-- ***********************************************************************************************
-- Chapter 0 - Patient's characteristics
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Patient sociodemographic or registration data',
    applied_rule = 'Chapter 0 - Patient demographic data'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '0%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Patient sociodemographic or registration data',
    applied_rule = 'EMIS - Chapter 0 - Patient demographic data'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '0%';

--------------------------------------------------------------------------------------------------
-- Chapter 1 - History or symptoms
--------------------------------------------------------------------------------------------------
-- Clinical data in chapter 1
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'History or symptoms',
    applied_rule = 'Chapter 1 - History or symptoms'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '1%'
AND code NOT LIKE '1z%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'History or symptoms',
    applied_rule = 'EMIS - Chapter 1 - History or symptoms'
WHERE code_type IN ('EMIS', 'Other EMIS')
AND emis_parent_readv2 = 1
AND emis_parent LIKE '1%'
AND emis_parent NOT LIKE '1z%';

--1z...  Read Code Administration

--------------------------------------------------------------------------------------------------
-- Admin related data in chapter 1
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = CASE WHEN code LIKE '1z%' THEN 'Other admin data'
                       ELSE 'Patient admin data' END,
    interaction_type_detail = CASE WHEN code NOT LIKE '1z%' THEN 'Patient sociodemographic or registration data'
                              ELSE NULL END,
    applied_rule = 'Chapter 1 - Admin related data'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^1[K,b,z]') OR REGEXP_LIKE(code, '^13[1-5,D-F,H-K,N-X,Z,b,d,e-h,j-l,n,q,s-w,y,z]'));

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = CASE WHEN emis_parent LIKE '1z%' THEN 'Other admin data'
                       ELSE 'Patient admin data' END,
    interaction_type_detail = CASE WHEN emis_parent NOT LIKE '1z%' THEN 'Patient sociodemographic or registration data'
                              ELSE NULL END,
    applied_rule = 'EMIS - Chapter 1 - Admin related data'
WHERE code_type IN ('EMIS', 'Other EMIS')
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^1[K,b,z]') OR REGEXP_LIKE(emis_parent, '^13[1-5,D-F,H-K,N-X,Z,b,d,e-h,j-l,n,q,s-w,y,z]'));
/*
131..   Occupation of spouse
132..   Social roup
133..   Personal status
134..   Country of origin
135..   Religion
13D..   Housing lack
13E..   Inadequate housing
13F..   Housing dependency scale
13H..   Personal milestones
13I..   Family milestones
13J..   Employment milestones
13K..   Economic milestones
13N..   Risk activity involvement
13O..   Sickness/invalidity benefit
13P..   Retirement pensions
13Q..   Widows benefits
13R..   Unemployment benefits
13S..   Pregnancy benefits
13T..   Parent's benefits
13U..   Low income benefits
13V..   Social history baselines
13W..   Family circumstance NOS
13X..   History of foreign travel
13Z..   Social/personal history NOS
13b..   World languages
13d..   Country of birth (European)
13e..   Country of birth (Asian)
13f..   Country of birth (American)
13g..   Country of birth (African)
13h..   Country of birth (Australasian)
13j..   Country of birth (Atlantic)
13k..   Country of birth (Pacific)
13l..   Main spoken language
13n..   Language read
13q..   Occupation history
13s..   Second language
13t..   Born in British overseas territory
13u..   Additional main spoken language
13v..   Born in French overseas region, department, collectivity or territory
13w..   Supplemental main language spoken
13y..   Religion - further affiliations
13z..   Religion - additional affiliations
1K...   Gender
1b...   Sexual orientation

Other admin data
1z...   Read Code Administration
*/

-------------------------------------------------------------------------------------------------
-- Observations in chapter 1
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'Chapter 1 - Observation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^1[G,P,Q,S]') OR REGEXP_LIKE(code, '^13[i,o]'));

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Observation',
    applied_rule = 'EMIS - Chapter 1 - Observation'
WHERE code_type IN ('EMIS', 'Other EMIS')
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^1[G,P,Q,S]') OR REGEXP_LIKE(emis_parent, '^13[i,o]'));

--1G...  Concerned about appearance
--1P...  Behaviours and observations relating to behaviour
--1Q...  Character trait observations
--1S...  Mental and psychological observations
--13i..  Safety behaviour observation
--13o..  Communication skills

--------------------------------------------------------------------------------------------------
-- Chapter 2 (Examination/sign)
--------------------------------------------------------------------------------------------------
-- F2F
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'Chapter 2 - Examination or sign'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '2%'
AND code NOT LIKE '211%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'EMIS - Chapter 2 - Examination or sign'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '2%'
AND emis_parent NOT LIKE '211%';

-- 211..  Patient not examined

--------------------------------------------------------------------------------------------------
-- Patient not examined
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Currently cannot be assigned',
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 2 - Patient not examined'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '211%';

--------------------------------------------------------------------------------------------------
-- Chapter 3 - Diagnostic procedures
--------------------------------------------------------------------------------------------------
-- Examination or sign
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'Chapter 3 - Diagnostic procedures'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND left(code, 2) IN ('39', '3A');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'EMIS - Chapter 3 - Diagnostic procedures'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND left(emis_parent, 2) IN ('39', '3A');

--39...    Disability assessment-physical
--3A...    Disability assessment - mental

--------------------------------------------------------------------------------------------------
-- Assessment
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Screening or assessment',
    applied_rule = 'Chapter 3 - assessment'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (code LIKE '32%'
     OR regexp_like(code, '^33[1269A]')
     OR regexp_like(code, '^38[2-58C-EGJKNP-TVW]')
    );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Screening or assessment',
    applied_rule = 'Chapter 3 - assessment'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (emis_parent LIKE '32%'
     OR regexp_like(emis_parent, '^33[1269A]')
     OR regexp_like(emis_parent, '^38[2-58C-EGJKNP-TVW]')
    );

--32...   Electrocardiography
--331..   Skin test for susceptibility
--332..   Tuberculin test - mantoux
--336..   Allergy testing NOS
--339..   Respiratory flow rates
--33A..   Ovulation test - temp. chart
--382..   Diagnostic psychology
--383..   Psychological testing
--384..   Psychological analysis
--385..   Physical/nutrit. assessment
--388..   Miscellaneous scales
--38C..   Health assessment
--38D..   Further miscellaneous scales
--38E..   Common assessment framework for children and young people
--38G..   Additional miscellaneous scales
--38J..   Breastfeeding assessment
--38K..   Assessment how client sees himself or herself
--38N..   Wound assessment
--38P..   Health of the Nation Outcome Scales
--38Q..   Miscellaneous scales - supplemental
--38R..   Framework for the Assessment of Children in Need and their Families
--38S..   Assessment of fitness for work
--38T..   Assessment of parenting capacity
--38V..   Miscellaneous scales 2
--38W..   Ages and Stages Questionnaires Third Edition scores - 1

--------------------------------------------------------------------------------------------------
-- Chapter 4 - Laboratory procedures
--------------------------------------------------------------------------------------------------
-- General rule for chapter 4
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 4 - Laboratory procedures'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '4%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'EMIS - Chapter 4 - Laboratory procedures'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '4%';

--------------------------------------------------------------------------------------------------
-- Lab test request/result
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Laboratory test request or result',
    applied_rule = 'Chapter 4 - Lab test request/result'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^4[2-9A-Q]') OR REGEXP_LIKE(code, '^41[3,5,C,D,F,H]'));

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Laboratory test request or result',
    applied_rule = 'EMIS - Chapter 4 - Lab test request/result'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^4[2-9A-Q]') OR REGEXP_LIKE(emis_parent, '^41[3,5,C,D,F,H]'));

--413..  Laboratory test requested
--415..  Patient refused lab. test
--41H..  Review of patient laboratory test report
--41C..  Patient informed - test result
--4[2-9A-Q] Lab results

--------------------------------------------------------------------------------------------------
-- Laboratory test performed/obtained
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Laboratory procedure',
    applied_rule = 'Chapter 4 - Laboratory test performed/obtained'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (left(code,3) IN ('412', '414', '41F', '41D', '41E', '4I1')
     OR code LIKE '41C3%'
     OR code LIKE '4K55%'
    );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Laboratory procedure',
    applied_rule = 'EMIS - Chapter 4 - Laboratory test performed/obtained'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (left(emis_parent,3) IN ('412', '414', '41F', '41D', '41E', '4I1')
     OR emis_parent LIKE '41C3%'
     OR emis_parent LIKE '4K55%'
    );
--412..  Laboratory procedure performed
--414..  Sample sent to lab. for test
--41C3.  Test result to pat.personally
--41D..  Sample obtained
--41E..  Collection of specimen
--41F..  Taking of swab
--4I1..  Sample examination - general
--4K55.  Cervical cytology test

--------------------------------------------------------------------------------------------------
-- Patient informed about their test resuls remotely
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = CASE WHEN code LIKE '41C2%' THEN 'Phone call with patient'
                            WHEN code LIKE '41C1%' THEN 'Text message/Letter/email'
                            ELSE interaction_type END,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 4 - Lab procedures admin'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,4) IN ('41C2', '41C1');

-- No EMIS code

--41C2.  Test result to pat.by 'phone
--41C1.  Test result by letter to pat.

--------------------------------------------------------------------------------------------------
-- Chapter 5 (Radiology/physics in medicine)
--------------------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 5 - Radiology - Secondary care'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '5%'
AND NOT REGEXP_LIKE(code_description, 'requested|refused|not |awaited|declined', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 5 - Radiology - Secondary care'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '5%'
AND NOT REGEXP_LIKE(code_description, 'requested|refused|not |awaited|declined', 'i');

--------------------------------------------------------------------------------------------------
-- Radiology/physics request or status
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 5 - Radiology/physics request or status'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '5%'
AND (REGEXP_LIKE(code_description, 'requested|refused|not |awaited|declined', 'i')
     OR REGEXP_LIKE(code_description, 'normal|abnormal|result not back', 'i')
     OR code LIKE '5C%'
    );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'EMIS - Chapter 5 - Radiology/physics request or status'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '5%'
AND (REGEXP_LIKE(code_description, 'requested|refused|not |awaited|declined', 'i')
     OR REGEXP_LIKE(code_description, 'normal|abnormal|result not back', 'i')
     OR code LIKE '5C%'
    );

-- 5C...    Imaging interpretation

--------------------------------------------------------------------------------------------------
-- Chapter 6 - Preventive procedures
--------------------------------------------------------------------------------------------------
-- Vaccination
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Immunisation/vaccination',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 6 - Immunisanion/vaccination'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^65[1-9A-M,O,a-b,d]') OR code LIKE '67E2%');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Immunisation/vaccination',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 6 - Immunisanion/vaccination'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^65[1-9A-M,O,a-b,d]') OR emis_parent LIKE '67E2%');

--  65...  Infectious dis:prevent/control
-- '651','652','653','654','655','656','657','658','659',
-- '65A','65B','65C','65D','65E','65F','65G','65H','65I','65J','65K','65L','65M', '65O'
-- '65a','65b','65d'

-- 67E2. Travel vaccination given

--------------------------------------------------------------------------------------------------
-- Chronic disease monitoring
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Chronic disease monitoring',
    applied_rule = 'Chapter 6 - Chronic disease monitoring'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^66[2-5,7,9A-Za-p]')
AND NOT REGEXP_LIKE(code_description, 'hospital|hospice|specialist|out-patient|secondary care', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Chronic disease monitoring',
    applied_rule = 'EMIS - Chapter 6 - Chronic disease monitoring'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^66[2-5,7,9A-Za-p]')
AND NOT REGEXP_LIKE(code_description, 'hospital|hospice|specialist|out-patient|secondary care', 'i');
/*
662..   Cardiac disease monitoring
663..   Respiratory disease monitoring
664..   GIT disease monitoring
665..   Psych. disorder monitoring
667..   Epilepsy monitoring
669..   Gout monitoring
66A..   Diabetic monitoring
            EXCLUDING code_description like '%hospital%', '%out-patient%'
66B..   Thyroid disease monitoring
66C..   Obesity monitoring
66D..   Endocrine disorder monitoring
66E..   B12 deficiency monitoring
66F..   Blood disorder monitoring
66G..   Allergic disorder monitoring
66H..   Rheumatol. disorder monitoring
66I..   Skin disorder monitoring
66J..   Gynae. disorder monitoring
66K..   Urinary disorder monitoring
66L..   ENT disorder monitoring
66M..   Occupation risk monitoring
66N..   Environment risk monitoring
66O..   Ostomy monitoring
66P..   High risk drug monitoring
            EXCLUDING code_description like '%secondary care%'
66Q..   Warfarin monitoring
            EXCLUDING code_description like '%secondary care%'
66R..   Repeat prescription monitoring
--          EXCLUDING code_description like '%hospital%'
66S..   Chronic dis - care arrangement
            EXCLUDING code_description like '%secondary care%', '%specialist%'
66T..   Eye disorder monitoring
66U..   Menopause monitoring
66V..   Ear disorder monitoring
66W..   Prognosis/outlook
66X..   Lipid disorder monitoring
66Y..   Other respiratory disease monitoring
            EXCLUDING code_description like '%hospital%'
66Z..   Chronic dis. monitoring NOS
66a..   Osteoporosis monitoring
66b..   Chronic disease monitoring not required
66c..   Medication monitoring
            EXCLUDING code_description like '%secondary care%'
66d..   Venous monitoring - lower limb
66e..   Alcohol disorder monitoring
66f..   Cardiovascular disease monitoring
66g..   Congenital heart condition monitoring
66h..   Dementia monitoring
66i..   Chronic kidney disease monitoring
66j..   Human immunodeficiency virus monitoring
66k..   Cystic fibrosis monitoring
66l..   Telehealth monitoring for chronic disease
66m..   Unsuitable for meteorological health forecasting service
66n..   Chronic pain review
66o..   Further diabetic monitoring
66p..   Vitamin D deficiency monitoring
*/
-----------------------------------------------------------------------------------------
-- Counselling, health education or health promotion
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = CASE WHEN access_mode IS NULL THEN 'Clinical data with unmatched access mode' ELSE access_mode END, -- See details for '67E2%' above
    interaction_type = CASE WHEN interaction_type IS NULL THEN 'Clinical activities' ELSE interaction_type END,
    interaction_type_detail = CASE WHEN interaction_type_detail IS NULL THEN 'Counselling or health education/promotion' ELSE interaction_type_detail END,
    applied_rule = CASE WHEN applied_rule IS NULL THEN 'Chapter 6 - Counselling or health education/promotion' ELSE applied_rule END
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^67[2,5-9B-TV-X]')
     OR left(code,4) IN ('6712','6714','671G','671F','6731','6732','6733','6734')
     OR code LIKE '6B%'
    )
AND LEFT(code, 4) NOT IN ('6736', '6737')
AND NOT REGEXP_LIKE(code_description, 'hospital|specialist|out-patient|secondary care', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = CASE WHEN access_mode IS NULL THEN 'Clinical data with unmatched access mode' ELSE access_mode END, -- See details for '67E2%' above
    interaction_type = CASE WHEN interaction_type IS NULL THEN 'Clinical activities' ELSE interaction_type END,
    interaction_type_detail = CASE WHEN interaction_type_detail IS NULL THEN 'Counselling or health education/promotion' ELSE interaction_type_detail END,
    applied_rule = CASE WHEN applied_rule IS NULL THEN 'EMIS - Chapter 6 - Counselling or health education/promotion' ELSE applied_rule END
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^67[2,5-9B-TV-X]')
     OR left(emis_parent,4) IN ('6712','6714','671G','671F','6731','6732','6733','6734')
     OR emis_parent LIKE '6B%'
    )
AND LEFT(emis_parent, 4) NOT IN ('6736', '6737')
AND NOT REGEXP_LIKE(code_description, 'hospital|specialist|out-patient|secondary care', 'i');
/*
6712.   Counselling offered
6714.   Counselling carried out
671G.   Discussed with pharmacist
671F.   Discussed with patient
672..   Person counselled
            EXCLUDING 6736.  Counselled by a counsellor; 6737.  Counselled by a vol. worker
6731.   Counselled by a doctor
6732.   Counselled by a nurse
6733.   Counselled by a health visitor
6734.   Counselled by a midwife
675..   Grieving counselling
676..   Pre-pregnancy counselling
677..   Medical counselling
678..   Health education - GENERAL
679..   Health education - subject
67B..   Ante-natal relaxation classes
67C..   Postnatal support GROUP
67D..   Informing patient
67E..   Foreign travel advice -- See section for vaccination above ('67E2%')
67F..   Informing RELATIVE
67G..   Informing next of kin
67H..   Lifestyle counselling
67I..   Advice
67J..   Stress counselling
67K..   Cycle of change stage
67L..   Goal identification
67M..   Informing partner
67N..   Work-related counselling
67P..   Discussion about PROCEDURE
67Q..   Counselling for end of life issues
67R..   Identifying barriers to goal achievement
67S..   Education for care planning
67T..   Identifying workable intervention
67V..   Goal achievement finding
67W..   Recommendation TO
67X..   Psychoeducation
67Y..   Provision of information about children''s centre
67Z..   Counselling/health ed. NOS

6B...   Health promotion
*/

--------------------------------------------------------------------------------------------------
-- Screening (general rule)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 6 - Screening - general'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '68%';

--68...   Screening

--------------------------------------------------------------------------------------------------
-- Screening (F2F)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Screening or assessment',
    applied_rule = 'Chapter 6 - Screening'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^68[2-4,8,F,K,O,P,S-W,a,e]')
     OR REGEXP_LIKE(code, '^685[9,B,C,N,P,Q]')
     OR REGEXP_LIKE(code, '^68R[2-4]')
    )
AND NOT REGEXP_LIKE(code, '^68W2[7-9A-B]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Screening or assessment',
    applied_rule = 'EMIS - Chapter 6 - Screening'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^68[2-4,8,F,K,O,P,S-W,a,e]')
     OR REGEXP_LIKE(emis_parent, '^685[9,B,C,N,P,Q]')
     OR REGEXP_LIKE(emis_parent, '^68R[2-4]')
    )
AND NOT REGEXP_LIKE(emis_parent, '^68W2[7-9A-B]');

--682..   Viral screening - excl.rubella
--683..   Bacterial disease screening
--            EXCLUDING 6831.    Tuberculosis screening
--684..   Other infection screening
--6859.   Ca cervix - screen done
--685B.   Ca cervix screen normal
--685C.   Ca cervix screen abnormal
--685N.   HPV test consent given
--685P.   HPV - Human papillomavirus test positive
--685Q.   HPV - Human papillomavirus test negative
--688..   Anaemia/blood screening
--68F..   Arthritis screen
--68K..   Urine screening
--68O..   Mobility screening
--68P..   Adult screening
--68R2.   New patient screen done
--68R3.   New pt. screen-no abnormality
--68R4.   New patient screen - problem identified
--68S..   Alcohol consumption screen
--68T..   Tobacco usage screen
--68U..   Drugs of abuse screening
--68V..   Toxicology screening
--68W..   Digestive system disease screening
--            EXCLUDING
--            68W27 Bowel scope (flexible-sigmoidoscopy) screening invitation declined
--            68W28   Bowel scope (flexible-sigmoidoscopy) screening invitation: did not respond
--            68W29   Bowel scope (flexible-sigmoidoscopy) appointment: did not attend
--            68W2A   Bowel scope (flexible-sigmoidoscopy) screening: attended but not screened
--            68W2B   Bowel scope (flexible sigmoidoscope) screening invitation: unsuitable at this time
--68a..   Lifestyle screening
--68e..   Screening for risk of falls

--------------------------------------------------------------------------------------------------
-- Immunisation status screening
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 6 - Screening status'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '68N%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'EMIS - Chapter 6 - Screening status'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '68N%';

--68N..  Immunisation status screening

--------------------------------------------------------------------------------------------------
-- Vaccination conset/advise
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Immunisation/vaccination',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 6 - consent for immunisation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^68N[5,V,e,g,l,q,r,t]');

-- No EMIS code

--68N5.   Full consent for immunisation
--68NV.   Influenza vacc consent given
--68Ne.   Consent given for pneumococcal vaccine
--68Ng.   Immunisation given   --> vaccination
--68Nl.   Consent given for measles mumps and rubella vaccine
--68Nq.   Consent given for human papillomavirus vaccination
--68Nr.   Consent given for pandemic influenza vaccination
--68Nt.   Consent given for influenza A subtype H1N1 vaccination

-----------------------------------------------------------------------------------------
-- Special examinations
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'Chapter 6 - Special examinations'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '69%'
AND left(code,3) NOT IN ('69G', '69Z');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'EMIS - Chapter 6 - Special examinations'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '69%'
AND left(emis_parent,3) NOT IN ('69G', '69Z');

--69...   Special examinations
--            EXCLUDING
--            69G..   Private medical examination;
--            69Z..   Special examinations NOS

--------------------------------------------------------------------------------------------------
-- Patient review or primary prevention
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Patient review or primary prevention',
    applied_rule = 'Chapter 6 - Patient review or primary prevention'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^6[A,C]')
AND code NOT LIKE '6A1'
AND NOT REGEXP_LIKE(code_description, 'hospital', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Patient review or primary prevention',
    applied_rule = 'EMIS - Chapter 6 - Patient review or primary prevention'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^6[A,C]')
AND emis_parent NOT LIKE '6A1'
AND NOT REGEXP_LIKE(code_description, 'hospital', 'i');

--6A...   Patient reviewed
--            EXCLUDING 6A1.. Patient reviewed at hospital
--6C...   Primary prevention

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    applied_rule = 'Chapter 6 - secondary care'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '6A1%';

-- 6A1.. Patient reviewed at hospital

--------------------------------------------------------------------------------------------------
-- Maternal or child health
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Maternal or child health',
    applied_rule = 'Chapter 6 - Maternal or child health'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^6[1-4,G]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Maternal or child health',
    applied_rule = 'EMIS - Chapter 6 - Maternal or child health'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^6[1-4,G]');

--61...  Contraception
--62...  Patient pregnant
--63...  Birth details
--64...  Child health care
--6G...  Postnatal care

--------------------------------------------------------------------------------------------------
-- Lab test request/result
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Laboratory test request or result',
    applied_rule = 'Chapter 6 - Lab test request/result'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^686[4,6-9A-C]');

--6864.   Large bowel neoplasm screen
--6866.   Bowel cancer screening programme: faecal occult blood result
--6867.   Bowel cancer screening programme faecal occult blood testing kit spoilt
--6868.   Bowel cancer screening programme faecal occult blood test technical failure
--6869.   Bowel cancer screening programme faecal occult blood test result unclear
--686A.   Bowel cancer screening programme faecal occult blood test normal
--686B.   Bowel cancer screening programme faecal occult blood test abnormal
--686C.   Bowel cancer screening programme faecal occult blood testing incomplete participation

-----------------------------------------------------------------------------------------
-- Chapter 7 (Operations, procedures, sites)
-----------------------------------------------------------------------------------------
-- Secondary care data
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 7 - Operations, procedures, sites'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '7%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 7 - Operations, procedures, sites'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '7%';

-----------------------------------------------------------------------------------------
-- F2F
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'Chapter 7 - Examination or sign'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,5) IN ('7E2A2', '7E2A5', '7E2Az');

-- No EMIS code

--7E2A2   Papanicolau smear NEC
--7E2A5   Genital swab
--7E2Az   Other examination of female genital tract NOS

-----------------------------------------------------------------------------------------
-- F2F
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Therapeutic procedures',
    applied_rule = 'Chapter 7 - Therapeutic procedures'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (code LIKE '7L185%' OR code LIKE '7L18.%' OR code LIKE '7305%' OR code LIKE '7L19%');

--7L185   Intramuscular injection of vitamin B12
--7L18.   Intramuscular injection (some cases excluded)
--7L19.   Subcutaneous injection
--7305.   Clearance of external auditory canal

-----------------------------------------------------------------------------------------
-- Vaccination
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Immunisation/vaccination',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 7 - Immunisanion/vaccination'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '7L1g%';

--7L1g.   Administration of vaccine

-----------------------------------------------------------------------------------------
-- F2F
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Laboratory procedure',
    applied_rule = 'Chapter 7 - Laboratory procedure'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (code LIKE '7L17.%' OR code LIKE '7L172%');

--7L17.   Blood withdrawal (some sub-codes excluded)
--7L172   Blood withdrawal for testing

-----------------------------------------------------------------------------------------
-- Chapter 8 (Other therapeutic procedures)
-----------------------------------------------------------------------------------------
-- Referral
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Referral',
    applied_rule = 'Chapter 8 - Other therapeutic procedures'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^8[H,L,T,W]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Referral',
    applied_rule = 'EMIS - Chapter 8 - Other therapeutic procedures'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^8[H,L,T,W]');

--8H...   Referral for further care
--8T...   Referral - additional
--8W...   Referral statuses
--8L...   Operative procedures planned (all secondary care operations)

-----------------------------------------------------------------------------------------
-- Clinical activities (other documentation)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 8 - Other clinical documentation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^8[3,4,C,I,K,M-O,R,SV,Z]')
     OR REGEXP_LIKE(code, '^8B[A-C,J,K,Q,R,Z]')
    )
AND NOT REGEXP_LIKE(code_description, 'hospital|supplementary prescriber|third party', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'EMIS - Chapter 8 - Other clinical documentation'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^8[3,4,C,I,K,M-O,R,SV,Z]')
     OR REGEXP_LIKE(emis_parent, '^8B[A-C,J,K,Q,R,Z]')
    )
AND NOT REGEXP_LIKE(code_description, 'hospital|supplementary prescriber|third party', 'i');

--83...  Immobilisation and support
--84...  Planned procedure
--8C...  Other care -- exceptions listed in the follwoing rules
--8I...  Procedure not carried out (includes detail about reasons)
--8K...  Body surface points
--8M...  Patient requested procedure
--8N...  Environmental adaptation
--8O...  Provision of services and equipment
--8R...  Use of foot impulse device
--8S...  Use of intermittent pneumatic compression device
--8V...  Admission Procedure
--8Z...  Other therapy procedure NOS

--8BA..   Other misc. therapy
--8BB..   Response to treatment
--8BC..   Treatment given
--8BJ..   Treatment intent
--8BK..   Disease management programme
--8BQ..   Treatment indicated
--8BR..   Investigation indicated
--8BZ..   Other therapy NOS

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 8 - Other clinical documentation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^8H[E,G,f,g]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'EMIS - Chapter 8 - Other clinical documentation'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^8H[E,G,f,g]');

--8HE.    Discharged from hospital
--8HG..   Died in hospital
--8Hf..   Discharge from intermediate care
--8Hg..   Discharge from care

-----------------------------------------------------------------------------------------
-- Unknown care provider
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Currently cannot be assigned',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 8 - cannot be assigned'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (regexp_like(code, '^8[5-8,E-G,J]')
     OR regexp_like(code, '^8C[1,8,C,s,u]')
     OR regexp_like(code, '^8H[O]')
     OR LEFT(code, 3) IN ('8BF', '8BH')
    );

--85...   Other mechanical procedures
--86...   Other physical agent therapy
--87...   Respiratory procedures
--88...   Cardiovascular procedures
--8E...   Physiotherapy/remedial therapy
--8F...   Other rehabilitation
--8G...   Psychotherapy/sociotherapy
--8J...   Radiotherapy treatment groups
--8BF..   Complementary therapy
--8BH..   Gene therapy

--8C1..   Nursing care  -- not sure if this is provided by primary care
--8C8..   Treatment for infertility
--8CC..   TLC - tender loving care
--8Cr..   Cutting toenails
--8Cs..   Filing toenails
--8Cu..   Drilling of a nail

--8HO..   Admission funding status

-----------------------------------------------------------------------------------------
-- Secondary care provider
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Secondary care',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 8 - Secondary care'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (code LIKE '8CO%' OR code LIKE '8HN%');

--8CO..   Inpatient care
--8HN..   Duration of in-patient STAY

-----------------------------------------------------------------------------------------
-- Monitoring of patient
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Patient monitoring',
    applied_rule = 'Chapter 8 - Patient monitoring'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '8A%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Patient monitoring',
    applied_rule = 'EMIS - Chapter 8 - Patient monitoring'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '8A%';

--8A...  Monitoring of patient

-----------------------------------------------------------------------------------------
-- Remote monitoring of patient
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Other remote interactions',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 8 - Remote monitoring'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '8AB%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Other remote interactions',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 8 - Remote monitoring'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '8AB%';

--8AB..  Telehealth monitoring

-----------------------------------------------------------------------------------------
-- Drug therapy or prescription
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Drug therapy or prescription',
    applied_rule = 'Chapter 8 - Drug therapy or prescription'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^8B[2-4,6-9,D,E,G,I,L,M,P,S,T,V]')
     OR code LIKE '88A5%'
    )
AND NOT REGEXP_LIKE(code_description, 'community');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Drug therapy or prescription',
    applied_rule = 'EMIS - Chapter 8 - Drug therapy or prescription'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^8B[2-4,6-9,D,E,G,I,L,M,P,S,T,V]')
     OR emis_parent LIKE '88A5%'
    )
AND NOT REGEXP_LIKE(code_description, 'community');

--8B2..   Therapeutic prescription
--8B3..   Drug therapy
--8B4..   Previous treatment CONTINUE
--8B6..   Prophylactic drug therapy
--8B7..   Inorganic salt/vitamin prophyl
--8B8..   Anti-D (rhesus) globulin
--8B9..   Dietary prophylaxis
--8BD..   Long term drug therapy
--8BE..   Maintenance therapy
--8BG..   Drug indicated
--8BI..   Other medication review
--8BL..   Patient on maximum tolerated dose
--8BM..   Other medication management (except community)
--8BP..   Other drug therapy
--8BS..   High risk drug monitoring review
--8BT..   Medication review - additional
--8BV..   Emergency contraception indicated

--88A5.   Anticoagulant therapy

-----------------------------------------------------------------------------------------
-- Pharmacy visit
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Pharmacy',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 8 - Pharmacy'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^8BM[C,E,H,d]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Pharmacy',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 8 - Pharmacy'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^8BM[C,E,H,d]');

--8BMC.    Prescription collected by pharmacy
--8BME.    Prescription sent to pharmacy
--8BMH.    Medication review done by pharmacy technician
--8BMd.    Prescribed medication to be delivered to patient by pharmacy

-----------------------------------------------------------------------------------------
-- Community
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Community',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 8 - Community services'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,4) IN ('8BMF', '8BMf');

-- No EMIS code

--8BMF.     Medicine use review done by community pharmacist
--8BMf.     Supply of urgent repeat medication by Community Pharmacy via Patient Group Direction

-----------------------------------------------------------------------------------------
-- F2F interactions
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Therapeutic procedures',
    applied_rule = 'Chapter 8 - Other therapeutic procedures'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^8[1,2,9,D,P,Q]')
     OR left(code, 3) IN ('831','839','85D','879','8BN','8B1','8OA','8CE')
     OR code LIKE '8I87%'
    );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Therapeutic procedures',
    applied_rule = 'EMIS - Chapter 8 - Other therapeutic procedures'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^8[1,2,9,D,P,Q]')
     OR left(emis_parent, 3) IN ('831','839','85D','879','8BN','8B1','8OA','8CE')
     OR emis_parent LIKE '8I87%'
    );

--81...   Removal of unwanted material
--82...   Correction of misplacement
--831..   Bandaging and sling support
--839..   Fixation/support removal
--85D..   Injection given
--879..   Other respiratory procedures
--89...   Pre/post-operative procedures
--8B1..   Emergency treatment
--8BN..   Treatment of wound with maggots
--8CE..   Self-help advice leaflet given
--8D...   Anatomo-physiolog. assistance
--8I87.   Unsuccessful urethral catheter insertion
--8OA..   Providing material
--8P...   Removal of surgical material and sutures
--8Q...   Behaviour management

-----------------------------------------------------------------------------------------
-- Chapter 9 (Administration)
-----------------------------------------------------------------------------------------
-- Patient sociodemographic or registration data
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Patient sociodemographic or registration data',
    applied_rule = 'Chapter 9 - Patient registration'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^9[1,2,4,S,T,W,d,i,r,t]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Patient sociodemographic or registration data',
    applied_rule = 'EMIS - Chapter 9 - Patient registration'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^9[1,2,4,S,T,W,d,i,r,t]');

--91...  Patient registration
--92...  Patient de-registration
--94...  Death administration
--9S...  Ethnic groups (census)
--9T...  Ethnicity and other related nationality DATA
--9W...  Power of attorney
--9d...  Relative
--9i...  Ethnic category - 2001 census
--9r...  Information gathering
--9t...  Ethnic category - 2011 census

-----------------------------------------------------------------------------------------
-- Other admin data
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Other admin data',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Other admin data'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^9[3,9,A-C,G,I-M,P,Q,U,V,Z,e-g,j,n]') OR code LIKE '9.%');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Other admin data',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 9 - Other admin data'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^9[3,9,A-C,G,I-M,P,Q,U,V,Z,e-g,j,n]') OR emis_parent LIKE '9.%');

--93...  Patient record types
--99...  Ancillary staff administration
--9A...  Rent and rates payments
--9B...  Supply of drugs payment admin
--9C...  Training/seniority/leave admin
--9G...  Notifications
--9I...  Practice supplies admin.
--9J...  Drug stock control admin.
--9K...  Forms - miscellaneous
--9L...  Accounting administration
--9M...  Audit administration
--9P...  Clinical trial administration
--9Q...  Research administration
--9U...  Complaints about care
--9V...  Bill/Fee administration
--9Z...  Administration NOS
--9e...  GP out of hours service administration
--9f...  History taking administration
--9g...  Significant event audit
--9j...  Risk management administration
--9n...  Practice based commissioning administration

-----------------------------------------------------------------------------------------
-- Other patient admin data
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Other patient admin data',
    applied_rule = 'Chapter 9 - Other patient admin data'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^9[a,c,l,h,q]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Other patient admin data',
    applied_rule = 'EMIS - Chapter 9 - Other patient admin data'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^9[a,c,l,h,q]');

--9a...  Explanation of practice procedure
--9c...  Context values
--       9c0..   Record headings
--       9c1..   Interpretation values
--       9c2..   Episodicities
--       9c3..   Presence findings
--       9c4..   Significance VALUES
--       9c5..   Priorities
--       9c6..   Agent relationship
--       9c7..   Patient
--9l...  Patient record status
--9h...  Exception reporting: GP contract quality indicators
--9q...  Consent status

-----------------------------------------------------------------------------------------
-- Maternal or child health
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Maternal or child health',
    applied_rule = 'Chapter 9 - Maternal or child health'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^9[5,6,F]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Maternal or child health',
    applied_rule = 'EMIS - Chapter 9 - Maternal or child health'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^9[5,6,F]');

--95...  Maternity services admin.
--96...  Contraceptive claims
--9F...  Child examn/reports/meetings

-----------------------------------------------------------------------------------------
-- Clinical activities (Other clinical documentation)
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'Chapter 9 - Other clinical documentation'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^9[7,8,E,H,N,O,b,k,m,s]') OR code LIKE '9Y3%');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Clinical data with unmatched access mode',
    interaction_type = 'Clinical activities',
    interaction_type_detail = 'Other clinical documentation',
    applied_rule = 'EMIS - Chapter 9 - Other clinical documentation'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^9[7,8,E,H,N,O,b,k,m,s]') OR emis_parent LIKE '9Y3%');

--97...  Immunisation claims
--98...  Other items of service admin.
--9E...  Medical examinations/reports
--9H...  Mental health administration
--9N...  Patient encounter admin. data
--9O...  Prevention/screening admin.
--9b...  Record transfer administration
--9k...  Enhanced services administration
--9m...  Prevention/screening administration - additional
--9s...  Drug misuse clinic administration
--9Y3..  Patient regularly seeks multiple medical opinions

-----------------------------------------------------------------------------------------
-- Certificates - administration
-- general rule
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Certificates',
    applied_rule = 'Chapter 9 - Certificates administration'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND code LIKE '9D%';

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Patient admin data',
    interaction_type_detail = 'Certificates',
    applied_rule = 'EMIS - Chapter 9 - Certificates - administration'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND emis_parent LIKE '9D%';

--9D...Certificates - administration

-----------------------------------------------------------------------------------------
-- F2F - certificates
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'Chapter 9 - Certificates - F2F'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND REGEXP_LIKE(code, '^9D[1,2,5-9,A-C,E,F,H,K,L,N,R]')
AND NOT REGEXP_LIKE(code_description, 'not', 'i')
AND NOT REGEXP_LIKE(code_description, 'refused', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'EMIS - Chapter 9 - Certificates - F2F'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^9D[1,2,5-9,A-C,E,F,H,K,L,N,R]')
AND NOT REGEXP_LIKE(code_description, 'not', 'i')
AND NOT REGEXP_LIKE(code_description, 'refused', 'i');

--9D1..  MED3 - doctor's statement
--9D2..  MED5 - doctor's special stat.
--9D5..  Private sickness certificate
--9D6..  Passport application signing
--9D7..  Forces sickness on leave cert.
--9D8..  Shotgun application cert.
--9D9..  Jury exemption form
--9DA..  RPF7 - postal vote APPLICATION
--9DB..  Misc. certificate signed
--9DC..  SC1 - self certificate admin.
--9DE..  Community charge exempt.admin.
--9DF..  MED4 Doctors statement
--9DH..  Driving licence application signed
--9DK..  Sick note generated from secondary care done by practice
--9DL..  SC2 - self-certificate administration
--9DN..  Issue of international yellow fever vaccination certificate
--9DR..  Photograph certified as true likeness

-----------------------------------------------------------------------------------------
-- Patient encounter admin data, detailed interactions
-----------------------------------------------------------------------------------------
-- Failed encounter
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Other admin data',
    interaction_type_detail = 'Failed encounter',
    applied_rule = 'Chapter 9 - Failed encounter'
WHERE REGEXP_LIKE(code, '^9N[4,i,j]');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Admin related data',
    interaction_type = 'Other admin data',
    interaction_type_detail = 'Failed encounter',
    applied_rule = 'EMIS - Chapter 9 - Failed encounter'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND REGEXP_LIKE(emis_parent, '^9N[4,i,j]');

--9N4.. Failed encounter
--9Ni.. Did not attend
--9Nj.. Other failed encounter

-----------------------------------------------------------------------------------------
-- Other F2F interactions
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'Chapter 9 - Other F2F interactions'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (LEFT(code,4) IN ('9N0G','9N11','9N1t','9N1z','9N1x','9N0t',
                      '9N21','9N2q','9N2S','9N2l','9N58',
                      '9NkE','9NkF','9Nl1','9Nl2','9Nl3','9Nl4',
                      '9Nl5','9Nl7','9NlB','9NlW','9NlY',
                      '9kh0','9NB1')
     OR REGEXP_LIKE(code, '^9N[M,N,P,Q,U,V,m,n,q,x]')
     OR REGEXP_LIKE(code, '^9Nz[1,7,8,C-F,H]')
     OR code LIKE '9o%');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'EMIS - Chapter 9 - Other F2F interactions'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (LEFT(emis_parent,4) IN ('9N0G','9N11','9N1t','9N1z','9N1x','9N0t',
                             '9N21','9N2q','9N2S','9N2l','9N58',
                             '9NkE','9NkF','9Nl1','9Nl2','9Nl3','9Nl4',
                             '9Nl5','9Nl7','9NlB','9NlW','9NlY',
                             '9kh0','9NB1')
     OR REGEXP_LIKE(emis_parent, '^9N[M,N,P,Q,U,V,m,n,q,x]')
     OR REGEXP_LIKE(emis_parent, '^9Nz[1,7,8,C-F,H]')
     OR emis_parent LIKE '9o%');

--9N0G.   Seen in primary care centre
--9N11.   Seen in GP's surgery
--9N1t.   Out of hours consultation at surgery
--9N1z.   Seen in GP unit
--9N1x.   Bank holiday surgery consultation
--9N0t.   Seen in primary care leg ulcer clinic
--9N210   Seen by GP of choice
--9N2q.   Seen prim car gra men hea work
--9N2S.   Seen by practice phlebotomist
--9N2l.   Seen by nurse practitioner
--9N58.   Emergency appointment
--9NkE.   Seen in general practitioner anticoagulation clinic
--9NkF.   Seen in general practitioner disease modifying antirheumatic drug monitoring clinic
--9Nl1.   Seen by GP spec int cardiology
--9Nl2.   Seen by GP specl int neurology
--9Nl3.   Seen GP spec int ENT disorders
--9Nl4.   Seen by GP spec int diabetes
--9Nl5.   Seen GP spe int resp disorders
--9Nl7.   Seen by GP spec int headache
--9NlB.   Seen by GP spec int dermatolgy
--9NlW.   Seen GP spe int generl surgery
--9NlY.   Seen by GP spec int rheumatlgy
--9kh0.   Attend extend hour clinc - ESA
--9NB1.   Appointment made at reception
--9NM..   Attending clinic
--9NP..   Presence of chaperone
--9NQ..   Presence of interpreter
--9NU..   Need for interpreter
--9NV..   Follow-up encounter
--9Nm..   Other interpreter needed
--9Nn..   Further interpreter needed
--9Nq..   Patient accompanied at encounter
--9Nx..   Inappropriate use of walk-in centre
--9Nz1.   Child not brought to appointment
--9Nz7.   Father present at encounter
--9Nz8.   Mother present at encounter
--9NzC.   Parent present at encounter
--9NzD.   Relative present at encounter
--9NzE.   Legal guardian present at encounter
--9NzF.   Carer present at encounter
--9NzH.   No other person present at encounter
--9o...   Walk in centre administration

-----------------------------------------------------------------------------------------
-- Dental service
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Dental service',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Dental service'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,4) IN ('9N2C');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Dental service',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 9 - Dental service'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND LEFT(emis_parent,4) IN ('9N2C');

--9N2C.   Seen by dentist

-----------------------------------------------------------------------------------------
-- Pharmacy visit
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Pharmacy',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Pharmacy'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,4) IN ('9NlQ');

--9NlQ.   Seen by pharmacist

-----------------------------------------------------------------------------------------
-- Remote interactions - telephone call
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Phone call with patient',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Remote'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,4) IN ('9N31','9N3A','9N3F','9N71','9N72');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Phone call with patient',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 9 - Remote'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND LEFT(emis_parent,4) IN ('9N31','9N3A','9N3F','9N71','9N72');

--9N31.   Telephone encounter
--9N3A.   Telephone triage encounter
--9N3F.   Nurse telephone triage
--9N71.   Patient called - prevention
--9N72.   Patient re-called-prevention

-----------------------------------------------------------------------------------------
-- Remote interactions - Text message/Letter/email
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Text message/Letter/email',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Remote'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (LEFT(code,4) IN ('9N33','9N37','9N38','9N3L','9NC3','9N35','9N3B','9N3C','9N3G','9N3H','9NCB','9NCC')
     OR code LIKE '9p%');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'Remote',
    interaction_type = 'Text message/Letter/email',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS - Chapter 9 - Remote'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (LEFT(emis_parent,4) IN ('9N33','9N37','9N38','9N3L','9NC3','9N35','9N3B','9N3C','9N3G','9N3H','9NCB','9NCC')
    OR emis_parent LIKE '9p%');

--9N33.   Letter encounter from patient
--9N35.   Letter encounter to patient
--9N37.   Message given to patient
--9N38.   Message from patient
--9N3B.   E-mail received from patient
--9N3C.   E-mail sent to patient
--9N3G.   SMS text message sent to patient
--9N3H.   SMS text message received from patient
--9N3L.   Copy of letter from specialist to patient
--9NC3.   Letter sent to patient
--9NCB.   Appointment letter sent to patient
--9NCC.   Discharge letter given to patient
--9p...   Medication monitoring administration --->>> all are letter

-----------------------------------------------------------------------------------------
-- Home visit
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Home visit',
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Home visit'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (LEFT(code,4) IN ('9N1w','9N1C','9NX2') OR
     LEFT(code,3) IN ('9NF','9NJ')
    );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'Home visit',
    interaction_type_detail = NULL,
    applied_rule = 'EMIS EMIS - Chapter 9 - Home visit'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (LEFT(emis_parent,4) IN ('9N1w','9N1C','9NX2') OR
     LEFT(emis_parent,3) IN ('9NF','9NJ')
    );

--9N1w.  Bank holiday home visit
--9N1C.  Seen in own home
--9NF..  Home visit admin
--9NJ..  In-house services
--9NX2.  In-house substance misuse treatment

-----------------------------------------------------------------------------------------
-- Community services
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Community',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Community'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND LEFT(code,4) IN ('9N2Y','9N2a','9N2y');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Community',
    access_mode = NULL,
    interaction_type = NULL,
    interaction_type_detail = NULL,
    applied_rule = 'Chapter 9 - Community'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND LEFT(emis_parent,4) IN ('9N2Y','9N2a','9N2y');

--9N2Y.  Seen by community paediatric nurse
--9N2a.  Seen by community psychiatric nurse
--9N2y.  Seen by community nurse for older people

-----------------------------------------------------------------------------------------
-- Prevention/screening admin
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = CASE WHEN REGEXP_LIKE(code_description, 'verbal|verb invit|verb.inv|attend', 'i') THEN 'F2F'
                       WHEN REGEXP_LIKE(code_description, 'call|phone|tele invite|teleph|phne invi', 'i')
                            OR REGEXP_LIKE(code_description, 'letter|lettr|letr|let sent|lett sent|postal|email|message|msg|sms', 'i') THEN 'Remote'
                       ELSE 'Clinical data with unmatched access mode' END,
    interaction_type = CASE WHEN REGEXP_LIKE(code_description, 'verbal|verb invit|verb.inv|attend', 'i') THEN 'In-practice visit'
                            WHEN REGEXP_LIKE(code_description, 'call|phone|tele invite|teleph|phne invi', 'i') THEN 'Phone call with patient'
                            WHEN REGEXP_LIKE(code_description, 'letter|lettr|letr|let sent|lett sent|postal|email|message|msg|sms', 'i') THEN 'Text message/Letter/email'
                       ELSE 'Clinical activities' END,
    interaction_type_detail = CASE WHEN REGEXP_LIKE(code_description, 'verbal|verb invit|verb.inv|attend', 'i') THEN 'Other F2F interactions within practice setting'
                       WHEN REGEXP_LIKE(code_description, 'call|phone|tele invite|teleph|phne invi', 'i')
                            OR REGEXP_LIKE(code_description, 'letter|lettr|letr|let sent|lett sent|postal|email|message|msg|sms', 'i') THEN NULL
                       ELSE 'Other clinical documentation' END, 
    applied_rule = 'Chapter 9 - Prevention/screening admin'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^9O[2-9A-Za-z]') OR REGEXP_LIKE(code, '^9m[0,1-9A-Z,a]'))
AND NOT REGEXP_LIKE(code_description, 'clinic|delete|exclude|eligible|inactive|postpone|delayed|suspend|not', 'i')
AND NOT REGEXP_LIKE(code_description, 'failure|lost|broken|required|community|refer|never had|fail|ghost|non-attender', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = CASE WHEN REGEXP_LIKE(code_description, 'verbal|verb invit|verb.inv|attend', 'i') THEN 'F2F'
                       WHEN REGEXP_LIKE(code_description, 'call|phone|tele invite|teleph|phne invi', 'i')
                            OR REGEXP_LIKE(code_description, 'letter|lettr|letr|let sent|lett sent|postal|email|message|msg|sms', 'i') THEN 'Remote'
                       ELSE 'Clinical data with unmatched access mode' END,
    interaction_type = CASE WHEN REGEXP_LIKE(code_description, 'verbal|verb invit|verb.inv|attend', 'i') THEN 'In-practice visit'
                            WHEN REGEXP_LIKE(code_description, 'call|phone|tele invite|teleph|phne invi', 'i') THEN 'Phone call with patient'
                            WHEN REGEXP_LIKE(code_description, 'letter|lettr|letr|let sent|lett sent|postal|email|message|msg|sms', 'i') THEN 'Text message/Letter/email'
                       ELSE 'Clinical activities' END,
    interaction_type_detail = CASE WHEN REGEXP_LIKE(code_description, 'verbal|verb invit|verb.inv|attend', 'i') THEN 'Other F2F interactions within practice setting'
                       WHEN REGEXP_LIKE(code_description, 'call|phone|tele invite|teleph|phne invi', 'i')
                            OR REGEXP_LIKE(code_description, 'letter|lettr|letr|let sent|lett sent|postal|email|message|msg|sms', 'i') THEN NULL
                       ELSE 'Other clinical documentation' END, 
    applied_rule = 'EMIS - Chapter 9 - Prevention/screening admin'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^9O[2-9A-Za-z]') OR REGEXP_LIKE(emis_parent, '^9m[0,1-9A-Z,a]'))
AND NOT REGEXP_LIKE(code_description, 'clinic|delete|exclude|eligible|inactive|postpone|delayed|suspend|not', 'i')
AND NOT REGEXP_LIKE(code_description, 'failure|lost|broken|required|community|refer|never had|fail|ghost|non-attender', 'i');

-----------------------------------------------------------------------------------------
-- F2F, Examinations or sign
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'Chapter 9 - Medical examinations/reports'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (REGEXP_LIKE(code, '^9E[1,2,5,D,F-N,P,R,d,m,n]')
     OR REGEXP_LIKE(code, '^9F[1,3,4,A,Z]')
     OR code LIKE '9H9%'
     OR code LIKE '9N7A%'
     OR REGEXP_LIKE(code, '^9Nd[0x]')
     )
AND NOT REGEXP_LIKE(code_description, 'paid|report only|no exam|bill|fee|received|not| ex|statement|request', 'i');

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Examination or sign',
    applied_rule = 'EMIS - Chapter 9 - Medical examinations/reports'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (REGEXP_LIKE(emis_parent, '^9E[1,2,5,D,F-N,P,R,d,m,n]')
     OR REGEXP_LIKE(emis_parent, '^9F[1,3,4,A,Z]')
     OR emis_parent LIKE '9H9%'
     OR emis_parent LIKE '9N7A%'
     OR REGEXP_LIKE(emis_parent, '^9Nd[0x]')
     )
AND NOT REGEXP_LIKE(code_description, 'paid|report only|no exam|bill|fee|received|not| ex|statement|request', 'i');

--9N7A.   Follow-up examination normal
--9Nd0.   Verbal consent for examination
--9Ndx.   Inform con for cerv smear givn
--9E1..   Employment examination/reports
--9E2..   Special activities medical
--9E5..   Life assurance - examination
--9ED..   Emigration suitability medical
--9EF..   Racing drivers medical exam.
--9EG..   Disabled driver badge report
--9EH..   Elderly drivers ins. medical
--9EI..   Seat belt exemption exam
--9EJ..   Public serv vehic driver exam
--9EK..   Heavy goods vehic drivers exam
--9EL..   Taxi cab driver medical exam
--9EM..   DS4-attendance allowance exam
--9EN..   Mobility allowance examination
--9EP..   Police request to attend
--9ER..   Solicitors report
--9Ed..   Medical examination - aviation
--9Em..   Offshore medical examination
--9En..   Seafarer medical examination
--9F1..   Boarded out child examination
--9F3..   Child into care examination
--9F4..   BAAF Adult 1/2-adopt:appl rep
--9FA..   Child protection medical examination
--9FZ..   Child exam/report NOS
--9H9..  Mental health annual physical examination done

-----------------------------------------------------------------------------------------
UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'Chapter 9 - Other F2F interactions'
WHERE code_type IN ('Read V2', 'Vision', 'Other Read or Vision')
AND (LEFT(code,3) IN ('911','922','9HC','9Y0','9Y1','9Y2')
     OR left(code,4) IN ('9122','912M','9511')
     OR code LIKE '9X%'
     );

UPDATE SAILW1151V.RRDA_WLGP_CLINICAL_CODES_AND_INTERACTION
SET care_provider = 'Primary care',
    access_mode = 'F2F',
    interaction_type = 'In-practice visit',
    interaction_type_detail = 'Other F2F interactions within practice setting',
    applied_rule = 'EMIS - Chapter 9 - Other F2F interactions'
WHERE code_type = 'EMIS'
AND emis_parent_readv2 = 1
AND (LEFT(emis_parent,3) IN ('911','922','9HC','9Y0','9Y1','9Y2')
     OR left(emis_parent,4) IN ('9122','912M','9511')
     OR emis_parent LIKE '9X%'
     )

--911..  Patient registration-form used
--9122.  Patient signed reg. form
--912M.  Registered with dentist
--922..  Patient self de-registration
--9511.  FP24 signed by patient
--9HC..  Substance misuse monitoring
--9X...  Advanced directive administration (discussion about future care preferences)
--9Y0..  Patient came for second opinion
--9Y1..  Patient request second opinion by consultant
--9Y2..  Patient requests another opinion after seeing consultant

