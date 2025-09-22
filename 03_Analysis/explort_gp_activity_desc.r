library(tidyverse) # all hail hadley wickham
library(janitor)
library(lubridate)
library(patchwork)
library(scales)
library(readxl)    # read XLSX
library(rvest)     # read HTML

setwd("~/Projects/ADR MSC - GP Activity/Results 2025-09-05/")

rm(list = ls())


# Plot GP Activity Trends ======================================================

sheets <- excel_sheets("t_gp_activity_counts.xlsx")

l_activity <- list()

for (sh in sheets) {
  l_activity[[sh]] <- read_xlsx(
    path = "t_gp_activity_counts.xlsx",
    sheet = sh
  )  
}

lkp_activity <- c(
  "Consultation"                 = "consultation",
  "Prescription only"            = "prescription_only",
  "Vaccination"                  = "vaccination",
  "Patient Review or\nMonitoring" = "patient_review_monitor",
  "Screening or\nAssessment"      = "screening_assessment"
  #"Admin only"                   = "admin_only",
  #"Issue medical certificate"    = "certificate",
  #"Failed encounter"             = "failed_encounter",
)

d_activity_obs <-
  bind_rows(l_activity) %>% 
  select(activity_cat, event_month, value = avg_daily_rate) %>% 
  mutate(measure = "obs", lwr_ci = NA, upr_ci = NA)

d_activity_exp <-
  bind_rows(l_activity) %>% 
  select(activity_cat, event_month, value = predicted_avg_count, lwr_ci, upr_ci) %>% 
  mutate(measure = "exp")

lkp_measure <- c(
  "Observed" = "obs",
  "Expected" = "exp"
)

d_activity <-
  bind_rows(
    d_activity_obs,
    d_activity_exp
  ) %>% 
  rename(activity = activity_cat) %>% 
  filter(!(activity %in% c("admin_only", "certificate", "failed_encounter"))) %>% 
  mutate(
    event_month = as.Date(event_month),
    activity = factor(activity, lkp_activity, names(lkp_activity)),
    measure = factor(measure, lkp_measure, names(lkp_measure))
  )

pal_measure <- c(
  "Observed" = "#000000",
  "Expected" = "#e7298a"
)

p_activity_2000_2024 <-
  d_activity %>% 
  filter(ymd("2000-01-01") <= event_month & event_month <= ymd("2024-12-31") ) %>% 
  ggplot(aes(
    x = event_month,
    y = value,
    ymin = lwr_ci,
    ymax = upr_ci,
    group = measure,
    colour = measure,
    fill = measure
  )) +
  facet_wrap(~ activity, ncol = 1, scales = "free_y", strip.position = "left") +
  geom_ribbon(colour = NA, alpha = 0.3) +
  geom_line() +
  scale_x_date(
    name = "Month",
    limits = c(NA_Date_, ymd("2025-01-01")),
    breaks = seq(ymd("2000-01-01"), ymd("2025-01-01"), by = "2 years"),
    date_labels = "%Y"
  ) +
  scale_y_continuous(
    name = "Average daily rate per 100,000 people",
    limits = c(0, NA),
    labels = label_number(scale_cut = cut_short_scale()),
    breaks = breaks_pretty(3),
    expand = expansion(mult = c(0.05, 0.10))
  ) +
  scale_colour_manual(
    name = "Trend",
    values = pal_measure
  ) +
  scale_fill_manual(
    name = "Trend",
    values = pal_measure
  ) +
  theme_bw(base_size = 8) +
  theme(
    legend.key.size = unit(4, "mm"),
    legend.position = "top",
    legend.background = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.background = element_blank(),
    strip.placement = "outside",
    strip.text = element_text(size = rel(0.8), face = "bold")
  )

p_activity_2019_2022 <-
  d_activity %>% 
  filter(ymd("2019-01-01") <= event_month & event_month <= ymd("2022-12-31") ) %>% 
  ggplot(aes(
    x = event_month,
    y = value,
    ymin = lwr_ci,
    ymax = upr_ci,
    group = measure,
    colour = measure,
    fill = measure
  )) +
  facet_wrap(~ activity, ncol = 1, scales = "free_y", strip.position = "left") +
  geom_ribbon(colour = NA, alpha = 0.3) +
  geom_line() +
  scale_x_date(
    name = "Month",
    breaks = seq(ymd("2000-01-01"), ymd("2025-01-01"), by = "1 year"),
    date_labels = "%b\n%Y"
  ) +
  scale_y_continuous(
    name = "Average daily rate per 100,000 people",
    limits = c(NA, NA),
    labels = label_number(scale_cut = cut_short_scale()),
    breaks = breaks_pretty(3),
    expand = expansion(mult = c(0.05, 0.10))
  ) +
  scale_colour_manual(
    values = pal_measure
  ) +
  scale_fill_manual(
    values = pal_measure
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    #axis.ticks.y = element_blank(),
    #axis.text.y = element_blank(),
    legend.position = "none",
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.background = element_blank(),
    strip.placement = "outside",
    strip.text = element_blank()
  )

