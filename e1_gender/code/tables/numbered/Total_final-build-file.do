/* BEGIN */

* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 25 March 2022
* Stata v.16.1

* does
	* combines files on (1) production, (2) decision making, (3) consumption, (4) geovars, (5) household  
	* for household-level 

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
	global 	filb 	= 	"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - LSMS Malawi\"
	global	code	=	"C:\Users\aljosephson\git\dissertation\e1_gender\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e1_gender\logs" 

* open log
	cap log 		close
	log using		"$logs/build_file", append
	
* **********************************************************************
* 1 - year 1
* **********************************************************************

* **********************************************************************
* 1a - household and gender details 
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
	
* determine sex of managers / mix 
	tab 			sex_salesmanager1
	tab 			sex_salesmanager2
	bys 			sex_salesmanager1: tab sex_salesmanager2
	
* determine primary manager 	
	gen 			female_decsale = 1 if sex_salesmanager1 == 2 
	replace 		female_decsale = 0 if female_decsale == .
	gen 			male_decsale = 1 if sex_salesmanager1 == 1
	replace 		male_decsale = 0 if male_decsale == .	
	
	gen 			joint_decsale = 1 if sex_salesmanager2 != .
	
	replace 		joint_decsale = . if sex_salesmanager1 == . & sex_salesmanager2 == .
	replace 		joint_decsale = 0 if salesmanager2 == 0 | salesmanager2 == . 
	
	save 			"$fil\production-and-sales\sales-with-managerid_y1", replace	
	
* bring in consumption variables 
	
	merge 			m:1 case_id year using "$fil\consumption\ihs3_summary_09.dta"
	keep 			if _merge == 3
	drop 			_merge
	*** dropping 11030 from using 
	
	save 			"$fil\regression-ready\household-level_y1.dta", replace	
	
* merge in geovars 

	merge 			m:1 case_id year using "$fil\geovar\householdgeovariables_09.dta"
	keep 			if _merge == 3
	drop 			_merge 
	*** drops 378 not matched from using
	
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
	gen 			male_ospec = male_decsale 
	
 	save 			"$fil\regression-ready\household-total_y1.dta", replace	
	
* **********************************************************************
* 1b - sales values
* **********************************************************************

* convert MKW to 2010 values
* 2009 = 93.1
*** from World Bank Indicators: https://databank.worldbank.org/source/world-development-indicators

* using rs_cropsales_valuei
	summarize 		rs_cropsales_valuei, detail
	*** mean = 22732.55, st. dev = 1243344.3, small = 0, large = 2340000

	generate 		cropsales = rs_cropsales_valuei / 0.931 
	summarize 		cropsales, detail	
	*** mean = 24417.35, st. dev = 133560, small = 0, large = 2631579
* create winsorized values 
	winsor 			cropsales, p(.05) gen(cropsales_win)
	
* convert MWK to USD 
* 1$ = 123 MK
*** from https://www.exchangerates.org.uk/USD-MWK-spot-exchange-rates-history-2010.html 
	gen 			cropsales_usd = cropsales / 123
	summarize 		cropsales_usd, detail
	*** mean = 198.52, st. dev = 1085.85, small = 0, large = 21394.95 

* determine values by sales manager

*** (1) joint 
	gen 			valuejoint_jspec = cropsales if joint_jspec == 1
	replace			valuejoint_jspec = 0 if valuejoint_jspec == . 
	gen 			valuefemale_jspec = cropsales if female_jspec == 1
	replace 		valuefemale_jspec = 0 if valuefemale_jspec == .
	gen 			valuemale_jspec = cropsales if male_jspec == 1
	replace 		valuemale_jspec = 0 if valuemale_jspec == . 
	
* winsorized
	gen 			valuejoint_jspecw = cropsales_win if joint_jspec == 1
	replace			valuejoint_jspecw = 0 if valuejoint_jspec == . 
	gen 			valuefemale_jspecw = cropsales_win if female_jspec == 1
	replace 		valuefemale_jspecw = 0 if valuefemale_jspec == .
	gen 			valuemale_jspecw = cropsales_win if male_jspec == 1
	replace 		valuemale_jspecw = 0 if valuemale_jspec == . 
	
