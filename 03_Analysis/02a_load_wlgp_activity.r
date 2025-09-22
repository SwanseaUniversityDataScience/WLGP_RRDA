source("clear_workspace.r")

con <- db2_open()

db2_glue <- function(con, q, ...) {
    query <- str_glue(q, ...)
    l_res <- lapply(query, db2_run, conn = con)
    d_res <- bind_rows(l_res)
    return(d_res)
}

years <- 1990:2024


# fetch cohort =================================================================
cat("fetch cohort\n")

q_cohort <- "
SELECT *
FROM sailw1151v.sb_wlgp_activity_cohort;
"

d_cohort <- db2_run(con, q_cohort)

q_lsoa_lhb <- "
SELECT *
FROM sailw1151v.sb_wlgp_activity_lkp_lsoa_lad_lhb
ORDER BY id;
"

lkp_hb <-
    db2_run(con, q_lsoa_lhb) %>%
    select(
        "lsoa_id" = id,
        "hb_id"   = lhb23cd,
        "hb_desc" = lhb23nm
    ) %>%
    arrange(hb_id) %>%
    mutate(hb_desc = fct_inorder(hb_desc))

d_cohort <-
    d_cohort %>%
    left_join(lkp_hb, join_by(resid1990_lsoa_id == lsoa_id)) %>% rename(resid1990_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1991_lsoa_id == lsoa_id)) %>% rename(resid1991_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1992_lsoa_id == lsoa_id)) %>% rename(resid1992_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1993_lsoa_id == lsoa_id)) %>% rename(resid1993_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1994_lsoa_id == lsoa_id)) %>% rename(resid1994_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1995_lsoa_id == lsoa_id)) %>% rename(resid1995_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1996_lsoa_id == lsoa_id)) %>% rename(resid1996_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1997_lsoa_id == lsoa_id)) %>% rename(resid1997_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1998_lsoa_id == lsoa_id)) %>% rename(resid1998_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid1999_lsoa_id == lsoa_id)) %>% rename(resid1999_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2000_lsoa_id == lsoa_id)) %>% rename(resid2000_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2001_lsoa_id == lsoa_id)) %>% rename(resid2001_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2002_lsoa_id == lsoa_id)) %>% rename(resid2002_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2003_lsoa_id == lsoa_id)) %>% rename(resid2003_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2004_lsoa_id == lsoa_id)) %>% rename(resid2004_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2005_lsoa_id == lsoa_id)) %>% rename(resid2005_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2006_lsoa_id == lsoa_id)) %>% rename(resid2006_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2007_lsoa_id == lsoa_id)) %>% rename(resid2007_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2008_lsoa_id == lsoa_id)) %>% rename(resid2008_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2009_lsoa_id == lsoa_id)) %>% rename(resid2009_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2010_lsoa_id == lsoa_id)) %>% rename(resid2010_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2011_lsoa_id == lsoa_id)) %>% rename(resid2011_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2012_lsoa_id == lsoa_id)) %>% rename(resid2012_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2013_lsoa_id == lsoa_id)) %>% rename(resid2013_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2014_lsoa_id == lsoa_id)) %>% rename(resid2014_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2015_lsoa_id == lsoa_id)) %>% rename(resid2015_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2016_lsoa_id == lsoa_id)) %>% rename(resid2016_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2017_lsoa_id == lsoa_id)) %>% rename(resid2017_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2018_lsoa_id == lsoa_id)) %>% rename(resid2018_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2019_lsoa_id == lsoa_id)) %>% rename(resid2019_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2020_lsoa_id == lsoa_id)) %>% rename(resid2020_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2021_lsoa_id == lsoa_id)) %>% rename(resid2021_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2022_lsoa_id == lsoa_id)) %>% rename(resid2022_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2023_lsoa_id == lsoa_id)) %>% rename(resid2023_healthboard_desc = hb_desc) %>%
    left_join(lkp_hb, join_by(resid2024_lsoa_id == lsoa_id)) %>% rename(resid2024_healthboard_desc = hb_desc) %>%
    select(-ends_with("healthboard_id")) %>%
    select(
        alf_e,
        wob,
        sex,
        starts_with("resid1990"),
        starts_with("resid1991"),
        starts_with("resid1992"),
        starts_with("resid1993"),
        starts_with("resid1994"),
        starts_with("resid1995"),
        starts_with("resid1996"),
        starts_with("resid1997"),
        starts_with("resid1998"),
        starts_with("resid1999"),
        starts_with("resid2000"),
        starts_with("resid2001"),
        starts_with("resid2002"),
        starts_with("resid2003"),
        starts_with("resid2004"),
        starts_with("resid2005"),
        starts_with("resid2006"),
        starts_with("resid2007"),
        starts_with("resid2008"),
        starts_with("resid2009"),
        starts_with("resid2010"),
        starts_with("resid2011"),
        starts_with("resid2012"),
        starts_with("resid2013"),
        starts_with("resid2014"),
        starts_with("resid2015"),
        starts_with("resid2016"),
        starts_with("resid2017"),
        starts_with("resid2018"),
        starts_with("resid2019"),
        starts_with("resid2020"),
        starts_with("resid2021"),
        starts_with("resid2022"),
        starts_with("resid2023"),
        starts_with("resid2024")
    )


