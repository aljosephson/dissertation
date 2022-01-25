/* BEGIN */

* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 24 January 2022
* Stata v.16.1

* does
	* combines files on (1) production, (2) decision making, (3) consumption, (4) geovars, (5) household  
	* for household-level 
	* add in plot level 

* assumes
	* access to data file(s) previously created 

* to do 
	* clean up data files 
	* code and data can be made available on github and googledrive 

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - LSMS Malawi\_replication2020" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e1_gender\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e1_gender\logs" 

* open log
	cap log 		close
	log using		"$logs/weather", append
	
* **********************************************************************
* 1 - year 1
* **********************************************************************

* merge sales decision with decision-maker information 

	use 			"$fil\Cleaned_LSMS\rs_hh_sales_y1.dta", clear

	merge 			1:m case_id ea_id year using ///
						"$fil\decision-making\decision-sales_wet_y1.dta"
	keep 			if _merge == 3
	*** drops 83 observations from using and 378 from master (no sales)
	drop 			_merge 
 
	save 			"$fil\production-and-sales\sales-with-manager_y1", replace	
	*** 2563 observations 
	
* manager 1 - year 1
* reduce sample significantly at this point - if do not identify a manager, not included 
	rename 			salesmanager1 id_code 
	merge 			m:1 case_id year id_code using "$fil\household\hhbase_y1-short.dta"
	drop 			if _merge == 2
	*** matched 815 
	*** drop unmatched from using = 7011
	*** unmatched from master = 1748 - okay, can drop later, as needed 
	
	rename 			id_code salesmanager1
	rename 			sex sex_salesmanager1
	rename			rltn rltn_salesmanager1
	rename 			age age_salesmanager1
	rename 			educ_years educ_years_salesmanager1
	drop 			_merge 
	
* manager 2	- year 1
* if no manager assume no one = 0
	replace 		salesmanager2 = 0 if salesmanager2 == . 
	rename 			salesmanager2 id_code 
	merge 			m:1 case_id year id_code using "$fil\household\hhbase_y1-short.dta"
	drop			if _merge == 2
	*** matched 353 
	*** drop unmatched from using = 7348
	*** keep unmatched from master = 2210 - perhaps no id code TO match - fewer observations here
	
	rename 			id_code salesmanager2
	rename 			sex sex_salesmanager2
	rename			rltn rltn_salesmanager2
	rename 			age age_salesmanager2
	rename 			educ_years educ_years_salesmanager2
	drop 			_merge 
	
* determine management 
	
	replace 		salesmanager2 = . if salesmanager1 == salesmanager2
	replace 		sex_salesmanager2 = . if salesmanager2 == .
	*** 4 changes made in both cases 
	
* determine primary manager 	
	gen 			female_decsale = 1 if sex_salesmanager1 == 2 
	replace 		female_decsale = 0 if female_decsale == .
	gen 			male_decsale = 1 if sex_salesmanager1 == 1
	replace 		male_decsale = 0 if male_decsale == .	
	
	gen 			joint_decsale = 1 if sex_salesmanager2 != .
	
	replace 		joint_decsale = . if sex_salesmanager1 == . & sex_salesmanager2 == .
	replace 		joint_decsale = 0 if salesmanager2 == 0 | salesmanager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\sales-with-managerid_y1", replace	
	
* bring in consumption variables 
	
	merge 			m:1 case_id year using "$fil\consumption\ihs3_summary_09.dta"
	keep 			if _merge == 3
	drop 			_merge
	*** dropping 11030 from using 
	
	save 			"$fil\regression-ready\household-level_y1", replace	
	
* merge in geovars 

	merge 			m:1 case_id year using "$fil\geovar\householdgeovariables_09.dta"
	keep 			if _merge == 3
	drop 			_merge 
	*** drops 378 not matched from using
	
compress
describe
summarize 
	
 	save 			"$fil\regression-ready\household-level_y1", replace	
	*** and now same number of observations = 2563			

	
* merge in plot-level files 
 	use 			"$fil\regression-ready\household-level_y1", clear	
	duplicates drop 
