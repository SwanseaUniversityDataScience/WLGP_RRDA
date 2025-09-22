source("clear_workspace.r")


# load =========================================================================
cat("load\n")

qload(s_drive("d_wlgp_activity.qsm"))


# prepare annual pop counts ====================================================
cat("prepare annual pop counts")

l_cohort_year <- list()

for (yr in 2000:2024) {
    #yr = 2000
    cat(".")

    # define key variables
    resid  <- d_cohort[[str_glue("resid{yr}_flg")]] == 1
    gp_reg <- d_cohort[[str_glue("gp{yr}_flg")]] == 1

    d_cohort_yr <- data.frame(
        year    = yr,
        pop_n   = d_cohort %>% filter(resid)  %>% count() %>% pull(n) %>% suppress_n(),
        gpreg_n = d_cohort %>% filter(gp_reg) %>% count() %>% pull(n) %>% suppress_n()
    )

    # store summary
    l_cohort_year[[as.character(yr)]] <- d_cohort_yr
}
cat("\n")

d_cohort_year <- bind_rows(l_cohort_year)


# prepare GP activity data frame ===============================================
cat("prep GP  activity\n")

d_activity <- bind_rows(
    d_gp_monthly_admin,
    d_gp_monthly_certificate,
    d_gp_monthly_consultation,
    d_gp_monthly_failed_encounter,
    d_gp_monthly_prescription,
    d_gp_monthly_review_monitor,
    d_gp_monthly_screening_assessment,
    d_gp_monthly_vaccination
)

lkp_activity <- c(
    "Consultation"                  = "consultation",
    "Prescription\nOnly"            = "prescription_only",
    "Vaccination"                   = "vaccination",
    "Patient Review\nor Monitoring" = "patient_review_monitor",
    "Screening\nor Assessment"      = "screening_assessment",
    "Certificate"                   = "certificate",
    "Admin Only"                    = "admin_only",
    "Failed\nEncounter"             = "failed_encounter"
)

ts_activity <-
    d_activity %>%
    rename(event_dt = event_month) %>% 
    # add pop counts
    mutate(year = year(event_dt)) %>%
    inner_join(d_cohort_year, by = "year") %>%
    # set up for trend analysis
    mutate(
        train_test = case_when(
            activity_cat == "vaccination" & year %in% 2021:2022 ~ "test",
            activity_cat != "vaccination" & year %in% 2020:2021 ~ "test",
            TRUE ~ "train"
        ),
        event_n = suppress_n(event_n),
        pop_n = suppress_n(pop_n),
        gpreg_n = suppress_n(gpreg_n),
        rate = event_n / days_in_month(event_dt), # events per day
        month = tsibble::yearmonth(event_dt),
        train_test = factor(train_test)
    ) %>%
    select(
        activity_cat,
        year,
        month,
        train_test,
        rate,
        event_dt,
        event_n,
        pop_n,
        gpreg_n
    ) %>%
    tsibble::as_tsibble(key = activity_cat, index = month)


# save =========================================================================
cat("save\n")

qsavem(
	lkp_activity,
	ts_activity,
	file = s_drive("gp_activity_clean.qsm")
)


# print plot ===================================================================
cat("print plot\n")

print(
	ts_activity %>%
    ggplot(aes(
        x = event_dt,
        y = rate,
        colour = activity_cat
    )) +
    facet_wrap(~ activity_cat, ncol = 1, scales = "free_y") +
    geom_line() +
	xlab("month") +
	ylab("average monthly events per day")
)
beep()
