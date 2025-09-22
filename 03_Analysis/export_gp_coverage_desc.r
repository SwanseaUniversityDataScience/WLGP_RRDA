library(tidyverse) # all hail hadley wickham
library(janitor)
library(patchwork)
library(scales)
library(readxl)    # read XLSX
library(rvest)     # read HTML

setwd("~/Projects/ADR MSC - GP Activity/Results 2025-09-05")

rm(list = ls())


# GP Coverage: Descriptive summary =============================================

lkp_link_status <- c(
  "Unlinked"                  = "no_link",   
  "Linked (historic backlog)" = "shared_backlog",
  "Linked (actively shared)"  = "shared_active"
)

pal_link_status <- c(
  "Unlinked"                  = "#fc8d62",
  "Linked (historic backlog)" = "#8da0cb",
  "Linked (actively shared)"  = "#66c2a5"
)


d_ons_wales_1971 <-
  read_excel(
    path = "ons_wales_mype_1971_2023.xls",
    skip = 8,
    col_names = c("mid_year", "n")
  ) %>% 
  mutate(mid_year = as.numeric(mid_year)) %>% 
  filter(mid_year >= 1990)

d_ons_wales_1971

d_ons_wales_2024 <-
  read_csv(
    file = "ons_lhb_mye_2001_2024.csv",
    show_col_types = FALSE
  ) %>% 
  filter(year == 2024) %>% 
  group_by(year) %>% 
  summarise(value = sum(value)) %>% 
  ungroup() %>% 
  select(
    mid_year = year,
    n = value
  )

d_ons_wales <- bind_rows(d_ons_wales_1971, d_ons_wales_2024)

expr <- "(no_link|shared_[a-z]+)_(.+)_(n|p)"

d_reg_desc_total <-
  read_xlsx(
    path = "t_reg_coverage_summaries.xlsx",
    sheet = "total"
  ) %>% 
  pivot_longer(cols = -mid_year) %>% 
  mutate(
    link_status = str_replace(name, expr, "\\1"),
    xlvl        = str_replace(name, expr, "\\2"),
    stat        = str_replace(name, expr, "\\3"),
  ) %>% 
  select(-name) %>% 
  pivot_wider(names_from = stat) %>% 
  mutate(
    xvar = "total",
    link_status = factor(link_status, lkp_link_status, names(lkp_link_status))
  )

d_reg_desc_total

d_reg_desc_sex <-
  read_xlsx(
    path = "t_reg_coverage_summaries.xlsx",
    sheet = "sex"
  ) %>% 
  pivot_longer(cols = -mid_year) %>% 
  mutate(
    link_status = str_replace(name, expr, "\\1"),
    xlvl        = str_replace(name, expr, "\\2"),
    stat        = str_replace(name, expr, "\\3"),
  ) %>% 
  select(-name) %>% 
  pivot_wider(names_from = stat) %>% 
  mutate(
    xvar = "sex",
    link_status = factor(link_status, lkp_link_status, names(lkp_link_status))
  ) %>% 
  filter(xlvl != "total")

d_reg_desc_age <-
  read_xlsx(
    path = "t_reg_coverage_summaries.xlsx",
    sheet = "age"
  ) %>% 
  pivot_longer(cols = -mid_year) %>% 
  mutate(
    link_status = str_replace(name, expr, "\\1"),
    xlvl        = str_replace(name, expr, "\\2"),
    stat        = str_replace(name, expr, "\\3"),
  ) %>% 
  select(-name) %>% 
  pivot_wider(names_from = stat) %>% 
  mutate(
    xvar = "age",
    link_status = factor(link_status, lkp_link_status, names(lkp_link_status))
  ) %>% 
  filter(xlvl != "total")

d_reg_desc_wimd <-
  read_xlsx(
    path = "t_reg_coverage_summaries.xlsx",
    sheet = "wimd"
  ) %>% 
  pivot_longer(cols = -mid_year) %>% 
  mutate(
    link_status = str_replace(name, expr, "\\1"),
    xlvl        = str_replace(name, expr, "\\2"),
    stat        = str_replace(name, expr, "\\3"),
  ) %>% 
  select(-name) %>% 
  pivot_wider(names_from = stat) %>% 
  mutate(
    xvar = "wimd",
    link_status = factor(link_status, lkp_link_status, names(lkp_link_status))
  ) %>% 
  filter(xlvl != "total")

