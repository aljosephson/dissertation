* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 14 October 2020
* Stata v.16.1

* does
	* combines files on (1) production, (2) decision making, (3) consumption, (4) geovars, (5) household  

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
	log using		"$logs/building_joint_variables-data", append
	

* **********************************************************************
* 1 - merge together production PLOT and decision making 
* **********************************************************************

	use 			"$fil\Cleaned_LSMS\rs_hh_plot.dta", clear
	
	merge 			m:m case_id y2_hhid y3_hhid year plotid using ///
						"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - LSMS Malawi\_replication2020\decision-making\decision_wet_all.dta"
	keep 			if _merge == 3
	*** drops 20568 observations from using which did not match 
	
	keep 			case_id plotid plotsize mz_yield mz_yieldimp harvest_value harvest_valueimp harvest_valueha ///
						harvest_valuehaimp year y2_hhid y3_hhid gardenid ea_id manager1 manager2 owner1 owner2 mangagero_1 
						
	save 			"$fil\production-and-sales\plot-with-manager", replace
	
* **********************************************************************
* 2 - merge together to determine sex of manager 
* **********************************************************************

* will need to repeat twice - once for each manager? 

* manager 1
	rename 			manager1 id_code 
	merge 			m:m case_id y2_hhid y3_hhid year id_code using "$fil\household\household_all.dta"
	drop 			if _merge == 2
	*** drop 28619 not matched
	*** matched 2413 (from master 6816 not matched)
	
	rename 			id_code manager1
	rename 			sex sex_manager1
	rename			rltn rltn_manager1
	rename 			age age_manager1
	rename 			educ_years educ_years_manager1
	drop 			_merge 
	
* manager 2	
	rename 			manager2 id_code 
	merge 			m:m case_id y2_hhid y3_hhid year id_code using "$fil\household\household_all.dta"
	drop			if _merge == 2
	*** drop 28651 not matched
	*** matched 2391 (from master 6838 not matched)
	
	rename 			id_code manager2
	rename 			sex sex_manager2
	rename			rltn rltn_manager2
	rename 			age age_manager2
	rename 			educ_years educ_years_manager2
	drop 			_merge 

	save 			"$fil\production-and-sales\plot-with-manager", replace
	
* **********************************************************************
* 3 - determine management 
* **********************************************************************
	
* determine primary manager 	
	bys case_id plotid: gen female_dec = 1 if sex_manager1 == 2 
	replace female_dec = 0 if female_dec == .
	bys case_id plotid: gen male_dec = 1 if sex_manager1 == 1
	replace male_dec = 0 if male_dec == .	
	
	bys case_id plotid: gen joint_dec = 1 if sex_manager2 != . 
	replace joint_dec = . if sex_manager1 == . | sex_manager2 == .
	*** THIS ISN'T WORKING

* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	