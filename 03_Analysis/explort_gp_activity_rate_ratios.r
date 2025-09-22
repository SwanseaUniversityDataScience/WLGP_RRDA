library(tidyverse) # all hail hadley wickham
library(janitor)
library(patchwork)
library(scales)
library(readxl)    # read XLSX
library(rvest)     # read HTML

setwd("~/Projects/ADR MSC - GP Activity/Results 2025-09-05/")

rm(list = ls())


# Plot GP Activity annual rate ratios ==========================================

lkp_activity <- c(
  "Consultation" = "consultation",
  "Prescription\nonly" = "prescription_only",
  "Vaccination" = "vaccination",
  "Patient Review\nor Monitoring" = "patient_review_monitor",
  "Screening or\nAssessment" = "screening_assessment"
  #"admin_only" = "admin_only",
  #"certificate" = "certificate",
  #"failed_encounter" = "failed_encounter"
)

d_rr_ref <-
  tibble(
    activity_cat = lkp_activity,
    year = 2019,
    rr = 1,
    lwr_ci = 1,
    upr_ci = 1
  )

d_rr <-
  read_xlsx(path = "t_gp_activity_rate_ratios.xlsx") %>% 
  mutate(year = as.numeric(year)) %>% 
  bind_rows(d_rr_ref) %>% 
  filter(activity_cat %in% lkp_activity) %>% 
  arrange(activity_cat, year) %>% 
  mutate(
    year = as.character(year),
    year = str_replace(year, "^20", ""),
    year = fct_inorder(year),
    year = fct_recode(year, "19\n(Ref)" = "19"),
    activity_cat = factor(activity_cat, lkp_activity, names(lkp_activity)),
    i = 1
  )

p_rr <-
  d_rr %>% 
  ggplot(aes(
    y = rr,
    ymin = lwr_ci,
    ymax = upr_ci,
    x = year,
    group = activity_cat
  )) +
  facet_grid(
    rows = vars(activity_cat),
    cols = vars(i),
    scales = "free_y",
    switch = "y"
  ) +
  geom_hline(yintercept = 1, colour = "grey92", linewidth = 1) +
  geom_pointrange(size = 0.1) +
  geom_line(linetype = "6969", linewidth = 0.25) +
  scale_y_continuous(
    name = "Rates Ratio (95 CI%)",
    breaks = pretty_breaks(4)
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    strip.background = element_blank(),
    strip.placement = "outside",
    strip.text.y.left = element_text(face = "bold"),
    strip.text.x = element_blank()
  )

print(p_rr)

# save =============================================================

ggsave(
  p_rr,
  file = "figures-and-tables/fig8_gp_activity_rate_ratio.png",
  width = 3.125,
  height = 4,
  dpi = 600
)

ggsave(
  p_rr,
  file = "figures-and-tables/fig8_gp_activity_rate_ratio.tif",
  width = 3.125,
  height = 4,
  dpi = 600
)




# # for slides =============================================================
# 
# slide_years <- c("19\n(Ref)", as.character(20:24))
# 
# 
# 
# p_rr <-
#   d_rr %>% 
#   filter(year %in% slide_years) %>% 
#   filter(activity_cat %in% c("Consultation", "Prescription\nonly", "Vaccination")) %>% 
#   ggplot(aes(
#     y = rr,
#     ymin = lwr_ci,
#     ymax = upr_ci,
#     x = year,
#     group = activity_cat
#   )) +
#   facet_wrap( ~ activity_cat,
#     scales = "free_y"
#   ) +
#   geom_hline(yintercept = 1, colour = "grey50", linewidth = 1) +
#   geom_line(linewidth = 0.25, colour = "#e7298a") +
#   geom_pointrange(size = 0.3, colour = "#e7298a") +
#   scale_y_continuous(
#     name = "Rates Ratio (95 CI%)",
#     breaks = pretty_breaks(4)
#   ) +
#   theme_grey(base_size = 12) +
#   theme(
#     axis.title.x = element_blank(),
#     panel.grid.minor.x = element_blank(),
#     panel.grid.major.x = element_blank()
#   )
# 
# p_rr
# 
# ggsave(
#   p_rr,
#   file = "slide_gp_activity_rate_ratio.png",
#   width = 22,
#   height = 14,
#   units = "cm"
# )
# 