d_reg_desc_hb <-
  read_xlsx(
    path = "t_reg_coverage_summaries.xlsx",
    sheet = "healthboard"
  ) %>% 
  pivot_longer(cols = -mid_year) %>% 
  mutate(
    link_status = str_replace(name, expr, "\\1"),
    xlvl        = str_replace(name, expr, "\\2"),
    stat        = str_replace(name, expr, "\\3"),
  ) %>% 
  select(-name) %>% 
  pivot_wider(names_from = stat) %>% 
  mutate(
    xvar = "healthboard",
    link_status = factor(link_status, lkp_link_status, names(lkp_link_status))
  ) %>% 
  filter(xlvl != "total")


# table of mid-year summaries --------------------------------------------------

yrs <- c(1990, 1995, 2000, 2005, 2010, 2015, 2020, 2024)

d_reg_desc <-
  bind_rows(
    d_reg_desc_total,
    d_reg_desc_sex,
    d_reg_desc_age,
    d_reg_desc_wimd,
    d_reg_desc_hb
  ) %>% 
  filter(mid_year %in% yrs) %>% 
  mutate(
    xvar = fct_inorder(xvar),
    xlvl = fct_inorder(xlvl)
  ) %>% 
  arrange(mid_year) %>% 
  select(mid_year, xvar, xlvl, link_status, n)

d_cohort_desc <-
  d_reg_desc %>% 
  group_by(mid_year, xvar, xlvl) %>% 
  summarise(n = sum(n)) %>% 
  ungroup() %>% 
  group_by(mid_year, xvar) %>% 
  mutate(p = n / sum(n)) %>% 
  ungroup() %>% 
  rename(
    cohort_n = n,
    cohort_p = p
  )

d_linked_desc <-
  d_reg_desc %>% 
  filter(link_status != "Unlinked") %>% 
  group_by(mid_year, xvar, xlvl) %>% 
  summarise(n = sum(n)) %>% 
  ungroup() %>% 
  group_by(mid_year, xvar) %>% 
  mutate(p = n / sum(n)) %>% 
  ungroup() %>% 
  rename(
    linked_n = n,
    linked_p = p
  )

t_cohort_linked_desc <-
  d_cohort_desc %>% 
  full_join(d_linked_desc, by = join_by(mid_year, xvar, xlvl)) %>% 
  mutate(
    cn = format(cohort_n, big.mark = ",", trim = TRUE),
    lp = percent(linked_n / cohort_n, accuracy = 0.1),
    cn_lp = str_glue("{cn} ({lp})")
  ) %>% 
  select(
    -cohort_n,
    -cohort_p,
    -linked_n,
    -linked_p,
    -cn,
    -lp
  ) %>% 
  pivot_wider(
    names_from = "mid_year",
    values_from = "cn_lp"
  )

write_csv(
  t_cohort_linked_desc,
  file = "figures-and-tables/t_cohort_linked_desc.csv"
)


# supp material ================================================================

# table of mid-year summaries
# for those living in wales
# and for those with linked GP records

d_reg_desc <-
  bind_rows(
    d_reg_desc_total,
    d_reg_desc_sex,
    d_reg_desc_age,
    d_reg_desc_wimd,
    d_reg_desc_hb
  ) %>% 
  mutate(
    xvar = fct_inorder(xvar),
    xlvl = fct_inorder(xlvl),
    n = replace_na(n, 0)
  ) %>% 
  arrange(mid_year) %>% 
  select(mid_year, xvar, xlvl, link_status, n)

smt_cohort_desc <-
  d_reg_desc %>% 
  group_by(mid_year, xvar, xlvl) %>% 
  summarise(n = sum(n)) %>% 
  ungroup() %>% 
  group_by(mid_year, xvar) %>% 
  mutate(p = n / sum(n)) %>% 
  ungroup() %>% 
  mutate(
    cn = format(round(n, -1), big.mark = ",", trim = TRUE),
    cp = percent(p, accuracy = 0.1),
    cpn = str_glue("{cn} ({cp})")
  ) %>% 
  select(-n, -p, -cn, -cp) %>% 
  pivot_wider(
    names_from = "mid_year",
    values_from = cpn
  )

