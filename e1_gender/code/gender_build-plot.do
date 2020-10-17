* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 16 October 2020
* Stata v.16.1

* does
	* combines files on (1) production, (2) decision making, (3) consumption, (4) geovars, (5) household  
	* for plot-level 

* assumes
	* access to data file(s) previously created ... 

* to do 
	* all of it 
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
	log using		"$logs/building_joint_variables-data_plot", append
	
	
* **********************************************************************
* 1 - year 1
* **********************************************************************

* merge sales decision with decision-maker information 

	use 			"$fil\Cleaned_LSMS\rs_hh_lp1-plot.dta", clear

	merge 			m:m case_id year using ///
						"$fil\decision-making\decision_wet_y1.dta"
	keep 			if _merge == 3
	*** drops 16760 observations from using and 0 from master 
	drop 			_merge 
	
	keep 			case_id plotid plotsize mz_yield mz_yieldimp harvest_value harvest_valueimp harvest_valueha ///
						harvest_valuehaimp year ea_id manager1 manager2 
			
	save 			"$fil\production-and-sales\production-with-manager_y1", replace	
	*** 2505 observations 
	
* manager 1 - year 1
	rename 			manager1 id_code 
	merge 			m:m case_id year id_code using "$fil\household\hhbase_y1-short.dta"
	drop 			if _merge == 2
	*** matched 2482 
	*** drop unmatched from using = 6317
	*** unmatched from master = 23
	
	rename 			id_code manager1
	rename 			sex sex_manager1
	rename			rltn rltn_manager1
	rename 			age age_manager1
	rename 			educ_years educ_years_manager1
	drop 			_merge 
	
* manager 2	- year 1
* if no manager assume no one = 0
	replace 		manager2 = 0 if manager2 == . 
	rename 			manager2 id_code 
	merge 			m:m case_id year id_code using "$fil\household\hhbase_y1-short.dta"
	drop			if _merge == 2
	*** matched 2457 
	*** drop unmatched from using = 6350
	*** keep unmatched from master = 48 
	
	rename 			id_code manager2
	rename 			sex sex_manager2
	rename			rltn rltn_manager2
	rename 			age age_manager2
	rename 			educ_years educ_years_manager2
	drop 			_merge 
	
* determine management 
	
* determine primary manager 	
	gen 			female_dec = 1 if sex_manager1 == 2 
	replace 		female_dec = 0 if female_dec == .
	gen 			male_dec = 1 if sex_manager1 == 1
	replace 		male_dec = 0 if male_dec == .	
	
	gen 			joint_dec = 1 if sex_manager2 != . | sex_manager2 != 0 
	
	replace 		joint_dec = . if sex_manager1 == . & sex_manager2 == .
	replace 		joint_dec = 0 if manager2 == 0 | sex_manager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\plot-with-managerid_y1", replace	
	
* **********************************************************************
* 2 - year 2
* **********************************************************************

* merge sales decision with decision-maker information 

	use 			"$fil\Cleaned_LSMS\rs_hh_lp2-plot.dta", clear

	merge 			m:m y2_hhid year using ///
						"$fil\decision-making\decision_wet_y2.dta"
	keep 			if _merge == 3
	*** drops 3439 observations from using and 0 from master 
	drop 			_merge 
	
	keep 			y2_hhid plotid plotsize mz_yield mz_yieldimp harvest_value harvest_valueimp harvest_valueha ///
						harvest_valuehaimp year manager1 manager2 
			
	save 			"$fil\production-and-sales\production-with-manager_y2", replace	
	*** 3051 observations 
	
* manager 1 
	rename 			manager1 id_code 
	merge 			m:m y2_hhid year id_code using "$fil\household\hhbase_y2-short.dta"
	drop 			if _merge == 2
	*** matched 3049 
	*** drop unmatched from using = 8525
	*** unmatched from master = 2
	
	rename 			id_code manager1
	rename 			sex sex_manager1
	rename			rltn rltn_manager1
	rename 			age age_manager1
	rename 			educ_years educ_years_manager1
	drop 			_merge 
	
* manager 2	
* if no manager assume no one = 0
	replace 		manager2 = 0 if manager2 == . 
	rename 			manager2 id_code 
	merge 			m:m case_id year id_code using "$fil\household\hhbase_y2-short.dta"
	drop			if _merge == 2
	*** matched 3160 
	*** drop unmatched from using = 8221
	*** keep unmatched from master = 37 
	
	rename 			id_code manager2
	rename 			sex sex_manager2
	rename			rltn rltn_manager2
	rename 			age age_manager2
	rename 			educ_years educ_years_manager2
	drop 			_merge 
	
* determine management 
	
* determine primary manager 	
	gen 			female_dec = 1 if sex_manager1 == 2 
	replace 		female_dec = 0 if female_dec == .
	gen 			male_dec = 1 if sex_manager1 == 1
	replace 		male_dec = 0 if male_dec == .	
	
	gen 			joint_dec = 1 if sex_manager2 != . | sex_manager2 != 0 
	
	replace 		joint_dec = . if sex_manager1 == . & sex_manager2 == .
	replace 		joint_dec = 0 if manager2 == 0 | sex_manager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\plot-with-managerid_y2", replace	
	

* **********************************************************************
* 3 - year 3
* **********************************************************************
* merge sales decision with decision-maker information 

	use 			"$fil\Cleaned_LSMS\rs_hh_lp3-plot.dta", clear

	merge 			m:m y3_hhid year using ///
						"$fil\decision-making\decision_wet_y3.dta"
	keep 			if _merge == 3
	*** drops 111 observations from using and 0 from master 
	drop 			_merge 
	
	keep 			y3_hhid plotid plotsize mz_yield mz_yieldimp harvest_value harvest_valueimp harvest_valueha ///
						harvest_valuehaimp year manager1 manager2 
			
	save 			"$fil\production-and-sales\production-with-manager_y3", replace	
	*** 3931 observations 
	
* manager 1 
	rename 			manager1 id_code 
	merge 			m:m y3_hhid year id_code using "$fil\household\hhbase_y3-short.dta"
	drop 			if _merge == 2
	*** matched 3921 
	*** drop unmatched from using = 10244
	*** unmatched from master = 10
	
	rename 			id_code manager1
	rename 			sex sex_manager1
	rename			rltn rltn_manager1
	rename 			age age_manager1
	rename 			educ_years educ_years_manager1
	drop 			_merge 

* manager 2	
* if no manager assume no one = 0
	replace 		manager2 = 0 if manager2 == . 
	rename 			manager2 id_code 
	merge 			m:m case_id year id_code using "$fil\household\hhbase_y3-short.dta"
	drop			if _merge == 2
	*** matched 4358 
	*** drop unmatched from using = 9454
	*** keep unmatched from master = 41 
	
	rename 			id_code manager2
	rename 			sex sex_manager2
	rename			rltn rltn_manager2
	rename 			age age_manager2
	rename 			educ_years educ_years_manager2
	drop 			_merge 
	
* determine management 
	
* determine primary manager 	
	gen 			female_dec = 1 if sex_manager1 == 2 
	replace 		female_dec = 0 if female_dec == .
	gen 			male_dec = 1 if sex_manager1 == 1
	replace 		male_dec = 0 if male_dec == .	
	
	gen 			joint_dec = 1 if sex_manager2 != . | sex_manager2 != 0 
	
	replace 		joint_dec = . if sex_manager1 == . & sex_manager2 == .
	replace 		joint_dec = 0 if manager2 == 0 | sex_manager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\plot-with-managerid_y3", replace	
	
* *********************************************************************
* 4 - end matter
* **********************************************************************


* close the log
	log	close	