# fetch cohort registration history ============================================
cat("fetch reg history\n")

q_gp_reg <- "
SELECT
	gp_reg.alf_e,
	gp_reg.prac_cd_e,
	gp_reg.start_date AS prac_start_date,
	max(gp_reg.end_date) AS prac_end_date,
	max(gp_reg.gp_data_flag) AS sail_data_flg,
	count(person_day.event_dt) AS event_n
FROM sailwmc_v.c19_cohort_wlgp_clean_gp_reg_by_prac_inclnonsail_median AS gp_reg
LEFT JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON gp_reg.alf_e = person_day.alf_e
	AND person_day.event_dt BETWEEN gp_reg.start_date AND gp_reg.end_date
GROUP BY
	gp_reg.alf_e,
	gp_reg.start_date,
	gp_reg.prac_cd_e
ORDER BY
	gp_reg.alf_e,
	gp_reg.start_date,
	gp_reg.prac_cd_e;
"

d_cohort_reg_history <- db2_run(con, q_gp_reg)


# prepare gp reg flags =========================================================
cat("prepare gp reg flags\n")

check_overlap <- function(x_start, x_end, y_start, y_end)  {
    (x_start <= y_start & y_start <= x_end) |
    (x_start <= y_end   & y_end   <= x_end)
}

