library(tidyverse) # all hail hadley wickham
library(janitor)
library(patchwork)
library(scales)
library(readxl)    # read XLSX
library(rvest)     # read HTML
library(cowplot)

setwd("~/Projects/ADR MSC - GP Activity/Results 2025-07-23")

rm(list = ls())

# Figure 3: % of patients and clinical records retained in the RRDA ============

d_rrda_orig <-
  read_xlsx(
    path = "RRDA_vs_Original_WLGP.xlsx",
    sheet = "RRDA_vs_Original_WLGP",
    skip  = 2
  ) %>% 
  clean_names() %>% 
  mutate(
    records_orig = wlgp_rrda_records / percent_of_original_wlgp_records,
    records_rrda = wlgp_rrda_records,
    patients_orig = patients_with_a_record_in_wlgp_rrda / percent_of_patients_in_the_original_wlgp,
    patients_rrda = patients_with_a_record_in_wlgp_rrda
  ) %>% 
  select(
    event_year,
    records_orig,
    records_rrda,
    patients_orig,
    patients_rrda
  ) %>% 
  pivot_longer(
    cols = -event_year,
    names_to = "stat",
    values_to = "n"
  ) %>% 
  separate(col = stat, into = c("unit", "stat")) %>% 
  group_by(event_year, unit) %>% 
  mutate(p = n / first(n)) %>% 
  ungroup()

lkp_unit <- c(
  "(a) Patients per year" = "patients",
  "(b) Records per year"  = "records"
)

lkp_stat <- c(
  "Original WLGP data" = "orig",
  "RRDA" = "rrda"
)

pal_stat <- c(
  "Original WLGP data" = "#66c2a5",
  "RRDA"  = "#fc8d62"
)

d_rrda_orig %>% 
  group_by(stat, unit) %>% 
  summarise(n = sum(n))

p_rrda_orig_n <-
  d_rrda_orig %>%
  mutate(
    unit = factor(unit, lkp_unit, names(lkp_unit)),
    stat = factor(stat, lkp_stat, names(lkp_stat)),
  ) %>% 
  ggplot(aes(
    x = event_year,
    y = n,
    group = stat,
    fill = stat,
    colour = stat
  )) +
  facet_wrap(~ unit, nrow = 1, scales = "free_y") +
  geom_line() +
  scale_x_continuous(
    breaks = seq(1990, 2025, by = 5)
  ) +
  scale_y_continuous(
    name   = "Frequency",
    breaks = breaks_pretty(4),
    limits = c(0, NA),
    labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0.01, 0.05))
  ) +
  scale_colour_manual(
    name = "Data source",
    values = pal_stat
  ) +
  scale_fill_manual(
    name = "Data source",
    values = pal_stat
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "top",
    legend.margin = margin(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.background = element_blank(),
    strip.placement = "outside"
  )
  
p_rrda_orig_n

p_rrda_orig_p <-
  d_rrda_orig %>% 
  mutate(
    unit = factor(unit, lkp_unit, names(lkp_unit)),
    stat = factor(stat, lkp_stat, names(lkp_stat)),
  ) %>% 
  ggplot(aes(
    x = event_year,
    y = p,
    group = stat,
    fill = stat,
    colour = stat
  )) +
  facet_wrap(~ unit, nrow = 1, scales = "free_y") +
  geom_line() +
  scale_x_continuous(
    breaks = seq(1990, 2025, by = 5)
  ) +
  scale_y_continuous(
    name   = "Percentage",
    breaks = breaks_pretty(),
    limits = c(0, 1),
    labels = percent,
    expand = expansion(mult = c(0.01, 0.05))
  ) +
  scale_colour_manual(
    name = "Data source",
    values = pal_stat
  ) +
  scale_fill_manual(
    name = "Data source",
    values = pal_stat
  ) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "none",
    legend.title = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )

p_rrda_orig_np <- plot_grid(
  p_rrda_orig_n + theme(legend.position = "none"),
  p_rrda_orig_p,
  align = "hv",
  axis = "trbl",
  ncol = 1
)

legend <- get_legend(p_rrda_orig_n)

p_rrda_orig <- plot_grid(
  legend,
  p_rrda_orig_np,
  ncol = 1,
  rel_heights = c(1, 19)
)

ggsave(
  p_rrda_orig,
  file = "figures/fig3_rrda_vs_original.png",
  width = 6.25,
  height = 4,
  dpi = 600,
  bg = "#ffffff"
)


ggsave(
  p_rrda_orig,
  file = "figures/fig3_rrda_vs_original.tif",
  width = 6.25,
  height = 4,
  dpi = 600,
  bg = "#ffffff"
)





# Figure 4: % of distinct codes and % of records mapped to clinical codes ======

col_names <- c(
  "year",
  "All distinct codes_n",
  "Read V2_n",
  "Read V2_percent",
  "SNOMED_n",
  "SNOMED_percent",
  "Vision DHCW list_n",
  "Vision DHCW list_percent",
  "EMIS DHCW list_n",
  "EMIS DHCW list_percent",
  "Additional Read or Vision_n",
  "Additional Read or Vision_percent",
  "Additional EMIS_n",
  "Additional EMIS_percent",
  "Blank or Invalid_n",
  "Blank or iIvalid_percent",
  "Unknown type_n",
  "Unknown type_percent"
)

