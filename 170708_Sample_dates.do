clear all
set max_memory 15000m
set maxvar 10000
set matsize 1000
label drop _all
set more off

global who = "J"


if "$who" == "J" {
	global DATA "/Users/JungsikHyun/Dropbox/Columbia/RA/Drenik/Drenik_not_shared/Low Wage Youth/NLSY1979/Data/1979"
	global DOFILES "/Users/JungsikHyun/Dropbox/Columbia/RA/Drenik/Drenik_not_shared/Low Wage Youth/NLSY1979/Codes/DoFiles"
	global SERIES "/Users/JungsikHyun/Dropbox/Columbia/RA/Drenik/Drenik_not_shared/Low Wage Youth/NLSY1979/Data/Series"
}

if "$who" == "A" {
	global DATA "/Users/adrenik/Dropbox/Stanford/Research/Low Wage Youth/Data/NLSY/1997"
	global DOFILES "/Users/adrenik/Dropbox/Stanford/Research/Low Wage Youth/Codes/DoFiles"
	global SERIES "/Users/adrenik/Dropbox/Stanford/Research/Low Wage Youth/Data/Series"
}
if "$who" == "S" {
	global DATA "F:\Stanford\Research\Low Wage Youth\Data\NLSY\1997"
	global DOFILES "F:\Stanford\Research\Low Wage Youth\Codes\DoFiles"
	global SERIES "F:\Stanford\Research\Low Wage Youth\Data\Series"
}

/************************************/
/************************************/
/*		WEEKS BY MONTH				*/
/*			by NLSY					*/
/************************************/
/************************************/

import excel "$DATA/month-week_crosswalk_nlsy79.xlsx", sheet("weekdates1") firstrow clear

/* Added by Jay : start
 : Generate CalendarYear. CalendarYear is infered based on CalendarYearWeekNumber.
 If CalendarYearWeekNumber==1, this means a new calendar year has started. */
gen CalendarYear=1977
gen temp=1 if CalendarYearWeekNumber==1
replace temp=sum(temp)
replace CalendarYear=CalendarYear+temp
drop temp
/* Added by Jay : end */

keep if inrange(WeekStartYear, 1978,1993)
keep CalendarYear CalendarYearWeekNumber WeekStartMonth
mkmat CalendarYear
mkmat CalendarYearWeekNumber
mkmat WeekStartMonth

mata
weeknlsy =  st_data(., 3)'
yearnlsy = st_data(., 2)'
nmonth = st_data(., 1)'
end
drop CalendarYear CalendarYearWeekNumber WeekStartMonth
set obs 1
mata
n=(1)
for (j=1; j<=cols(weeknlsy); j++) {
	yname =  "beginmonth" + "_" + strofreal(yearnlsy[1,j]) + "_" + strofreal(weeknlsy[1,j])
	value = nmonth[j]
	(void) st_addvar("float", yname)
	st_store(n, yname, value )
}
end
save "$SERIES/nweeks_nlsy.dta", replace


import excel "$DATA/month-week_crosswalk_nlsy79.xlsx", sheet("weekdates1") firstrow clear

/* Added by Jay : start
 : Generate CalendarYear. CalendarYear is infered based on CalendarYearWeekNumber.
 If CalendarYearWeekNumber==1, this means a new calendar year has started. */
gen CalendarYear=1977
gen temp=1 if CalendarYearWeekNumber==1
replace temp=sum(temp)
replace CalendarYear=CalendarYear+temp
drop temp
/* Added by Jay : end */

keep if inrange(WeekStartYear, 1978,1993)
gen date = mdy(WeekStartMonth, WeekStartDay, WeekStartYear)
keep CalendarYear CalendarYearWeekNumber date
mata
weeknlsy =  st_data(., 2)'
yearnlsy = st_data(., 1)'
begmonth = st_data(., 3)'
end
drop CalendarYearWeekNumber CalendarYear date
set obs 1
mata
n=(1)
for (j=1; j<=cols(weeknlsy); j++) {
	yname =  "beginweekdate" + "_" + strofreal(yearnlsy[1,j]) + "_" + strofreal(weeknlsy[1,j])
	value = begmonth[j]
	(void) st_addvar("float", yname)
	st_store(n, yname, value )
}
end
format beginweekdate* %d
save "$SERIES/beginweek_nlsy.dta", replace

/************************************/
/************************************/
/*		INTERVIEW DATE				*/
/************************************/
/************************************/

