source("clear_workspace.r")

suppress_p <- function(x) {
    janitor::round_half_up(x, 3)
}

pal <- c(
    "No linked records"           = "#fc8d62",
    "Linked (shared via backlog)" = "#8da0cb",
    "Linked (actively shared)"    = "#66c2a5"
)

x_breaks <- seq(from = 1990, to = 2025, by = 5)


# load =========================================================================
cat("load\n")

qload(s_drive("reg_coverage_clean.qsm"))


# ons health board pop estimates

d_cohort_hb_total <-
    d_cohort_years %>%
    lazy_dt() %>%
    group_by(mid_year, healthboard) %>%
    summarise(cohort_n = sum(n)) %>% 
    ungroup() %>% 
    mutate(cohort_n = suppress_n(cohort_n)) %>%
    as_tibble()

d_ons_lhb_mye <-
    read_csv(
        file = s_drive("lookup/ons_lhb_mye_2001_2024.csv")
    ) %>% 
    group_by(lhb_cd, lhb_nm, unit, year) %>% 
    summarise(value = mean(value)) %>% 
    ungroup() %>% 
    select(
        healthboard = lhb_nm,
        mid_year = year,
        n = value
    ) %>% 
    left_join(d_cohort_hb_total, by = c("mid_year", "healthboard")) %>% 
    mutate(
        p = n / cohort_n,
        p = round(p, 3)
    )

# ons wales estimates

d_cohort_total <-
    d_cohort_years %>%
    lazy_dt() %>%
    group_by(mid_year) %>%
    summarise(cohort_n = sum(n)) %>% 
    ungroup() %>% 
    mutate(cohort_n = suppress_n(cohort_n)) %>%
    as_tibble()

d_ons_wales_mye <-
    d_ons_lhb_mye %>% 
    group_by(mid_year) %>% 
    summarise(n = sum(n)) %>% 
    left_join(d_cohort_total, by = "mid_year") %>% 
    mutate(
        p = n / cohort_n,
        p = round(p, 3)
    )

d_ons_wales_mye %>% filter(mid_year %in% c(1990,2000,2010,2020,2024))

# plot coverage ================================================================
cat("plot coverage:\n")

# overall ----------------------------------------------------------------------
cat("\toverall\n")

d_reg_overall_summary <-
    d_cohort_years %>%
    lazy_dt() %>%
    group_by(mid_year, gp_reg_cat) %>%
    summarise(n = sum(n)) %>%
    group_by(mid_year) %>%
    mutate(
        n = suppress_n(n),
        p = n / sum(n),
        p = suppress_p(p)
    ) %>%
    ungroup() %>%
    as_tibble()

p_reg_overall_n <-
    d_reg_overall_summary %>%
    ggplot(aes(
        x = mid_year,
        y = n,
        fill = gp_reg_cat
    )) +
    geom_col() +
    geom_line(
        mapping = aes(fill = NULL),
        data = d_ons_wales_mye,
        linetype = 2
    ) +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "Mid-year count",
        limits = c(0, 3.5) * 10^6,
        breaks = breaks_pretty(6),
        labels = label_number(scale_cut = cut_short_scale())
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme_bw(base_size = 10) +
    theme(
        axis.title.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        legend.position = "bottom",
        legend.title = element_text(face = "bold"),
        strip.background = element_blank(),
        strip.text = element_text(face = "bold")
    ) +
    ggtitle("(a) National coverage")

p_reg_overall_p <-
    d_reg_overall_summary %>%
    ggplot(aes(
        x = mid_year,
        y = p,
        fill = gp_reg_cat
    )) +
    geom_col() +
    geom_line(
        mapping = aes(fill = NULL),
        data = d_ons_wales_mye,
        linetype = 2
    ) +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "",
        limits = c(0, NA),
        breaks = breaks_pretty(5),
        labels = label_percent()
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme_bw(base_size = 10) +
    theme(
        axis.title.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        legend.position = "bottom",
        legend.title = element_text(face = "bold"),
        strip.background = element_blank(),
        strip.text = element_text(face = "bold")
    )


