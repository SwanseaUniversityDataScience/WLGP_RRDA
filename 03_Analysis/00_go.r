stop("Never source this script")


# Load data ====================================================================

source("02a_load_wlgp_activity.r")
source("02b_load_statswales.r")


# Analysis =====================================================================

source("04a_cohort_summary.r")
source("04b_compare_wlgp_statswales.r")

source("05a_reg_coverage_clean.r")
source("05b_reg_coverage_analysis.r")

source("06a_gp_activity_clean.r")
source("06b_gp_activity_explore.r")
source("06c_gp_activity_analysis.r")

# Compare results ==============================================================

source("07a_compare_obs_counts.r")

# Report =======================================================================

source("clear_workspace.r")

render(
    input = "99_notebook.rmd",
    output_format = html_document(toc = TRUE),
    output_file = s_drive("request-out/99_notebook.html"),
    quiet = TRUE
)

rstudioapi::viewer(
    url = s_drive("request-out/99_notebook.html")
)
