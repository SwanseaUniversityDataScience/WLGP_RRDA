cat("clear workspace\n")

# try to close any open connection =============================================

tryCatch(
    expr = {db2_close(con)},
    error = function(e) {invisible()}
)

tryCatch(
    expr = {db2_close(conn)},
    error = function(e) {invisible()}
)

# clear workspace ==============================================================

rm(list = ls())
gc()

# options ======================================================================

options(
    dplyr.summarise.inform = FALSE,
    readr.show_col_types   = FALSE,
    readr.show_progress    = FALSE,
    lubridate.week.start   = 1 # Monday
)

# portable library =============================================================

# if we are using a portable version of R, use only the packages within its
# own library i.e. ignore user library
if (grepl(x = R.home(), pattern = "R-Portable")) {
    .libPaths(paste0(R.home(), "/library"))
}

# load packages ================================================================

pkgs <- c(
    # alphabetical
    "assertr",
    "beepr",
    "broom",
    "dplyr",
    "dtplyr",
    #"fable",
    #"fabletools",
    "forcats",
    "forecast",
    #"fpp3",
    "ggplot2",
    "ggridges",
    "ggstance",
    "ggh4x",
    "knitr",
    "kableExtra",
    "janitor",
    "lubridate",
    "mgcv",
    "modelr",
    "openxlsx",
    "patchwork",
    "qs",
    "readr",
    "rlang",
    "rmarkdown",
    "sailr",
    "scales",
    "stringr",
    "readr",
    "tibble",
    "tidyr"
)

for (pkg in pkgs) {
    suppressWarnings(
        suppressPackageStartupMessages(
            library(pkg, character.only = TRUE)
        )
    )
}

# custom functions =============================================================

s_drive <- function(...) {
    str_c("S:/1151 - Wales Multi-morbidity cohort (0911) - Census Data/ADR-MSC/WLGP_Interaction_Types/", ...)
}

cp_levels <- function(.data, ...) {
    mc <- match.call(expand.dots = FALSE)
    dots <- mc$...[[1]]
    lvls <- levels(.data[[dots]])
    msg <- paste0('"', lvls, '"')
    msg <- paste0(msg, sep = "\n", collapse = "")
    cat(msg)
}

quotemeta <- function(string) {
    str_replace_all(string, "(\\W)", "\\\\\\1")
}

suppress_n <- function(x) {
    y <- if_else(1 <= x & x <= 9, NA_integer_, as.integer(x))
    y <- janitor::round_half_up(y, -1)
    return(y)
}

kable_pretty <- function(
    # kable arguments
    x,
    align = NULL,
    format.args = list(big.mark = ","),
    # kable_styling arguments
    bootstrap_options = c("striped", "hover", "condensed"),
    full_width = FALSE,
    fixed_thead = TRUE,
    position = "center",
    ...
) {
    if (is.null(align)) {
        align <- rep("l", ncol(x))
        align[sapply(x, is.numeric)] <- "r"
    }
    kable(
        x = x,
        align = align,
        format.args = format.args
    ) %>%
    kable_styling(
        bootstrap_options = bootstrap_options,
        full_width = full_width,
        fixed_thead = fixed_thead,
        position = position,
        ...
    )
}

`%not_in%` <- Negate(`%in%`)


# plot dimensions ==============================================================

p_width  <- 5.20
p_height <- 8.75


# tidy up ======================================================================

rm(pkg, pkgs)