# health board -----------------------------------------------------------------
cat("\thealth board\n")



expr_year <- "([0-9]{2})([0-9]{2})"

lkp_hb <- c(
    "Betsi Cadwaladr"   = "Betsi Cadwaladr University Health Board",
    "Powys"             = "Powys Teaching Health Board",
    "Hywel Dda"         = "Hywel Dda University Health Board",
    "Aneurin Bevan"     = "Aneurin Bevan University Health Board",
    "Cwm Taf Morgannwg" = "Cwm Taf Morgannwg University Health Board",
    "Swansea Bay"       = "Swansea Bay University Health Board",
    "Cardiff and Vale"  = "Cardiff and Vale University Health Board"
)

d_lhb_mye <-
    d_ons_lhb_mye %>% 
    mutate(
        healthboard = factor(healthboard, lkp_hb, names(lkp_hb))
    )

d_reg_healthboard_summary <-
    d_cohort_years %>%
    lazy_dt() %>%
    mutate(healthboard = factor(healthboard, lkp_hb, names(lkp_hb))) %>%
    group_by(healthboard, mid_year, gp_reg_cat) %>%
    summarise(n = sum(n)) %>%
    group_by(healthboard, mid_year) %>%
    mutate(
        n = suppress_n(n),
        p = n / sum(n),
        p = suppress_p(p)
    ) %>%
    ungroup() %>%
    as_tibble()