/* From here : 170709 */
/*

infile using "$DATA/2013_Sep_19-InterviewData-Weights/2013_Sep_19-InterviewData-Weights.dct", clear
do "$DOFILES/CleanData/2013_Sep_19-InterviewData-Weights-value-labels.do"

rename R0000100 PUBID
rename R0536300 SEX
rename R0536401 BDATE_M
rename R0536402 BDATE_Y
rename R1209400 CV_INTERVIEW_DATE_D_1997
rename R1209401 CV_INTERVIEW_DATE_M_1997
rename R1209402 CV_INTERVIEW_DATE_Y_1997
rename R1235800 CV_SAMPLE_TYPE_1997
rename R1236101 R1_SAMPLE_WEIGHT_CC_1997
rename R1236201 R1_SAMPLE_WEIGHT_PANEL_1997
rename R1482600 RACE_ETHNICITY
rename R2568300 CV_INTERVIEW_DATE_D_1998
rename R2568301 CV_INTERVIEW_DATE_M_1998
rename R2568302 CV_INTERVIEW_DATE_Y_1998
rename R2600301 R2_SAMPLE_WEIGHT_CC_1998
rename R2600401 R2_SAMPLE_WEIGHT_PANEL_1998
rename R3890300 CV_INTERVIEW_DATE_D_1999
rename R3890301 CV_INTERVIEW_DATE_M_1999
rename R3890302 CV_INTERVIEW_DATE_Y_1999
rename R3923701 R3_SAMPLE_WEIGHT_CC_1999
rename R3958501 R3_PANEL_WEIGHT_1999
rename R5472300 CV_INTERVIEW_DATE_D_2000
rename R5472301 CV_INTERVIEW_DATE_M_2000
rename R5472302 CV_INTERVIEW_DATE_Y_2000
rename R5510600 R4_SAMPLE_WEIGHT_CC_2000
rename R5510700 R4_SAMPLE_WEIGHT_PANEL_2000
rename R7236100 CV_INTERVIEW_DATE_D_2001
rename R7236101 CV_INTERVIEW_DATE_M_2001
rename R7236102 CV_INTERVIEW_DATE_Y_2001
rename R7274200 R5_SAMPLE_WEIGHT_CC_2001
rename R7274300 R5_SAMPLE_WEIGHT_PANEL_2001
rename S1550900 CV_INTERVIEW_DATE_D_2002
rename S1550901 CV_INTERVIEW_DATE_M_2002
rename S1550902 CV_INTERVIEW_DATE_Y_2002
rename S1598100 R6_SAMPLE_WEIGHT_CC_2002
rename S1598200 R6_SAMPLE_WEIGHT_PANEL_2002
rename S2020800 CV_INTERVIEW_DATE_D_2003
rename S2020801 CV_INTERVIEW_DATE_M_2003
rename S2020802 CV_INTERVIEW_DATE_Y_2003
rename S2067000 R7_SAMPLE_WEIGHT_CC_2003
rename S2067100 R7_SAMPLE_WEIGHT_PANEL_2003
rename S3822000 CV_INTERVIEW_DATE_D_2004
rename S3822001 CV_INTERVIEW_DATE_M_2004
rename S3822002 CV_INTERVIEW_DATE_Y_2004
rename S3861600 R8_SAMPLE_WEIGHT_CC_2004
rename S3861700 R8_SAMPLE_WEIGHT_PANEL_2004
rename S5422000 CV_INTERVIEW_DATE_D_2005
rename S5422001 CV_INTERVIEW_DATE_M_2005
rename S5422002 CV_INTERVIEW_DATE_Y_2005
rename S5444200 R9_SAMPLE_WEIGHT_CC_2005
rename S5444300 R9_SAMPLE_WEIGHT_PANEL_2005
rename S7524100 CV_INTERVIEW_DATE_D_2006
rename S7524101 CV_INTERVIEW_DATE_M_2006
rename S7524102 CV_INTERVIEW_DATE_Y_2006
rename S7545500 R10_SAMPLE_WEIGHT_CC_2006
rename S7545600 R10_SAMPLE_WEIGHT_PANEL_2006
rename T0024500 CV_INTERVIEW_DATE_D_2007
rename T0024501 CV_INTERVIEW_DATE_M_2007
rename T0024502 CV_INTERVIEW_DATE_Y_2007
rename T0042100 R11_SAMPLE_WEIGHT_CC_2007
rename T0042200 R11_SAMPLE_WEIGHT_PANEL_2007
rename T2019400 CV_INTERVIEW_DATE_D_2008
rename T2019401 CV_INTERVIEW_DATE_M_2008
rename T2019402 CV_INTERVIEW_DATE_Y_2008
rename T2022500 R12_SAMPLE_WEIGHT_CC_2008
rename T2022600 R12_SAMPLE_WEIGHT_PANEL_2008
rename T3610000 CV_INTERVIEW_DATE_D_2009
rename T3610001 CV_INTERVIEW_DATE_M_2009
rename T3610002 CV_INTERVIEW_DATE_Y_2009
rename T3613300 R13_SAMPLE_WEIGHT_CC_2009
rename T3613400 R13_SAMPLE_WEIGHT_PANEL_2009
rename T5210400 CV_INTERVIEW_DATE_D_2010
rename T5210401 CV_INTERVIEW_DATE_M_2010
rename T5210402 CV_INTERVIEW_DATE_Y_2010
rename T5213200 R14_SAMPLE_WEIGHT_CC_2010
rename T5213300 R14_SAMPLE_WEIGHT_PANEL_2010
rename T6661400 CV_INTERVIEW_DATE_D_2011
rename T6661401 CV_INTERVIEW_DATE_M_2011
rename T6661402 CV_INTERVIEW_DATE_Y_2011
rename T6665000 R15_SAMPLE_WEIGHT_CC_2011
rename T6665100 R15_SAMPLE_WEIGHT_PANEL_2011
tolower

order pubid sex bdate_m bdate_y race_ethnicity
count
keep if sex == 1 // keep male individuals
count
keep if cv_interview_date_y_1997 != -5 & cv_interview_date_y_1998 != -5 & cv_interview_date_y_1999 != -5 & /*
	*/ cv_interview_date_y_2000 != -5 & cv_interview_date_y_2001 != -5 & cv_interview_date_y_2002 != -5 &  /*
	*/ cv_interview_date_y_2003 != -5 & cv_interview_date_y_2004 != -5 & cv_interview_date_y_2005 != -5 &  /*
	*/ cv_interview_date_y_2006 != -5 & cv_interview_date_y_2007 != -5 & cv_interview_date_y_2008 != -5 &  /*
	*/ cv_interview_date_y_2009 != -5 & cv_interview_date_y_2010 != -5 & cv_interview_date_y_2011 != -5
	// keep individuals that were interviewed in all 15 rounds
