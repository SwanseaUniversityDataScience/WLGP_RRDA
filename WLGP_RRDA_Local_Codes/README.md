
# Local Codes in WLGP RRDA

Most clinical events in the **Welsh Longitudinal General Practice (WLGP)** data are recorded using the official **Read V2** coding system at the 5-character level. However, a proportion of events are recorded using alternative or **local coding systems**.  

Primary care software systems (e.g., **EMIS** and **Vision**) use local codes for specific purposes. As these are not official codes, they are not listed or published in standard clinical code browsers. Local codes became especially important after the discontinuation of Read codes in 2018.  

For example, new clinical concepts such as *COVID-19* and *Long COVID* were introduced in SNOMED, but because SNOMED is not yet fully available in Welsh primary care EHR systems, these concepts are instead captured as local codes within individual software systems.  

In collaboration with the **SAIL Databank** and **Digital Health and Care Wales (DHCW)**, we confirmed lists of local codes used in the current GP software systems for Wales (**EMIS** and **Vision**) as of 2023.  
Additional EMIS clinical and prescription codes were obtained from the **UK Biobank**, and further Vision and Read V2 codes were collated from external sources.  
See the main project documentation for more details.  

---

## Code Type Definitions  

The WLGP RRDA look-up table includes the following code types:  

- **Read V2**  
  Official Read V2 codes available in the `SAILUKHDV` schema.  

- **SNOMED**  
  Official SNOMED codes available in the `SAILUKHDV` schema.  

- **Vision**  
  Local codes (5 or 7 characters) provided by DHCW and the SAIL team, similar in structure to official Read codes.  

- **EMIS**  
  Local EMIS codes (variable length/format) provided by DHCW and the SAIL team.  

- **Additional Read or Vision**  
  Read or Vision codes identified from external resources (includes some 7-character Read codes and 5/7-character Vision codes).  

- **Additional EMIS**  
  EMIS codes identified from the UK Biobank that were not included in the DHCW/SAIL lists.  

---

## Contents of this Directory  

This directory contains the lists of known **Vision**, **EMIS**, **Additional Read or Vision**, and **Additional EMIS** codes, as extracted in 2023.  

---



