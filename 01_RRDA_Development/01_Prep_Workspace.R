# ******************************************************************************
# Script:        01_Prep_Workspace.r
# About:         Prepare workspace
# Author:        Hoda Abbasizanjani
# Date:          2025

# ******************************************************************************
# Clear workspace ----
# ******************************************************************************
cat("Preparation of workspace\n")
rm(list = ls())
gc()

# ******************************************************************************
# Load packages ----
# ******************************************************************************
pkgs <- c(
  # alphabetical
  "dplyr",
  "RODBC",
  "sailr",
  "janitor",
  "tidyr",
  "tidyverse",
  "tidyselect",
  "lubridate",
  "stringr",
  "data.table",
  "dtplyr",
  "stringi",
  "formattable",
  "kableExtra",
  "ggplot2",
  "ggthemes",
  "qs"
)

for (pkg in pkgs) {
  suppressWarnings(
    suppressPackageStartupMessages(
      library(pkg, character.only = TRUE)
    )
  )
}

rm(pkg, pkgs)

# ******************************************************************************
# Open DB2 connection (using SAILR package) ----
# ******************************************************************************
conn <- db2_open()

# ******************************************************************************
# Plots setup ----
# ******************************************************************************
theme_set(theme_bw())

# ******************************************************************************
