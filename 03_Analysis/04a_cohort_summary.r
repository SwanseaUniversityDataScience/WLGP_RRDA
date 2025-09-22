source("clear_workspace.r")


# load =========================================================================
cat("load\n")

qload(s_drive("d_wlgp_activity.qsm"))


# prepare datasets for overall summaries =======================================
cat("prepare datasets for overall summaries\n")

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

d_cohort <-
    d_cohort %>%
    mutate(
        total = "total",
        year_of_birth = floor(year(wob) / 10) * 10,
        year_of_birth = factor(year_of_birth),
        sex = factor(sex, lkp_sex, names(lkp_sex))
    ) %>%
    mutate(
        ever_wimd2019_q1 = if_any(matches("wimd2019_quintile"), ~ . == 1),
        ever_wimd2019_q2 = if_any(matches("wimd2019_quintile"), ~ . == 2),
        ever_wimd2019_q3 = if_any(matches("wimd2019_quintile"), ~ . == 3),
        ever_wimd2019_q4 = if_any(matches("wimd2019_quintile"), ~ . == 4),
        ever_wimd2019_q5 = if_any(matches("wimd2019_quintile"), ~ . == 5)
    ) %>%
    mutate(across(
        .cols = matches("^ever_wimd2019_q[1-5]$"),
        .fns = ~ factor(replace_na(.x, FALSE), c(FALSE, TRUE), c(0, 1))
    ))

d_cohort_resid_overall <-
    d_cohort %>%
    select(
        alf_e,
        total,
        year_of_birth,
        sex,
        wimd2019_q1 = ever_wimd2019_q1,
        wimd2019_q2 = ever_wimd2019_q2,
        wimd2019_q3 = ever_wimd2019_q3,
        wimd2019_q4 = ever_wimd2019_q4,
        wimd2019_q5 = ever_wimd2019_q5
    )

d_cohort_gp_overall <-
    d_cohort %>%
    filter(gp_ever_flg == 1) %>%
    select(
        alf_e,
        total,
        year_of_birth,
        sex,
        wimd2019_q1 = ever_wimd2019_q1,
        wimd2019_q2 = ever_wimd2019_q2,
        wimd2019_q3 = ever_wimd2019_q3,
        wimd2019_q4 = ever_wimd2019_q4,
        wimd2019_q5 = ever_wimd2019_q5
    )


# make overall cohort summaries ==================================================
cat("make overall cohort summaries\n")

univar_summary <- function(x, d) {
    xlvl <- c("xlvl" = x)

    d %>%
    group_by_at(x) %>%
    summarise(n = n()) %>%
    ungroup() %>%
    rename(any_of(xlvl)) %>%
    mutate(
        xvar = x,
        n = suppress_n(n),
        p = n / sum(n, na.rm = TRUE),
        p = round(p, 3)
    ) %>%
    select(xvar, xlvl, n, p) %>%
    mutate(
        xlvl = as.character(xlvl)
    )
}

xvar <- c(
    "total",
    "sex",
    "wimd2019_q1",
    "wimd2019_q2",
    "wimd2019_q3",
    "wimd2019_q4",
    "wimd2019_q5",
    "year_of_birth"
)

t_cohort_resid_overall <-
    lapply(xvar, univar_summary, d = d_cohort_resid_overall) %>%
    bind_rows() %>%
    filter(!(str_detect(xvar, "wimd2019") & xlvl == 0)) %>%
    mutate(
        xlvl = if_else(xvar == "wimd2019_q1", "1", xlvl),
        xlvl = if_else(xvar == "wimd2019_q2", "2", xlvl),
        xlvl = if_else(xvar == "wimd2019_q3", "3", xlvl),
        xlvl = if_else(xvar == "wimd2019_q4", "4", xlvl),
        xlvl = if_else(xvar == "wimd2019_q5", "5", xlvl),
        xvar = if_else(str_detect(xvar, "wimd2019"), "wimd", xvar)
    ) %>%
    rename(
        pop_n = n,
        pop_p = p
    )

t_cohort_gp_overall <-
    lapply(xvar, univar_summary, d = d_cohort_gp_overall) %>%
    bind_rows() %>%
    filter(!(str_detect(xvar, "wimd2019") & xlvl == 0)) %>%
    mutate(
        xlvl = if_else(xvar == "wimd2019_q1", "1", xlvl),
        xlvl = if_else(xvar == "wimd2019_q2", "2", xlvl),
        xlvl = if_else(xvar == "wimd2019_q3", "3", xlvl),
        xlvl = if_else(xvar == "wimd2019_q4", "4", xlvl),
        xlvl = if_else(xvar == "wimd2019_q5", "5", xlvl),
        xvar = if_else(str_detect(xvar, "wimd2019"), "wimd", xvar)
    ) %>%
    rename(
        gpreg_n = n,
        gpreg_p = p
    )


# prepare events summary =======================================================
cat("prepare events summary\n")

t_gp_activity_overall <-
    d_cohort_summary_gp_activity %>%
    group_by(xvar, xlvl) %>%
    summarise(event_n = sum(event_n)) %>%
    ungroup() %>%
    group_by(xvar) %>%
    mutate(
        event_n = suppress_n(event_n),
        event_p = event_n / sum(event_n, na.rm = TRUE)
    ) %>%
    ungroup()


