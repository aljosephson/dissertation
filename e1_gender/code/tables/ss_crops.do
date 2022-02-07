* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 7 February 2022
* Stata v.16.1

* does
	* determines crop code at the plot level 
	* for creating Table 1
	
* assumes
	* original data files from LSMS

* to do 
	* code and data can be made available on github and googledrive 

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - LSMS Malawi" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e1_gender\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e1_gender\logs" 

* open log
	cap log 		close
	log using		"$logs/building_joint_variables-production_plot", append
	
	
* **********************************************************************
* 1 - y1
* **********************************************************************	

	use 			"$fil\Year 1\AG_MOD_B.dta", clear
	
	destring 		case_id, replace
	
	keep 			ag_b09a ag_b09b case_id ea_id ag_b0c
	
	rename 			ag_b0c cropcode 
	rename 			ag_b09a id_code 
	merge 			m:1 ea_id case_id id_code using "$fil\_replication2020\household\hhbase_y1-short.dta"
	keep 			if _merge == 3
	*** 831 matched, 4578 not matched from master, 6999 not matched from using 
	drop 			_merge
	
	keep 			case_id ea_id cropcode id_code ag_b09b region district sex 
	
* determine management types 	
	gen 			female = 1 if sex == 2 
	replace 		female = 0 if female == .
	gen 			male = 1 if sex == 1
	replace 		male = 0 if male == .	
	gen 			joint = 1 if ag_b09b != .
	replace			joint = 0 if joint == .
	
* look at crops 
	bys 			female: tab cropcode
	bys 			male: tab cropcode
	bys 			joint: tab cropcode
	*** comprise Table 1
	*** sum similar crops - ex. maize = 16.57+12.15+2.21 (includes hybrid, local, and recycled hybrid)
	*** table constructed by hand 
	
	save "$fil\_replication2020\production-and-sales\crop-code_manager_y1.dta", replace 
	
* **********************************************************************
* 2 - y2
* **********************************************************************	

	use 			"$fil\Year 2\Agriculture\AG_MOD_BA.dta", clear
	
	keep 			ag_b09a ag_b09b y2_hhid ag_b0c
	
	rename 			ag_b0c cropcode 
	rename 			ag_b09a id_code 
	merge 			m:1 y2_hhid id_code using "$fil\_replication2020\household\hhbase_y2-short.dta"
	keep 			if _merge == 3
	*** 1073 matched, 5528 not matched from master, 9322 not matched from using 
	drop 			_merge
	
	keep 			y2_hhid cropcode id_code ag_b09b region district sex 
	
* determine management types 	
	gen 			female = 1 if sex == 2 
	replace 		female = 0 if female == .
	gen 			male = 1 if sex == 1
	replace 		male = 0 if male == .	
	gen 			joint = 1 if ag_b09b != .
	replace			joint = 0 if joint == .
	
* look at crops 
	bys 			female: tab cropcode
	bys 			male: tab cropcode
	bys 			joint: tab cropcode
	*** comprise Table 1
	*** same procedure as described in y1
	
	save "$fil\_replication2020\production-and-sales\crop-code_manager_y2.dta"
	

* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	