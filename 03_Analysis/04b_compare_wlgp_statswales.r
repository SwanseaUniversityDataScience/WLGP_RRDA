source("clear_workspace.r")


# load =========================================================================
cat("load\n")

# load all wlgp activity data frames
qload(s_drive("d_wlgp_activity.qsm"))

# load stats wales consultations for all of Wales only
d_stats_wales <- qread(s_drive("d_statswales_wales_activity.qs"))


# visualise ====================================================================
cat("visualise\n")

d_total_wlgp <-
	d_gp_monthly_total %>%
	mutate(src = "WLGP Total Activity") %>%
	select(
		src,
		month = event_month,
		count = event_n
	)

d_consult_stats_wales <-
	d_stats_wales %>%
	group_by(month) %>%
	summarise(count = sum(count)) %>%
	mutate(src = "PHW Consultations") %>%
	select(
		src,
		month,
		count
	)

d_consult_wlgp <-
    d_gp_monthly_consultation %>%
	mutate(src = "WLGP Consultations") %>%
	select(
		src,
		month = event_month,
		count = event_n
	)

d_consult_compare <- bind_rows(
	d_total_wlgp,
	d_consult_stats_wales,
	d_consult_wlgp %>% mutate(src = "WLGP Consultations * 1/0.85", count = count * 1/0.85)
)

p_compare_consultation <-
	d_consult_compare %>%
	ggplot(aes(
		x = month,
		y = count,
		group = src,
		colour = src
	)) +
	geom_line() +
	scale_y_continuous(
		limits = c(0, NA),
		labels = comma
	) +
	scale_x_date(
		date_breaks = "1 year",
		date_labels = "%y"
	) +
    theme(
        legend.position = "bottom"
    )

p_compare_consultation

# save =========================================================================
cat("save\n")

qsavem(
	p_compare_consultation,
	file = s_drive("compare_wlgp_statswales.qsm")
)
beep()