# merge ========================================================================
cat("merge\n")

t_cohort_overall <-
    t_cohort_resid_overall %>%
    full_join(t_cohort_gp_overall, join_by(xvar, xlvl)) %>%
    full_join(t_gp_activity_overall, join_by(xvar, xlvl)) %>%
    mutate(
        xvar = fct_inorder(xvar),
        xlvl = fct_inorder(xlvl)
    )

# check counts are consistent

t_cohort_overall %>%
    group_by(xvar) %>%
    summarise(
        pop_n = sum(pop_n),
        gpreg_n = sum(gpreg_n),
        event_n = sum(event_n)
    )



# make yearly cohort summary ===================================================
cat("make yearly cohort summary ")

age_breaks <- c(0, 16, 35, 50, 65, 110, 999)
age_labels <- c("00_15", "16_34", "35_49", "50_64", "65_110", "111_999")

l_cohort_years <- list()

for (yr in 1990:2024) {
    cat(".")
    # define key variables
    resid    <- d_cohort[[str_glue("resid{yr}_flg")]] == 1
    gp_reg   <- d_cohort[[str_glue("gp{yr}_flg")]] == 1
    mid_year <- ymd(str_glue("{yr}-07-01"))
    wimd     <- factor(d_cohort[[str_glue("resid{yr}_wimd2019_quintile")]], lkp_wimd, names(lkp_wimd))

    # prep data
    d_cohort_year <-
        d_cohort %>%
        mutate(
            age = interval(wob, mid_year) / dyears(),
            age = cut(age, breaks = age_breaks, labels = age_labels, include.lowest = TRUE, right = FALSE),
            age = factor(age),
            wimd = wimd
        )

    d_cohort_pop <-
        d_cohort_year %>%
        filter(resid) %>%
        select(alf_e, age, sex, wimd, total)

    d_cohort_gpreg <-
        d_cohort_year %>%
        filter(gp_reg) %>%
        select(alf_e, age, sex, wimd, total)

    # select xvars
    xvar <- c(
        "total",
        "sex",
        "wimd",
        "age"
    )

    # make summary
    t_cohort_pop   <-
        lapply(xvar, univar_summary, d = d_cohort_pop) %>%
        bind_rows() %>%
        rename(pop_n = n, pop_p = p)

    t_cohort_gpreg <-
        lapply(xvar, univar_summary, d = d_cohort_gpreg) %>%
        bind_rows() %>%
        rename(gpreg_n = n, gpreg_p = p)

    t_cohort_year <- full_join(t_cohort_pop, t_cohort_gpreg, join_by(xvar, xlvl))

    # store summary
    l_cohort_years[[as.character(yr)]] <- t_cohort_year
}
cat("\n")

d_cohort_year <-
    l_cohort_years %>%
    bind_rows(.id = "year")

t_cohort_year_total <-
    d_cohort_year %>%
    filter(xvar == "total") %>%
    select(-pop_p, -gpreg_p) %>%
    select(xvar, everything()) %>%
    pivot_wider(
        values_from = c(pop_n, gpreg_n),
        names_from = xlvl,
        names_glue = "{xlvl}_{.value}",
        names_vary = "slowest"
    )

t_cohort_year_sex <-
    d_cohort_year %>%
    filter(xvar == "sex") %>%
    select(-pop_p, -gpreg_p) %>%
    select(xvar, everything()) %>%
    pivot_wider(
        values_from = c(pop_n, gpreg_n),
        names_from = xlvl,
        names_glue = "{xlvl}_{.value}",
        names_vary = "slowest"
    )

t_cohort_year_wimd <-
    d_cohort_year %>%
    filter(xvar == "wimd") %>%
    select(-pop_p, -gpreg_p) %>%
    select(xvar, everything()) %>%
    pivot_wider(
        values_from = c(pop_n, gpreg_n),
        names_from = xlvl,
        names_glue = "{xlvl}_{.value}",
        names_vary = "slowest"
    )

t_cohort_year_age <-
    d_cohort_year %>%
    filter(xvar == "age") %>%
    select(-pop_p, -gpreg_p) %>%
    select(xvar, everything()) %>%
    pivot_wider(
        values_from = c(pop_n, gpreg_n),
        names_from = xlvl,
        names_glue = "age{xlvl}_{.value}",
        names_vary = "slowest"
    )

# save =========================================================================

cat("save\n")

qsavem(
    t_cohort_overall,
    t_cohort_year_total,
    t_cohort_year_sex,
    t_cohort_year_wimd,
    t_cohort_year_age,
    file = s_drive("cohort_summary.qsm")
)

# print ========================================================================
cat("print\n")

t_cohort_overall %>%
kable_pretty() %>%
print()


p_raw_coverage <-
    t_cohort_year_total %>%
    pivot_longer(
        cols = c(total_pop_n, total_gpreg_n)
    ) %>%
    ggplot(aes(
        x = year,
        y = value,
        group = name,
        colour = name
    )) +
    geom_line() +
    ylim(0, NA)

print(p_raw_coverage)

beep()
