# ******************************************************************************
# Script:        03_WLGP_RRDA_Clinical_Codes_LK.R
# About:         Create a list of clinical codes for Wales primary care data
# Authors:       Hoda Abbasizanjani, Stuart Bedston, Ashley Akbari
# Date:          2025

# ******************************************************************************
# Prepare workspace & load parameters ----
# ******************************************************************************
source("01_Prep_Workspace.R")
source("02_WLGP_RRDA_Parameters.R")

lk_code_type <- c(
  "Read V2",
  "SNOMED",
  "Vision",
  "EMIS",
  "Other Read or Vision",
  "Other EMIS",
  "Blank, 'ZZZ' or invalid",
  "Unknown type"
)

# ******************************************************************************
# Find & load the latest LK of Read V2 and local codes
# ******************************************************************************
wlgp_read_and_local_codes <- db2_run(conn,
  str_glue("
    SELECT TABNAME FROM SYSCAT.TABLES
    WHERE TABSCHEMA = '{schema_w}'
    AND TABNAME LIKE 'RRDA_WLGP_CLINICAL_CODES_READ_LOCAL_%'
    ORDER BY TABNAME")
  )

wlgp_read_and_local_codes <- last(wlgp_read_and_local_codes)

lk_read_and_local_codes <- db2_run(conn, str_glue("SELECT * FROM {schema_w}.{wlgp_read_and_local_codes}"))

# ******************************************************************************
# Load SNOMED codes (available in SAIL) ----
# ******************************************************************************
snomed <- db2_run(conn, "SELECT concept_id, term FROM SAILUKHDV.SNOMED_DESCRIPTIONS_SCD WHERE is_latest = 1")

snomed <-
  snomed %>%
  setnames(new = c("code", "code_description")) %>%
  lazy_dt() %>%
  # Remove duplicate SNOMED codes
  group_by(code) %>%
  summarise(across(everything(), first)) %>%
  ungroup() %>%
  # Harmonisation of columns
  mutate(
    code = as.character(code),
    code_description = stri_trans_general(code_description, "latin-ascii"),
    code_type = "SNOMED",
    code_source = "SAILUKHDV",
    sensitive = NA
  ) %>%
  as_tibble()

# ******************************************************************************
# Put together a list of all known clinical codes used in WLGP data ----
# ******************************************************************************
primary_care_codes <- rbind(lk_read_and_local_codes, snomed)

# De-duplicate combined list
primary_care_codes <-
  primary_care_codes %>%
  lazy_dt() %>%
  mutate(
    code_type = factor(code_type, lk_code_type)
    ) %>%
  arrange(code, code_type) %>%
  group_by(code) %>%
  mutate(
    row_num = row_number()
    ) %>%
  ungroup() %>%
  filter(row_num == 1) %>%
  as_tibble() %>%
  dplyr::select(-row_num)

# ******************************************************************************
# Create a DB2 table of known primary care codes ----
# ******************************************************************************
lk_known_codes <- str_glue(schema_w,".RRDA_WLGP_CLINICAL_CODES_KNOWN_",format(Sys.Date(), "%Y%m%d"))

db2_write(
  data           = primary_care_codes,
  conn           = conn,
  tab_name       = lk_known_codes,
  drop_if_exists = TRUE,
  grant_all      = TRUE
)

# ******************************************************************************
# Identify unknown codes used in WLGP ----
# ******************************************************************************
q_unknown_codes <- str_glue("SELECT event_cd AS code, count(*) AS freq
                            FROM {wlgp_event} g
                            LEFT JOIN {lk_known_codes} c
                            ON g.event_cd = c.code
                            WHERE code_type IS NULL
                            AND event_yr BETWEEN {start_date_yr} AND {end_date_yr}
                            GROUP BY event_cd
                            ")

unknown_codes <- db2_run(conn, q_unknown_codes)

unknown_codes <-
  unknown_codes %>%
  dplyr::select(-freq) %>%
  mutate(
    code_description = NA,
    sensitive = NA,
    code_type = ifelse(grepl("zzz", code, ignore.case = T) == TRUE
                       # to exclude any character other than letters, numbers, asterisk (*), and hat (^)
                       | grepl("^[a-zA-Z0-9\\*\\^]", code) == FALSE,
                       "Blank, 'ZZZ' or invalid",
                       "Unknown type"),
    code_source = NA
    )

db2_run(conn, str_glue("DROP TABLE {lk_known_codes}"))

# ******************************************************************************
# Create a unique ID for all codes in the LK ----
# ******************************************************************************
primary_care_codes_all <- rbind(primary_care_codes, unknown_codes)

primary_care_codes_all <-
  primary_care_codes_all %>%
  lazy_dt() %>%
  mutate(
    code_type = factor(code_type, lk_code_type),
    prefix = as.numeric(code_type)
  ) %>%
  arrange(code_type, code) %>%
  group_by(code_type) %>%
  mutate(
    row_num = row_number()
  ) %>%
  ungroup() %>%
  as_tibble() %>%
  # Add a harmonised unique code ID, left number shows code type
  mutate(
    row_num = str_pad(row_num, width = 7, side = "left", pad= "0"),
    code_id = str_glue("{prefix}{row_num}"),
    code_id = as.numeric(code_id),
    .before = code
  ) %>%
  dplyr::select(-row_num, -prefix)

# ******************************************************************************
# Create a DB2 table of all primary care codes ----
# ******************************************************************************
db2_write(
  data           = primary_care_codes_all,
  conn           = conn,
  tab_name       = str_glue(schema_w,".RRDA_WLGP_CLINICAL_CODES_ALL_",format(Sys.Date(), "%Y%m%d")),
  drop_if_exists = TRUE,
  grant_all      = TRUE
)
