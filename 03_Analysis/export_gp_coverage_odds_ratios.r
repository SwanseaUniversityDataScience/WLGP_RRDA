library(tidyverse) # all hail hadley wickham
library(janitor)
library(patchwork)
library(scales)
library(readxl)    # read XLSX
library(rvest)     # read HTML

setwd("~/Projects/ADR MSC - GP Activity/Results 2025-09-05/")

rm(list = ls())


# GP Coverage: Odds Ratios =====================================================

lkp_xvar <- c(
  "Sex" = "sex",
  "Age" = "age",
  "WIMD\n2019" = "wimd",
  "Health\nBoard" = "healthboard"
)

lkp_coef_type <- c(
  "Ref."       = "ref",
  "Unadjusted" = "udj",
  "Adjusted"   = "adj"
)

lkp_hb <- c(
  "Powys"             = "Powys Teaching Health Board",
  "Betsi Cadwaladr"   = "Betsi Cadwaladr University Health Board",
  "Hywel Dda"         = "Hywel Dda University Health Board",
  "Aneurin Bevan"     = "Aneurin Bevan University Health Board",
  "Cardiff & Vale"    = "Cardiff and Vale University Health Board",
  "Swansea Bay"       = "Swansea Bay University Health Board",
  "Cwm Taf Morgannwg" = "Cwm Taf Morgannwg University Health Board"
)

d_reg_or <-
  read_xlsx(
    path = "t_reg_coverage_odds_ratios.xlsx"
  ) %>% 
  mutate(
    conf.low = replace_na(conf.low, 1),
    conf.high = replace_na(conf.low, 1),
    coef_type = factor(coef_type, lkp_coef_type, names(lkp_coef_type)),
    xvar = fct_inorder(xvar),
    xvar = fct_recode(xvar, !!!lkp_xvar),
    xlvl = str_replace(xlvl, "_", "-"),
    xlvl = str_replace(xlvl, "00", "0"),
    xlvl = if_else(xlvl == "1", "1 (Most)", xlvl),
    xlvl = if_else(xlvl == "5", "5 (Least)", xlvl),
    xlvl = fct_inorder(xlvl),
    xlvl = fct_recode(xlvl, !!!lkp_hb),
    xlvl = fct_relevel(xlvl, names(lkp_hb)),
    i = "lol"
  )

pal_coef_type <- c(
  "Ref."       = "#000000",
  "Unadjusted" = "#e78ac3",
  "Adjusted"   = "#a6d854"
)

x_breaks <- c(0.25, 0.5, 1, 2, 4)

p_reg_or <-
  d_reg_or %>% 
  ggplot(aes(
    x = estimate,
    xmin = conf.low,
    xmax = conf.high,
    y = xlvl,
    colour = coef_type
  )) +
  facet_grid(
    rows = vars(xvar),
    cols = vars(i),
    scales = "free_y",
    space = "free",
    switch = "y"
  ) +
  geom_vline(xintercept = 1 , colour = "grey92", linewidth = 1) +
  geom_pointrange(position = position_dodge(0.7), size = 0.1) +
  scale_x_continuous(
    name = "Odds Ratio (95 CI%)",
    breaks = breaks_pretty(8)
  ) +
  scale_color_manual(
    name = "Estimate Type",
    values = pal_coef_type
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.y = element_blank(),
    legend.key.size = unit(4, "mm"),
    legend.position = "top",
    legend.title = element_text(size = rel(0.8)),
    panel.grid.minor = element_blank(),
    panel.grid.major = element_blank(),
    strip.background = element_blank(),
    strip.placement = "outside",
    strip.text.y.left = element_text(face = "bold", angle = 0),
    strip.text.x = element_blank()
  )

print(p_reg_or)


# save =============================================================

ggsave(
  p_reg_or,
  file = "figures-and-tables/fig6_gp_coverage_odds_ratio.png",
  width = 6.25,
  height = 4,
  dpi = 600
)

ggsave(
  p_reg_or,
  file = "figures-and-tables/fig6_gp_coverage_odds_ratio.tif",
  width = 6.25,
  height = 4,
  dpi = 600
)