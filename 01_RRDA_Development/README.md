# WLGP RRDA development

This directory contains the scripts used to create the **Research-Ready Data Asset (RRDA)** version of the **Welsh Longitudinal General Practice (WLGP)** data within the SAIL Databank.  

The WLGP is originally stored as a long-format event list and contains known quality issues (e.g., duplicates, re-inserted GP-to-GP transferred records, invalid or missing entries). These scripts implement systematic cleaning, curation, and restructuring steps to produce a **normalised WLGP RRDA**, optimised for analysis.  

The WLGP RRDA development involves following main steps:
- Data cleaning: Removing records with missing ALF, event date, practice code, or event code;
- GP registration-based validation and extraction of correct practice ID: Excluding records with no history of a GP registration information for the patient in Wales at the time of event (using demographic data), and extracting correct practice code at the time of event;
- Removal of exact duplicates: Compressing records with same ALF, event date, practice code (in WLGP), event code and value;
- De-duplication of GP-to-GP transferred records: Identifying and de-duplicating GP-to-GP transferred records (by comparing practice code from WLGP and demographic data).
- Creating a comprehensive look-up of primary care clinical codes (Read V2, SNOMED, local EMIS/Vision codes, and supplementary categories). 
- Normalising WLGP RRDA: Converting long-format event list into a structured, three-table format by grouping all events for each patient per day. 

See https://doi.org/10.1101/2025.09.22.25336310 for more details.

## Notes  

- These scripts are designed for use **within the SAIL Databank** and rely on its specific data schemas.
- For transparency and reusability, all scripts are provided in this repository.  
- Users outside of SAIL may need to adapt the scripts to their TRE/SDE environment.  

