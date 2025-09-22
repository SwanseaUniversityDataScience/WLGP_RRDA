source("clear_workspace.r")

# load =========================================================================
cat("load\n")

qload(s_drive("gp_activity_clean.qsm"))


# simple summary ===============================================================
cat("simple summary\n")

d_obs_rate <-
    ts_activity %>%
    as_tibble() %>%
    filter(year >= 2015) %>%
    group_by(activity_cat, year) %>%
    # total events per day
    summarise(count = sum(event_n), gpreg_n = first(gpreg_n)) %>%
    ungroup() %>%
    mutate(rate = count / gpreg_n * 100000) %>%
    select(-gpreg_n)

rate_2019 <-
    d_obs_rate %>%
    filter(year == 2019) %>%
    select(activity_cat, count_2019 = count, rate_2019 = rate)

t_compare_rate <-
    d_obs_rate %>%
    left_join(rate_2019, by = "activity_cat") %>%
    mutate(
        count_2019 = count / count_2019,
        rate_2019 = rate / rate_2019
    ) %>%
    select(activity_cat, year, count, rate, count_2019, rate_2019)

print(t_compare_rate)


# fit negative binomial models =================================================
cat("fit negbin models")

# set warnings to be errors
#options(warn = 2)

l_negbin <- list()

for (act in lkp_activity) {
    cat(".")
    # act = "Consultation"

    df <-
        ts_activity %>%
        as_tibble() %>%
        filter(activity_cat == act) %>%
        mutate(
            year_f  = fct_relevel(factor(year), "2019"),
            month   = month(event_dt),
            month_f = month(event_dt, label = TRUE),
            month_f = as.character(month_f),
            month_f = fct_inorder(month_f),
            index   = row_number()
        ) %>%
        select(
            activity_cat,
            train_test,
            event_dt,
            index,
            year,
            year_f,
            month,
            month_f,
            rate,
            event_n,
            gpreg_n
        )

    # assume AR(1) correlation structure amongst the residuals

    m_ar1 <- mgcv::gamm(
        formula = rate ~ s(month, bs = "cc", k = 12) + s(index) + offset(log(gpreg_n)),
        correlation = corAR1(),
        family = "nb",
        data = df,
        subset = train_test == "train",
        niterPQL = 100,
        verbosePQL = FALSE
    )

    m_ar1_f <- mgcv::gamm(
        formula = rate ~ s(month, bs = "cc", k = 12) + year_f + offset(log(gpreg_n)),
        correlation = corAR1(),
        family = "nb",
        data = df,
        #subset = train_test == "train",
        niterPQL = 100,
        verbosePQL = FALSE
    )

    # # assess correlation amongst the residuals
    # layout(matrix(1:6, ncol = 3))
    # # Uncorrelated
    # acf(resid(m_uncor$lme), lag.max = 36, main = "m_uncor - ACF", ylim = c(-1, 1))
    # pacf(resid(m_uncor$lme), lag.max = 36, main = "m_uncor - pACF", ylim = c(-1, 1))
    # # ARMA(1,0)
    # acf(resid(m_ar1$lme), lag.max = 36, main = "m_ar1 - ACF", ylim = c(-1, 1))
    # pacf(resid(m_ar1$lme), lag.max = 36, main = "m_ar1 - pACF", ylim = c(-1, 1))
    # # Cat
    # acf(resid(m_ar1_yf$lme), lag.max = 36, main = "m_ar1_yf - ACF", ylim = c(-1, 1))
    # pacf(resid(m_ar1_yf$lme), lag.max = 36, main = "m_ar1_yf - pACF", ylim = c(-1, 1))
    # layout(1)

    # look at smoothing terms
    l_smooth_month <- plot(m_ar1$gam, scale = 0, select = 1, n = 120, se = 1.96)[[1]]

    d_smooth_month <- data.frame(
        x   = l_smooth_month$x,
        fit = l_smooth_month$fit,
        se  = l_smooth_month$se
    )

    p_smooth_month <-
        d_smooth_month %>%
         mutate(
             lwr = fit - se,
             upr = fit + se
        ) %>%
        ggplot(aes(
            x = x,
            y = fit,
            ymin = lwr,
            ymax = upr
        )) +
        geom_ribbon(colour = "black", fill = NA, linetype = 2) +
        geom_line() +
        scale_x_continuous(
            name = "Calendar Month",
            breaks = 1:12
        ) +
        scale_y_continuous(
            name = "s(Calendar Month)",
            breaks = breaks_pretty()
        ) +
        theme_bw() +
        theme(
            panel.grid.minor.x = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.y = element_blank()
        )

    l_smooth_index <- plot(m_ar1$gam, scale = 0, select = 2, n = 300, se = 1.96)[[2]]

    d_smooth_index <- data.frame(
        x   = l_smooth_index$x,
        fit = l_smooth_index$fit,
        se  = l_smooth_index$se
    )

    p_smooth_index <-
        d_smooth_index %>%
        mutate(
            lwr = fit - se,
            upr = fit + se
        ) %>%
        ggplot(aes(
            x = x,
            y = fit,
            ymin = lwr,
            ymax = upr
        )) +
        geom_ribbon(colour = "black", fill = NA, linetype = 2) +
        geom_line() +
        scale_x_continuous(
            name = "Time (years)",
            breaks = seq(0, 400, by = 24),
            labels = seq(0, 400, by = 24) / 12,
        ) +
        scale_y_continuous(
            name = "s(Time)",
            breaks = breaks_pretty()
        ) +
        theme_bw() +
        theme(
            panel.grid.minor.x = element_blank(),
            panel.grid.major.x = element_blank(),
            panel.grid.minor.y = element_blank()
        )

    # fit the trend only
    pred_ar1 <-
        predict(
            object = m_ar1$gam,
            newdata = df,
            type = "link",
            se.fit = TRUE
            #exclude = "s(month)"
        ) %>%
        as.data.frame() %>%
        mutate(
            upr_ci = exp(fit + 1.96 * se.fit),
            lwr_ci = exp(fit - 1.96 * se.fit),
            pred = exp(fit)
        ) %>%
        select(-fit, -se.fit)

    df <- bind_cols(df, pred_ar1)

    # extract coef for year 2024
    beta <- coef(m_ar1_f$gam)
    V <- vcov(m_ar1_f$gam)
    se <- diag(V)

    rate_ratio_ci <- data.frame(
        activity_cat = act,
        xvar = names(beta),
        rr = exp(beta),
        lwr_ci = exp(beta - 1.96*se),
        upr_ci = exp(beta + 1.96*se),
        row.names = NULL
    )

    l_negbin[[act]] <- list(
        df = df,
        mod_cont = m_ar1,
        mod_fact = m_ar1_f,
        coef = rate_ratio_ci,
        p_smooth_index = p_smooth_index,
        p_smooth_month = p_smooth_month
    )
}
cat("\n")

