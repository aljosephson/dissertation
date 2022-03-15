/* BEGIN */

* Project: Joint Household Resources - Malawi 
* Created: January 2022
* Created by: alj
* Last edit: 3 February 2022
* Stata v.16.1

* does
	* creates matrilineal variables 
	* creates female headed household variables 

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
	log using		"$logs/build_file_matrilhh", append

* **********************************************************************
* 1 - year 1
* **********************************************************************

* **********************************************************************
* 1a - matrilineal 
* **********************************************************************

	use 			"$filb\Year 1\COM_CC.dta", clear
	
	keep 			ea_id com_cc06
	gen 			matril = 1 if com_cc06 == 2
	tab 			com_cc06, missing
	replace 		matril = 0 if matril == .
	replace 		matril = . if com_cc06 == .	
	drop 			com_cc06
	
	*** 1613 identify through mother, 549 through father, 189 through both
	*** so 1613 = matril, 738 = otherwise 
	
	save 			"$fil\matril-hh\matril_y1.dta", replace 
	
* **********************************************************************
* 1b - female headed  
* **********************************************************************

	use 			"$fil\household\hhbase_y1.dta"  
	
	keep 			case_id region district ea_id sex rltn 	
	gen 			femalehead = 1 if rltn == 1 & sex == 2
	replace 		femalehead = 0 if femalehead == .
	collapse 		(max) femalehead, by (case_id region district ea_id)
	tab 			femalehead
	*** 354 female headed, 1265 otherwise 
	
	save 			"$fil\matril-hh\fhh_y1.dta", replace 

* **********************************************************************
* 1c - merge  
* **********************************************************************
	
	merge 			m:1 ea_id using "$fil\matril-hh\matril_y1.dta"
	keep			if _merge == 3
	drop 			_merge 
	*** 1619 matched, 666 not matched from using 
	
	destring 		case_id, replace
	
	compress
	describe
	summarize
	
	save 			"$fil\matril-hh\mathh_y1", replace
	
* **********************************************************************
* 2 - year 2
* **********************************************************************

* **********************************************************************
* 2a - matrilineal 
* **********************************************************************

	use 		 	"$filb\Year 2\Community\COM_MOD_C.dta", clear
	
	keep 			ea_id com_cc06
	gen 			matril = 1 if com_cc06 == 2
	tab 			com_cc06, missing
	replace 		matril = 0 if matril == .
	replace 		matril = . if com_cc06 == .	
	drop 			com_cc06
	
	*** 446 identify through mother, 246 through father, 75 through both
	*** 446 = matril, 321 = otherwise 
	
	save 			"$fil\matril-hh\matril_y2", replace
	
	
* **********************************************************************
* 2b - female headed  
* **********************************************************************

	use 			"$fil\household\hhbase_y2.dta"  
	
	keep 			case_id y2_hhid region district ea_id sex rltn 	
	gen 			femalehead = 1 if rltn == 1 & sex == 2
	replace 		femalehead = 0 if femalehead == .
	collapse 		(max) femalehead, by (case_id region district ea_id y2_hhid)
	tab 			femalehead
	*** 445 female headed, 1271 otherwise 
	
	save 			"$fil\matril-hh\fhh_y2.dta", replace 

* **********************************************************************
* 1c - merge  
* **********************************************************************
	
	merge 			m:1 ea_id using "$fil\matril-hh\matril_y2.dta"
	keep			if _merge == 3
	drop 			_merge 
	*** 1716 matched, 101 not matched from using 
	
	destring 		case_id, replace
	
	compress
	describe
	summarize
	
	save 			"$fil\matril-hh\mathh_y2", replace
	
* *********************************************************************
* 5 - end matter
* **********************************************************************
	
* close the log
	log	close	
	
/* END */	