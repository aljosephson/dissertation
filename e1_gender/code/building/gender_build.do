* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 16 October 2020
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
						"$fil\decision-making\decision_wet_all.dta"
						
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
* 3 - determine management gender variables 
* **********************************************************************
	
* issue where nonresponse to manager2 set it equal to manager1 
* fix by replace with ., as appropriate 		
	replace 		manager2 = . if manager1 == manager2
	replace 		sex_manager2 = . if manager2 == .
	
* determine primary manager 	
	gen 			female_dec = 1 if sex_manager1 == 2 
	replace 		female_dec = 0 if female_dec == .
	gen 			male_dec = 1 if sex_manager1 == 1
	replace 		male_dec = 0 if male_dec == .	
	
	gen 			joint_dec = 1 if sex_manager2 != . 
	replace 		joint_dec = . if sex_manager1 == . | sex_manager2 == .
	replace 		joint_dec = 0 if manager2 == 0 | manager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\plot-with-manager", replace
	
* **********************************************************************
* 4 - turn to household-level variables: production sales 
* **********************************************************************

use 			"$fil\Cleaned_LSMS\rs_hh_sales.dta", clear
	
	merge 			m:m case_id year using ///
						"$fil\decision-making\decision-sales_wet_y1.dta"
	drop 			if _merge == 2
	*** drops 83 observations from using 
	drop 			_merge 
	
	merge 			m:m y2_hhid year using ///
						"$fil\decision-making\decision-sales_wet_y2.dta"
	drop 			if _merge == 2
	*** drops 136 observations from using 
	drop 			_merge 
	
	merge 			m:m y3_hhid year using ///
						"$fil\decision-making\decision-sales_wet_y3.dta"
	drop 			if _merge == 2
	*** drops 101 observations from using 
	drop 			_merge 
	
* there are 1545 without a year - preserve for now, but that's odd 	
						
	save 			"$fil\production-and-sales\sales-with-manager", replace
	
* **********************************************************************
* 5 - merge together to determine sex of manager 
* **********************************************************************

* will need to repeat twice - once for each manager? 

* manager 1
	rename 			salesmanager1 id_code 
	merge 			m:m case_id y2_hhid y3_hhid year id_code using "$fil\household\household_all.dta"
	drop 			if _merge == 2
	*** drop 29300 not matched
	*** matched 831 (from master 13467 not matched)
	
	rename 			id_code salesmanager1
	rename 			sex sex_salesmanager1
	rename			rltn rltn_salesmanager1
	rename 			age age_salesmanager1
	rename 			educ_years educ_years_salesmanager1
	drop 			_merge 
	
* manager 2	
	rename 			salesmanager2 id_code 
	merge 			m:m case_id y2_hhid y3_hhid year id_code using "$fil\household\household_all.dta"
	drop			if _merge == 2
	*** drop 29647 not matched
	*** matched 357 (from master 13941 not matched)
	
	rename 			id_code salesmanager2
	rename 			sex sex_salesmanager2
	rename			rltn rltn_salesmanager2
	rename 			age age_salesmanager2
	rename 			educ_years educ_years_salesmanager2
	drop 			_merge 

	save 			"$fil\production-and-sales\sales-with-manager", replace
	
* **********************************************************************
* 6 - determine management gender variables 
* **********************************************************************
	
* issue where nonresponse to manager2 set it equal to manager1 
* fix by replace with ., as appropriate 		
	replace 		salesmanager2 = . if salesmanager1 == salesmanager2
	replace 		sex_salesmanager2 = . if salesmanager2 == .
	
* determine primary manager 	
	gen 			female_decsale = 1 if sex_salesmanager1 == 2 
	replace 		female_decsale = 0 if female_decsale == .
	gen 			male_decsale = 1 if sex_salesmanager1 == 1
	replace 		male_decsale = 0 if male_decsale == .	
	
	gen 			joint_decsale = 1 if sex_salesmanager2 != . 
	replace 		joint_decsale = . if sex_salesmanager1 == . | sex_salesmanager2 == .
	replace 		joint_decsale = 0 if salesmanager2 == 0 | salesmanager2 == . 
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\sales-with-manager", replace	
	
* **********************************************************************
* 7 - create household-level file 
* **********************************************************************

* merge in consumption data 

	use 			"$fil\production-and-sales\sales-with-manager", clear	
	
	merge 			m:m case_id y2_hhid year using "$fil\consumption\consumptionagg.dta"
	keep 			if _merge == 3
	drop 			_merge
	
	save 			"$fil\regression-ready\household-level", replace	
	
* merge in geovars 

	merge 			m:m case_id y2_hhid y3_hhid year using "$fil\geovar\geovars.dta"
	keep 			if _merge == 3
	drop 			_merge 
	
compress
describe
summarize 
	
 	save 			"$fil\regression-ready\household-level", replace	
				
	
* **********************************************************************
* 8 - combine household and plot-level files 
* **********************************************************************

 	use 			"$fil\regression-ready\household-level", clear	
	merge 			1:m case_id y2_hhid y3_hhid year using "$fil\production-and-sales\plot-with-manager"


* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	