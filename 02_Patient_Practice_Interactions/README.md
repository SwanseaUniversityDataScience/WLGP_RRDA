# Multi-layer approach for identifying types of patient-practice interactions  

This directory contains the SQL scripts used to implement a **four-layer classification framework** for assigning patient–practice interaction types in the **WLGP RRDA**.  

The purpose of this framework is to systematically capture the complexity of patient–provider interactions by combining information from official and local clinical codes, supported by text search and logical rules.  


## Four-Layer Framework  

### 1. Care Provider Layer  
Identifies the type of care provider responsible for the interaction. While most records in WLGP relate to an interaction within primary care settings, some may document interactions with other care providers, such as secondary care or community services

### 2. Access Mode Layer  
Classifies how the patient accessed care, defined only for primary care interactions.  
- Face-to-face (e.g., in-practice visits, home visits, immunisations/vaccinations). 
- Remote (e.g., telephone or video appointments).  
- Clinical data with unmatched access mode (e.g., clinical records where access type cannot be determined).  
- Admin (e.g., registration updates or demographic records).  
- Cannot be assigned (e.g., non-clinical records with no available interaction information).  

### 3. Interaction Type Layer  
Provides a more specific classification within each access mode, detailing the method or setting of the interaction.  

### 4. Interaction Details Layer  
Offers a granular breakdown of specific activities or procedures recorded in the interaction, ensuring key clinical activities are accurately represented.  


## Implementation  

The scripts apply **hierarchies and categories of official and local codes** (where available), along with free-text search, to ensure accurate classification while maintaining flexibility for evolving clinical documentation practices.


## Output  

The resulting patient–practice interaction related variables can be combined with the WLGP RRDA to:  
- Categorise daily patient activity (person–day events).  
- Classify interactions into **key activity types** (consultations, prescriptions, vaccinations, administrative events, etc.).  
- Support longitudinal analyses of service delivery and patient access patterns.  
