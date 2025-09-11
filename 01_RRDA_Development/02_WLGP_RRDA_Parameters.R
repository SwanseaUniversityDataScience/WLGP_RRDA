# ******************************************************************************
# Script:        02_WLGP_RRDA_Parameters.R
# About:         Set RRDA parameters (schema/table names, coverage end date, etc.)
# Author:        Hoda Abbasizanjani
# Date:          2025

# ******************************************************************************
# Define schema related parameters ----
# ******************************************************************************
cat("Setting parameters\n")

# Schemas
schema_v <- readline(prompt = "Enter name of V schema")
schema_w <- readline(prompt = "Enter name of W schema")

# ******************************************************************************
# Define version parameters ----
# ******************************************************************************
# List of WLGP_GP_EVENT_CLEANSED versions
wlgp_versions <- db2_run(conn,
  str_glue("
    SELECT TABNAME FROM SYSCAT.TABLES
    WHERE TABSCHEMA = '{schema_v}'
    AND TABNAME LIKE 'WLGP_GP_EVENT_CLEANSED_%'
    ORDER BY TABNAME")
  )

# Select version of WLGP
i <- as.integer(readline(prompt = "Enter version of WLGP (0 = latest version, 1 = one version before latest, etc.)"))
#i = 0 for last version
#i = 1 for one version before the latest
#i = 2 for two versions before the latest

wlgp_event <- str_glue("{schema_v}.{wlgp_versions[nrow(wlgp_versions) - i,]}")


# List of WLGP_CLEAN_GP_REG_BY_PRAC_INCLNONSAIL_MEDIAN versions
wlgp_gp_flag_versions <- db2_run(conn,
  str_glue("
    SELECT TABNAME FROM SYSCAT.TABLES
    WHERE TABSCHEMA = '{schema_v}'
    AND TABNAME LIKE 'WLGP_CLEAN_GP_REG_BY_PRAC_INCLNONSAIL_MEDIAN_%'
    ORDER BY TABNAME")
  )

# WLGP_CLEAN_GP_REG_BY_PRAC_INCLNONSAIL_MEDIAN versions are same as WLGP_GP_EVENT_CLEANSED tables
wlgp_gp_flag <- str_glue("{schema_v}.{wlgp_gp_flag_versions[nrow(wlgp_gp_flag_versions) - i,]}")


# List of WDSD_PER_RESIDENCE_GPREG versions
wdsd_gp_reg_versions <- db2_run(conn,
  str_glue("
    SELECT TABNAME FROM SYSCAT.TABLES
    WHERE TABSCHEMA = '{schema_v}'
    AND TABNAME LIKE 'WDSD_PER_RESIDENCE_GPREG_%'
    ORDER BY TABNAME")
  )

# Use last version of WDSD tables
wdsd_gp_reg <- str_glue("{schema_v}.{last(wdsd_gp_reg_versions)}")


rm(wlgp_versions, wlgp_gp_flag_versions, wdsd_gp_reg_versions)

# ******************************************************************************
# Define coverage parameters ----
# ******************************************************************************
# Coverage start date
start_date_yr <- as.integer(readline(prompt = "Enter coverage start year"))

# Extract the WLGP coverage end date using table name
# end date = date at the end of table name - 1 day (for data provided since 2021)
# For more info see the Confluence page on WLGP coverage report
end_date <- ymd(substr(wlgp_event,nchar(wlgp_event) - 8 + 1, nchar(wlgp_event))) - 1

end_date_t <- format(end_date, "%Y%m%d")
end_date_yr <- as.numeric(format(end_date, "%Y"))

# ******************************************************************************
# Other variables ----
# ******************************************************************************
event_intrvl_3m <- c('(1,2,3)', '(4,5,6)', '(7,8,9)', '(10,11,12)')

filepath <- "Results"
