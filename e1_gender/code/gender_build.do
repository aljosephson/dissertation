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
						
	save 			"$fil\production-and-sales\plot-with-manager"

* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	