/*
* not sure what I'm getting from this ... 
	merge			1:m case_id ea_id using "$fil\production-and-sales\plot-with-managerid_y1"	
	*** all matched 
	drop 			_merge 
*/	
	replace 		sex_salesmanager1 = 0 if sex_salesmanager1 == 1
	replace 		sex_salesmanager1 = 1 if sex_salesmanager1 == 2
	label 			var sex_salesmanager1 "0 = male,  = 1 female"
	label 			define sex_salesmanager1 0 "male" 1 "female"	
	
	replace 		sex_salesmanager2 = 0 if sex_salesmanager2 == 1
	replace 		sex_salesmanager2 = 1 if sex_salesmanager2 == 2
	label 			var sex_salesmanager2 "0 = male,  = 1 female"
	label 			define sex_salesmanager2 0 "male" 1 "female"	
	
	summarize 		sex_salesmanager1 sex_salesmanager2
	*** 22 percent of first manager women
	*** 99 percent of second manager women 
	
* define manager categories of interest

*** (1) joint 

	gen 			joint_jspec = joint_decsale
	gen 			female_jspec = female_decsale if female_decsale == 1 & joint_jspec == 0 
	replace			female_jspec = 0 if female_jspec == . 
	gen 			male_jspec = male_decsale if male_decsale == 1 & joint_jspec == 0 
	replace 		male_jspec = 0 if male_jspec == . 
	*** this is the new specification which this paper puts forward
	
*** (2) omit 

	gen 			female_ospec = female_decsale 
	replace 		female_ospec = 1 if sex_salesmanager1 == 1 
	gen 			male_ospec = male_decsale 
	replace 		male_ospec = 1 if sex_salesmanager1 == 0 
	*** in this specification, we reallocate things as though there were no joint specification 
	
*** (3) reallocate 	

	gen 			female_rspec = female_decsale
	gen 			male_rspec = male_decsale 
	replace			male_rspec = joint_decsale if male_rspec == 0 & joint_decsale == 1
	*** in this specification, we assume that all joint labor is actually men's
	*** which is a fair assumption, given above 	

compress
describe
summarize
	
 	save 			"$fil\regression-ready\household-total_y1", replace	
	
* **********************************************************************
* 2 - year 2
* **********************************************************************

* merge sales decision with decision-maker information 

	use 			"$fil\Cleaned_LSMS\rs_hh_sales_y2.dta", clear

	merge 			1:m y2_hhid year using ///
						"$fil\decision-making\decision-sales_wet_y2.dta"
	keep 			if _merge == 3
	*** drops 136 observations from using and 505 from master (no sales)
	drop 			_merge 

	save 			"$fil\production-and-sales\sales-with-manager_y2", replace	
	*** 3258 observations 
	
* manager 1 
* reduce sample significantly at this point - if do not identify a manager, not included 
	rename 			salesmanager1 id_code 
	merge 			m:1 case_id year id_code y2_hhid using "$fil\household\hhbase_y2-short.dta"
	drop 			if _merge == 2
	*** matched 1060 
	*** drop unmatched from using = 9331
	*** unmatched from master = 2198 - okay, can drop later, as needed 
	
	rename 			id_code salesmanager1
	rename 			sex sex_salesmanager1
	rename			rltn rltn_salesmanager1
	rename 			age age_salesmanager1
	rename 			educ_years educ_years_salesmanager1
	drop 			_merge 
	
* manager 2
* if no manager assume no one = 0
	replace 		salesmanager2 = 0 if salesmanager2 == . 
	rename 			salesmanager2 id_code 
	merge 			m:1 case_id year id_code y2_hhid using "$fil\household\hhbase_y2-short.dta"
	drop			if _merge == 2
	*** matched 625 
	*** drop unmatched from using = 9647
	*** keep unmatched from master = 2633 
	
	rename 			id_code salesmanager2
	rename 			sex sex_salesmanager2
	rename			rltn rltn_salesmanager2
	rename 			age age_salesmanager2
	rename 			educ_years educ_years_salesmanager2
	drop 			_merge 
	
* determine management 
	
	replace 		salesmanager2 = . if salesmanager1 == salesmanager2
	replace 		sex_salesmanager2 = . if salesmanager2 == .
	*** 2 changes made in first case 
	
