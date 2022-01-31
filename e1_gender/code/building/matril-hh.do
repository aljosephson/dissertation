/* BEGIN */

* Project: Joint Household Resources - Malawi 
* Created: January 2022
* Created by: alj
* Last edit: 31 January 2022
* Stata v.16.1

* does
	* creates matrilineal variables 
	* creates female / male headed household variables 

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
	
* *********************************************************************
* 5 - end matter
* **********************************************************************
	
* close the log
	log	close	
	
/* END */	