*** (2) omit

	gen 			valuefemale_ospec = cropsales if female_ospec == 1
	replace 		valuefemale_ospec = 0 if valuefemale_ospec == .
	gen 			valuemale_ospec = cropsales if male_ospec == 1
	replace 		valuemale_ospec = 0 if valuemale_ospec == . 
	
* winsorized
	gen 			valuefemale_ospecw = cropsales_win if female_ospec == 1
	replace 		valuefemale_ospecw = 0 if valuefemale_ospec == .
	gen 			valuemale_ospecw = cropsales_win if male_ospec == 1
	replace 		valuemale_ospecw = 0 if valuemale_ospec == . 	

* *********************************************************************
* 1c - weather 
* **********************************************************************

	merge 			m:1 case_id ea_id year using "$fil\geovar\rain_2yr.dta"
	*** matched = 3853
	keep if _merge == 3
	drop _merge 
	
	rename			total totalr 
	
 	save 			"$fil\regression-ready\household-total_y1.dta", replace	

* *********************************************************************
* 1d - aggregates 
* **********************************************************************	

* adjusting for inflation 	

	generate 		foodexp = rexp_cat01 / 0.931 
	generate 		alctobexp = rexp_cat02 / 0.931 
	generate		clothexp = rexp_cat03 / 0.931 
	egen 			houseutilsexp = rsum (rexp_cat04 rexp_cat05)
	*** adding housing and utilities with furnishings 
	replace 		houseutilsexp = houseutilsexp / 0.931 
	generate 		healthexp = rexp_cat06 / 0.931  
	generate 		transpoexp = rexp_cat07 / 0.931 
	generate 		commexp	= rexp_cat08 / 0.931 
	generate 		recexp = rexp_cat09 / 0.931 
	generate 		eduexp = rexp_cat10 / 0.931 
	generate 		hotelrestexp = rexp_cat11 / 0.931 
	generate 		miscexp	= rexp_cat12 / 0.931 
	generate 		totalexp = rexpagg / 0.931 
	
 	save 			"$fil\regression-ready\household-total_y1.dta", replace	

* *********************************************************************
* 1e - matrilineal and head of household gender   
* **********************************************************************	
	
	merge 			m:1 case_id ea_id using "$fil\matril-hh\mathh_y1.dta"
	keep 			if _merge == 3
	*** 1693 matched, 378 not matched from using 
	drop 			_merge 
	
	tab 			matril 
	*** 73 percent matril, 27 percent otherwise 
	tab 			femalehead
	*** 22 percent female headed, 78 percent otherwise 
	
* *********************************************************************
* 1f - reduce + clean up   
* **********************************************************************	
	
	keep 			valuejoint_jspec valuefemale_jspec valuemale_jspec valuefemale_ospec valuemale_ospec ///
						valuejoint_jspecw valuefemale_jspecw valuemale_jspecw valuefemale_ospecw valuemale_ospecw /// 
						totalr noraindays dryspell foodexp alctobexp clothexp houseutilsexp healthexp transpoexp commexp recexp ///
						eduexp hotelrestexp miscexp totalexp case_id year region district ea_id HHID ssa_aez09 matril femalehead
	
	collapse 		(sum) valuejoint_jspec valuefemale_jspec valuemale_jspec valuefemale_ospec valuemale_ospec ///
						valuejoint_jspecw valuefemale_jspecw valuemale_jspecw valuefemale_ospecw valuemale_ospecw /// 
						totalr noraindays dryspell foodexp alctobexp clothexp houseutilsexp healthexp transpoexp commexp recexp ///
						eduexp hotelrestexp miscexp totalexp (max) ssa_aez09 matril femalehead, ///
						by (case_id year region district ea_id HHID)
						
	rename 			* *09
	rename 			case_id09 case_id
	rename 			year09 year 
	rename 			region09 region 
	rename 			district09 district
	rename 			ea_id09 ea_id 
	rename 			HHID09 HHID
	rename 			ssa_aez0909 ssa_aez09
	
	duplicates 		drop
						
	isid 			case_id year region district ea_id HHID
	
