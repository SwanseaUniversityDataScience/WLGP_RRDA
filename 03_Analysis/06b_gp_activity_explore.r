source("clear_workspace.r")


# load =========================================================================
cat("load\n")

qload(s_drive("gp_activity_clean.qsm"))

x_breaks <- seq(
    from = ymd("2000-01-01"),
    to = ymd("2025-01-01"),
    by = "5 years"
)

lkp_measure <- c(
    "Total Event Count" = "event_n",
    "Daily event rate per 100,000 people" = "rate"
)


# total activity ===============================================================
cat("total activity\n")

d_activity_total <-
    ts_activity %>%
    as_tibble() %>% 
    group_by(month, event_dt) %>% 
    summarise(event_n = sum(event_n), gpreg_n = min(gpreg_n)) %>%
    ungroup() %>% 
    mutate(rate = ((event_n / days_in_month(event_dt)) / gpreg_n) * 100000) %>% 
    select(-gpreg_n) %>% 
    pivot_longer(cols = c(event_n, rate), names_to = "measure") %>% 
    mutate(measure = factor(measure, lkp_measure, names(lkp_measure)))

p_activity_total <-
    d_activity_total %>% 
	ggplot(aes(
		x = event_dt,
		y = value
	)) +
    facet_wrap( ~ measure, nrow = 1, scales = "free") +
	geom_line() +
	scale_x_date(
		date_labels = "%b\n%Y",
		breaks = x_breaks,
		expand = expansion(add = 200)
	) +
	scale_y_continuous(
		name = "GP activity per month",
		breaks = breaks_pretty(),
		labels = comma,
		limits = c(0, NA)
	) +
	theme_bw() +
	theme(
		panel.grid.major.x = element_blank(),
		panel.grid.minor.x = element_blank(),
		axis.title.y = element_blank()
	)

p_activity_total


# consultation =================================================================
cat("consultation\n")

d_activity_consultation <-
    ts_activity %>%
    filter(activity_cat == "consultation") %>% 
    select(event_dt, event_n, rate) %>% 
    pivot_longer(cols = c(event_n, rate), names_to = "measure") %>% 
    mutate(measure = factor(measure, lkp_measure, names(lkp_measure)))

p_activity_consultation <-
    d_activity_consultation %>% 
    ggplot(aes(
        x = event_dt,
        y = value
    )) +
    facet_wrap( ~ measure, nrow = 1, scales = "free") +
    geom_line() +
    scale_x_date(
        date_labels = "%b\n%Y",
        breaks = x_breaks,
        expand = expansion(add = 200)
    ) +
    scale_y_continuous(
        name = "GP activity per month",
        breaks = breaks_pretty(),
        labels = comma,
        limits = c(0, NA)
    ) +
    theme_bw() +
    theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        axis.title.x = element_blank()
    )

p_activity_consultation


# all types ====================================================================
cat("all types\n")

d_activity_by_type <-
    ts_activity %>%
    as_tibble() %>% 
    select(activity_cat, event_dt, event_n, rate) %>% 
    pivot_longer(cols = c(event_n, rate), names_to = "measure") %>% 
    mutate(
        measure = factor(measure, lkp_measure, names(lkp_measure)),
        activity_cat = factor(activity_cat, lkp_activity, names(lkp_activity))
    )

p_activity_by_type <-
    d_activity_by_type %>% 
	ggplot(aes(
		x = event_dt,
		y = value
	)) +
    ggh4x::facet_grid2(
	    rows = vars(activity_cat),
	    cols = vars(measure),
	    scales = "free_y",
	    independent = "y",
	    switch = "y"
    ) +
	geom_line() +
	scale_x_date(
	    breaks = x_breaks,
		date_labels = "%Y",
		expand = expansion(add = 200)
	) +
	scale_y_continuous(
		limits = c(0, NA),
		labels = label_number(scale_cut = cut_short_scale()),
		breaks = breaks_pretty(3),
		expand = expansion(mult = c(0.05, 0.2))
	) +
    theme_bw() +
	theme(
		legend.position = "none",
		axis.title = element_blank(),
		panel.grid.minor = element_blank(),
		strip.text.x = element_text(angle = 0, hjust = 0.5, vjust = 0.5, face = "bold"),
		strip.text.y.left = element_text(angle = 0, hjust = 0.5, vjust = 0.5, face = "bold"),
		strip.placement = "outside",
		strip.background = element_blank()
	)

print(p_activity_by_type)


# plot ACF =====================================================================
cat("plot ACF\n")

p_activity_acf <- list()

for (i in 1:length(lkp_activity)) {
    # i = 1
    act <- lkp_activity[i]

    p_activity_acf[[act]] <-
        ts_activity %>%
        filter(activity_cat == act) %>%
        feasts::ACF(y = rate, lag_max = 48) %>%
        autoplot() +
        scale_x_continuous(
            name = "Lag [1 Month]",
            breaks = seq(0, 48, by = 6),
            expand = expansion(add = 1)
        ) +
        scale_y_continuous(
            name = "ACF",
            breaks = breaks_pretty(3)
        ) +
        theme_bw() +
        theme(
            legend.position = "none",
            panel.grid.minor.x = element_blank(),
            panel.grid.major.x = element_blank(),
            strip.text.y.left = element_text(angle = 0, hjust = 0.5, vjust = 0.5, face = "bold"),
            strip.placement = "outside",
            strip.background = element_blank(),
            title = element_blank()
        )
}


# plot STL =====================================================================
cat("plot STL\n")

p_activity_stl <- list()

for (i in 1:length(lkp_activity)) {
    # i = 1
    act <- lkp_activity[i]

    p_activity_stl[[act]] <-
        ts_activity %>%
        filter(activity_cat == act) %>%
        fabletools::model(stl = feasts::STL(rate)) %>%
        fabletools::components() %>%
        fabletools::autoplot() +
        tsibble::scale_x_yearmonth(
            breaks = x_breaks,
            date_labels = "%b\n%Y",
            expand = expansion()
        ) +
        scale_y_continuous(
            labels = comma,
            breaks = breaks_pretty(3)
        ) +
        theme_bw() +
        theme(title = element_blank())
}

# save =========================================================================
cat("save\n")

qsavem(
    p_activity_total,
    p_activity_consultation,
	p_activity_by_type,
    p_activity_acf,
    p_activity_stl,
	file = s_drive("gp_activity_explore.qsm")
)
beep()