# rest warnings to be raised as warnings
#options(warn = 1)


# plot all trends ==============================================================
cat("plot all trends\n")

d_gam_trend <-
    l_negbin %>%
    purrr::map(~ .x$df) %>%
    bind_rows() %>%
    mutate(
        activity_cat = factor(activity_cat, lkp_activity, names(lkp_activity)),
        # make values per 100,000 people
        rate   = rate / gpreg_n * 100000,
        pred   = pred / gpreg_n * 100000,
        lwr_ci = lwr_ci / gpreg_n * 100000,
        upr_ci = upr_ci / gpreg_n * 100000
    )

p_gam_trend <-
    d_gam_trend %>%
    ggplot(aes(x = event_dt)) +
    facet_wrap(~ activity_cat, ncol = 1, scales = "free_y", strip.position = "left") +
    geom_ribbon(aes(ymin = lwr_ci, ymax = upr_ci), colour = NA, fill = "blue", alpha = 0.25) +
    geom_line(aes(x = event_dt, y = pred), colour = "blue") +
    geom_line(aes(x = event_dt, y = rate)) +
    scale_x_date(
        name = "Month",
        limits = c(ymd("2000-01-01"), ymd("2025-01-01")),
        breaks = seq(from = ymd("1995-01-01"), to = ymd("2025-01-01"), by = "5 years"),
        date_minor_breaks = "1 year",
        date_labels = "%b\n%Y",
        expand = expansion(mult = 0.01)
    ) +
    scale_y_continuous(
        name = "Average Daily Rate per 10,000",
        limits = c(0, NA),
        labels = comma,
        breaks = breaks_pretty(3),
        expand = expansion(mult = c(0.05, 0.1))
    ) +
    theme_bw() +
    theme(
        legend.position = "none",
        axis.title = element_blank(),
        panel.grid.minor.y = element_blank(),
        strip.text.y.left = element_text(angle = 0, hjust = 0.5, vjust = 0.5, face = "bold"),
        strip.placement = "outside",
        strip.background = element_blank()
    )

print(p_gam_trend)

p_gam_trend_2010 <-
    d_gam_trend %>%
    filter(event_dt >= ymd("2010-01-01")) %>%
    ggplot(aes(x = event_dt)) +
    facet_wrap(~ activity_cat, ncol = 1, scales = "free_y", strip.position = "left") +
    geom_ribbon(aes(ymin = lwr_ci, ymax = upr_ci), colour = NA, fill = "blue", alpha = 0.25) +
    geom_line(aes(x = event_dt, y = pred), colour = "blue") +
    geom_line(aes(x = event_dt, y = rate)) +
    scale_x_date(
        name = "Month",
        limits = c(ymd("2010-01-01"), ymd("2025-01-01")),
        breaks = seq(from = ymd("2010-01-01"), to = ymd("2025-01-01"), by = "2 years"),
        date_labels = "%b\n%Y",
        expand = expansion(mult = 0.01)
    ) +
    scale_y_continuous(
        name = "Average Daily Rate per 10,000",
        limits = c(0, NA),
        labels = comma,
        breaks = breaks_pretty(3),
        expand = expansion(mult = c(0.05, 0.1))
    ) +
    theme_bw() +
    theme(
        legend.position = "none",
        axis.title = element_blank(),
        panel.grid.minor = element_blank(),
        strip.text.y.left = element_text(angle = 0, hjust = 0.5, vjust = 0.5, face = "bold"),
        strip.placement = "outside",
        strip.background = element_blank()
    )

p_gam_trend_2010


# extract coef =================================================================
cat("extract coef\n")

d_nb_coef <-
    l_negbin %>%
    purrr::map(~ .x$coef) %>%
    bind_rows()

d_nb_coef %>%
filter(xvar == "year_f2024") %>%
print()



# save =========================================================================
cat("save\n")

qsavem(
    l_negbin,
    p_gam_trend,
    p_gam_trend_2010,
    d_nb_coef,
    file = s_drive("gp_activity_analysis.qsm")
)
beep()