count

gen int_date_1997 = mdy(cv_interview_date_m_1997,cv_interview_date_d_1997,cv_interview_date_y_1997)
gen int_date_1998 = mdy(cv_interview_date_m_1998,cv_interview_date_d_1998,cv_interview_date_y_1998)
gen int_date_1999 = mdy(cv_interview_date_m_1999,cv_interview_date_d_1999,cv_interview_date_y_1999)
gen int_date_2000 = mdy(cv_interview_date_m_2000,cv_interview_date_d_2000,cv_interview_date_y_2000)
gen int_date_2001 = mdy(cv_interview_date_m_2001,cv_interview_date_d_2001,cv_interview_date_y_2001)
gen int_date_2002 = mdy(cv_interview_date_m_2002,cv_interview_date_d_2002,cv_interview_date_y_2002)
gen int_date_2003 = mdy(cv_interview_date_m_2003,cv_interview_date_d_2003,cv_interview_date_y_2003)
gen int_date_2004 = mdy(cv_interview_date_m_2004,cv_interview_date_d_2004,cv_interview_date_y_2004)
gen int_date_2005 = mdy(cv_interview_date_m_2005,cv_interview_date_d_2005,cv_interview_date_y_2005)
gen int_date_2006 = mdy(cv_interview_date_m_2006,cv_interview_date_d_2006,cv_interview_date_y_2006)
gen int_date_2007 = mdy(cv_interview_date_m_2007,cv_interview_date_d_2007,cv_interview_date_y_2007)
gen int_date_2008 = mdy(cv_interview_date_m_2008,cv_interview_date_d_2008,cv_interview_date_y_2008)
gen int_date_2009 = mdy(cv_interview_date_m_2009,cv_interview_date_d_2009,cv_interview_date_y_2009)
gen int_date_2010 = mdy(cv_interview_date_m_2010,cv_interview_date_d_2010,cv_interview_date_y_2010)
gen int_date_2011 = mdy(cv_interview_date_m_2011,cv_interview_date_d_2011,cv_interview_date_y_2011)
format int_date* %d

tempfile sample
save "$SERIES/sample.dta", replace