d_cohort_gp_coverage <-
    d_cohort_reg_history %>%
    mutate(
        sail_data_flg = replace_na(sail_data_flg, 0),
        event_n = replace_na(event_n, 0)
    ) %>%
    filter(sail_data_flg > 0 | event_n > 0) %>%
    lazy_dt() %>%
    mutate(
        gp1990_flg = check_overlap(prac_start_date, prac_end_date, ymd("1990-01-01"), ymd("1990-12-31")),
        gp1991_flg = check_overlap(prac_start_date, prac_end_date, ymd("1991-01-01"), ymd("1991-12-31")),
        gp1992_flg = check_overlap(prac_start_date, prac_end_date, ymd("1992-01-01"), ymd("1992-12-31")),
        gp1993_flg = check_overlap(prac_start_date, prac_end_date, ymd("1993-01-01"), ymd("1993-12-31")),
        gp1994_flg = check_overlap(prac_start_date, prac_end_date, ymd("1994-01-01"), ymd("1994-12-31")),
        gp1995_flg = check_overlap(prac_start_date, prac_end_date, ymd("1995-01-01"), ymd("1995-12-31")),
        gp1996_flg = check_overlap(prac_start_date, prac_end_date, ymd("1996-01-01"), ymd("1996-12-31")),
        gp1997_flg = check_overlap(prac_start_date, prac_end_date, ymd("1997-01-01"), ymd("1997-12-31")),
        gp1998_flg = check_overlap(prac_start_date, prac_end_date, ymd("1998-01-01"), ymd("1998-12-31")),
        gp1999_flg = check_overlap(prac_start_date, prac_end_date, ymd("1999-01-01"), ymd("1999-12-31")),
        gp2000_flg = check_overlap(prac_start_date, prac_end_date, ymd("2000-01-01"), ymd("2000-12-31")),
        gp2001_flg = check_overlap(prac_start_date, prac_end_date, ymd("2001-01-01"), ymd("2001-12-31")),
        gp2002_flg = check_overlap(prac_start_date, prac_end_date, ymd("2002-01-01"), ymd("2002-12-31")),
        gp2003_flg = check_overlap(prac_start_date, prac_end_date, ymd("2003-01-01"), ymd("2003-12-31")),
        gp2004_flg = check_overlap(prac_start_date, prac_end_date, ymd("2004-01-01"), ymd("2004-12-31")),
        gp2005_flg = check_overlap(prac_start_date, prac_end_date, ymd("2005-01-01"), ymd("2005-12-31")),
        gp2006_flg = check_overlap(prac_start_date, prac_end_date, ymd("2006-01-01"), ymd("2006-12-31")),
        gp2007_flg = check_overlap(prac_start_date, prac_end_date, ymd("2007-01-01"), ymd("2007-12-31")),
        gp2008_flg = check_overlap(prac_start_date, prac_end_date, ymd("2008-01-01"), ymd("2008-12-31")),
        gp2009_flg = check_overlap(prac_start_date, prac_end_date, ymd("2009-01-01"), ymd("2009-12-31")),
        gp2010_flg = check_overlap(prac_start_date, prac_end_date, ymd("2010-01-01"), ymd("2010-12-31")),
        gp2011_flg = check_overlap(prac_start_date, prac_end_date, ymd("2011-01-01"), ymd("2011-12-31")),
        gp2012_flg = check_overlap(prac_start_date, prac_end_date, ymd("2012-01-01"), ymd("2012-12-31")),
        gp2013_flg = check_overlap(prac_start_date, prac_end_date, ymd("2013-01-01"), ymd("2013-12-31")),
        gp2014_flg = check_overlap(prac_start_date, prac_end_date, ymd("2014-01-01"), ymd("2014-12-31")),
        gp2015_flg = check_overlap(prac_start_date, prac_end_date, ymd("2015-01-01"), ymd("2015-12-31")),
        gp2016_flg = check_overlap(prac_start_date, prac_end_date, ymd("2016-01-01"), ymd("2016-12-31")),
        gp2017_flg = check_overlap(prac_start_date, prac_end_date, ymd("2017-01-01"), ymd("2017-12-31")),
        gp2018_flg = check_overlap(prac_start_date, prac_end_date, ymd("2018-01-01"), ymd("2018-12-31")),
        gp2019_flg = check_overlap(prac_start_date, prac_end_date, ymd("2019-01-01"), ymd("2019-12-31")),
        gp2020_flg = check_overlap(prac_start_date, prac_end_date, ymd("2020-01-01"), ymd("2020-12-31")),
        gp2021_flg = check_overlap(prac_start_date, prac_end_date, ymd("2021-01-01"), ymd("2021-12-31")),
        gp2022_flg = check_overlap(prac_start_date, prac_end_date, ymd("2022-01-01"), ymd("2022-12-31")),
        gp2023_flg = check_overlap(prac_start_date, prac_end_date, ymd("2023-01-01"), ymd("2023-12-31")),
        gp2024_flg = check_overlap(prac_start_date, prac_end_date, ymd("2024-01-01"), ymd("2024-12-31")),
    ) %>%
    group_by(alf_e) %>%
    summarise(
        gp1990_flg = max(gp1990_flg),
        gp1991_flg = max(gp1991_flg),
        gp1992_flg = max(gp1992_flg),
        gp1993_flg = max(gp1993_flg),
        gp1994_flg = max(gp1994_flg),
        gp1995_flg = max(gp1995_flg),
        gp1996_flg = max(gp1996_flg),
        gp1997_flg = max(gp1997_flg),
        gp1998_flg = max(gp1998_flg),
        gp1999_flg = max(gp1999_flg),
        gp2000_flg = max(gp2000_flg),
        gp2001_flg = max(gp2001_flg),
        gp2002_flg = max(gp2002_flg),
        gp2003_flg = max(gp2003_flg),
        gp2004_flg = max(gp2004_flg),
        gp2005_flg = max(gp2005_flg),
        gp2006_flg = max(gp2006_flg),
        gp2007_flg = max(gp2007_flg),
        gp2008_flg = max(gp2008_flg),
        gp2009_flg = max(gp2009_flg),
        gp2010_flg = max(gp2010_flg),
        gp2011_flg = max(gp2011_flg),
        gp2012_flg = max(gp2012_flg),
        gp2013_flg = max(gp2013_flg),
        gp2014_flg = max(gp2014_flg),
        gp2015_flg = max(gp2015_flg),
        gp2016_flg = max(gp2016_flg),
        gp2017_flg = max(gp2017_flg),
        gp2018_flg = max(gp2018_flg),
        gp2019_flg = max(gp2019_flg),
        gp2020_flg = max(gp2020_flg),
        gp2021_flg = max(gp2021_flg),
        gp2022_flg = max(gp2022_flg),
        gp2023_flg = max(gp2023_flg),
        gp2024_flg = max(gp2024_flg),
    ) %>%
    ungroup() %>%
    as_tibble() %>%
    left_join(d_cohort, by = "alf_e") %>%
    mutate(
        gp1990_flg = if_else(resid1990_flg == 0, 0, gp1990_flg),
        gp1991_flg = if_else(resid1991_flg == 0, 0, gp1991_flg),
        gp1992_flg = if_else(resid1992_flg == 0, 0, gp1992_flg),
        gp1993_flg = if_else(resid1993_flg == 0, 0, gp1993_flg),
        gp1994_flg = if_else(resid1994_flg == 0, 0, gp1994_flg),
        gp1995_flg = if_else(resid1995_flg == 0, 0, gp1995_flg),
        gp1996_flg = if_else(resid1996_flg == 0, 0, gp1996_flg),
        gp1997_flg = if_else(resid1997_flg == 0, 0, gp1997_flg),
        gp1998_flg = if_else(resid1998_flg == 0, 0, gp1998_flg),
        gp1999_flg = if_else(resid1999_flg == 0, 0, gp1999_flg),
        gp2000_flg = if_else(resid2000_flg == 0, 0, gp2000_flg),
        gp2001_flg = if_else(resid2001_flg == 0, 0, gp2001_flg),
        gp2002_flg = if_else(resid2002_flg == 0, 0, gp2002_flg),
        gp2003_flg = if_else(resid2003_flg == 0, 0, gp2003_flg),
        gp2004_flg = if_else(resid2004_flg == 0, 0, gp2004_flg),
        gp2005_flg = if_else(resid2005_flg == 0, 0, gp2005_flg),
        gp2006_flg = if_else(resid2006_flg == 0, 0, gp2006_flg),
        gp2007_flg = if_else(resid2007_flg == 0, 0, gp2007_flg),
        gp2008_flg = if_else(resid2008_flg == 0, 0, gp2008_flg),
        gp2009_flg = if_else(resid2009_flg == 0, 0, gp2009_flg),
        gp2010_flg = if_else(resid2010_flg == 0, 0, gp2010_flg),
        gp2011_flg = if_else(resid2011_flg == 0, 0, gp2011_flg),
        gp2012_flg = if_else(resid2012_flg == 0, 0, gp2012_flg),
        gp2013_flg = if_else(resid2013_flg == 0, 0, gp2013_flg),
        gp2014_flg = if_else(resid2014_flg == 0, 0, gp2014_flg),
        gp2015_flg = if_else(resid2015_flg == 0, 0, gp2015_flg),
        gp2016_flg = if_else(resid2016_flg == 0, 0, gp2016_flg),
        gp2017_flg = if_else(resid2017_flg == 0, 0, gp2017_flg),
        gp2018_flg = if_else(resid2018_flg == 0, 0, gp2018_flg),
        gp2019_flg = if_else(resid2019_flg == 0, 0, gp2019_flg),
        gp2020_flg = if_else(resid2020_flg == 0, 0, gp2020_flg),
        gp2021_flg = if_else(resid2021_flg == 0, 0, gp2021_flg),
        gp2022_flg = if_else(resid2022_flg == 0, 0, gp2022_flg),
        gp2023_flg = if_else(resid2023_flg == 0, 0, gp2023_flg),
        gp2024_flg = if_else(resid2024_flg == 0, 0, gp2024_flg),
        gp_ever_flg = pmax(
            gp1990_flg,
            gp1991_flg,
            gp1992_flg,
            gp1993_flg,
            gp1994_flg,
            gp1995_flg,
            gp1996_flg,
            gp1997_flg,
            gp1998_flg,
            gp1999_flg,
            gp2000_flg,
            gp2001_flg,
            gp2002_flg,
            gp2003_flg,
            gp2004_flg,
            gp2005_flg,
            gp2006_flg,
            gp2007_flg,
            gp2008_flg,
            gp2009_flg,
            gp2010_flg,
            gp2011_flg,
            gp2012_flg,
            gp2013_flg,
            gp2014_flg,
            gp2015_flg,
            gp2016_flg,
            gp2017_flg,
            gp2018_flg,
            gp2019_flg,
            gp2020_flg,
            gp2021_flg,
            gp2022_flg,
            gp2023_flg,
            gp2024_flg
        )
    ) %>%
    select(
        alf_e,
        matches("gp[0-9]{4}_flg"),
        gp_ever_flg
    )