compress
describe
summarize
	
 	save 			"$fil\regression-ready\household-total_y1.dta", replace	

* **********************************************************************
* 2 - year 2
* **********************************************************************

* **********************************************************************
* 2a - household and gender details 
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
	
	save 			"$fil\production-and-sales\sales-with-managerid_y2.dta", replace	
	
* bring in consumption variables 
	
	merge 			m:1 case_id year y2_hhid using "$fil\consumption\ihs3_summary_12.dta"
	keep 			if _merge == 3
	drop 			_merge
	*** dropping 2515 from using 
	
	save 			"$fil\regression-ready\household-level_y2.dta", replace	
	
* merge in geovars 

	merge 			m:1 y2_hhid year using "$fil\geovar\householdgeovariables_12.dta"
	keep 			if _merge == 3
	drop 			_merge 
	*** drops 505 not matched from using
	
 	save 			"$fil\regression-ready\household-level_y2", replace	
	*** 3342 - so some observations added at some point

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
	
* determine sex of managers / mix 
	tab 			sex_salesmanager1
	tab 			sex_salesmanager2
	bys 			sex_salesmanager1: tab sex_salesmanager2

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
	
 	save 			"$fil\regression-ready\household-total_y2.dta", replace	
	

* *********************************************************************
* 2b - sales values 
* **********************************************************************
	
* convert MKW to 2010 values
* 2012 = 130.5 
*** from World Bank Indicators: https://databank.worldbank.org/source/world-development-indicators

* using rs_cropsales_valuei
	summarize 		rs_cropsales_valuei, detail
	*** mean = 44933.32, st. dev = 196788, small = 0, large = 333333

	gen 			cropsales = rs_cropsales_valuei / 1.661 
	summarize 		cropsales, detail	
	*** mean = 27051.97, st. dev = 118475.6, small = 0, large = 2006823
* winzorized values 
	winsor 			cropsales, p(.05) gen(cropsales_win)
	
* convert MWK to USD 
* 1 USD = 123 MWK
*** from https://www.exchangerates.org.uk/USD-MWK-spot-exchange-rates-history-2010.html 
	gen 			cropsales_usd = cropsales / 123 
	summarize 		cropsales_usd, detail
	*** mean = 219.94, st. dev = 963.22, small = 0, large = 16315.63 

* determine values by sales manager

*** (1) joint 
	gen 			valuejoint_jspec = cropsales if joint_jspec == 1
	replace			valuejoint_jspec = 0 if valuejoint_jspec == . 
	gen 			valuefemale_jspec = cropsales if female_jspec == 1
	replace 		valuefemale_jspec = 0 if valuefemale_jspec == .
	gen 			valuemale_jspec = cropsales if male_jspec == 1
	replace 		valuemale_jspec = 0 if valuemale_jspec == . 
	
* winsorized
	gen 			valuejoint_jspecw = cropsales_win if joint_jspec == 1
	replace			valuejoint_jspecw = 0 if valuejoint_jspec == . 
	gen 			valuefemale_jspecw = cropsales_win if female_jspec == 1
	replace 		valuefemale_jspecw = 0 if valuefemale_jspec == .
	gen 			valuemale_jspecw = cropsales_win if male_jspec == 1
	replace 		valuemale_jspecw = 0 if valuemale_jspec == . 
	
*** (2) omit

	gen 			valuefemale_ospec = cropsales if female_ospec == 1
	replace 		valuefemale_ospec = 0 if valuefemale_ospec == .
	gen 			valuemale_ospec = cropsales if male_ospec == 1
	replace 		valuemale_ospec = 0 if valuemale_ospec == . 
	
* winsorized
	gen 			valuefemale_ospecw = cropsales_win if female_ospec == 1
	replace 		valuefemale_ospecw = 0 if valuefemale_ospec == .
	gen 			valuemale_ospecw = cropsales_win if male_ospec == 1
	replace 		valuemale_ospecw = 0 if valuemale_ospec == . 		
	
