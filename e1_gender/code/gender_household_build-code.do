* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 15 October 2020
* Stata v.16.1

* does
	* put together household files
	* for determining gender of manager 

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
	log using		"$logs/building_household_variables-data", append
	
* **********************************************************************
* 1 - merge together household rosters
* **********************************************************************

* 2009
	use				"$fil\household\hhbase_y1.dta", clear
	gen 			year = 2009
	keep			case_id region district urban ta ea_id strata cluster hhweightR1 id_code sex rltn age educ_years 
	destring		case_id, replace 
	save			"$fil\household\hhbase_y1-short.dta", replace
	
* 2012 
	use				"$fil\household\hhbase_y2.dta", clear
	gen 			year = 2012
	keep 			y2_hhid case_id region district urbanR2 ta ea_id urbanR1 strataR1 ///
						strataR2 cluster hhweightR1 hhweightR2 splitoffR2 PID id_code hhmember rltn sex age educ_years
	destring 		case_id, replace 
	save			"$fil\household\hhbase_y2-short.dta", replace

* 2015	
	use				"$fil\household\hhbase_y3.dta", clear
	gen 			year = 2015
	keep			y3_hhid y2_hhid case_id region district urbanR3 ta ea_id strataR3 ///
						cluster hhweightR1 hhweightR2 hhweightR3 mover_R1R2R3 PID id_code rltn age educ_years sex
	destring 		case_id, replace 
	save			"$fil\household\hhbase_y3-short.dta", replace
	
	
* append all 
	use				"$fil\household\hhbase_y1-short.dta", clear
	append 			using "$fil\household\hhbase_y2-short.dta"
	append 			using "$fil\household\hhbase_y3-short.dta"
	save 			"$fil\household\household_all.dta", replace


* *********************************************************************
* 2 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	
