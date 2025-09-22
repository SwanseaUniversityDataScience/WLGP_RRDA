-- who is living in Wales between 1990-01-01 and 2024-12-31

-- =================================================================================================
-- Create table
-- =================================================================================================

CALL fnc.drop_if_exists('sailw1151v.sb_wlgp_activity_cohort');

CREATE TABLE sailw1151v.sb_wlgp_activity_cohort
(
	alf_e                       BIGINT NOT NULL,
	wob                         DATE,
	sex                         SMALLINT,
	resid1990_flg               SMALLINT,
	resid1990_wimd2019_quintile SMALLINT,
	resid1990_lsoa_id           SMALLINT,
	resid1991_flg               SMALLINT,
	resid1991_wimd2019_quintile SMALLINT,
	resid1991_lsoa_id           SMALLINT,
	resid1992_flg               SMALLINT,
	resid1992_wimd2019_quintile SMALLINT,
	resid1992_lsoa_id           SMALLINT,
	resid1993_flg               SMALLINT,
	resid1993_wimd2019_quintile SMALLINT,
	resid1993_lsoa_id           SMALLINT,
	resid1994_flg               SMALLINT,
	resid1994_wimd2019_quintile SMALLINT,
	resid1994_lsoa_id           SMALLINT,
	resid1995_flg               SMALLINT,
	resid1995_wimd2019_quintile SMALLINT,
	resid1995_lsoa_id           SMALLINT,
	resid1996_flg               SMALLINT,
	resid1996_wimd2019_quintile SMALLINT,
	resid1996_lsoa_id           SMALLINT,
	resid1997_flg               SMALLINT,
	resid1997_wimd2019_quintile SMALLINT,
	resid1997_lsoa_id           SMALLINT,
	resid1998_flg               SMALLINT,
	resid1998_wimd2019_quintile SMALLINT,
	resid1998_lsoa_id           SMALLINT,
	resid1999_flg               SMALLINT,
	resid1999_wimd2019_quintile SMALLINT,
	resid1999_lsoa_id           SMALLINT,
	resid2000_flg               SMALLINT,
	resid2000_wimd2019_quintile SMALLINT,
	resid2000_lsoa_id           SMALLINT,
	resid2001_flg               SMALLINT,
	resid2001_wimd2019_quintile SMALLINT,
	resid2001_lsoa_id           SMALLINT,
	resid2002_flg               SMALLINT,
	resid2002_wimd2019_quintile SMALLINT,
	resid2002_lsoa_id           SMALLINT,
	resid2003_flg               SMALLINT,
	resid2003_wimd2019_quintile SMALLINT,
	resid2003_lsoa_id           SMALLINT,
	resid2004_flg               SMALLINT,
	resid2004_wimd2019_quintile SMALLINT,
	resid2004_lsoa_id           SMALLINT,
	resid2005_flg               SMALLINT,
	resid2005_wimd2019_quintile SMALLINT,
	resid2005_lsoa_id           SMALLINT,
	resid2006_flg               SMALLINT,
	resid2006_wimd2019_quintile SMALLINT,
	resid2006_lsoa_id           SMALLINT,
	resid2007_flg               SMALLINT,
	resid2007_wimd2019_quintile SMALLINT,
	resid2007_lsoa_id           SMALLINT,
	resid2008_flg               SMALLINT,
	resid2008_wimd2019_quintile SMALLINT,
	resid2008_lsoa_id           SMALLINT,
	resid2009_flg               SMALLINT,
	resid2009_wimd2019_quintile SMALLINT,
	resid2009_lsoa_id           SMALLINT,
	resid2010_flg               SMALLINT,
	resid2010_wimd2019_quintile SMALLINT,
	resid2010_lsoa_id           SMALLINT,
	resid2011_flg               SMALLINT,
	resid2011_wimd2019_quintile SMALLINT,
	resid2011_lsoa_id           SMALLINT,
	resid2012_flg               SMALLINT,
	resid2012_wimd2019_quintile SMALLINT,
	resid2012_lsoa_id           SMALLINT,
	resid2013_flg               SMALLINT,
	resid2013_wimd2019_quintile SMALLINT,
	resid2013_lsoa_id           SMALLINT,
	resid2014_flg               SMALLINT,
	resid2014_wimd2019_quintile SMALLINT,
	resid2014_lsoa_id           SMALLINT,
	resid2015_flg               SMALLINT,
	resid2015_wimd2019_quintile SMALLINT,
	resid2015_lsoa_id           SMALLINT,
	resid2016_flg               SMALLINT,
	resid2016_wimd2019_quintile SMALLINT,
	resid2016_lsoa_id           SMALLINT,
	resid2017_flg               SMALLINT,
	resid2017_wimd2019_quintile SMALLINT,
	resid2017_lsoa_id           SMALLINT,
	resid2018_flg               SMALLINT,
	resid2018_wimd2019_quintile SMALLINT,
	resid2018_lsoa_id           SMALLINT,
	resid2019_flg               SMALLINT,
	resid2019_wimd2019_quintile SMALLINT,
	resid2019_lsoa_id           SMALLINT,
	resid2020_flg               SMALLINT,
	resid2020_wimd2019_quintile SMALLINT,
	resid2020_lsoa_id           SMALLINT,
	resid2021_flg               SMALLINT,
	resid2021_wimd2019_quintile SMALLINT,
	resid2021_lsoa_id           SMALLINT,
	resid2022_flg               SMALLINT,
	resid2022_wimd2019_quintile SMALLINT,
	resid2022_lsoa_id           SMALLINT,
	resid2023_flg               SMALLINT,
	resid2023_wimd2019_quintile SMALLINT,
	resid2023_lsoa_id           SMALLINT,
	resid2024_flg               SMALLINT,
	resid2024_wimd2019_quintile SMALLINT,
	resid2024_lsoa_id           SMALLINT,
	ever_wimd2019_q1            SMALLINT,
	ever_wimd2019_q2            SMALLINT,
	ever_wimd2019_q3            SMALLINT,
	ever_wimd2019_q4            SMALLINT,
	ever_wimd2019_q5            SMALLINT,
	PRIMARY KEY (alf_e)
);