* *********************************************************************
* 2c - weather and aez 
* **********************************************************************

	merge 			m:1 case_id y2_hhid ea_id year using "$fil\geovar\rain_2yr.dta"
	*** matched = 3853
	keep if _merge == 3
	drop _merge 
	
	rename			total totalr 
	
 	save 			"$fil\regression-ready\household-total_y2.dta", replace	

* *********************************************************************
* 2d - aggregates 
* **********************************************************************	

* adjusting for inflation 	

	generate 		foodexp = rexp_cat01 / 1.661 
	generate 		alctobexp = rexp_cat02 / 1.661 
	generate		clothexp = rexp_cat03 / 1.661
	egen 			houseutilsexp = rsum (rexp_cat04 rexp_cat05)
	*** adding housing and utilities with furnishings 
	replace 		houseutilsexp = houseutilsexp / 1.661
	generate 		healthexp = rexp_cat06 / 1.661  
	generate 		transpoexp = rexp_cat07 / 1.661
	generate 		commexp	= rexp_cat08 / 1.661
	generate 		recexp = rexp_cat09 / 1.661
	generate 		eduexp = rexp_cat10 / 1.661
	generate 		hotelrestexp = rexp_cat11 / 1.661
	generate 		miscexp	= rexp_cat12 / 1.661
	generate 		totalexp = rexpagg / 1.661
	
 	save 			"$fil\regression-ready\household-total_y2.dta", replace	
	
* *********************************************************************
* 2e - matrilineal and head of household gender   
* **********************************************************************	
	
	merge 			m:1 case_id ea_id y2_hhid using "$fil\matril-hh\mathh_y2.dta"
	keep 			if _merge == 3
	*** 2160 matched, 1022 not matched from using 
	drop 			_merge 
	
	tab 			matril 
	*** 85 percent matril, 15 percent otherwise 
	tab 			femalehead
	*** 25 percent female headed, 75 percent otherwise 
	
* *********************************************************************
* 2f - reduce + clean up   
* **********************************************************************	
	
	keep 			valuejoint_jspec valuefemale_jspec valuemale_jspec valuefemale_ospec valuemale_ospec ///
						valuejoint_jspecw valuefemale_jspecw valuemale_jspecw valuefemale_ospecw valuemale_ospecw /// 
						totalr noraindays dryspell foodexp alctobexp clothexp houseutilsexp healthexp transpoexp commexp recexp ///
						eduexp hotelrestexp miscexp totalexp case_id year region district ea_id y2_hhid HHID ssa_aez09 matril femalehead
	
	collapse 		(sum) valuejoint_jspec valuefemale_jspec valuemale_jspec valuefemale_ospec valuemale_ospec ///
						valuejoint_jspecw valuefemale_jspecw valuemale_jspecw valuefemale_ospecw valuemale_ospecw /// 
						totalr noraindays dryspell foodexp alctobexp clothexp houseutilsexp healthexp transpoexp commexp recexp ///
						eduexp hotelrestexp miscexp totalexp (max) ssa_aez09 matril femalehead, ///
						by (case_id year y2_hhid region district ea_id HHID)
	
	rename 			* *12
	rename 			case_id12 case_id
	rename 			year12 year 
	rename 			region12 region 
	rename 			district12 district
	rename 			ea_id12 ea_id 
	rename 			HHID12 HHID
	rename 			y2_hhid12 y2_hhid
	rename 			ssa_aez0912 ssa_aez12
	
	duplicates 		drop
	
	isid 			case_id year region district ea_id HHID y2_hhid
	
	
compress
describe
summarize
	
 	save 			"$fil\regression-ready\household-total_y2.dta", replace	

	
* *********************************************************************
* 3 - merge together 
* **********************************************************************	

* append all 
	use 			"$fil\regression-ready\household-total_y1.dta", clear 
	merge 			m:1 case_id ea_id region district HHID using "$fil\regression-ready\household-total_y2.dta"	
	drop 			_merge 
	*** 850 matched, 391 not matched from 2009, 118 not matched from 2012
	*** keeping all observations for now 
	
