* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 7 February 2022
* Stata v.16.1

* does
	* determines crop code at the plot level 
	* for creating table 1
	
* assumes
	* original data files from LSMS

* to do 
	* code and data can be made available on github and googledrive 

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - LSMS Malawi\" 
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
	
	keep 			ag_b09a ag_b09b case_id  ea_id ag_b0c
	
	rename 			ag_b0c cropcode 
	rename 			ag_b09a id_code 
	merge 			m:1 case_id ea_id id_code using "$fil\_replication2020\household\hhbase_y1-short.dta"
	keep 			if _merge == 3
	*** 831 matched, 4578 not matched from master, 6999 not matched from using 
	drop 			_merge
	
	keep 			case_id ea_id cropcode id_code ag_b09b region district sex 

	* classify as m, f, j
	* look at crops 
	
	
	save "$fil\_replication2020\production-and-sales\crop-code_manager_y1.dta"
	

* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	
