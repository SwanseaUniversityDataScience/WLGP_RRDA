source("clear_workspace.r")

# list files ===================================================================
cat("list files\n")

wales_file <- dir(s_drive("StatsWales GP Activity"), pattern = ".*.csv", full.names = TRUE)

cluster_data_dir <- dir(s_drive("StatsWales GP Activity/Cluster"), full.names = TRUE)

lhb_data_dir <- dir(s_drive("StatsWales GP Activity/LHB"), full.names = TRUE)


# create header ================================================================
cat("create header\n")

# first two rows of the CSV are the header, which R cant handle, so we roll our
# own header and then skip the first two rows when reading the file later

header <-
    read_csv(
        file = lhb_data_dir[1],
        n_max = 2,
        col_names = FALSE,
        na = c("", ".")
    ) %>%
    summarise(across(everything(), ~ last(na.omit(.x)))) %>%
    unlist(use.names = FALSE)

header <- c("measure", "category", header[-1:-2])
header <- make_clean_names(header)


# load cluster data ============================================================
cat("load cluster data\n")

# loop over the list of CSV file names, read in and process

l_cluster <- list()
expr_cluster <- ".*/([A-Za-z ]*) - ([A-Za-z ]*)\\.csv"

for (i in 1:length(cluster_data_dir)) {
    l_cluster[[i]] <-
        read_csv(
            file = cluster_data_dir[i],
            col_names = header,
            na = c("", "."),
            skip = 2
        ) %>%
        fill(measure, .direction = "down") %>%
        filter(!is.na(category)) %>%
        mutate(
            local_health_board = str_replace(cluster_data_dir[i], expr_cluster, "\\1"),
            cluster = str_replace(cluster_data_dir[i], expr_cluster, "\\2"),
            .before = measure
        )
}

d_cluster <-
    bind_rows(l_cluster) %>%
    select(
        -x2022_23,
        -x2023_24
    ) %>%
    pivot_longer(
        cols = c(-local_health_board, -cluster, -measure, -category),
        names_to = "month",
        values_to = "count"
    ) %>%
    mutate(
        month = str_c("01_", month),
        month = dmy(month)
    ) %>%
    rename(
        lhb_nm = local_health_board
    )

d_cluster <-
    d_cluster %>%
    filter(measure == "Mode of Consultation") %>%
    select(-measure) %>%
    rename(consultation = category)


# load lhb data ================================================================
cat("load lhb data\n")

# loop over the list of CSV file names, read in and process

l_lhb <- list()
expr_lhb <- ".*/([A-Za-z ]*)\\.csv"

for (i in 1:length(lhb_data_dir)) {
    l_lhb[[i]] <-
        read_csv(
            file = lhb_data_dir[i],
            col_names = header,
            na = c("", "."),
            skip = 2
        ) %>%
        fill(measure, .direction = "down") %>%
        filter(!is.na(category)) %>%
        mutate(
            local_health_board = str_replace(lhb_data_dir[i], expr_lhb, "\\1"),
            .before = measure
        )
}

d_lhb <-
    bind_rows(l_lhb) %>%
    select(
        -x2022_23,
        -x2023_24
    ) %>%
    pivot_longer(
        cols = c(-local_health_board, -measure, -category),
        names_to = "month",
        values_to = "count"
    ) %>%
    mutate(
        month = str_c("01_", month),
        month = dmy(month)
    ) %>%
    rename(
        lhb_nm = local_health_board
    )

d_lhb <-
    d_lhb %>%
    filter(measure == "Mode of Consultation") %>%
    select(-measure) %>%
    rename(consultation = category)


# load wales data ==============================================================
cat("load wales data\n")

d_wales <-
    read_csv(
        file = wales_file,
        col_names = header,
        na = c("", "."),
        skip = 2
    ) %>%
    fill(measure, .direction = "down") %>%
    filter(!is.na(category)) %>%
    mutate(
        country = "wales",
        .before = measure
    ) %>%
    select(
        -x2022_23,
        -x2023_24
    ) %>%
    pivot_longer(
        cols = c(-country, -measure, -category),
        names_to = "month",
        values_to = "count"
    ) %>%
    mutate(
        month = str_c("01_", month),
        month = dmy(month)
    ) %>%
    filter(measure == "Mode of Consultation") %>%
    select(-measure) %>%
    rename(consultation = category)


# save =========================================================================
cat("save\n")

qsave(
    d_cluster,
    file = s_drive("d_statswales_cluster_activity.qs")
)

qsave(
    d_lhb,
    file = s_drive("d_statswales_lhb_activity.qs")
)

qsave(
    d_wales,
    file = s_drive("d_statswales_wales_activity.qs")
)

beep()
