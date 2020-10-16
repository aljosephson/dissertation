* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 14 October 2020
* Stata v.16.1

* does
	* builds respondent decision maker variable for sales 
	* just clean up for now - will merge with production data before determining genders (since only need if ACTUALLY sell something)

* assumes
	* access to original LSMS data files "ag_mod_b_10", "ag_mod_ba_13", "

* to do 
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
	log using		"$logs/building_joint-decision-sales_variables", append

* **********************************************************************
* 1 - identify decision makers (Y1)
* **********************************************************************

* identify managers (decision maker)

	use				"$fil\LSMS\ag_mod_b_10.dta", clear

* determine plot id and relevant decision maker variables 	
	
	keep 			HHID case_id ea_id ag_b09a ag_b09b
	
* primary and secondary manager 
	rename 			ag_b09a salesmanager1
	rename 			ag_b09b salesmanager2
	
	gen 			year = 2009
	destring 		case_id, replace 
	
* save new file	

compress
describe
summarize 

	save 			"$fil\decision-making\decision-sales_wet_y1.dta", replace
	
* **********************************************************************
* 2 - identify decision makers (Y2)
* **********************************************************************

* identify managers (decision maker)

	use				"$fil\LSMS\ag_mod_ba_13.dta", clear

* determine plot id and relevant decision maker variables 	
	
	keep 			occ y2_hhid ag_b09a ag_b09b
	
* primary and secondary manager 
	rename 			ag_b09a salesmanager1
	rename 			ag_b09b salesmanager2
	
	gen 			year = 2012
	
* save new file 

compress
describe
summarize 
	
	save 			"$fil\decision-making\decision-sales_wet_y2.dta", replace
	
* **********************************************************************
* 3 - identify decision makers  (Y3)
* **********************************************************************

* identify managers (decision maker)

	use				"$fil\LSMS\ag_mod_g_16.dta", clear

* determine plot id and relevant decision maker variables 	
	
	keep 			y3_hhid ag_g14a ag_g14b
	
* primary and secondary manager 
	rename 			ag_g14a salesmanager1
	rename 			ag_g14b salesmanager2
	
	gen 			year = 2015
	
* save new file 

compress
describe
summarize 
	
	save 			"$fil\decision-making\decision-sales_wet_y3.dta", replace
	
* *********************************************************************
* 4 - append files together 
* **********************************************************************	

* append all 
	use 			"$fil\decision-making\decision-sales_wet_y1.dta", clear 
	append 			using "$fil\decision-making\decision-sales_wet_y2.dta"
	append 			using "$fil\decision-making\decision-sales_wet_y3.dta"
	
* save new full file 	

compress
describe
summarize 

	save 			"$fil\decision-making\decision-sales_wet_all.dta", replace

* *********************************************************************
* 5 - end matter
* **********************************************************************

* close the log
	log	close	