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
	* access to data file(s) previously created ... 

* to do 
	* SECTION 3: DEBUG 2016 CONSUMPTION VARIABLES 
	* SECTION 6: DEBUG 
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
	log using		"$logs/building_joint_variables-data_household", append
	
	
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
*/

	merge			m:1 y2_hhid using "$fil\production-and-sales\plot-with-managerid_y2"	
	*** 15662 matched 
	*** drop 4313 from using 
	keep 			if _merge == 3
	drop 			_merge
	
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
	*** 95 percent of second manager women 
	

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


* **********************************************************************
* 3 - year 3
* **********************************************************************

* merge sales decision with decision-maker information 

	use 			"$fil\Cleaned_LSMS\rs_hh_sales_y3.dta", clear

	merge 			m:m y3_hhid year using ///
						"$fil\decision-making\decision-sales_wet_y3.dta"
	keep 			if _merge == 3
	*** drops 103 observations from using and 662 from master (no sales)
	drop 			_merge 

	save 			"$fil\production-and-sales\sales-with-manager_y3", replace	
	*** 6186 observations 
	
* manager 1 
* reduce sample significantly at this point - if do not identify a manager, not included 
	rename 			salesmanager1 id_code 
	merge 			m:m case_id year id_code using "$fil\household\hhbase_y3-short.dta"
	drop 			if _merge == 2
	*** matched 6332 
	*** drop unmatched from using = 9603
	*** unmatched from master = 129 - okay, can drop later, as needed 
	
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
	merge 			m:m case_id year id_code using "$fil\household\hhbase_y3-short.dta"
	drop			if _merge == 2
	*** matched 4047 
	*** drop unmatched from using = 10372
	*** keep unmatched from master = 2593 - perhaps no id code TO match - fewer observations here
	
	rename 			id_code salesmanager2
	rename 			sex sex_salesmanager2
	rename			rltn rltn_salesmanager2
	rename 			age age_salesmanager2
	rename 			educ_years educ_years_salesmanager2
	drop 			_merge 
	
* determine management 
	
	replace 		salesmanager2 = . if salesmanager1 == salesmanager2
	replace 		sex_salesmanager2 = . if salesmanager2 == .
	*** 242 changes made in first case, 241 in second case 
	
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
	
	save 			"$fil\production-and-sales\sales-with-managerid_y3", replace	
	
* bring in consumption variables 
	
	merge 			m:m case_id year using "$fil\consumption\ihs3_summary_15.dta"
	keep 			if _merge == 3
	drop 			_merge
**** THIS IS NOT WORKING ****
**** WILL HAVE TO OMIT 2016 FOR NOW **** 
	
	save 			"$fil\regression-ready\household-level_y3", replace	
	
* merge in geovars 

	merge 			m:m y3_hhid year using "$fil\geovar\householdgeovariables_15.dta"
	keep 			if _merge == 3
	drop 			_merge 
	*** drops 662 not matched from using

compress
describe
summarize 
	
 	save 			"$fil\regression-ready\household-level_y3", replace	
	
	
* merge in plot-level files 
 	use 			"$fil\regression-ready\household-level_y3", clear	
	duplicates drop 
	*** 2877 duplicates dropped

	merge			m:m y3_hhid using "$fil\production-and-sales\plot-with-managerid_y3"	
	*** 5051 matched
	keep 			if _merge == 3
	drop 			_merge
	
		
	replace 		sex_salesmanager1 = 0 if sex_salesmanager1 == 1
	replace 		sex_salesmanager1 = 1 if sex_salesmanager1 == 2
	label 			var sex_salesmanager1 "0 = male,  = 1 female"
	label 			define sex_salesmanager1 0 "male" 1 "female"	
	
	replace 		sex_salesmanager2 = 0 if sex_salesmanager2 == 1
	replace 		sex_salesmanager2 = 1 if sex_salesmanager2 == 2
	label 			var sex_salesmanager2 "0 = male,  = 1 female"
	label 			define sex_salesmanager2 0 "male" 1 "female"	
	
	summarize 		sex_salesmanager1 sex_salesmanager2
	*** 35 percent of first manager women
	*** 83 percent of second manager women 
	
compress
describe
summarize
	
 	save 			"$fil\regression-ready\household-total_y3", replace	
	
* *********************************************************************
* 4 - append all together 
* **********************************************************************	

* append all 
	use 			"$fil\regression-ready\household-total_y1", clear 
	append 			using "$fil\regression-ready\household-total_y2"
	append 			using "$fil\regression-ready\household-total_y3"
	
* save new full file 	

compress
describe
summarize 

	save 			"$fil\regression-ready\household-total_all", replace
	
* *********************************************************************
* 5 - append all together 
* **********************************************************************

* adapt management variables 
/*
	gen 			female_deconly = female_dec
	replace			female_deconly = 0 if joint_dec == 1 
	gen 			male_deconly = male_dec
	replace			male_deconly = 0 if joint_dec == 1
	gen 			female_decsaleonly = 0 
	gen 			male_decsaleonly = 
*/	
	
	**** THIS IS NOT WORKING 
	
* *********************************************************************
* 6 - end matter
* **********************************************************************

* close the log
	log	close	
	
/* END */	