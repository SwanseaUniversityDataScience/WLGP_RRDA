source("clear_workspace.r")

# find previous results ========================================================
cat("find previous results:")

folders <- dir(s_drive("request-out"), include.dirs = TRUE, pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}")
folders <- sort(folders)
previous <- folders[length(folders)]

cat(" '", previous, "'\n", sep = "")


# compare cohort overall summary ===============================================
cat("compare cohort overall summary\n")

filename <- "t_cohort_overall_summary.xlsx"

file_cur <- s_drive("request-out/", filename)
file_prv <- s_drive("request-out/", previous, "/", filename)

t_cur <- read.xlsx(file_cur)
t_prv <- read.xlsx(file_prv)

t_diff <-
    t_cur %>%
    full_join(t_prv, by = c("xvar", "xlvl"), suffix = c(".current", ".previous")) %>%
    mutate(
        pop_n.diff   = pop_n.current - pop_n.previous,
        gpreg_n.diff = gpreg_n.current - gpreg_n.previous,
        event_n.diff = event_n.current - event_n.previous
    ) %>%
    select(
        xvar,
        xlvl,
        starts_with("pop_n"),
        starts_with("gpreg_n"),
        starts_with("event_n")
    )

# check for any values between 1 and 9
t_diff %>% verify(!(1 <= pop_n.diff & pop_n.diff <= 9), success_fun = success_logical)
t_diff %>% verify(!(1 <= gpreg_n.diff & gpreg_n.diff <= 9), success_fun = success_logical)
t_diff %>% verify(!(1 <= event_n.diff & event_n.diff <= 9), success_fun = success_logical)

write.xlsx(
    t_diff,
    file = s_drive("request-out/diff_cohort_overall_summary.xlsx")
)

# compare reg coverage counts ==================================================
cat("compare reg coverage counts\n")

filename <- "t_reg_coverage_summaries.xlsx"

file_cur <- s_drive("request-out/", filename)
file_prv <- s_drive("request-out/", previous, "/", filename)

sheets <- c(
    "total",
    "sex",
    "wimd",
    "age",
    "healthboard"
)

l_diff <- list()
wb <- createWorkbook()

for (sh in sheets) {
    # sh = sheets[1]
    t_cur <- read.xlsx(file_cur, sheet = sh) %>% as_tibble()
    t_prv <- read.xlsx(file_prv, sheet = sh) %>% as_tibble()
    
    # names need cleaning in order to compare health boards
    if (sh == "healthboard") {
        names(t_cur) <- str_to_lower(names(t_cur))
        names(t_cur) <- str_replace_all(names(t_cur), "[ \\.]+", "_")
        names(t_cur) <- str_replace_all(names(t_cur), "&", "and")
        
        names(t_prv) <- str_to_lower(names(t_prv))
        names(t_prv) <- str_replace_all(names(t_prv), "[ \\.]+", "_")
        names(t_prv) <- str_replace_all(names(t_prv), "&", "and")
        names(t_prv) <- str_replace(names(t_prv), "abertawe_bro_morganwg", "swansea_bay")
        names(t_prv) <- str_replace(names(t_prv), "cwm_taf", "cwm_taf_morgannwg")
    }

    t_diff <- full_join(t_cur, t_prv, by = "mid_year", suffix = c(".current", ".previous"))

    # calc diff columns via a loop, since all sheets have unique columns
    cols <- names(t_cur)[str_detect(names(t_cur), "_n")]
    for (col in cols) {
        # col = cols[1]
        col_diff <- str_c(col, ".diff")
        t_diff[[col_diff]] <- t_cur[[col]] - t_prv[[col]]
        # check for any values between 1 and 9
        small_n <- 1 <= t_diff[[col_diff]] & t_diff[[col_diff]] <= 9
        if (any(small_n, na.rm = TRUE)) {
            msg <- str_glue("Small N found in {sh}${col} {sum(small_n)} times")
            stop(msg)
        }
    }
    
    # order the cols
    new_col_order <- unlist(lapply(cols, function(x) str_c(x, c(".current", ".previous", ".diff"))))
    new_col_order <- c("mid_year", new_col_order)
    t_diff <- t_diff[, new_col_order]
    
    # save to list
    l_diff[[sh]] <- t_diff

    # save to workbook
    addWorksheet(wb, sheetName = sh)
    writeData(wb, sh, t_diff)
}

# save
saveWorkbook(wb, s_drive("request-out/diff_reg_coverage_summaries.xlsx"), overwrite = TRUE)


# compare gp activity counts ===================================================
cat("compare gp activity counts\n")

filename <- "t_gp_activity_counts.xlsx"

file_cur <- s_drive("request-out/", filename)
file_prv <- s_drive("request-out/", previous, "/", filename)

sheets <- c(
    "admin_only",
    "certificate",
    "consultation",
    "failed_encounter",
    "patient_review_monitor",
    "prescription_only",
    "screening_assessment",
    "vaccination"
)

l_diff <- list()
wb <- createWorkbook()

for (sh in sheets) {
    # sh = sheets[1]
    t_cur <- read.xlsx(file_cur, sheet = sh)
    t_prv <- read.xlsx(file_prv, sheet = sh)

    t_diff <-
        t_cur %>%
        full_join(t_prv, by = c("activity_cat", "event_month"), suffix = c(".current", ".previous")) %>%
        mutate(
            obs_count.diff = obs_count.current - obs_count.previous,
            gpreg_n.diff   = gpreg_n.current - gpreg_n.previous
        ) %>%
        select(
            activity_cat,
            event_month,
            starts_with("obs_count"),
            starts_with("gpreg_n")
        )

    # check for any values less than 10 e.g. 9
    t_diff %>% verify(!(1 <= obs_count.diff & obs_count.diff <= 9))
    t_diff %>% verify(!(1 <= gpreg_n.diff & gpreg_n.diff <= 9))

    # save to list
    l_diff[[sh]] <- t_diff

    # save to workbook
    addWorksheet(wb, sheetName = sh)
    writeData(wb, sh, t_diff)
}

# save
saveWorkbook(wb, s_drive("request-out/diff_gp_activity_counts.xlsx"), overwrite = TRUE)

# done
cat("done!")
beep()