d_cohort <-
    d_cohort %>%
    left_join(d_cohort_gp_coverage, by = "alf_e")


# fetch cohort activity summaries ==============================================
cat("fetch cohort activity summaries:\n")

# total ------------------------------------------------------------------------
cat("\ttotal\n")

q_gp_overall_activity_total <- "
SELECT
    {year} AS event_yr,
    COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND cohort.resid{year}_wimd2019_quintile IS NOT NULL
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND (
		chronic_disease_monitoring = 1
		OR screening_or_assessment = 1
		OR patient_monitoring = 1
		OR patient_review = 1
		OR certificate = 1
		OR vaccination = 1
		OR maternal_or_child_health = 1
		OR observation = 1
		OR history_or_symptom = 1
		OR examination_or_sign = 1
		OR lab_procedure = 1
		OR lab_test_request_or_result = 1
		OR diagnosis = 1
		OR counselling_or_health_education = 1
		OR therapeutic_procedure = 1
		OR drug_theraphy_or_prescription = 1
		OR referral = 1
	);
"

d_gp_overall_activity_total <-
    db2_glue(con, q_gp_overall_activity_total, year = years) %>%
    mutate(xvar = "total", xlvl = "total")


# by year of birth -------------------------------------------------------------
cat("\tby year of birth\n")

