# ******************************************************************************
# Script:        06_RRDA_WLGP_NF_PERSON_DAY.R
# About:         Create normalised form (NF) of WLGP RRDA - person-day table
# Author:        Hoda Abbasizanjani
# Creation date: April 2025
# ******************************************************************************
# Prepare workspace and set variables ----
# ******************************************************************************
source("01_Prep_Workspace.R")
source("02_WLGP_RRDA_Parameters.R")

# ******************************************************************************
# Create normalised person-day table with unique event ID ----
# ******************************************************************************
print(str_glue("Create {schema_w}.RRDA_WLGP_NF_PERSON_DAY_{end_date_t} \n"))

q_create_rrda_wlgp_pd <- str_glue("
    CREATE TABLE {schema_w}.RRDA_WLGP_NF_PERSON_DAY_{end_date_t} (
        event_id                    bigint,
        alf_e                       bigint,
        alf_sts_cd                  char(2),
        event_dt                    date,
        actual_practice_cd_e        int
    )
    DISTRIBUTE BY HASH(alf_e);
")

db2_run(conn, q_create_rrda_wlgp_pd)

#db2_run(conn, str_glue("DROP TABLE {schema_w}.RRDA_WLGP_NF_PERSON_DAY_{end_date_t}"))
#db2_run(conn, str_glue("TRUNCATE TABLE {schema_w}.RRDA_WLGP_NF_PERSON_DAY_{end_date_t} IMMEDIATE;"))

# ******************************************************************************
# Insert data ----
# ******************************************************************************
for (y in start_date_yr:(end_date_yr)) {
  cat("Insert data for year = ", y, "\n")

  # To harmonise format of event ID (11-digit number, left 2 digits show coded year)
  yr_id <- (y - 1980) * 10^9

  q_rrda_wlgp_pd <- str_glue("
      INSERT INTO {schema_w}.RRDA_WLGP_NF_PERSON_DAY_{end_date_t}
          SELECT ROW_NUMBER() OVER (PARTITION BY event_yr ORDER BY alf_e, event_dt, wdsd_prac_cd_e)
                              + {yr_id} AS event_id,
                 alf_e,
                 alf_sts_cd,
                 event_dt,
                 wdsd_prac_cd_e
          FROM (SELECT alf_e,
                       alf_sts_cd,
                       event_dt,
                       wdsd_prac_cd_e,
                       event_yr,
                       ROW_NUMBER() OVER (PARTITION BY alf_e, event_dt, wdsd_prac_cd_e ORDER BY event_cd) AS event_num
                FROM {schema_w}.RRDA_WLGP_WDSD_GP_REG_CURATED_{end_date_t}
                WHERE event_yr = {y}
                AND gp2gp_transferred IN ('Y', 'N')  -- Only version A or B of records
               )
          WHERE event_num = 1
  ")

  db2_run(conn, q_rrda_wlgp_pd)
}