* save new full file 	

compress
describe
summarize 

	save 			"$fil\regression-ready\household-total_both.dta", replace
	
* *********************************************************************
* 4 - differencing / logs / reconciling 
* ********************************************************************** 

* *********************************************************************
* 4a - differencing + summing 
* ********************************************************************** 

* difference sales values by manager 
	bys case_id HHID: gen dvaluejoint_jspec = valuejoint_jspec12 - valuejoint_jspec09 
	bys case_id HHID: gen dvaluefemale_jspec = valuefemale_jspec12 - valuefemale_jspec09
	bys case_id HHID: gen dvaluemale_jspec = valuemale_jspec12 - valuemale_jspec09 
	bys case_id HHID: gen dvaluefemale_ospec = valuefemale_ospec12 - valuefemale_ospec09
	bys case_id HHID: gen dvaluemale_ospec = valuemale_ospec12 - valuemale_ospec09 

* difference sales values by manager, winsorized 
	bys case_id HHID: gen dvaluejoint_jspecw = valuejoint_jspecw12 - valuejoint_jspecw09 
	bys case_id HHID: gen dvaluefemale_jspecw = valuefemale_jspecw12 - valuefemale_jspecw09
	bys case_id HHID: gen dvaluemale_jspecw = valuemale_jspecw12 - valuemale_jspecw09 
	bys case_id HHID: gen dvaluefemale_ospecw = valuefemale_ospecw12 - valuefemale_ospecw09
	bys case_id HHID: gen dvaluemale_ospecw = valuemale_ospecw12 - valuemale_ospecw09 	
	
* difference rainfall 
	bys case_id HHID: gen dtotalr = totalr12 - totalr09
	bys case_id HHID: gen dnoraindays = noraindays12 - noraindays09 
	bys case_id HHID: gen ddryspell = dryspell12 - dryspell09 
	
* aggregate consumption categories 
* transportation and communication 
	egen commtransexp09 = rsum (transpoexp09 commexp09)
	egen commtransexp12 = rsum (transpoexp12 commexp12)
* hotels, restaurants, recreation 
	egen agrecexp09 = rsum (recexp09 hotelrestexp09)
	egen agrecexp12 = rsum (recexp12 hotelrestexp12)

* difference consumption categories 
	bys case_id HHID: gen dfoodexp = foodexp12 - foodexp09
	bys case_id HHID: gen dalctobexp = alctobexp12 - alctobexp09 
	bys case_id HHID: gen dclothexp = clothexp12 - clothexp09 
	bys case_id HHID: gen dhouseutilsexp = houseutilsexp12 - houseutilsexp09 
	bys case_id HHID: gen dhealthexp = healthexp12 - healthexp09 
	bys case_id HHID: gen dtranspoexp = transpoexp12 - transpoexp09 
	bys case_id HHID: gen dcommexp = commexp12 - commexp09 
	bys case_id HHID: gen drecexp = recexp12 - recexp09 
	bys case_id HHID: gen deduexp = eduexp12 - eduexp09 
	bys case_id HHID: gen dhotelrestexp = hotelrestexp12 - hotelrestexp09 
	bys case_id HHID: gen dmiscexp = miscexp12 - miscexp09 
	bys case_id HHID: gen dtotalexp = totalexp12 - totalexp09 
	bys case_id HHID: gen dcommtransexp = commtransexp12 - commtransexp09
	bys case_id HHID: gen dagrecexp = agrecexp12 - agrecexp09

* *********************************************************************
* 4b - logs  
* ********************************************************************** 

* sales values by manager 
	bys case_id HHID: gen dlnvaluejoint_jspec = asinh(dvaluejoint_jspec)
	bys case_id HHID: gen dlnvaluefemale_jspec = asinh(dvaluefemale_jspec)
	bys case_id HHID: gen dlnvaluemale_jspec = asinh(dvaluemale_jspec)
	bys case_id HHID: gen dlnvaluefemale_ospec = asinh(dvaluefemale_ospec)
	bys case_id HHID: gen dlnvaluemale_ospec = asinh(dvaluemale_ospec)
	
