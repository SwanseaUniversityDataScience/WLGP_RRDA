source("clear_workspace.r")

# load =========================================================================
cat("load\n")

qload(s_drive("d_wlgp_activity.qsm"))


# prepare sail gp flag =========================================================
cat("prepare sail gp flag\n")

d_gp_reg_history <-
    d_cohort_reg_history %>%
    lazy_dt() %>%
    filter(!is.na(prac_cd_e)) %>%
    mutate(
        sail_data_flg = as.logical(sail_data_flg),
        sail_event_flg = event_n > 0
    ) %>%
    select(
        alf_e,
        prac_cd_e,
        prac_start_date,
        prac_end_date,
        sail_data_flg,
        sail_event_flg
    ) %>%
    group_by(alf_e) %>%
    mutate(
        sail_future_flg = rev(cumsum(sail_data_flg)),
        sail_future_flg = sail_future_flg > 0,
        sail_backlog_flg = sail_event_flg & sail_future_flg
    ) %>%
    ungroup() %>%
    as_tibble() %>%
    mutate(
        prac_end_date = if_else(prac_end_date == ymd("9999-12-31"), max(prac_start_date), prac_end_date),
        prac_dur_yr = interval(prac_start_date, prac_end_date) / dyears()
    ) %>%
    select(
        alf_e,
        prac_cd_e,
        prac_start_date,
        prac_end_date,
        prac_dur_yr,
        sail_active_flg = sail_data_flg,
        sail_backlog_flg
    ) %>%
    mutate(
        sail_flg = sail_active_flg | sail_backlog_flg
    )


# prepare mid-year dataset =====================================================
cat("prepare mid-year dataset")

lkp_sex <- c(
    "Male"   = 1,
    "Female" = 2
)

lkp_wimd <- c(
    "q1" = 1,
    "q2" = 2,
    "q3" = 3,
    "q4" = 4,
    "q5" = 5
)

age_breaks <- c(0, 16, 35, 50, 65, 110, 999)
age_labels <- c("00_15", "16_34", "35_49", "50_64", "65_110", "111_999")

l_cohort_years <- list()

for (yr in 1990:2024) {
    # yr = 2001
    cat(".")

    mid_year <- ymd(str_glue("{yr}-07-01"))

    d_gp_reg_year <-
        d_gp_reg_history %>%
        filter(prac_start_date <= mid_year, mid_year <= prac_end_date) %>%
        select(
            alf_e,
            prac_start_date,
            prac_end_date,
            sail_active_flg,
            sail_backlog_flg,
            sail_flg
        )

    rename_lkp <- c(
        "resid_flg"   = str_glue("resid{yr}_flg"),
        "wimd"        = str_glue("resid{yr}_wimd2019_quintile"),
        "healthboard" = str_glue("resid{yr}_healthboard_desc")
    )

    d_cohort_year <-
        d_cohort %>%
        mutate(
            mid_year = mid_year,
            age = lubridate::interval(wob, mid_year) / dyears(),
            age = interval(wob, mid_year) / dyears(),
            age = cut(age, breaks = age_breaks, labels = age_labels, include.lowest = TRUE, right = FALSE),
            age = factor(age),
            sex = factor(sex, lkp_sex, names(lkp_sex))
        ) %>%
        rename(!!rename_lkp) %>%
        select(
            alf_e,
            mid_year,
            resid_flg,
            wob,
            age,
            sex,
            wimd,
            healthboard
        ) %>%
        filter(wob <= mid_year, resid_flg == 1, !is.na(healthboard)) %>%
        arrange(alf_e) %>%
        left_join(d_gp_reg_year, join_by(alf_e == alf_e, between(mid_year, prac_start_date, prac_end_date))) %>%
        select(
            -resid_flg,
            -prac_start_date,
            -prac_end_date
        )

    # store summary
    l_cohort_years[[as.character(yr)]] <- d_cohort_year
}
cat("\n")

cat("counting\n")
d_cohort_years <-
    bind_rows(l_cohort_years) %>%
    mutate(
        sail_active_flg  = replace_na(sail_active_flg, FALSE),
        sail_backlog_flg = replace_na(sail_backlog_flg, FALSE),
        sail_flg         = replace_na(sail_flg, FALSE),
    ) %>%
    arrange(alf_e, mid_year) %>%
    mutate(
        gp_reg_cat = case_when(
            sail_active_flg ~ "Linked (actively shared)",
            sail_backlog_flg ~ "Linked (shared via backlog)",
            !sail_flg ~ "No linked records"
        ),
        gp_reg_cat = factor(
            x = gp_reg_cat,
            levels = c("No linked records", "Linked (shared via backlog)", "Linked (actively shared)")
        ),
        mid_year = year(mid_year)
    ) %>%
    lazy_dt() %>%
    count(
        sex,
        age,
        wimd,
        healthboard,
        mid_year,
        gp_reg_cat
    ) %>%
    as_tibble()


# save ========================================================================-
cat("save data prep\n")

qsavem(
    d_cohort_years,
    d_gp_reg_history,
    file = s_drive("reg_coverage_clean.qsm")
)


cat("done\n")
beep()