* determine primary manager 	
	gen 			female_decsale = 1 if sex_salesmanager1 == 2 
	replace 		female_decsale = 0 if female_decsale == .
	gen 			male_decsale = 1 if sex_salesmanager1 == 1
	replace 		male_decsale = 0 if male_decsale == .	
	
	gen 			joint_decsale = 1 if sex_salesmanager2 != .
	
	replace 		joint_decsale = . if sex_salesmanager1 == . & sex_salesmanager2 == .
	replace 		joint_decsale = 0 if salesmanager2 == 0 | salesmanager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\sales-with-managerid_y2", replace	
	
* bring in consumption variables 
	
	merge 			m:1 case_id year y2_hhid using "$fil\consumption\ihs3_summary_12.dta"
	keep 			if _merge == 3
	drop 			_merge
	*** dropping 2515 from using 
	
	save 			"$fil\regression-ready\household-level_y2", replace	
	
* merge in geovars 

	merge 			m:1 y2_hhid year using "$fil\geovar\householdgeovariables_12.dta"
	keep 			if _merge == 3
	drop 			_merge 
	*** drops 505 not matched from using
	
compress
describe
summarize 
	
 	save 			"$fil\regression-ready\household-level_y2", replace	
	*** 3342 - so some observations added at some point
	
	
* merge in plot-level files 
/*
* not sure of purpose of this 
 	use 			"$fil\regression-ready\household-level_y2", clear	
	duplicates drop 
	*** no duplicates dropped

	merge			m:1 y2_hhid case_id year using "$fil\production-and-sales\plot-with-managerid_y2"	
	*** 15662 matched 
	*** drop 4313 from using 
	keep 			if _merge == 3
	drop 			_merge
*/

	replace 		sex_salesmanager1 = 0 if sex_salesmanager1 == 1
	replace 		sex_salesmanager1 = 1 if sex_salesmanager1 == 2
	label 			var sex_salesmanager1 "0 = male,  = 1 female"
	label 			define sex_salesmanager1 0 "male" 1 "female"	
	
	replace 		sex_salesmanager2 = 0 if sex_salesmanager2 == 1
	replace 		sex_salesmanager2 = 1 if sex_salesmanager2 == 2
	label 			var sex_salesmanager2 "0 = male,  = 1 female"
	label 			define sex_salesmanager2 0 "male" 1 "female"	
	
	summarize 		sex_salesmanager1 sex_salesmanager2
	*** 23 percent of first manager women
	*** 97 percent of second manager women 

* define manager categories of interest

*** (1) joint 

	gen 			joint_jspec = joint_decsale
	gen 			female_jspec = female_decsale if female_decsale == 1 & joint_jspec == 0 
	replace			female_jspec = 0 if female_jspec == . 
	gen 			male_jspec = male_decsale if male_decsale == 1 & joint_jspec == 0 
	replace 		male_jspec = 0 if male_jspec == . 
	*** this is the new specification which this paper puts forward
	
*** (2) omit 

	gen 			female_ospec = female_decsale 
	replace 		female_ospec = 1 if sex_salesmanager1 == 1 
	gen 			male_ospec = male_decsale 
	replace 		male_ospec = 1 if sex_salesmanager1 == 0 
	*** in this specification, we reallocate things as though there were no joint specification 
	
*** (3) reallocate 	

	gen 			female_rspec = female_decsale
	gen 			male_rspec = male_decsale 
	replace			male_rspec = joint_decsale if male_rspec == 0 & joint_decsale == 1
	*** in this specification, we assume that all joint labor is actually men's
	*** which is a fair assumption, given above 	
	
compress
describe
summarize
	
 	save 			"$fil\regression-ready\household-total_y2", replace	
	
* *********************************************************************
* 3 - append all together 
* **********************************************************************	

* append all 
	use 			"$fil\regression-ready\household-total_y1", clear 
	append 			using "$fil\regression-ready\household-total_y2"
	
* save new full file 	

compress
describe
summarize 

	save 			"$fil\regression-ready\household-total_both", replace
	
* *********************************************************************
* 4 - sales values 
* **********************************************************************
	