smt_cohort_desc

write_csv(
  smt_cohort_desc,
  file = "figures-and-tables/sm_all_year_cohort_desc.csv"
)

smt_linked_desc <-
  d_reg_desc %>% 
  filter(link_status != "Unlinked") %>% 
  group_by(mid_year, xvar, xlvl) %>% 
  summarise(n = sum(n)) %>% 
  ungroup() %>% 
  group_by(mid_year, xvar) %>% 
  mutate(p = n / sum(n)) %>% 
  ungroup() %>% 
  mutate(
    ln = format(round(n, -1), big.mark = ",", trim = TRUE),
    lp = percent(p, accuracy = 0.1),
    lpn = str_glue("{ln} ({lp})")
  ) %>% 
  select(-n, -p, -ln, -lp) %>% 
  pivot_wider(
    names_from = "mid_year",
    values_from = lpn
  )

smt_linked_desc

write_csv(
  smt_linked_desc,
  file = "figures-and-tables/sm_all_year_linked_desc.csv"
)



# compare ONS to WDS/WLGP -----------------------------------

d_wdsd <- d_reg_desc_total %>% group_by(mid_year) %>% summarise(wdsd_n = sum(n))

compare <- d_wdsd %>% 
  left_join(d_ons_wales, by = "mid_year") %>% 
  rename(ons_n = n) %>% 
  mutate(
    diff = wdsd_n - ons_n,
    diff_p = diff / ons_n
  )

compare %>% filter(mid_year >= 1994) %>% 
  summarise(avg = mean(diff_p * 100))

# plot =========================================================================

x_breaks <- seq(from = 1990, to = 2025, by = 5)

p_reg_total_n <-
  d_reg_desc_total %>% 
  ggplot(aes(
    x = mid_year,
    y = n,
    fill = link_status
  )) +
  geom_col() +
  geom_line(
    data = d_ons_wales,
    mapping = aes(fill = NULL),
    linetype = "31"
  ) +
  scale_x_continuous(
    breaks = x_breaks
  ) +
  scale_y_continuous(
    name = "Mid-year count",
    limits = c(0, 3.5*10^6),
    breaks = breaks_pretty(6),
    labels = label_number(scale_cut = cut_short_scale())
  ) +
  scale_fill_manual(
    name = "GP record status",
    values = pal_link_status
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title.position = "plot",
    strip.background = element_blank(),
    strip.text = element_text(face = "bold")
  ) +
  ggtitle("(a) National coverage")

p_reg_total_n

p_reg_total_p <-
  d_reg_desc_total %>% 
  ggplot(aes(
    x = mid_year,
    y = p,
    fill = link_status
  )) +
  geom_col() +
  scale_x_continuous(
    breaks = x_breaks
  ) +
  scale_y_continuous(
    name = "",
    breaks = breaks_pretty(5),
    labels = label_percent()
  ) +
  scale_fill_manual(
    name = "GP record status",
    values = pal_link_status
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold")
  )

p_reg_total_p


# health board counts ----------------------------------------------------------

lkp_ons_hb <- c(
  "Aneurin Bevan"     = "Aneurin Bevan University Health Board",
  "Betsi Cadwaladr"   = "Betsi Cadwaladr University Health Board",
  "Cardiff & Vale"    = "Cardiff and Vale University Health Board",
  "Cwm Taf Morgannwg" = "Cwm Taf Morgannwg University Health Board",
  "Hywel Dda"         = "Hywel Dda University Health Board",
  "Powys"             = "Powys Teaching Health Board",
  "Swansea Bay"       = "Swansea Bay University Health Board"
)

d_ons_lhb <-
  read_csv(
    file = "ons_lhb_mye_2001_2024.csv",
    show_col_types = FALSE
  ) %>% 
  select(
    health_board = lhb_nm,
    mid_year = year,
    n = value
  ) %>% 
  mutate(health_board = factor(health_board, lkp_ons_hb, names(lkp_ons_hb))) %>% 
  group_by(health_board, mid_year) %>% 
  summarise(n = mean(n)) %>% 
  ungroup()