q_gp_overall_activity_yob <- "
WITH
    yob_activity AS
    (
        SELECT
            FLOOR(year(cohort.wob) / 10) * 10 AS xlvl
        FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
        INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
        	ON cohort.alf_e = person_day.alf_e
        WHERE 1=1
            AND cohort.resid{year}_flg = 1
            AND cohort.resid{year}_wimd2019_quintile IS NOT NULL
            AND year(person_day.event_dt) = {year}
        	AND primary_care = 1
        	AND (
        		chronic_disease_monitoring = 1
        		OR screening_or_assessment = 1
        		OR patient_monitoring = 1
        		OR patient_review = 1
        		OR certificate = 1
        		OR vaccination = 1
        		OR maternal_or_child_health = 1
        		OR observation = 1
        		OR history_or_symptom = 1
        		OR examination_or_sign = 1
        		OR lab_procedure = 1
        		OR lab_test_request_or_result = 1
        		OR diagnosis = 1
        		OR counselling_or_health_education = 1
        		OR therapeutic_procedure = 1
        		OR drug_theraphy_or_prescription = 1
        		OR referral = 1
        	)
    )
SELECT xlvl, {year} AS event_yr, COUNT(*) AS event_n
FROM yob_activity
GROUP BY xlvl
ORDER BY xlvl;
"