* convert MKW to 2010 values
* 2009 = 93.1, 2012 = 130.5 
*** from World Bank Indicators: https://databank.worldbank.org/source/world-development-indicators

* using rs_cropsales_valuei
	summarize 		rs_cropsales_valuei, detail
	*** mean = 37331, st. dev = 175685.4, small = 0, large = 333333

	gen 			cropsales = rs_cropsales_valuei / 1.661 if year == 2012
	replace 		cropsales = rs_cropsales_valuei / 0.931 if year == 2009	
	summarize 		cropsales, detail	
	*** mean = 26149.78, st. dev = 123840.8, small = 0, large = 2006823
	
* convert MWK to USD 
* 1 USD = 123 MWK
*** from https://www.exchangerates.org.uk/USD-MWK-spot-exchange-rates-history-2010.html 
	gen 			cropsales_usd = cropsales / 123 
	summarize 		cropsales_usd, detail
	*** mean = 212.60, st. dev = 1006.84, small = 0, large = 21394.95 

* determine values by sales manager

*** (1) joint 
	gen 			valuejoint_jspec = cropsales if joint_jspec == 1
	replace			valuejoint_jspec = 0 if valuejoint_jspec == . 
	gen 			valuefemale_jspec = cropsales if female_jspec == 1
	replace 		valuefemale_jspec = 0 if valuefemale_jspec == .
	gen 			valuemale_jspec = cropsales if male_jspec == 1
	replace 		valuemale_jspec = 0 if valuemale_jspec == . 
	
*** (2) omit

	gen 			valuefemale_ospec = cropsales if female_ospec == 1
	replace 		valuefemale_ospec = 0 if valuefemale_ospec == .
	gen 			valuemale_ospec = cropsales if male_ospec == 1
	replace 		valuemale_ospec = 0 if valuemale_ospec == . 

*** (3) reallocate 

	gen 			valuefemale_rspec = cropsales if female_rspec == 1
	replace 		valuefemale_rspec = 0 if valuefemale_rspec == .
	gen 			valuemale_rspec = cropsales if male_rspec == 1
	replace 		valuemale_rspec = 0 if valuemale_rspec == . 
	
* *********************************************************************
* 5 - weather 
* **********************************************************************

	merge 			m:1 case_id y2_hhid ea_id year using "$fil\geovar\rain_2yr.dta"
	*** matched = 3853
	keep if _merge == 3
	drop _merge 
	
	rename			total totalr 
	
	save 			"$fil\regression-ready\gender_all", replace

* *********************************************************************
* 6 - aggregates 
* **********************************************************************	

	rename 			rexp_cat01 foodexp
	rename 			rexp_cat02 alctobexp
	rename 			rexp_cat03 clothexp
	egen 			houseutilsexp = rsum (rexp_cat04 rexp_cat05)
	*** adding housing and utilities with furnishings 
	rename 			rexp_cat06 healthexp 
	rename 			rexp_cat07 transpoexp
	rename 			rexp_cat08 commexp
	rename 			rexp_cat09 recexp
	rename 			rexp_cat10 eduexp
	rename 			rexp_cat11 hotelrestexp
	rename 			rexp_cat12 miscexp 
	rename 			rexpagg totalexp 
	
	save 			"$fil\regression-ready\gender_all", replace
	
* *********************************************************************
* 7 - differencing  
* **********************************************************************

* keep only variables for regression 
******* dsajklf;ajfkdsa

	keep 			valuejoint_jspec valuefemale_jspec valuemale_jspec valuefemale_ospec valuemale_ospec ///
						valuefemale_rspec valuemale_rspec totalr noraindays dryspell foodexp alctobexp ///
						clothexp houseutilsexp healthexp transpoexp commexp recexp eduexp hotelrestexp ///
						miscexp totalexp case_id year region district ea_id HHID y2_hhid 
						
*** NEED TO GO BACK AND DO MERGE - SO THAT THINGS ARE 2009 AND 2012 IN THE DATA - FOR DIFFERENCING 

* *********************************************************************
* 7 - end matter
* **********************************************************************

* close the log
	log	close	
	
/* END */	