source("clear_workspace.r")

con <- db2_open()

# make a lookup for mapping lsoa to health board ===============================
cat("load and join\n")

d_lsoa <-
    read_csv(
        file = s_drive("lookup/LSOA_(2011)_to_LSOA_(2021)_to_Local_Authority_District_(2022)_Best_Fit_Lookup_for_EW_(V2).csv")
    ) %>% 
    clean_names() %>% 
    filter(str_detect(lsoa11cd, "^W")) %>% 
    # make an ID
    mutate(
        id = str_replace(lsoa11cd, "^W01", ""),
        id = as.integer(id)
    ) %>% 
    select(
        id,
        lsoa11cd,
        lsoa21cd,
        lad22cd,
        lad22nm
    )


d_lhb <-
    read_csv(
        file = s_drive("lookup/Unitary_Authority_to_Local_Health_Board_(December_2023)_Lookup_in_Wales.csv")
    ) %>% 
    clean_names() %>% 
    select(
        ua23cd,
        ua23nm,
        lhb23cd,
        lhb23nm
    )

d_lsoa_lad_lhb <-
    full_join(
        x = d_lsoa,
        y = d_lhb,
        by = join_by(lad22cd == ua23cd),
        keep = TRUE
    ) %>% 
    select(
        id,
        lsoa11cd,
        lad22cd,
        lad22nm,
        lhb23cd,
        lhb23nm
    )


# check ========================================================================
cat("check")

d_lsoa_lad_lhb %>% verify(not_na(id))
d_lsoa_lad_lhb %>% assert(is_uniq, id)
d_lsoa_lad_lhb %>% verify(not_na(lsoa11cd))
d_lsoa_lad_lhb %>% verify(not_na(lad22cd))
d_lsoa_lad_lhb %>% verify(not_na(lhb23cd))


# write to db2 =================================================================
cat("write\n")

db2_write(
    data = d_lsoa_lad_lhb,
    conn = con,
    tab_name = "sailw1151v.sb_wlgp_activity_lkp_lsoa_lad_lhb",
    pk_col = "lsoa11cd",
    drop_if_exists = TRUE
)

db2_close(con)