p_activity <-
  p_activity_2000_2024 +
  p_activity_2019_2022 +
  plot_layout(
    nrow = 1,
    widths = c(0.7, 0.3)
  )

print(p_activity)

ggsave(
  p_activity,
  file = "figures-and-tables/fig7_gp_activity_desc.png",
  width = 6.25,
  height = 7.2,
  dpi = 600
)

ggsave(
  p_activity,
  file = "figures-and-tables/fig7_gp_activity_desc.tif",
  width = 6.25,
  height = 7.2,
  dpi = 600
)







# 
# 
# # for slides =============================================================
# 
# p_activity_2000_2024 <-
#   d_activity %>% 
#   filter(activity == "Vaccination") %>% 
#   filter(ymd("2000-01-01") <= event_month & event_month <= ymd("2024-12-31") ) %>% 
#   ggplot(aes(
#     x = event_month,
#     y = value,
#     ymin = lwr_ci,
#     ymax = upr_ci,
#     group = measure,
#     colour = measure,
#     fill = measure
#   )) +
#   facet_wrap(~ activity, ncol = 1, scales = "free_y", strip.position = "left") +
#   geom_ribbon(colour = NA, alpha = 0.3) +
#   geom_line() +
#   scale_x_date(
#     name = "Month",
#     limits = c(NA_Date_, ymd("2025-01-01")),
#     breaks = seq(ymd("2000-01-01"), ymd("2025-01-01"), by = "2 years"),
#     date_labels = "%Y"
#   ) +
#   scale_y_continuous(
#     name = "Average daily rate per 100,000 people",
#     limits = c(0, NA),
#     labels = label_number(scale_cut = cut_short_scale()),
#     breaks = breaks_pretty(3),
#     expand = expansion(mult = c(0.05, 0.10))
#   ) +
#   scale_colour_manual(
#     name = "Trend",
#     values = pal_measure
#   ) +
#   scale_fill_manual(
#     name = "Trend",
#     values = pal_measure
#   ) +
#   theme_bw(base_size = 12) +
#   theme(
#     legend.key.size = unit(4, "mm"),
#     legend.position = "top",
#     legend.background = element_blank(),
#     panel.grid.major.x = element_blank(),
#     panel.grid.minor.x = element_blank(),
#     strip.background = element_blank(),
#     strip.placement = "outside",
#     strip.text = element_text(size = rel(0.8), face = "bold")
#   )
# 
# 
# p_activity_2019_2022 <-
#   d_activity %>% 
#   filter(activity == "Vaccination") %>% 
#   filter(ymd("2019-01-01") <= event_month & event_month <= ymd("2022-12-31") ) %>% 
#   ggplot(aes(
#     x = event_month,
#     y = value,
#     ymin = lwr_ci,
#     ymax = upr_ci,
#     group = measure,
#     colour = measure,
#     fill = measure
#   )) +
#   facet_wrap(~ activity, ncol = 1, scales = "free_y", strip.position = "left") +
#   geom_ribbon(colour = NA, alpha = 0.3) +
#   geom_line() +
#   scale_x_date(
#     name = "Month",
#     breaks = seq(ymd("2000-01-01"), ymd("2025-01-01"), by = "1 year"),
#     date_labels = "%b\n%Y"
#   ) +
#   scale_y_continuous(
#     name = "Average daily rate per 100,000 people",
#     limits = c(NA, NA),
#     labels = label_number(scale_cut = cut_short_scale()),
#     breaks = breaks_pretty(3),
#     expand = expansion(mult = c(0.05, 0.10))
#   ) +
#   scale_colour_manual(
#     values = pal_measure
#   ) +
#   scale_fill_manual(
#     values = pal_measure
#   ) +
#   theme_bw(base_size = 12) +
#   theme(
#     axis.title.x = element_blank(),
#     axis.title.y = element_blank(),
#     #axis.ticks.y = element_blank(),
#     #axis.text.y = element_blank(),
#     legend.position = "none",
#     panel.grid.major.x = element_blank(),
#     panel.grid.minor.x = element_blank(),
#     strip.background = element_blank(),
#     strip.placement = "outside",
#     strip.text = element_blank()
#   )
# 
# p_activity <-
#   p_activity_2000_2024 +
#   p_activity_2019_2022 +
#   plot_layout(
#     nrow = 1,
#     widths = c(0.7, 0.3)
#   )
# 
# ggsave(
#   p_activity,
#   file = "slide_vaccination_desc.png",
#   width = 30,
#   height = 14,
#   units = "cm"
# )