GRANT ALL ON TABLE sailw1151v.sb_wlgp_activity_cohort
TO ROLE nrdasail_sail_1151_analyst;

TRUNCATE TABLE sailw1151v.sb_wlgp_activity_cohort
IMMEDIATE;

-- =================================================================================================
-- Populate table
-- =================================================================================================

INSERT INTO sailw1151v.sb_wlgp_activity_cohort
WITH
	cohort AS (
		SELECT
			pers.alf_e,
			pers.wob,
			cast(pers.gndr_cd AS SMALLINT) AS sex,
			lsoa.welsh_address,
			lsoa.start_date,
			lsoa.end_date,
			lsoa.lsoa2011_cd,
			lsoa.wimd_2014_quintile,
			lsoa.wimd_2019_quintile,
			lsoa.townsend_2011_quintile,
			ruc.rural_urban_classification_code,
			ruc.rural_urban_classification,
			lkp.id AS lsoa_id
		FROM sailwmc_v.c19_cohort_wdsd_single_clean_ar_pers                 AS pers
		INNER JOIN sailwmc_v.c19_cohort_wdsd_single_clean_geo_char_lsoa2011 AS lsoa
			ON pers.alf_e = lsoa.alf_e
		LEFT JOIN sailukhdv.rural_urban_class_lsoas_2011_scd                AS ruc
			ON lsoa.lsoa2011_cd = ruc.lsoa_code
		LEFT JOIN sailw1151v.sb_wlgp_activity_lkp_lsoa_lad_lhb              AS lkp
			ON lsoa.lsoa2011_cd = lkp.lsoa11cd
		WHERE
			pers.alf_e IS NOT NULL
			AND pers.wob IS NOT NULL
			AND pers.wob > '1880-01-01'
			AND pers.gndr_cd IN (1, 2)
			AND lsoa.welsh_address = 1
			AND lsoa.start_date <= '2024-12-31'
			AND lsoa.end_date >= '1990-01-01'
	),
	-- summarise yearly residence
	resid_summary AS (
		SELECT
			alf_e                                                                                                                                  AS alf_e,
			max(wob)                                                                                                                               AS wob,
			max(sex)                                                                                                                               AS sex,
			max(CASE WHEN wob + 110 YEARS > '1990-07-01' AND (start_date <= '1990-04-01' OR wob BETWEEN '1990-04-01' AND '1990-07-01') AND end_date > '1990-07-01' THEN 1 ELSE 0 END)           AS resid1990_flg,
			max(CASE WHEN wob + 110 YEARS > '1990-07-01' AND (start_date <= '1990-04-01' OR wob BETWEEN '1990-04-01' AND '1990-07-01') AND end_date > '1990-07-01' THEN wimd_2019_quintile END) AS resid1990_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1990-07-01' AND (start_date <= '1990-04-01' OR wob BETWEEN '1990-04-01' AND '1990-07-01') AND end_date > '1990-07-01' THEN lsoa_id END)            AS resid1990_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1991-07-01' AND (start_date <= '1991-04-01' OR wob BETWEEN '1991-04-01' AND '1991-07-01') AND end_date > '1991-07-01' THEN 1 ELSE 0 END)           AS resid1991_flg,
			max(CASE WHEN wob + 110 YEARS > '1991-07-01' AND (start_date <= '1991-04-01' OR wob BETWEEN '1991-04-01' AND '1991-07-01') AND end_date > '1991-07-01' THEN wimd_2019_quintile END) AS resid1991_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1991-07-01' AND (start_date <= '1991-04-01' OR wob BETWEEN '1991-04-01' AND '1991-07-01') AND end_date > '1991-07-01' THEN lsoa_id END)            AS resid1991_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1992-07-01' AND (start_date <= '1992-04-01' OR wob BETWEEN '1992-04-01' AND '1992-07-01') AND end_date > '1992-07-01' THEN 1 ELSE 0 END)           AS resid1992_flg,
			max(CASE WHEN wob + 110 YEARS > '1992-07-01' AND (start_date <= '1992-04-01' OR wob BETWEEN '1992-04-01' AND '1992-07-01') AND end_date > '1992-07-01' THEN wimd_2019_quintile END) AS resid1992_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1992-07-01' AND (start_date <= '1992-04-01' OR wob BETWEEN '1992-04-01' AND '1992-07-01') AND end_date > '1992-07-01' THEN lsoa_id END)            AS resid1992_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1993-07-01' AND (start_date <= '1993-04-01' OR wob BETWEEN '1993-04-01' AND '1993-07-01') AND end_date > '1993-07-01' THEN 1 ELSE 0 END)           AS resid1993_flg,
			max(CASE WHEN wob + 110 YEARS > '1993-07-01' AND (start_date <= '1993-04-01' OR wob BETWEEN '1993-04-01' AND '1993-07-01') AND end_date > '1993-07-01' THEN wimd_2019_quintile END) AS resid1993_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1993-07-01' AND (start_date <= '1993-04-01' OR wob BETWEEN '1993-04-01' AND '1993-07-01') AND end_date > '1993-07-01' THEN lsoa_id END)            AS resid1993_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1994-07-01' AND (start_date <= '1994-04-01' OR wob BETWEEN '1994-04-01' AND '1994-07-01') AND end_date > '1994-07-01' THEN 1 ELSE 0 END)           AS resid1994_flg,
			max(CASE WHEN wob + 110 YEARS > '1994-07-01' AND (start_date <= '1994-04-01' OR wob BETWEEN '1994-04-01' AND '1994-07-01') AND end_date > '1994-07-01' THEN wimd_2019_quintile END) AS resid1994_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1994-07-01' AND (start_date <= '1994-04-01' OR wob BETWEEN '1994-04-01' AND '1994-07-01') AND end_date > '1994-07-01' THEN lsoa_id END)            AS resid1994_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1995-07-01' AND (start_date <= '1995-04-01' OR wob BETWEEN '1995-04-01' AND '1995-07-01') AND end_date > '1995-07-01' THEN 1 ELSE 0 END)           AS resid1995_flg,
			max(CASE WHEN wob + 110 YEARS > '1995-07-01' AND (start_date <= '1995-04-01' OR wob BETWEEN '1995-04-01' AND '1995-07-01') AND end_date > '1995-07-01' THEN wimd_2019_quintile END) AS resid1995_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1995-07-01' AND (start_date <= '1995-04-01' OR wob BETWEEN '1995-04-01' AND '1995-07-01') AND end_date > '1995-07-01' THEN lsoa_id END)            AS resid1995_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1996-07-01' AND (start_date <= '1996-04-01' OR wob BETWEEN '1996-04-01' AND '1996-07-01') AND end_date > '1996-07-01' THEN 1 ELSE 0 END)           AS resid1996_flg,
			max(CASE WHEN wob + 110 YEARS > '1996-07-01' AND (start_date <= '1996-04-01' OR wob BETWEEN '1996-04-01' AND '1996-07-01') AND end_date > '1996-07-01' THEN wimd_2019_quintile END) AS resid1996_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1996-07-01' AND (start_date <= '1996-04-01' OR wob BETWEEN '1996-04-01' AND '1996-07-01') AND end_date > '1996-07-01' THEN lsoa_id END)            AS resid1996_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1997-07-01' AND (start_date <= '1997-04-01' OR wob BETWEEN '1997-04-01' AND '1997-07-01') AND end_date > '1997-07-01' THEN 1 ELSE 0 END)           AS resid1997_flg,
			max(CASE WHEN wob + 110 YEARS > '1997-07-01' AND (start_date <= '1997-04-01' OR wob BETWEEN '1997-04-01' AND '1997-07-01') AND end_date > '1997-07-01' THEN wimd_2019_quintile END) AS resid1997_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1997-07-01' AND (start_date <= '1997-04-01' OR wob BETWEEN '1997-04-01' AND '1997-07-01') AND end_date > '1997-07-01' THEN lsoa_id END)            AS resid1997_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1998-07-01' AND (start_date <= '1998-04-01' OR wob BETWEEN '1998-04-01' AND '1998-07-01') AND end_date > '1998-07-01' THEN 1 ELSE 0 END)           AS resid1998_flg,
			max(CASE WHEN wob + 110 YEARS > '1998-07-01' AND (start_date <= '1998-04-01' OR wob BETWEEN '1998-04-01' AND '1998-07-01') AND end_date > '1998-07-01' THEN wimd_2019_quintile END) AS resid1998_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1998-07-01' AND (start_date <= '1998-04-01' OR wob BETWEEN '1998-04-01' AND '1998-07-01') AND end_date > '1998-07-01' THEN lsoa_id END)            AS resid1998_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '1999-07-01' AND (start_date <= '1999-04-01' OR wob BETWEEN '1999-04-01' AND '1999-07-01') AND end_date > '1999-07-01' THEN 1 ELSE 0 END)           AS resid1999_flg,
			max(CASE WHEN wob + 110 YEARS > '1999-07-01' AND (start_date <= '1999-04-01' OR wob BETWEEN '1999-04-01' AND '1999-07-01') AND end_date > '1999-07-01' THEN wimd_2019_quintile END) AS resid1999_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '1999-07-01' AND (start_date <= '1999-04-01' OR wob BETWEEN '1999-04-01' AND '1999-07-01') AND end_date > '1999-07-01' THEN lsoa_id END)            AS resid1999_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2000-07-01' AND (start_date <= '2000-04-01' OR wob BETWEEN '2000-04-01' AND '2000-07-01') AND end_date > '2000-07-01' THEN 1 ELSE 0 END)           AS resid2000_flg,
			max(CASE WHEN wob + 110 YEARS > '2000-07-01' AND (start_date <= '2000-04-01' OR wob BETWEEN '2000-04-01' AND '2000-07-01') AND end_date > '2000-07-01' THEN wimd_2019_quintile END) AS resid2000_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2000-07-01' AND (start_date <= '2000-04-01' OR wob BETWEEN '2000-04-01' AND '2000-07-01') AND end_date > '2000-07-01' THEN lsoa_id END)            AS resid2000_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2001-07-01' AND (start_date <= '2001-04-01' OR wob BETWEEN '2001-04-01' AND '2001-07-01') AND end_date > '2001-07-01' THEN 1 ELSE 0 END)           AS resid2001_flg,
			max(CASE WHEN wob + 110 YEARS > '2001-07-01' AND (start_date <= '2001-04-01' OR wob BETWEEN '2001-04-01' AND '2001-07-01') AND end_date > '2001-07-01' THEN wimd_2019_quintile END) AS resid2001_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2001-07-01' AND (start_date <= '2001-04-01' OR wob BETWEEN '2001-04-01' AND '2001-07-01') AND end_date > '2001-07-01' THEN lsoa_id END)            AS resid2001_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2002-07-01' AND (start_date <= '2002-04-01' OR wob BETWEEN '2002-04-01' AND '2002-07-01') AND end_date > '2002-07-01' THEN 1 ELSE 0 END)           AS resid2002_flg,
			max(CASE WHEN wob + 110 YEARS > '2002-07-01' AND (start_date <= '2002-04-01' OR wob BETWEEN '2002-04-01' AND '2002-07-01') AND end_date > '2002-07-01' THEN wimd_2019_quintile END) AS resid2002_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2002-07-01' AND (start_date <= '2002-04-01' OR wob BETWEEN '2002-04-01' AND '2002-07-01') AND end_date > '2002-07-01' THEN lsoa_id END)            AS resid2002_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2003-07-01' AND (start_date <= '2003-04-01' OR wob BETWEEN '2003-04-01' AND '2003-07-01') AND end_date > '2003-07-01' THEN 1 ELSE 0 END)           AS resid2003_flg,
			max(CASE WHEN wob + 110 YEARS > '2003-07-01' AND (start_date <= '2003-04-01' OR wob BETWEEN '2003-04-01' AND '2003-07-01') AND end_date > '2003-07-01' THEN wimd_2019_quintile END) AS resid2003_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2003-07-01' AND (start_date <= '2003-04-01' OR wob BETWEEN '2003-04-01' AND '2003-07-01') AND end_date > '2003-07-01' THEN lsoa_id END)            AS resid2003_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2004-07-01' AND (start_date <= '2004-04-01' OR wob BETWEEN '2004-04-01' AND '2004-07-01') AND end_date > '2004-07-01' THEN 1 ELSE 0 END)           AS resid2004_flg,
			max(CASE WHEN wob + 110 YEARS > '2004-07-01' AND (start_date <= '2004-04-01' OR wob BETWEEN '2004-04-01' AND '2004-07-01') AND end_date > '2004-07-01' THEN wimd_2019_quintile END) AS resid2004_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2004-07-01' AND (start_date <= '2004-04-01' OR wob BETWEEN '2004-04-01' AND '2004-07-01') AND end_date > '2004-07-01' THEN lsoa_id END)            AS resid2004_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2005-07-01' AND (start_date <= '2005-04-01' OR wob BETWEEN '2005-04-01' AND '2005-07-01') AND end_date > '2005-07-01' THEN 1 ELSE 0 END)           AS resid2005_flg,
			max(CASE WHEN wob + 110 YEARS > '2005-07-01' AND (start_date <= '2005-04-01' OR wob BETWEEN '2005-04-01' AND '2005-07-01') AND end_date > '2005-07-01' THEN wimd_2019_quintile END) AS resid2005_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2005-07-01' AND (start_date <= '2005-04-01' OR wob BETWEEN '2005-04-01' AND '2005-07-01') AND end_date > '2005-07-01' THEN lsoa_id END)            AS resid2005_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2006-07-01' AND (start_date <= '2006-04-01' OR wob BETWEEN '2006-04-01' AND '2006-07-01') AND end_date > '2006-07-01' THEN 1 ELSE 0 END)           AS resid2006_flg,
			max(CASE WHEN wob + 110 YEARS > '2006-07-01' AND (start_date <= '2006-04-01' OR wob BETWEEN '2006-04-01' AND '2006-07-01') AND end_date > '2006-07-01' THEN wimd_2019_quintile END) AS resid2006_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2006-07-01' AND (start_date <= '2006-04-01' OR wob BETWEEN '2006-04-01' AND '2006-07-01') AND end_date > '2006-07-01' THEN lsoa_id END)            AS resid2006_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2007-07-01' AND (start_date <= '2007-04-01' OR wob BETWEEN '2007-04-01' AND '2007-07-01') AND end_date > '2007-07-01' THEN 1 ELSE 0 END)           AS resid2007_flg,
			max(CASE WHEN wob + 110 YEARS > '2007-07-01' AND (start_date <= '2007-04-01' OR wob BETWEEN '2007-04-01' AND '2007-07-01') AND end_date > '2007-07-01' THEN wimd_2019_quintile END) AS resid2007_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2007-07-01' AND (start_date <= '2007-04-01' OR wob BETWEEN '2007-04-01' AND '2007-07-01') AND end_date > '2007-07-01' THEN lsoa_id END)            AS resid2007_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2008-07-01' AND (start_date <= '2008-04-01' OR wob BETWEEN '2008-04-01' AND '2008-07-01') AND end_date > '2008-07-01' THEN 1 ELSE 0 END)           AS resid2008_flg,
			max(CASE WHEN wob + 110 YEARS > '2008-07-01' AND (start_date <= '2008-04-01' OR wob BETWEEN '2008-04-01' AND '2008-07-01') AND end_date > '2008-07-01' THEN wimd_2019_quintile END) AS resid2008_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2008-07-01' AND (start_date <= '2008-04-01' OR wob BETWEEN '2008-04-01' AND '2008-07-01') AND end_date > '2008-07-01' THEN lsoa_id END)            AS resid2008_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2009-07-01' AND (start_date <= '2009-04-01' OR wob BETWEEN '2009-04-01' AND '2009-07-01') AND end_date > '2009-07-01' THEN 1 ELSE 0 END)           AS resid2009_flg,
			max(CASE WHEN wob + 110 YEARS > '2009-07-01' AND (start_date <= '2009-04-01' OR wob BETWEEN '2009-04-01' AND '2009-07-01') AND end_date > '2009-07-01' THEN wimd_2019_quintile END) AS resid2009_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2009-07-01' AND (start_date <= '2009-04-01' OR wob BETWEEN '2009-04-01' AND '2009-07-01') AND end_date > '2009-07-01' THEN lsoa_id END)            AS resid2009_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2010-07-01' AND (start_date <= '2010-04-01' OR wob BETWEEN '2010-04-01' AND '2010-07-01') AND end_date > '2010-07-01' THEN 1 ELSE 0 END)           AS resid2010_flg,
			max(CASE WHEN wob + 110 YEARS > '2010-07-01' AND (start_date <= '2010-04-01' OR wob BETWEEN '2010-04-01' AND '2010-07-01') AND end_date > '2010-07-01' THEN wimd_2019_quintile END) AS resid2010_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2010-07-01' AND (start_date <= '2010-04-01' OR wob BETWEEN '2010-04-01' AND '2010-07-01') AND end_date > '2010-07-01' THEN lsoa_id END)            AS resid2010_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2011-07-01' AND (start_date <= '2011-04-01' OR wob BETWEEN '2011-04-01' AND '2011-07-01') AND end_date > '2011-07-01' THEN 1 ELSE 0 END)           AS resid2011_flg,
			max(CASE WHEN wob + 110 YEARS > '2011-07-01' AND (start_date <= '2011-04-01' OR wob BETWEEN '2011-04-01' AND '2011-07-01') AND end_date > '2011-07-01' THEN wimd_2019_quintile END) AS resid2011_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2011-07-01' AND (start_date <= '2011-04-01' OR wob BETWEEN '2011-04-01' AND '2011-07-01') AND end_date > '2011-07-01' THEN lsoa_id END)            AS resid2011_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2012-07-01' AND (start_date <= '2012-04-01' OR wob BETWEEN '2012-04-01' AND '2012-07-01') AND end_date > '2012-07-01' THEN 1 ELSE 0 END)           AS resid2012_flg,
			max(CASE WHEN wob + 110 YEARS > '2012-07-01' AND (start_date <= '2012-04-01' OR wob BETWEEN '2012-04-01' AND '2012-07-01') AND end_date > '2012-07-01' THEN wimd_2019_quintile END) AS resid2012_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2012-07-01' AND (start_date <= '2012-04-01' OR wob BETWEEN '2012-04-01' AND '2012-07-01') AND end_date > '2012-07-01' THEN lsoa_id END)            AS resid2012_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2013-07-01' AND (start_date <= '2013-04-01' OR wob BETWEEN '2013-04-01' AND '2013-07-01') AND end_date > '2013-07-01' THEN 1 ELSE 0 END)           AS resid2013_flg,
			max(CASE WHEN wob + 110 YEARS > '2013-07-01' AND (start_date <= '2013-04-01' OR wob BETWEEN '2013-04-01' AND '2013-07-01') AND end_date > '2013-07-01' THEN wimd_2019_quintile END) AS resid2013_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2013-07-01' AND (start_date <= '2013-04-01' OR wob BETWEEN '2013-04-01' AND '2013-07-01') AND end_date > '2013-07-01' THEN lsoa_id END)            AS resid2013_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2014-07-01' AND (start_date <= '2014-04-01' OR wob BETWEEN '2014-04-01' AND '2014-07-01') AND end_date > '2014-07-01' THEN 1 ELSE 0 END)           AS resid2014_flg,
			max(CASE WHEN wob + 110 YEARS > '2014-07-01' AND (start_date <= '2014-04-01' OR wob BETWEEN '2014-04-01' AND '2014-07-01') AND end_date > '2014-07-01' THEN wimd_2019_quintile END) AS resid2014_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2014-07-01' AND (start_date <= '2014-04-01' OR wob BETWEEN '2014-04-01' AND '2014-07-01') AND end_date > '2014-07-01' THEN lsoa_id END)            AS resid2014_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2015-07-01' AND (start_date <= '2015-04-01' OR wob BETWEEN '2015-04-01' AND '2015-07-01') AND end_date > '2015-07-01' THEN 1 ELSE 0 END)           AS resid2015_flg,
			max(CASE WHEN wob + 110 YEARS > '2015-07-01' AND (start_date <= '2015-04-01' OR wob BETWEEN '2015-04-01' AND '2015-07-01') AND end_date > '2015-07-01' THEN wimd_2019_quintile END) AS resid2015_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2015-07-01' AND (start_date <= '2015-04-01' OR wob BETWEEN '2015-04-01' AND '2015-07-01') AND end_date > '2015-07-01' THEN lsoa_id END)            AS resid2015_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2016-07-01' AND (start_date <= '2016-04-01' OR wob BETWEEN '2016-04-01' AND '2016-07-01') AND end_date > '2016-07-01' THEN 1 ELSE 0 END)           AS resid2016_flg,
			max(CASE WHEN wob + 110 YEARS > '2016-07-01' AND (start_date <= '2016-04-01' OR wob BETWEEN '2016-04-01' AND '2016-07-01') AND end_date > '2016-07-01' THEN wimd_2019_quintile END) AS resid2016_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2016-07-01' AND (start_date <= '2016-04-01' OR wob BETWEEN '2016-04-01' AND '2016-07-01') AND end_date > '2016-07-01' THEN lsoa_id END)            AS resid2016_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2017-07-01' AND (start_date <= '2017-04-01' OR wob BETWEEN '2017-04-01' AND '2017-07-01') AND end_date > '2017-07-01' THEN 1 ELSE 0 END)           AS resid2017_flg,
			max(CASE WHEN wob + 110 YEARS > '2017-07-01' AND (start_date <= '2017-04-01' OR wob BETWEEN '2017-04-01' AND '2017-07-01') AND end_date > '2017-07-01' THEN wimd_2019_quintile END) AS resid2017_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2017-07-01' AND (start_date <= '2017-04-01' OR wob BETWEEN '2017-04-01' AND '2017-07-01') AND end_date > '2017-07-01' THEN lsoa_id END)            AS resid2017_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2018-07-01' AND (start_date <= '2018-04-01' OR wob BETWEEN '2018-04-01' AND '2018-07-01') AND end_date > '2018-07-01' THEN 1 ELSE 0 END)           AS resid2018_flg,
			max(CASE WHEN wob + 110 YEARS > '2018-07-01' AND (start_date <= '2018-04-01' OR wob BETWEEN '2018-04-01' AND '2018-07-01') AND end_date > '2018-07-01' THEN wimd_2019_quintile END) AS resid2018_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2018-07-01' AND (start_date <= '2018-04-01' OR wob BETWEEN '2018-04-01' AND '2018-07-01') AND end_date > '2018-07-01' THEN lsoa_id END)            AS resid2018_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2019-07-01' AND (start_date <= '2019-04-01' OR wob BETWEEN '2019-04-01' AND '2019-07-01') AND end_date > '2019-07-01' THEN 1 ELSE 0 END)           AS resid2019_flg,
			max(CASE WHEN wob + 110 YEARS > '2019-07-01' AND (start_date <= '2019-04-01' OR wob BETWEEN '2019-04-01' AND '2019-07-01') AND end_date > '2019-07-01' THEN wimd_2019_quintile END) AS resid2019_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2019-07-01' AND (start_date <= '2019-04-01' OR wob BETWEEN '2019-04-01' AND '2019-07-01') AND end_date > '2019-07-01' THEN lsoa_id END)            AS resid2019_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2020-07-01' AND (start_date <= '2020-04-01' OR wob BETWEEN '2020-04-01' AND '2020-07-01') AND end_date > '2020-07-01' THEN 1 ELSE 0 END)           AS resid2020_flg,
			max(CASE WHEN wob + 110 YEARS > '2020-07-01' AND (start_date <= '2020-04-01' OR wob BETWEEN '2020-04-01' AND '2020-07-01') AND end_date > '2020-07-01' THEN wimd_2019_quintile END) AS resid2020_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2020-07-01' AND (start_date <= '2020-04-01' OR wob BETWEEN '2020-04-01' AND '2020-07-01') AND end_date > '2020-07-01' THEN lsoa_id END)            AS resid2020_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2021-07-01' AND (start_date <= '2021-04-01' OR wob BETWEEN '2021-04-01' AND '2021-07-01') AND end_date > '2021-07-01' THEN 1 ELSE 0 END)           AS resid2021_flg,
			max(CASE WHEN wob + 110 YEARS > '2021-07-01' AND (start_date <= '2021-04-01' OR wob BETWEEN '2021-04-01' AND '2021-07-01') AND end_date > '2021-07-01' THEN wimd_2019_quintile END) AS resid2021_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2021-07-01' AND (start_date <= '2021-04-01' OR wob BETWEEN '2021-04-01' AND '2021-07-01') AND end_date > '2021-07-01' THEN lsoa_id END)            AS resid2021_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2022-07-01' AND (start_date <= '2022-04-01' OR wob BETWEEN '2022-04-01' AND '2022-07-01') AND end_date > '2022-07-01' THEN 1 ELSE 0 END)           AS resid2022_flg,
			max(CASE WHEN wob + 110 YEARS > '2022-07-01' AND (start_date <= '2022-04-01' OR wob BETWEEN '2022-04-01' AND '2022-07-01') AND end_date > '2022-07-01' THEN wimd_2019_quintile END) AS resid2022_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2022-07-01' AND (start_date <= '2022-04-01' OR wob BETWEEN '2022-04-01' AND '2022-07-01') AND end_date > '2022-07-01' THEN lsoa_id END)            AS resid2022_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2023-07-01' AND (start_date <= '2023-04-01' OR wob BETWEEN '2023-04-01' AND '2023-07-01') AND end_date > '2023-07-01' THEN 1 ELSE 0 END)           AS resid2023_flg,
			max(CASE WHEN wob + 110 YEARS > '2023-07-01' AND (start_date <= '2023-04-01' OR wob BETWEEN '2023-04-01' AND '2023-07-01') AND end_date > '2023-07-01' THEN wimd_2019_quintile END) AS resid2023_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2023-07-01' AND (start_date <= '2023-04-01' OR wob BETWEEN '2023-04-01' AND '2023-07-01') AND end_date > '2023-07-01' THEN lsoa_id END)            AS resid2023_lsoa_id,
			max(CASE WHEN wob + 110 YEARS > '2024-07-01' AND (start_date <= '2024-04-01' OR wob BETWEEN '2024-04-01' AND '2024-07-01') AND end_date > '2024-07-01' THEN 1 ELSE 0 END)           AS resid2024_flg,
			max(CASE WHEN wob + 110 YEARS > '2024-07-01' AND (start_date <= '2024-04-01' OR wob BETWEEN '2024-04-01' AND '2024-07-01') AND end_date > '2024-07-01' THEN wimd_2019_quintile END) AS resid2024_wimd2019_quintile,
			max(CASE WHEN wob + 110 YEARS > '2024-07-01' AND (start_date <= '2024-04-01' OR wob BETWEEN '2024-04-01' AND '2024-07-01') AND end_date > '2024-07-01' THEN lsoa_id END)            AS resid2024_lsoa_id
		FROM cohort
		GROUP BY alf_e
	)