d_gp_overall_activity_yob <-
    db2_glue(con, q_gp_overall_activity_yob, year = years) %>%
    mutate(xvar = "year_of_birth", xlvl = as.character(xlvl))


# by sex -----------------------------------------------------------------------
cat("\tby sex\n")

q_gp_overall_activity_sex <- "
SELECT
    {year} AS event_yr,
    CASE
        WHEN cohort.sex = 1 THEN 'Male'
        WHEN cohort.sex = 2 THEN 'Female'
    END AS xlvl,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND (
		chronic_disease_monitoring = 1
		OR screening_or_assessment = 1
		OR patient_monitoring = 1
		OR patient_review = 1
		OR certificate = 1
		OR vaccination = 1
		OR maternal_or_child_health = 1
		OR observation = 1
		OR history_or_symptom = 1
		OR examination_or_sign = 1
		OR lab_procedure = 1
		OR lab_test_request_or_result = 1
		OR diagnosis = 1
		OR counselling_or_health_education = 1
		OR therapeutic_procedure = 1
		OR drug_theraphy_or_prescription = 1
		OR referral = 1
	)
GROUP BY cohort.sex
ORDER BY cohort.sex;
"

d_gp_overall_activity_sex <-
    db2_glue(con, q_gp_overall_activity_sex, year = years) %>%
    mutate(xvar = "sex")


# by wimd ----------------------------------------------------------------------
cat("\tby wimd\n")

q_gp_overall_activity_wimd <- "
WITH
    wimd_activity AS
    (
        SELECT
            CASE
                WHEN year(event_dt) = {year}
                THEN resid{year}_wimd2019_quintile
            END AS xlvl
        FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
        INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
        	ON cohort.alf_e = person_day.alf_e
        WHERE 1=1
            AND cohort.resid{year}_flg = 1
            AND year(person_day.event_dt) = {year}
        	AND primary_care = 1
        	AND (
        		chronic_disease_monitoring = 1
        		OR screening_or_assessment = 1
        		OR patient_monitoring = 1
        		OR patient_review = 1
        		OR certificate = 1
        		OR vaccination = 1
        		OR maternal_or_child_health = 1
        		OR observation = 1
        		OR history_or_symptom = 1
        		OR examination_or_sign = 1
        		OR lab_procedure = 1
        		OR lab_test_request_or_result = 1
        		OR diagnosis = 1
        		OR counselling_or_health_education = 1
        		OR therapeutic_procedure = 1
        		OR drug_theraphy_or_prescription = 1
        		OR referral = 1
        	)
    )
SELECT xlvl, {year} AS event_yr, COUNT(*) AS event_n
FROM wimd_activity
GROUP BY xlvl
ORDER BY xlvl;
"

d_gp_overall_activity_wimd <-
    db2_glue(con, q_gp_overall_activity_wimd, year = years) %>%
    mutate(xvar = "wimd", xlvl = as.character(xlvl))


# combine results --------------------------------------------------------------
cat("\tcombine results\n")

d_cohort_summary_gp_activity <-
    bind_rows(
        d_gp_overall_activity_total,
        d_gp_overall_activity_yob,
        d_gp_overall_activity_sex,
        d_gp_overall_activity_wimd
    ) %>%
    select(
        xvar, xlvl, event_yr, event_n
    ) %>%
    mutate(
        xvar = fct_inorder(xvar),
        xlvl = fct_inorder(xlvl)
    ) %>%
    arrange(
        xvar, xlvl, event_yr
    )


# check ------------------------------------------------------------------------
cat("\tcheck\n")

# totals for each xvar are the same
d_cohort_summary_gp_activity %>%
    group_by(xvar) %>%
    summarise(event_n = sum(event_n)) %>%
    verify(all(event_n == first(event_n)))



# fetch gp activity by month ===================================================
cat("fetch gp activity by month\n")


# total ------------------------------------------------------------------------
cat("\ttotal\n")

# regardless of the event just count the number of person-days involving GPs