* sales values by manager, winsorized 
	bys case_id HHID: gen dlnvaluejoint_jspecw = asinh(dvaluejoint_jspecw)
	bys case_id HHID: gen dlnvaluefemale_jspecw = asinh(dvaluefemale_jspecw)
	bys case_id HHID: gen dlnvaluemale_jspecw = asinh(dvaluemale_jspecw)
	bys case_id HHID: gen dlnvaluefemale_ospecw = asinh(dvaluefemale_ospecw)
	bys case_id HHID: gen dlnvaluemale_ospecw = asinh(dvaluemale_ospecw)
	
* do not log rainfall 
	
* consumption categories 
	bys case_id HHID: gen dlnconsume_agg = asinh(dtotalexp)
	bys case_id HHID: gen dlnconsume_food = asinh(dfoodexp)
	bys case_id HHID: gen dlnconsume_alctob = asinh(dalctobexp)
	bys case_id HHID: gen dlnconsume_clothfoot = asinh(dclothexp)
	bys case_id HHID: gen dlnconsume_houseutils = asinh(dhouseutilsexp)
	bys case_id HHID: gen dlnconsume_health = asinh(dhealthexp)
	bys case_id HHID: gen dlnconsume_transpo = asinh(dtranspoexp)
	bys case_id HHID: gen dlnconsume_comm = asinh(dcommexp)
	bys case_id HHID: gen dlnconsume_rec = asinh(drecexp)
	bys case_id HHID: gen dlnconsume_educ = asinh(deduexp)
	bys case_id HHID: gen dlnconsume_hotres = asinh(dhotelrestexp)
	bys case_id HHID: gen dlnconsume_misc = asinh(dmiscexp)		
	bys case_id HHID: gen dlnconsume_commtrans = asinh(dcommtransexp)
	bys case_id HHID: gen dlnconsume_agrec = asinh(dagrecexp)
						
	save 			"$fil\regression-ready\household-total_both.dta", replace	
	
* *********************************************************************
* 4c - reconciling   
* ********************************************************************** 

	gen 				matri_change = matril12 - matril09
	tab 				matri_change
	*** 40 households say they BECOME matrilineal, 128 households say they become non-matrilineal 
	*** will classify these households as non-matrilineal, going with most conservative evaluation 
	
	gen 				matril = 1 if matril09 == 1 & matril12 == 1
	replace 			matril = 0 if matril == . 
	*** 581 matrilineal, 778 non-matrilineal 
	
	gen 				headchange = femalehead12 - femalehead09
	tab 				headchange
	*** 40 households say they BECOME femaleheaded, 51 households say they become maleheaded 
	*** will classify these households as non-female-headed, again, most conservative evaluation 
	
	gen 				femalehead = 1 if femalehead09 == 1 & femalehead12 == 1 
	replace 			femalehead = 0 if femalehead == . 
	*** 173 femaleheaded, 1186 non-femlaeheaded 
	
	drop 				femalehead09 femalehead12 matril09 matril12 
						