p_reg_healthboard_n <-
    d_reg_healthboard_summary %>%
    ggplot(aes(
        x = mid_year,
        y = n,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ healthboard, ncol = 2) +
    geom_col() +
    geom_line(
        mapping = aes(fill = NULL),
        data = d_lhb_mye,
        linetype = 2
    ) +
    scale_x_continuous(
        breaks = x_breaks,
        labels = function(x) {str_replace(x, expr_year, "\\2")}
    ) +
    scale_y_continuous(
        name = "Mid-year count",
        limits = c(0, 800000),
        breaks = breaks_pretty(5),
        labels = label_number(scale_cut = cut_short_scale())
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme_bw(base_size = 10) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        legend.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(face = "bold")
    ) +
    ggtitle("(b) Health board coverage")

p_reg_healthboard_p <-
    d_reg_healthboard_summary %>%
    ggplot(aes(
        x = mid_year,
        y = p,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ healthboard, ncol = 2) +
    geom_col() +
    geom_line(
        mapping = aes(fill = NULL),
        data = d_lhb_mye,
        linetype = 2
    ) +
    scale_x_continuous(
        breaks = x_breaks,
        labels = function(x) {str_replace(x, expr_year, "\\2")}
    ) +
    scale_y_continuous(
        name = "",
        limits = c(0, NA),
        breaks = breaks_pretty(5),
        labels = label_percent()
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme_bw(base_size = 10) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        legend.title = element_text(face = "bold"),
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        strip.background = element_blank(),
        strip.text = element_text(face = "bold")
    )

p_reg_healthboard_n | p_reg_healthboard_p


# combine overall and health board plots =======================================
cat("\tcombine plots\n")

plot_design <- "
AA
BC
DE
"

p_reg_main <-
    guide_area() +
    p_reg_overall_n +
    p_reg_overall_p +
    p_reg_healthboard_n +
    p_reg_healthboard_p +
    plot_layout(
        design = plot_design,
        guides = "collect",
        heights = c(0.1, 1.25, 2)
    )

print(p_reg_main)


# sex --------------------------------------------------------------------------
cat("\tsex\n")

d_reg_sex_summary <-
    d_cohort_years %>%
    lazy_dt() %>%
    group_by(sex, mid_year, gp_reg_cat) %>%
    summarise(n = sum(n)) %>%
    group_by(sex, mid_year) %>%
    mutate(
        n = suppress_n(n),
        p = n / sum(n),
        p = suppress_p(p)
    ) %>%
    ungroup() %>%
    as_tibble()

p_reg_sex_n <-
    d_reg_sex_summary %>%
    ggplot(aes(
        x = mid_year,
        y = n,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ sex, ncol = 1) +
    geom_col() +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "Mid-year count",
        limits = c(0, 1.75) * 10^6,
        breaks = breaks_pretty(4),
        labels = label_number(scale_cut = cut_short_scale())
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        panel.grid.minor.x = element_blank()
    )

p_reg_sex_p <-
    d_reg_sex_summary %>%
    ggplot(aes(
        x = mid_year,
        y = p,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ sex, ncol = 1) +
    geom_col() +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "",
        limits = c(0, NA),
        breaks = breaks_pretty(4),
        labels = label_percent()
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        panel.grid.minor.x = element_blank()
    )

p_reg_sex_n | p_reg_sex_p


# age --------------------------------------------------------------------------
cat("\tage\n")

d_reg_age_summary <-
    d_cohort_years %>%
    lazy_dt() %>%
    group_by(age, mid_year, gp_reg_cat) %>%
    summarise(n = sum(n)) %>%
    group_by(age, mid_year) %>%
    mutate(
        n = suppress_n(n),
        p = n / sum(n),
        p = suppress_p(p)
    ) %>%
    ungroup() %>%
    as_tibble()

p_reg_age_n <-
    d_reg_age_summary %>%
    ggplot(aes(
        x = mid_year,
        y = n,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ age, ncol = 1) +
    geom_col() +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "",
        limits = c(0, NA),
        breaks = c(0, 250, 500, 750) * 1000,
        labels = label_number(scale_cut = cut_short_scale())
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        panel.grid.minor = element_blank()
    )

p_reg_age_p <-
    d_reg_age_summary %>%
    ggplot(aes(
        x = mid_year,
        y = p,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ age, ncol = 1) +
    geom_col() +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "",
        limits = c(0, NA),
        breaks = breaks_pretty(3),
        labels = label_percent()
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        panel.grid.minor.x = element_blank()
    )

p_reg_age_n | p_reg_age_p


# wimd -------------------------------------------------------------------------
cat("\twimd\n")

lkp_wimd  <- c(
    "WIMD Quintile 1" = 1,
    "WIMD Quintile 2" = 2,
    "WIMD Quintile 3" = 3,
    "WIMD Quintile 4" = 4,
    "WIMD Quintile 5" = 5
)

d_reg_wimd_summary <-
    d_cohort_years %>%
    lazy_dt() %>%
    mutate(wimd = factor(wimd, lkp_wimd, names(lkp_wimd))) %>%
    group_by(wimd, mid_year, gp_reg_cat) %>%
    summarise(n = sum(n)) %>%
    group_by(wimd, mid_year) %>%
    mutate(
        n = suppress_n(n),
        p = n / sum(n),
        p = suppress_p(p)
    ) %>%
    ungroup() %>%
    as_tibble()

p_reg_wimd_n <-
    d_reg_wimd_summary %>%
    ggplot(aes(
        x = mid_year,
        y = n,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ wimd, ncol = 1) +
    geom_col() +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "Mid-year count",
        limits = c(0, 750) * 1000,
        breaks = c(0, 250, 500, 750) * 1000,
        labels = label_number(scale_cut = cut_short_scale())
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        panel.grid.minor = element_blank()
    )

p_reg_wimd_p <-
    d_reg_wimd_summary %>%
    ggplot(aes(
        x = mid_year,
        y = p,
        fill = gp_reg_cat
    )) +
    facet_wrap(~ wimd, ncol = 1) +
    geom_col() +
    scale_x_continuous(
        breaks = x_breaks
    ) +
    scale_y_continuous(
        name = "",
        breaks = breaks_pretty(3),
        labels = label_percent()
    ) +
    scale_fill_manual(
        name = "GP record linkage status",
        values = pal
    ) +
    theme(
        axis.title.x = element_blank(),
        legend.position = "bottom",
        panel.grid.minor.x = element_blank()
    )

p_reg_wimd_n | p_reg_wimd_p


# prepare binomial dataset =====================================================
cat("prepare binomial dataset\n")

# simplify coverage category to be binary
# summarise
# reshape for binomial model fitting

lkp_reg <- c(
    "no_link"  = "No linked records",
    "yes_link" = "Linked (shared via backlog)",
    "yes_link" = "Linked (actively shared)"
)

d_reg_pattern <-
    d_cohort_years %>%
    lazy_dt() %>%
    mutate(gp_reg_cat = fct_recode(gp_reg_cat, !!!lkp_reg)) %>%
    group_by(sex, age, wimd, healthboard, mid_year, gp_reg_cat) %>%
    summarise(n = sum(n)) %>%
    ungroup() %>%
    pivot_wider(
        names_from = gp_reg_cat,
        values_from = n,
        values_fill = 0
    ) %>%
    mutate(
        index = mid_year - min(mid_year),
        wimd = factor(wimd)
    ) %>%
    select(sex, age, wimd, healthboard, mid_year, index, yes_link, no_link) %>%
    arrange(sex, age, wimd, healthboard, index) %>%
    as_tibble()


# analyse coverage =============================================================
cat("analyse coverage:\n")


# sex --------------------------------------------------------------------------
cat("\tsex\n")

df_sex <-
    d_reg_pattern %>%
    group_by(sex, mid_year, index) %>%
    summarise(
        no_link = sum(no_link),
        yes_link = sum(yes_link)
    ) %>%
    ungroup()

gamm_sex <- mgcv::gamm(
    formula = cbind(yes_link, no_link) ~ sex + s(index),
    correlation = corARMA(form = ~ 1 | sex, p = 1), # AR(1) within sex categories
    family = binomial,
    data = df_sex,
    verbosePQL = FALSE
)


# age --------------------------------------------------------------------------
cat("\tage\n")

df_age <-
    d_reg_pattern %>%
    group_by(age, mid_year, index) %>%
    summarise(
        no_link = sum(no_link),
        yes_link = sum(yes_link)
    ) %>%
    ungroup()

gamm_age <- mgcv::gamm(
    formula = cbind(yes_link, no_link) ~ age + s(index),
    correlation = corARMA(form = ~ 1 | age, p = 1), # AR(1) within age categories
    family = binomial,
    data = df_age,
    verbosePQL = FALSE
)


# wimd -------------------------------------------------------------------------
cat("\twimd\n")

df_wimd <-
    d_reg_pattern %>%
    group_by(wimd, mid_year, index) %>%
    summarise(
        no_link = sum(no_link),
        yes_link = sum(yes_link)
    ) %>%
    ungroup()

gamm_wimd <- mgcv::gamm(
    formula = cbind(yes_link, no_link) ~ wimd + s(index),
    correlation = corARMA(form = ~ 1 | wimd, p = 1), # AR(1) within wimd categories
    family = binomial,
    data = df_wimd,
    verbosePQL = FALSE
)


# health board -----------------------------------------------------------------
cat("\thealth board\n")

df_healthboard <-
    d_reg_pattern %>%
    group_by(healthboard, mid_year, index) %>%
    summarise(
        no_link = sum(no_link),
        yes_link = sum(yes_link)
    ) %>%
    ungroup()

gamm_healthboard <- mgcv::gamm(
    formula = cbind(yes_link, no_link) ~ healthboard + s(index),
    correlation = corARMA(form = ~ 1 | healthboard, p = 1), # AR(1) within health board categories
    family = binomial,
    data = df_healthboard,
    verbosePQL = FALSE
)


# saturated --------------------------------------------------------------------
cat("\tsaturated\n")

gamm_saturated <- mgcv::gamm(
    formula = cbind(yes_link, no_link) ~ sex + age + wimd + healthboard + s(index),
    correlation = corARMA(form = ~ 1 | sex + age + wimd + healthboard, p = 1), # AR(1) within each covariate pattern
    family = binomial,
    data = d_reg_pattern,
    verbosePQL = FALSE
)


# collate coefs ================================================================
cat("collate coefs\n")

d_xlvl_ref <- tribble(
    ~xvar,         ~xlvl,                                ~coef_type, ~estimate, ~conf.low, ~conf.high,
    "sex",         levels(d_reg_pattern$sex)[1],         "ref", 1, 1, 1,
    "age",         levels(d_reg_pattern$age)[1],         "ref", 1, 1, 1,
    "wimd",        levels(d_reg_pattern$wimd)[1],        "ref", 1, 1, 1,
    "healthboard", levels(d_reg_pattern$healthboard)[1], "ref", 1, 1, 1,
)

expr_xvar <- "(sex|age|wimd|healthboard)(.*)"

d_reg_coef <-
    bind_rows(
        gamm_sex$gam         %>% tidy(parametric = TRUE, conf.int = TRUE) %>% mutate(coef_type = "udj"),
        gamm_age$gam         %>% tidy(parametric = TRUE, conf.int = TRUE) %>% mutate(coef_type = "udj"),
        gamm_wimd$gam        %>% tidy(parametric = TRUE, conf.int = TRUE) %>% mutate(coef_type = "udj"),
        gamm_healthboard$gam %>% tidy(parametric = TRUE, conf.int = TRUE) %>% mutate(coef_type = "udj"),
        gamm_saturated$gam   %>% tidy(parametric = TRUE, conf.int = TRUE) %>% mutate(coef_type = "adj")
    ) %>%
    mutate(
        xvar = str_replace(term, expr_xvar, "\\1"),
        xlvl = str_replace(term, expr_xvar, "\\2"),
        estimate = exp(estimate),
        conf.low = exp(conf.low),
        conf.high = exp(conf.high)
    ) %>%
    bind_rows(d_xlvl_ref, .) %>%
    mutate(
        xvar = fct_inorder(xvar),
        xlvl = fct_inorder(xlvl),
        coef_type = fct_inorder(coef_type)
    ) %>%
    filter(xvar != "(Intercept)") %>%
    select(xvar, xlvl, coef_type, estimate, conf.low, conf.high) %>%
    arrange(xvar, xlvl)

d_reg_coef


# plot coefs ===================================================================
cat("plot coefs\n")

p_reg_coef <-
    d_reg_coef %>%
    ggplot(aes(
        x = estimate,
        xmin = conf.low,
        xmax = conf.high,
        y = xlvl,
        colour = coef_type
    )) +
    facet_grid(rows = "xvar", space = "free", scales = "free", switch = "y") +
    geom_vline(xintercept = 1, linetype = 2) +
    geom_point(position = position_dodge(0.5)) +
    geom_linerange(position = position_dodge(0.5)) +
    scale_x_continuous(
        breaks = pretty_breaks()
    ) +
    theme(
        strip.background = element_blank(),
        strip.placement = "outside",
        strip.text.y.left = element_text(angle = 0, face = "bold"),
        axis.title.y = element_blank(),
        legend.position = "bottom"
    )

p_reg_coef


# save =========================================================================
cat("save\n")

qsavem(
    expr_year,
    # underlying counts
    d_reg_overall_summary,
    d_reg_healthboard_summary,
    d_reg_sex_summary,
    d_reg_age_summary,
    d_reg_wimd_summary,
    # plots
    p_reg_main,
    p_reg_overall_n,
    p_reg_overall_p,
    p_reg_healthboard_n,
    p_reg_healthboard_p,
    p_reg_sex_n,
    p_reg_sex_p,
    p_reg_age_n,
    p_reg_age_p,
    p_reg_wimd_n,
    p_reg_wimd_p,
    # model results
    p_reg_coef,
    d_reg_coef,
    file = s_drive("reg_coverage_analysis.qsm")
)

beep()