d_code_distinct <-
  read_xlsx(
    path = "RRDA_Records_and_Distinct_Codes.xlsx",
    sheet = "RRDA_Distinct_Codes_By_Year",
    skip = 2,
    col_names = col_names
  ) %>% 
  select(-`All distinct codes_n`) %>% 
  filter(!is.na(year)) %>% 
  mutate(across(everything(), as.numeric)) %>% 
  pivot_longer(col = -year) %>% 
  separate(col = name, into = c("src", "stat"), sep = "_") %>% 
  mutate(cat = "(a) Distinct codes per year")

d_code_records <-
  read_xlsx(
    path = "RRDA_Records_and_Distinct_Codes.xlsx",
    sheet = "RRDA_Records_By_Year",
    skip = 2,
    col_names = col_names
  ) %>% 
  select(-`All distinct codes_n`) %>% 
  filter(!is.na(year)) %>% 
  mutate(across(everything(), as.numeric)) %>% 
  pivot_longer(col = -year) %>% 
  separate(col = name, into = c("src", "stat"), sep = "_") %>% 
  mutate(cat = "(b) Records per year")

lkp_src <- c(
  "Blank or Invalid"          = "Blank or Invalid",
  "Blank or Invalid"          = "Blank or iIvalid",
  "Unknown type"              = "Unknown type",
  "SNOMED"                    = "SNOMED",
  "Vision"                    = "Vision DHCW list",
  "EMIS"                      = "EMIS DHCW list",
  "Additional Read or Vision" = "Additional Read or Vision",
  "Additional EMIS"           = "Additional EMIS",
  "Read V2"                   = "Read V2"
)

d_code <-
  bind_rows(d_code_distinct, d_code_records) %>% 
  mutate(src = factor(src, lkp_src, names(lkp_src))) %>% 
  group_by(year, src, stat, cat) %>% 
  summarise(value = sum(value)) %>% 
  ungroup()

pal_src <- c(
  "Blank or Invalid"          = "#36648b",
  "Unknown type"              = "#87ceeb",
  "SNOMED"                    = "#a6d854",
  "Vision"                    = "#458b74",
  "EMIS"                      = "#74c69d",
  "Additional Read or Vision" = "#b5ead7",
  "Additional EMIS"           = "#ffd92f"
)

p_code_freq <-
  d_code %>% 
  filter(stat == "n") %>% 
  filter(src != "Read V2") %>% 
  ggplot(aes(
    x = year,
    y = value,
    group = src,
    fill = src
  )) +
  facet_wrap(~ cat, nrow = 1, scales = "free_y") +
  geom_col() +
  scale_x_continuous(
    breaks = seq(1990, 2025, by = 5)
  ) +
  scale_y_continuous(
    name   = "Frequency",
    breaks = breaks_pretty(5),
    limits = c(0, NA),
    labels = label_number(scale_cut = cut_short_scale()),
    expand = expansion(mult = c(0.01, 0.05))
  ) +
  scale_fill_manual(values = pal_src) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "right",
    legend.title = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.background = element_blank()
  )

p_code_percent <-
  d_code %>% 
  filter(stat == "percent") %>% 
  filter(src != "Read V2") %>% 
  ggplot(aes(
    x = year,
    y = value,
    group = src,
    fill = src
  )) +
  facet_wrap(~ cat, nrow = 1, scales = "free_y") +
  geom_col() +
  scale_x_continuous(
    breaks = seq(1990, 2025, by = 5)
  ) +
  scale_y_continuous(
    name   = "Percent",
    breaks = breaks_pretty(5),
    limits = c(0, NA),
    labels = percent,
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  scale_fill_manual(values = pal_src) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "right",
    legend.title = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )

plot_layout <- "
AC
BC
"

p_code <-
  p_code_freq +
  p_code_percent +
  guide_area() +
  plot_layout(guides = "collect", widths = c(8, 1), design = plot_layout)


p_code



#####################

p_code_percent <-
  d_code %>% 
  filter(stat == "percent") %>% 
  filter(src != "Read V2") %>% 
  ggplot(aes(
    x = year,
    y = value,
    group = src,
    fill = src
  )) +
  facet_wrap(~ cat, nrow = 1, scales = "free_y") +
  geom_col() +
  scale_x_continuous(
    breaks = seq(1990, 2025, by = 5)
  ) +
  scale_y_continuous(
    name   = "Percent",
    breaks = breaks_pretty(5),
    limits = c(0, 0.5),
    labels = percent,
    expand = expansion(mult = c(0.01, 0.01))
  ) +
  scale_fill_manual(values = pal_src) +
  theme_bw(base_size = 8) +
  theme(
    axis.title.x = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0.98, 0.98),
    legend.justification = c(1, 1),
    legend.title = element_blank(),
    legend.key.size = unit(12, "pt"),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    strip.background = element_blank()
  )

p_code_percent

ggsave(
  p_code_percent,
  file = "figures/fig4_extra_code_percent.png",
  width = 6.25,
  height = 3,
  dpi = 600
)

ggsave(
  p_code_percent,
  file = "figures/fig4_extra_code_percent.tif",
  width = 6.25,
  height = 3,
  dpi = 600
)
  