* *********************************************************************
* 5 - end matter
* **********************************************************************

	isid 			case_id HHID year
	
	keep 			dlnvaluejoint_jspec dlnvaluefemale_jspec dlnvaluemale_jspec dlnvaluefemale_ospec dlnvaluemale_ospec ///
						dlnvaluejoint_jspecw dlnvaluefemale_jspecw dlnvaluemale_jspecw dlnvaluefemale_ospecw dlnvaluemale_ospecw ///
						dtotalr dnoraindays ddryspell dlnconsume_agg dlnconsume_food /// 
						dlnconsume_alctob dlnconsume_clothfoot dlnconsume_houseutils dlnconsume_health dlnconsume_health ///
						dlnconsume_transpo dlnconsume_comm dlnconsume_rec dlnconsume_educ dlnconsume_hotres dlnconsume_misc ///
						ssa_aez09 ssa_aez12 case_id year region district ea_id HHID y2_hhid femalehead matril /// 
						valuejoint_jspec09 valuejoint_jspec12 valuefemale_jspec09 valuefemale_jspec12 valuemale_jspec09 valuemale_jspec12 ///
						valuemale_ospec09 valuemale_ospec12 valuefemale_ospec09 valuefemale_ospec12 ///
						valuejoint_jspecw09 valuejoint_jspecw12 valuefemale_jspecw09 valuefemale_jspecw12 valuemale_jspecw09 valuemale_jspecw12 ///
						valuemale_ospecw09 valuemale_ospecw12 valuefemale_ospecw09 valuefemale_ospecw12 /// 
						foodexp12 foodexp09 alctobexp12 alctobexp09 clothexp12 clothexp09 /// 
						houseutilsexp12 houseutilsexp09 healthexp12 healthexp09 transpoexp12 transpoexp09 commexp12 commexp09 /// 
						recexp09 recexp12 eduexp09 eduexp12 hotelrestexp09 hotelrestexp12 miscexp09 miscexp12 totalexp09 totalexp12 /// 
						totalr09 totalr12 dlnconsume_agrec dlnconsume_commtrans commtransexp12 commtransexp09 agrecexp12 agrecexp09
					
compress
describe
summarize

* details for Table 2
* by 2010, 2013
* income 
	tabstat 		valuejoint_jspec09 valuejoint_jspec12 valuefemale_jspec09 valuefemale_jspec12 valuemale_jspec09 valuemale_jspec12 ///
						valuemale_ospec09 valuemale_ospec12 valuefemale_ospec09 valuefemale_ospec12, statistics (mean sd)
* expenditure 	
	tabstat 		totalexp09 totalexp12 foodexp09 foodexp12 alctobexp09 alctobexp12 clothexp09 clothexp12 recexp09 recexp12 ///
						eduexp09 eduexp12 healthexp09 healthexp12 houseutilsexp09 houseutilsexp12 transpoexp09 transpoexp12 ///
						commexp09 commexp12 hotelrestexp09 hotelrestexp12, statistics (mean sd)
* rainfall 
	tabstat 		totalr09 totalr12, statistics (mean sd)
						
* simplify - single stat 
* income 
	egen 			valuejoint_jspec = rmean(valuejoint_jspec09 valuejoint_jspec12)
	egen 			valuefemale_jspec = rmean(valuefemale_jspec09 valuefemale_jspec12)
	egen			valuemale_jspec = rmean(valuemale_jspec09 valuemale_jspec12)
	egen 			valuefemale_ospec = rmean(valuefemale_ospec09 valuefemale_ospec12)
	egen 			valuemale_ospec = rmean(valuemale_ospec09 valuemale_ospec12)

	tabstat 		valuefemale_jspec valuemale_jspec valuejoint_jspec /// 
						valuefemale_ospec valuemale_ospec, statistics (mean sd)  
	
* expenditure 
	egen 			totalexp = rmean(totalexp09 totalexp12)
	egen 			foodexp = rmean(foodexp09 foodexp12)
	egen 			alctobexp =rmean(alctobexp09 alctobexp12)
	egen			clothexp = rmean(clothexp09 clothexp12)
	egen 			recexp = rmean(recexp09 recexp12)
	egen 			eduexp = rmean(eduexp09 eduexp12)
	egen 			healthexp = rmean(healthexp09 healthexp12)
	egen 			houseutilsexp = rmean(houseutilsexp09 houseutilsexp12)
	egen 			transpoexp = rmean(transpoexp09 transpoexp12)
	egen 			commexp = rmean(commexp09 commexp12)
	egen 			hotelrestexp = rmean(hotelrestexp09 hotelrestexp12)
	
	tabstat 		totalexp foodexp alctobexp clothexp recexp eduexp healthexp houseutilsexp ///
						transpoexp commexp hotelrestexp, statistics (mean sd)
	
* rainfall 
	egen 			totalr = rmean(totalr09 totalr12)
	
	tabstat 		totalr, statistics (mean sd)

* save and all that
	isid case_id HHID year
	
 	save 			"$fil\regression-ready\reg_ready-final.dta", replace	

* close the log
	log	close	
	
/* END */	