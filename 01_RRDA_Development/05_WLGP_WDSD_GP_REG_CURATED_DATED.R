# ******************************************************************************
# Script:        05_WLGP_WDSD_GP_REG_CURATED_DATED.R
# About:         Create a curated version of WLGP events by compressing records,
#                adding event code type and flagging duplicate records added due
#                to GP2GP transfer
# Author:        Hoda Abbasizanjani
# Creation date: April 2025

# ******************************************************************************
# Prepare workspace and load parameters ----
# ******************************************************************************
source("01_Prep_Workspace.R")
source("02_WLGP_RRDA_Parameters.R")

wlgp_wdsd_gp_reg <- str_glue("{schema_w}.RRDA_WLGP_WDSD_GP_REG_{end_date_t}")

# LK for clinical codes
wlgp_codes_lk <- db2_run(conn,
  str_glue("
    SELECT TABNAME FROM SYSCAT.TABLES
    WHERE TABSCHEMA = '{schema_w}'
    AND TABNAME LIKE 'RRDA_WLGP_CLINICAL_CODES_ALL_%'
    ORDER BY TABNAME")
  )

# Select version of the clinical code LK (same as the WLGP version)
#wlgp_codes_lk <- str_glue("{schema_w}.{wlgp_codes_lk[nrow(wlgp_codes_lk) - i,]}")
wlgp_codes_lk <- str_glue("{schema_w}.{last(wlgp_codes_lk)}")

# ******************************************************************************
# Create dated table on DB2 ----
# ******************************************************************************
wlgp_wdsd_gp_reg_curated <- str_glue("{schema_w}.RRDA_WLGP_WDSD_GP_REG_CURATED_{end_date_t}")

q_create_wlgp_wdsd_curated <- str_glue("
    CREATE TABLE {wlgp_wdsd_gp_reg_curated} (
        alf_pe                 bigint,
        alf_sts_cd             char(2),
        alf_mtch_pct           decimal(7,6),
        gndr_cd                char(1),
        wob                    date,
        lsoa_cd                character(10),
        prac_cd_pe             bigint,
        event_dt               date,
        event_cd               char(40),
        event_val              decimal(31,8),
        event_cd_type          char(23),
        event_cd_id            int,
        event_yr               int,
        wdsd_prac_cd_pe        int,
        wdsd_prac_start_dt     date,
        wdsd_prac_end_dt       date,
        wdsd_prac_matched      smallint,
        duplicate_num          int,
        gp2gp_transferred      char(1)   -- Y/N/U
      )
  DISTRIBUTE BY HASH(alf_pe);
")

db2_run(conn, q_create_wlgp_wdsd_curated)

#db2_run(conn, str_glue("DROP TABLE {wlgp_wdsd_gp_reg_curated}"))
#db2_run(conn, str_glue("TRUNCATE TABLE {wlgp_wdsd_gp_reg_curated} IMMEDIATE;"))

# ******************************************************************************
# Insert data ----
# ******************************************************************************
for (y in start_date_yr:end_date_yr) {
  for (m in event_intrvl_3m) {
    cat("Insert data for year = ", y, "and months", m, "\n")

    q_insert_wlgp_wdsd_curated <- str_glue("
        INSERT INTO {wlgp_wdsd_gp_reg_curated}
            -- RRDA: Compressed WLGP-WDSD with columns to identify duplicates & GP2GP transferred records
            SELECT alf_pe,
                   alf_sts_cd,
                   alf_mtch_pct,
                   gndr_cd,
                   wob,
                   lsoa_cd,
                   prac_cd_pe,
                   event_dt,
                   event_cd,
                   event_val,
                   c.code_type AS event_cd_type,
                   c.code_id AS event_cd_id,
                   event_yr,
                   wdsd_prac_cd_pe,
                   wdsd_prac_start_dt,
                   wdsd_prac_end_dt,
                   wdsd_prac_matched,
                   ROW_NUMBER() OVER (PARTITION BY alf_pe, event_dt, event_cd, event_val ORDER BY wdsd_prac_matched DESC, prac_cd_pe) AS duplicate_num,
                   NULL AS gp2gp_transferred
            -- Compressed WLGP_WDSD
            FROM (SELECT *,
                         ROW_NUMBER() OVER (PARTITION BY alf_pe, event_dt, event_cd, event_val, prac_cd_pe ORDER BY wdsd_prac_matched) AS row_num
                  FROM {wlgp_wdsd_gp_reg}
                  WHERE event_yr = {y} AND MONTH(event_dt) IN {m}
                  ) g
            LEFT JOIN {wlgp_codes_lk} c
            ON g.event_cd = c.code
            WHERE row_num = 1
    ")

    db2_run(conn, q_insert_wlgp_wdsd_curated)
  }
}

# ******************************************************************************
# Identify GP2GP transferred records ----
# ******************************************************************************
cat("Update GP2GP flag \n")

for (y in start_date_yr: end_date_yr) {
  for (m in event_intrvl_3m) {
    cat("Update flag for year = ", y, "and months", m, "\n")

    q_update_wlgp_wdsd_curated <- str_glue("
        UPDATE {wlgp_wdsd_gp_reg_curated}
        SET gp2gp_transferred = CASE WHEN duplicate_num = 1 AND wdsd_prac_matched = 1 THEN 'N' -- Version A records
                                     WHEN duplicate_num = 1 AND wdsd_prac_matched = 0 THEN 'Y' -- Version B records
                                     ELSE 'U'
                                END -- These records to be excluded from normalised form
        WHERE event_yr = {y} AND MONTH(event_dt) IN {m}
    ")

    db2_run(conn, q_update_wlgp_wdsd_curated)
  }
}

# ******************************************************************************
# Basic checks
# ******************************************************************************
q_cnt_yr <- str_glue("
    SELECT event_yr, count(*) AS freq
    FROM {wlgp_wdsd_gp_reg_curated}
    GROUP BY event_yr
    ORDER BY event_yr;
")

cnt_yr <- db2_run(conn, q_cnt_yr)

q_cnt_gp2gp <- str_glue("
    SELECT event_yr, gp2gp_transferred, count(*) AS freq
    FROM {wlgp_wdsd_gp_reg_curated}
    GROUP BY event_yr, gp2gp_transferred
    ORDER BY event_yr, gp2gp_transferred
")

cnt_gp2gp <- db2_run(conn, q_cnt_gp2gp)