expr_measure <- "(no_link|shared_backlog|shared_active)_(.*)_n"

lkp_wlgp_hb <- c(
  "Aneurin Bevan"         = "aneurin_bevan",
  "Betsi Cadwaladr"       = "betsi_cadwaladr",
  "Cardiff & Vale"        = "cardiff_and_vale",
  "Hywel Dda"             = "hywel_dda",
  "Cwm Taf Morgannwg"     = "cwm_taf_morgannwg",
  "Powys"                 = "powys",
  "Swansea Bay"           = "swansea_bay"
)

d_reg_desc_hb <-
  read_xlsx(
    path = "t_reg_coverage_summaries.xlsx",
    sheet = "healthboard"
  ) %>% 
  clean_names() %>% 
  # reshape
  pivot_longer(cols = -mid_year, values_to = "n") %>% 
  mutate(
    link_status  = str_replace(name, expr_measure, "\\1"),
    health_board = str_replace(name, expr_measure, "\\2"),
    n = replace_na(n, 0)
  ) %>% 
  select(-name) %>% 
  filter(health_board != "total") %>% 
  # calculate percentage
  group_by(health_board, mid_year) %>% 
  mutate(p = n / sum(n)) %>% 
  ungroup() %>% 
  mutate(
    link_status = factor(link_status, lkp_link_status, names(lkp_link_status)),
    health_board = factor(health_board, lkp_wlgp_hb, names(lkp_wlgp_hb))
  )

# plot -------------------------------------------------------------------------

p_reg_healthboard_n <-
  d_reg_desc_hb %>% 
  ggplot(aes(
    x = mid_year,
    y = n,
    fill = link_status
  )) +
  facet_wrap(~ health_board, ncol = 2) +
  geom_col() +
  geom_line(
    data = d_ons_lhb,
    mapping = aes(fill= NULL),
    linetype = "31"
  ) +
  scale_x_continuous(
    breaks = x_breaks,
    labels = function(x) {str_replace(x, ".{2}(.{2})", "\\1")}
  ) +
  scale_y_continuous(
    name = "Mid-year count",
    limits = c(0, 0.8*10^6),
    breaks = breaks_pretty(4),
    labels = label_number(scale_cut = cut_short_scale())
  ) +
  scale_fill_manual(
    name = "GP record status",
    values = pal_link_status
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    plot.title.position = "plot",
    strip.background = element_blank(),
    strip.text = element_text(face = "bold")
  ) +
  ggtitle("(b) Health board coverage")

p_reg_healthboard_n

p_reg_healthboard_p <-
  d_reg_desc_hb %>% 
  ggplot(aes(
    x = mid_year,
    y = p,
    fill = link_status
  )) +
  facet_wrap(~ health_board, ncol = 2) +
  geom_col() +
  scale_x_continuous(
    breaks = x_breaks,
    labels = function(x) {str_replace(x, ".{2}(.{2})", "\\1")}
  ) +
  scale_y_continuous(
    name = "",
    breaks = breaks_pretty(5),
    labels = label_percent()
  ) +
  scale_fill_manual(
    name = "GP record status",
    values = pal_link_status
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    legend.title = element_text(face = "bold"),
    strip.background = element_blank(),
    strip.text = element_text(face = "bold")
  )

p_reg_healthboard_p


# final plot of gp coverage description ========================================

plot_design <- "
AA
BC
DE
"

p_reg_final <-
  guide_area() +
  p_reg_total_n +
  p_reg_total_p +
  p_reg_healthboard_n +
  p_reg_healthboard_p +
  plot_layout(
    design = plot_design,
    guides = "collect",
    heights = c(0.1, 1, 2.25)
  )

print(p_reg_final)

# save =========================================================================

ggsave(
  p_reg_final,
  file = "figures-and-tables/fig5_gp_coverage_desc.png",
  width = 6.25,
  height = 7.2,
  dpi = 600
)

ggsave(
  p_reg_final,
  file = "figures-and-tables/fig5_gp_coverage_desc.tif",
  width = 6.25,
  height = 7.2,
  dpi = 600
)