SELECT *,
	CASE
		WHEN resid1990_wimd2019_quintile = 1 THEN 1
		WHEN resid1991_wimd2019_quintile = 1 THEN 1
		WHEN resid1992_wimd2019_quintile = 1 THEN 1
		WHEN resid1993_wimd2019_quintile = 1 THEN 1
		WHEN resid1994_wimd2019_quintile = 1 THEN 1
		WHEN resid1995_wimd2019_quintile = 1 THEN 1
		WHEN resid1996_wimd2019_quintile = 1 THEN 1
		WHEN resid1997_wimd2019_quintile = 1 THEN 1
		WHEN resid1998_wimd2019_quintile = 1 THEN 1
		WHEN resid1999_wimd2019_quintile = 1 THEN 1
		WHEN resid2000_wimd2019_quintile = 1 THEN 1
		WHEN resid2001_wimd2019_quintile = 1 THEN 1
		WHEN resid2002_wimd2019_quintile = 1 THEN 1
		WHEN resid2003_wimd2019_quintile = 1 THEN 1
		WHEN resid2004_wimd2019_quintile = 1 THEN 1
		WHEN resid2005_wimd2019_quintile = 1 THEN 1
		WHEN resid2006_wimd2019_quintile = 1 THEN 1
		WHEN resid2007_wimd2019_quintile = 1 THEN 1
		WHEN resid2008_wimd2019_quintile = 1 THEN 1
		WHEN resid2009_wimd2019_quintile = 1 THEN 1
		WHEN resid2010_wimd2019_quintile = 1 THEN 1
		WHEN resid2011_wimd2019_quintile = 1 THEN 1
		WHEN resid2012_wimd2019_quintile = 1 THEN 1
		WHEN resid2013_wimd2019_quintile = 1 THEN 1
		WHEN resid2014_wimd2019_quintile = 1 THEN 1
		WHEN resid2015_wimd2019_quintile = 1 THEN 1
		WHEN resid2016_wimd2019_quintile = 1 THEN 1
		WHEN resid2017_wimd2019_quintile = 1 THEN 1
		WHEN resid2018_wimd2019_quintile = 1 THEN 1
		WHEN resid2019_wimd2019_quintile = 1 THEN 1
		WHEN resid2020_wimd2019_quintile = 1 THEN 1
		WHEN resid2021_wimd2019_quintile = 1 THEN 1
		WHEN resid2022_wimd2019_quintile = 1 THEN 1
		WHEN resid2023_wimd2019_quintile = 1 THEN 1
		WHEN resid2024_wimd2019_quintile = 1 THEN 1
		ELSE 0
	END AS ever_wimd2019_q1,
	CASE
		WHEN resid1990_wimd2019_quintile = 2 THEN 1
		WHEN resid1991_wimd2019_quintile = 2 THEN 1
		WHEN resid1992_wimd2019_quintile = 2 THEN 1
		WHEN resid1993_wimd2019_quintile = 2 THEN 1
		WHEN resid1994_wimd2019_quintile = 2 THEN 1
		WHEN resid1995_wimd2019_quintile = 2 THEN 1
		WHEN resid1996_wimd2019_quintile = 2 THEN 1
		WHEN resid1997_wimd2019_quintile = 2 THEN 1
		WHEN resid1998_wimd2019_quintile = 2 THEN 1
		WHEN resid1999_wimd2019_quintile = 2 THEN 1
		WHEN resid2000_wimd2019_quintile = 2 THEN 1
		WHEN resid2001_wimd2019_quintile = 2 THEN 1
		WHEN resid2002_wimd2019_quintile = 2 THEN 1
		WHEN resid2003_wimd2019_quintile = 2 THEN 1
		WHEN resid2004_wimd2019_quintile = 2 THEN 1
		WHEN resid2005_wimd2019_quintile = 2 THEN 1
		WHEN resid2006_wimd2019_quintile = 2 THEN 1
		WHEN resid2007_wimd2019_quintile = 2 THEN 1
		WHEN resid2008_wimd2019_quintile = 2 THEN 1
		WHEN resid2009_wimd2019_quintile = 2 THEN 1
		WHEN resid2010_wimd2019_quintile = 2 THEN 1
		WHEN resid2011_wimd2019_quintile = 2 THEN 1
		WHEN resid2012_wimd2019_quintile = 2 THEN 1
		WHEN resid2013_wimd2019_quintile = 2 THEN 1
		WHEN resid2014_wimd2019_quintile = 2 THEN 1
		WHEN resid2015_wimd2019_quintile = 2 THEN 1
		WHEN resid2016_wimd2019_quintile = 2 THEN 1
		WHEN resid2017_wimd2019_quintile = 2 THEN 1
		WHEN resid2018_wimd2019_quintile = 2 THEN 1
		WHEN resid2019_wimd2019_quintile = 2 THEN 1
		WHEN resid2020_wimd2019_quintile = 2 THEN 1
		WHEN resid2021_wimd2019_quintile = 2 THEN 1
		WHEN resid2022_wimd2019_quintile = 2 THEN 1
		WHEN resid2023_wimd2019_quintile = 2 THEN 1
		WHEN resid2024_wimd2019_quintile = 2 THEN 1
		ELSE 0
	END AS ever_wimd2019_q2,
	CASE
		WHEN resid1990_wimd2019_quintile = 3 THEN 1
		WHEN resid1991_wimd2019_quintile = 3 THEN 1
		WHEN resid1992_wimd2019_quintile = 3 THEN 1
		WHEN resid1993_wimd2019_quintile = 3 THEN 1
		WHEN resid1994_wimd2019_quintile = 3 THEN 1
		WHEN resid1995_wimd2019_quintile = 3 THEN 1
		WHEN resid1996_wimd2019_quintile = 3 THEN 1
		WHEN resid1997_wimd2019_quintile = 3 THEN 1
		WHEN resid1998_wimd2019_quintile = 3 THEN 1
		WHEN resid1999_wimd2019_quintile = 3 THEN 1
		WHEN resid2000_wimd2019_quintile = 3 THEN 1
		WHEN resid2001_wimd2019_quintile = 3 THEN 1
		WHEN resid2002_wimd2019_quintile = 3 THEN 1
		WHEN resid2003_wimd2019_quintile = 3 THEN 1
		WHEN resid2004_wimd2019_quintile = 3 THEN 1
		WHEN resid2005_wimd2019_quintile = 3 THEN 1
		WHEN resid2006_wimd2019_quintile = 3 THEN 1
		WHEN resid2007_wimd2019_quintile = 3 THEN 1
		WHEN resid2008_wimd2019_quintile = 3 THEN 1
		WHEN resid2009_wimd2019_quintile = 3 THEN 1
		WHEN resid2010_wimd2019_quintile = 3 THEN 1
		WHEN resid2011_wimd2019_quintile = 3 THEN 1
		WHEN resid2012_wimd2019_quintile = 3 THEN 1
		WHEN resid2013_wimd2019_quintile = 3 THEN 1
		WHEN resid2014_wimd2019_quintile = 3 THEN 1
		WHEN resid2015_wimd2019_quintile = 3 THEN 1
		WHEN resid2016_wimd2019_quintile = 3 THEN 1
		WHEN resid2017_wimd2019_quintile = 3 THEN 1
		WHEN resid2018_wimd2019_quintile = 3 THEN 1
		WHEN resid2019_wimd2019_quintile = 3 THEN 1
		WHEN resid2020_wimd2019_quintile = 3 THEN 1
		WHEN resid2021_wimd2019_quintile = 3 THEN 1
		WHEN resid2022_wimd2019_quintile = 3 THEN 1
		WHEN resid2023_wimd2019_quintile = 3 THEN 1
		WHEN resid2024_wimd2019_quintile = 3 THEN 1
		ELSE 0
	END AS ever_wimd2019_q3,
	CASE
		WHEN resid1990_wimd2019_quintile = 4 THEN 1
		WHEN resid1991_wimd2019_quintile = 4 THEN 1
		WHEN resid1992_wimd2019_quintile = 4 THEN 1
		WHEN resid1993_wimd2019_quintile = 4 THEN 1
		WHEN resid1994_wimd2019_quintile = 4 THEN 1
		WHEN resid1995_wimd2019_quintile = 4 THEN 1
		WHEN resid1996_wimd2019_quintile = 4 THEN 1
		WHEN resid1997_wimd2019_quintile = 4 THEN 1
		WHEN resid1998_wimd2019_quintile = 4 THEN 1
		WHEN resid1999_wimd2019_quintile = 4 THEN 1
		WHEN resid2000_wimd2019_quintile = 4 THEN 1
		WHEN resid2001_wimd2019_quintile = 4 THEN 1
		WHEN resid2002_wimd2019_quintile = 4 THEN 1
		WHEN resid2003_wimd2019_quintile = 4 THEN 1
		WHEN resid2004_wimd2019_quintile = 4 THEN 1
		WHEN resid2005_wimd2019_quintile = 4 THEN 1
		WHEN resid2006_wimd2019_quintile = 4 THEN 1
		WHEN resid2007_wimd2019_quintile = 4 THEN 1
		WHEN resid2008_wimd2019_quintile = 4 THEN 1
		WHEN resid2009_wimd2019_quintile = 4 THEN 1
		WHEN resid2010_wimd2019_quintile = 4 THEN 1
		WHEN resid2011_wimd2019_quintile = 4 THEN 1
		WHEN resid2012_wimd2019_quintile = 4 THEN 1
		WHEN resid2013_wimd2019_quintile = 4 THEN 1
		WHEN resid2014_wimd2019_quintile = 4 THEN 1
		WHEN resid2015_wimd2019_quintile = 4 THEN 1
		WHEN resid2016_wimd2019_quintile = 4 THEN 1
		WHEN resid2017_wimd2019_quintile = 4 THEN 1
		WHEN resid2018_wimd2019_quintile = 4 THEN 1
		WHEN resid2019_wimd2019_quintile = 4 THEN 1
		WHEN resid2020_wimd2019_quintile = 4 THEN 1
		WHEN resid2021_wimd2019_quintile = 4 THEN 1
		WHEN resid2022_wimd2019_quintile = 4 THEN 1
		WHEN resid2023_wimd2019_quintile = 4 THEN 1
		WHEN resid2024_wimd2019_quintile = 4 THEN 1
		ELSE 0
	END AS ever_wimd2019_q4,
	CASE
		WHEN resid1990_wimd2019_quintile = 5 THEN 1
		WHEN resid1991_wimd2019_quintile = 5 THEN 1
		WHEN resid1992_wimd2019_quintile = 5 THEN 1
		WHEN resid1993_wimd2019_quintile = 5 THEN 1
		WHEN resid1994_wimd2019_quintile = 5 THEN 1
		WHEN resid1995_wimd2019_quintile = 5 THEN 1
		WHEN resid1996_wimd2019_quintile = 5 THEN 1
		WHEN resid1997_wimd2019_quintile = 5 THEN 1
		WHEN resid1998_wimd2019_quintile = 5 THEN 1
		WHEN resid1999_wimd2019_quintile = 5 THEN 1
		WHEN resid2000_wimd2019_quintile = 5 THEN 1
		WHEN resid2001_wimd2019_quintile = 5 THEN 1
		WHEN resid2002_wimd2019_quintile = 5 THEN 1
		WHEN resid2003_wimd2019_quintile = 5 THEN 1
		WHEN resid2004_wimd2019_quintile = 5 THEN 1
		WHEN resid2005_wimd2019_quintile = 5 THEN 1
		WHEN resid2006_wimd2019_quintile = 5 THEN 1
		WHEN resid2007_wimd2019_quintile = 5 THEN 1
		WHEN resid2008_wimd2019_quintile = 5 THEN 1
		WHEN resid2009_wimd2019_quintile = 5 THEN 1
		WHEN resid2010_wimd2019_quintile = 5 THEN 1
		WHEN resid2011_wimd2019_quintile = 5 THEN 1
		WHEN resid2012_wimd2019_quintile = 5 THEN 1
		WHEN resid2013_wimd2019_quintile = 5 THEN 1
		WHEN resid2014_wimd2019_quintile = 5 THEN 1
		WHEN resid2015_wimd2019_quintile = 5 THEN 1
		WHEN resid2016_wimd2019_quintile = 5 THEN 1
		WHEN resid2017_wimd2019_quintile = 5 THEN 1
		WHEN resid2018_wimd2019_quintile = 5 THEN 1
		WHEN resid2019_wimd2019_quintile = 5 THEN 1
		WHEN resid2020_wimd2019_quintile = 5 THEN 1
		WHEN resid2021_wimd2019_quintile = 5 THEN 1
		WHEN resid2022_wimd2019_quintile = 5 THEN 1
		WHEN resid2023_wimd2019_quintile = 5 THEN 1
		WHEN resid2024_wimd2019_quintile = 5 THEN 1
		ELSE 0
	END AS ever_wimd2019_q5
FROM resid_summary;


-- =================================================================================================
-- Run indexes
-- =================================================================================================

CALL sysproc.admin_cmd('
RUNSTATS ON TABLE sailw1151v.sb_wlgp_activity_cohort
WITH DISTRIBUTION AND DETAILED INDEXES ALL
');


-- =================================================================================================
-- Print summary
-- =================================================================================================


SELECT 1990 AS resid_year, SUM(resid1990_flg) AS person_count FROM sailw1151v.sb_wlgp_activity_cohort
UNION
SELECT 2000 AS resid_year, SUM(resid2000_flg) AS person_count FROM sailw1151v.sb_wlgp_activity_cohort
UNION
SELECT 2010 AS resid_year, SUM(resid2010_flg) AS person_count FROM sailw1151v.sb_wlgp_activity_cohort
UNION
SELECT 2020 AS resid_year, SUM(resid2020_flg) AS person_count FROM sailw1151v.sb_wlgp_activity_cohort
UNION
SELECT 2024 AS resid_year, SUM(resid2024_flg) AS person_count FROM sailw1151v.sb_wlgp_activity_cohort
ORDER BY resid_year;
