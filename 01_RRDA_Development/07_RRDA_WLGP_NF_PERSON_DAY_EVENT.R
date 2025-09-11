# ******************************************************************************
# Script:        07_RRDA_WLGP_NF_PERSON_DAY_EVENT.R
# About:         Create normalised form (NF) of WLGP RRDA - person-day events table
# Author:        Hoda Abbasizanjani
# Creation date: April 2025
# ******************************************************************************
# Prepare workspace and set variables ----
# ******************************************************************************
source("01_Prep_Workspace.R")
source("02_WLGP_RRDA_Parameters.R")

# ******************************************************************************
# Create normalised person-day events table with unique event ID & code ID ----
# ******************************************************************************
print(str_glue("Create {schema_w}.RRDA_WLGP_NF_PERSON_DAY_EVENT_{end_date_t} \n"))

q_create_rrda_wlgp_pde <- str_glue("
    CREATE TABLE {schema_w}.RRDA_WLGP_NF_PERSON_DAY_EVENT_{end_date_t} (
        event_id              bigint,
        event_cd_id           bigint,
        event_val             decimal(31,8)
    )
    DISTRIBUTE BY HASH(event_id);
")

db2_run(conn, q_create_rrda_wlgp_pde)

#db2_run(conn, str_glue("DROP TABLE {schema_w}.RRDA_WLGP_NF_PERSON_DAY_EVENT_{end_date_t}"))
#db2_run(conn, str_glue("TRUNCATE TABLE {schema_w}.RRDA_WLGP_NF_PERSON_DAY_EVENT_{end_date_t} IMMEDIATE;"))

# ******************************************************************************
# Insert data ----
# ******************************************************************************
for (y in start_date_yr:(end_date_yr)) {
  cat("Insert data for year = ", y, "\n")

  q_rrda_wlgp_pde <- str_glue("
      INSERT INTO {schema_w}.RRDA_WLGP_NF_PERSON_DAY_EVENT_{end_date_t}
          SELECT p.event_id,
                 c.event_cd_id,
                 c.event_val
          FROM {schema_w}.RRDA_WLGP_NF_PERSON_DAY_{end_date_t} p
          INNER JOIN {schema_w}.RRDA_WLGP_WDSD_GP_REG_CURATED_{end_date_t} c
          ON p.alf_e = c.alf_e
          AND p.event_dt = c.event_dt
          AND p.actual_practice_cd_e = c.wdsd_prac_cd_e
          WHERE event_yr = {y}
          AND gp2gp_transferred IN ('Y', 'N') -- Only version A or B records
    ")

  db2_run(conn, q_rrda_wlgp_pde)
}