q_gp_monthly_total <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND (
		chronic_disease_monitoring = 1
		OR screening_or_assessment = 1
		OR patient_monitoring = 1
		OR patient_review = 1
		OR certificate = 1
		OR vaccination = 1
		OR maternal_or_child_health = 1
		OR observation = 1
		OR history_or_symptom = 1
		OR examination_or_sign = 1
		OR lab_procedure = 1
		OR lab_test_request_or_result = 1
		OR diagnosis = 1
		OR counselling_or_health_education = 1
		OR therapeutic_procedure = 1
		OR drug_theraphy_or_prescription = 1
		OR referral = 1
	)
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_total <-
	db2_glue(con, q_gp_monthly_total, year = years) %>%
	arrange(event_month)


# admin only events ------------------------------------------------------------
cat("\tadmin only events\n")

# count person-days in which there is only admin events

q_gp_monthly_admin <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND pharmacy_visit = 0
	AND dental_visit = 0
	AND chronic_disease_monitoring = 0
	AND screening_or_assessment = 0
	AND patient_monitoring = 0
	AND patient_review = 0
	AND certificate = 0
	AND vaccination = 0
	AND maternal_or_child_health = 0
	AND observation = 0
	AND history_or_symptom = 0
	AND examination_or_sign = 0
	AND lab_procedure = 0
	AND lab_test_request_or_result = 0
	AND diagnosis = 0
	AND counselling_or_health_education = 0
	AND therapeutic_procedure = 0
	AND drug_theraphy_or_prescription = 0
	AND referral = 0
	AND (
		admin = 1
	 OR demographics_or_registration = 1
	)
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_admin <-
    db2_glue(con, q_gp_monthly_admin, year = years) %>%
	mutate(activity_cat = "admin_only") %>%
	arrange(event_month)


# certificates -----------------------------------------------------------------
cat("\tcertificates\n")

q_gp_monthly_certificate <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND certificate = 1
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_certificate <-
    db2_glue(con, q_gp_monthly_certificate, year = years) %>%
	mutate(activity_cat = "certificate") %>%
	arrange(event_month)


# consultations ----------------------------------------------------------------
cat("\tconsultations\n")

# any person-day that involved some sort of clinical event
# outside of screening, monitoring or reviewing

q_gp_monthly_consultation <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND (
		chronic_disease_monitoring = 1
		OR screening_or_assessment = 1
		OR patient_monitoring = 1
		OR patient_review = 1
		OR certificate = 1
		OR maternal_or_child_health = 1
		OR observation = 1
		OR history_or_symptom = 1
		OR examination_or_sign = 1
		OR lab_procedure = 1
		OR lab_test_request_or_result = 1
		OR diagnosis = 1
		OR counselling_or_health_education = 1
		OR therapeutic_procedure = 1
		OR ((f2f = 1 OR remote = 1 OR in_practice_visit = 1 OR phone_call = 1 OR home_visit = 1) AND drug_theraphy_or_prescription = 1)
		OR referral = 1
	)
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_consultation <-
    db2_glue(con, q_gp_monthly_consultation, year = years) %>%
	mutate(activity_cat = "consultation") %>%
	arrange(event_month)


# failed encounters ------------------------------------------------------------
cat("\tfailed encounters\n")

q_gp_monthly_failed_encounter <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND failed_encounter = 1
	AND chronic_disease_monitoring = 0
	AND screening_or_assessment = 0
	AND patient_monitoring = 0
	AND patient_review = 0
	AND certificate = 0
	AND vaccination = 0
	AND maternal_or_child_health = 0
	AND observation = 0
	AND history_or_symptom = 0
	AND examination_or_sign = 0
	AND lab_procedure = 0
	AND lab_test_request_or_result = 0
	AND diagnosis = 0
	AND counselling_or_health_education = 0
	AND therapeutic_procedure = 0
	AND drug_theraphy_or_prescription = 0
	AND referral = 0
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_failed_encounter <-
    db2_glue(con, q_gp_monthly_failed_encounter, year = years) %>%
	mutate(activity_cat = "failed_encounter") %>%
	arrange(event_month)


# prescriptions only -----------------------------------------------------------
cat("\tprescriptions only\n")

