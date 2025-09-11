# ******************************************************************************
# Script:        04_WLGP_WDSD_GP_REG_DATED.R
# About:         Create a copy of WLGP records with additional columns for
#                patients with a GP registration information history
# Author:        Hoda Abbasizanjani
# Date:          2025

# ******************************************************************************
# Prepare workspace and load parameters ----
# ******************************************************************************
source("01_Prep_Workspace.R")
source("02_WLGP_RRDA_Parameters.R")

# ******************************************************************************
# Create dated table on DB2 ----
# ******************************************************************************
wlgp_wdsd_gp_reg <- str_glue("{schema_w}.RRDA_WLGP_WDSD_GP_REG_{end_date_t}")

q_create_wlgp_wdsd <- str_glue("
    CREATE TABLE {wlgp_wdsd_gp_reg} (
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
        event_yr               int,
        --------------------------
        wdsd_prac_cd_pe        int,
        wdsd_prac_start_dt     date,
        wdsd_prac_end_dt       date,     -- For current GP practice, end date is NULL in WDSD_PER_RESIDENCE_GPREG, so converted to '9999-12-31'
        wdsd_prac_matched      smallint
      )
  DISTRIBUTE BY HASH(alf_pe);
")

db2_run(conn, q_create_wlgp_wdsd)

#db2_run(conn, str_glue("DROP TABLE {wlgp_wdsd_gp_reg}"))
#db2_run(conn, str_glue("TRUNCATE TABLE {wlgp_wdsd_gp_reg} IMMEDIATE"))

# ******************************************************************************
# Insert data ----
# ******************************************************************************
# Insert data from start_date_yr to end_date_yr
for (y in start_date_yr:(end_date_yr)) {
  for (m in event_intrvl_3m) {
    cat("Insert WLGP data for year = ", y, "and months", m, "\n")

    q_insert_wlgp_wdsd <- str_glue("
        INSERT INTO {wlgp_wdsd_gp_reg}
            SELECT g.alf_pe,
                   g.alf_sts_cd,
                   g.alf_mtch_pct,
                   g.gndr_cd,
                   g.wob,
                   g.lsoa_cd,
                   g.prac_cd_pe,
                   g.event_dt,
                   TRIM(g.event_cd),
                   g.event_val,
                   g.event_yr,
                   r.prac_cd_pe AS wdsd_prac_cd_pe,
                   r.activefrom AS wdsd_prac_start_dt,
                   CASE WHEN r.activeto IS NULL THEN '9999-12-31' ELSE r.activeto END AS wdsd_prac_end_dt,
                   CASE WHEN g.prac_cd_pe = r.prac_cd_pe THEN 1 ELSE 0 END AS wdsd_prac_matched
            FROM {wlgp_event} g
            INNER JOIN {wdsd_gp_reg} r
            ON g.alf_pe = r.alf_pe
            AND r.activefrom IS NOT NULL
            AND r.prac_cd_pe IS NOT NULL
            AND event_dt >= activefrom
            AND event_dt <= (CASE WHEN r.activeto IS NULL THEN '9999-12-31' ELSE r.activeto END)  -- 'activeto' is NULL for current registered practice
            WHERE event_yr = {y}
            AND MONTH(event_dt) IN {m}
            AND event_dt <= '{end_date}';
    ")

    db2_run(conn, q_insert_wlgp_wdsd)
  }
}

# ******************************************************************************
# Basic checks
# ******************************************************************************
q_cnt_yr <- str_glue("
    SELECT event_yr, count(*) AS freq
    FROM {wlgp_wdsd_gp_reg}
    GROUP BY event_yr
    ORDER BY event_yr;
")

cnt_yr <- db2_run(conn, q_cnt_yr)