# only count person-days that contain only a prescription events

q_gp_monthly_prescription <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND pharmacy_visit = 0
	AND dental_visit = 0
	AND chronic_disease_monitoring = 0
	AND screening_or_assessment = 0
	AND patient_monitoring = 0
	AND patient_review = 0
	AND certificate = 0
	AND vaccination = 0
	AND maternal_or_child_health = 0
	AND observation = 0
	AND history_or_symptom = 0
	AND examination_or_sign = 0
	AND lab_procedure = 0
	AND lab_test_request_or_result = 0
	AND diagnosis = 0
	AND counselling_or_health_education = 0
	AND therapeutic_procedure = 0
	AND drug_theraphy_or_prescription = 1
	AND referral = 0
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_prescription <-
    db2_glue(con, q_gp_monthly_prescription, year = years) %>%
	mutate(activity_cat = "prescription_only") %>%
	arrange(event_month)


# patient review or monitoring -------------------------------------------------
cat("\tpatient review or monitoring\n")

# any person-day with patient monitoring or reviewing

q_gp_monthly_review_monitor <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND (
		chronic_disease_monitoring = 1
		OR patient_monitoring = 1
		OR patient_review = 1
	)
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_review_monitor <-
	db2_glue(con, q_gp_monthly_review_monitor, year = years) %>%
	mutate(activity_cat = "patient_review_monitor") %>%
	arrange(event_month)


# screening and assessments ----------------------------------------------------
cat("\tscreening and assessments\n")

# any person-day with screening or assessments

q_gp_monthly_screening_assessment <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND screening_or_assessment = 1
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_screening_assessment <-
    db2_glue(con, q_gp_monthly_screening_assessment, year = years) %>%
	mutate(activity_cat = "screening_assessment") %>%
	arrange(event_month)


# vaccinations -----------------------------------------------------------------
cat("\tvaccinations\n")

# any person-day with a vaccination

q_gp_monthly_vaccination <- "
SELECT
	CAST(DATE_TRUNC('MONTH', event_dt) AS DATE) AS event_month,
	COUNT(*) AS event_n
FROM sailw1151v.sb_wlgp_activity_cohort AS cohort
INNER JOIN sailw1151v.rrda_wlgp_person_day_interactions_20241231 AS person_day
	ON cohort.alf_e = person_day.alf_e
WHERE 1=1
    AND cohort.resid{year}_flg = 1
    AND year(person_day.event_dt) = {year}
	AND primary_care = 1
	AND vaccination = 1
GROUP BY
	DATE_TRUNC('MONTH', event_dt);
"

d_gp_monthly_vaccination <-
    db2_glue(con, q_gp_monthly_vaccination, year = years) %>%
	mutate(activity_cat = "vaccination") %>%
	arrange(event_month)


# save =========================================================================
cat("save\n")

qsavem(
	d_cohort,
	d_cohort_summary_gp_activity,
	d_cohort_reg_history,
	d_gp_monthly_total,
	d_gp_monthly_admin,
	d_gp_monthly_certificate,
	d_gp_monthly_consultation,
	d_gp_monthly_failed_encounter,
	d_gp_monthly_prescription,
	d_gp_monthly_review_monitor,
	d_gp_monthly_screening_assessment,
	d_gp_monthly_vaccination,
	file = s_drive("d_wlgp_activity.qsm")
)

db2_close(con)


# plot monthly activity ========================================================
cat("plot monthly activity\n")

print(
	bind_rows(
	    d_gp_monthly_total        %>% mutate(activity = "overall"),
	    d_gp_monthly_consultation %>% mutate(activity = "consultation"),
	    d_gp_monthly_prescription %>% mutate(activity = "prescription"),
	    d_gp_monthly_vaccination  %>% mutate(activity = "vaccination")
	) %>%
	ggplot(aes(
		x = event_month,
		y = event_n,
		colour = activity
	)) +
	geom_line() +
	scale_y_continuous(
		labels = comma
	) +
	scale_x_date(
		date_breaks = "1 year",
		date_labels = "%y"
	)
)

cat("done\n")
beep()
