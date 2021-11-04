* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 4 November 2021
* Stata v.16.1

* does
	* builds respondent decision maker variable 
	* just clean up for now - will merge with production data before determining genders (since only need if ACTUALLY produce something)

* assumes
	* access to original LSMS data files "AG_MOD_D_*" for each year

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
	log using		"$logs/building_joint_variables", append

* **********************************************************************
* 1 - identify decision makers and owners (Y1)
* **********************************************************************

* for each plot:
* identify managers (decision maker), owner [can identify joint ownership]

* primary wet season 

	use				"$fil\LSMS\AG_MOD_D_y1.dta", clear

* determine plot id and relevant decision maker variables 	
	
	keep 			case_id ea_id ag_d00 ag_d01 ag_d02 ag_d04a ag_d04b
	rename 			ag_d00 plotid
	
* primary and secondary manager 
	rename 			ag_d01 manager1
	rename 			ag_d02 manager2
	rename 			ag_d04a owner1
	rename 			ag_d04b owner2 
	
	gen 			year = 2009
	destring 		case_id, replace 
	
* save new file	

compress
describe
summarize 

	save 			"$fil\decision-making\decision_wet_y1.dta", replace
	
* **********************************************************************
* 2 - identify decision makers and owners (Y2)
* **********************************************************************

* for each plot:
* identify managers (decision maker), owner [can identify joint ownership]

* primary wet season 

	use				"$fil\LSMS\AG_MOD_D_y2.dta", clear

* determine plot id and relevant decision maker variables 	
	
	keep 			occ y2_hhid interview_status ag_d00 ag_d01 ag_d01_1 ag_d01_2a ag_d01_2b ag_d04a ag_d04b
	rename 			ag_d00 plotid
	
* primary and secondary manager 
	rename 			ag_d01 manager1
	rename 			ag_d01_1 manager2
	rename 			ag_d01_2a mangagero_1
	rename 			ag_d01_2b managero_2
	rename 			ag_d04a owner1
	rename 			ag_d04b owner2 
	
	gen 			year = 2012
	
* save new file 

compress
describe
summarize 
	
	save 			"$fil\decision-making\decision_wet_y2.dta", replace
	
* **********************************************************************
* 3 - identify decision makers  (Y3)
* **********************************************************************

* for each plot:
* identify managers (decision maker)
* owner not identified in this module - will need to go back and find if decide to use these 

* primary wet season 

	use				"$fil\LSMS\AG_MOD_D_y3.dta", clear

* determine plot id and relevant decision maker variables 	
	
	keep 			y3_hhid gardenid plotid ag_d01 ag_d01_1 ag_d01_2a ag_d01_2b ag_d02
	
* primary and secondary manager 
	rename 			ag_d01 manager1
	rename 			ag_d01_1 manager2
	rename 			ag_d01_2a mangagero_1
	rename 			ag_d01_2b managero_2
	rename 			ag_d02 respond_id 
	
	gen 			year = 2015
	
* save new file 

compress
describe
summarize 
	
	save 			"$fil\decision-making\decision_wet_y3.dta", replace
	
* *********************************************************************
* 4 - append files together 
* **********************************************************************	

* append all 
	use 			"$fil\decision-making\decision_wet_y1.dta", clear 
	append 			using "$fil\decision-making\decision_wet_y2.dta"
	append 			using "$fil\decision-making\decision_wet_y3.dta"
	
* save new full file 	

compress
describe
summarize 

	save 			"$fil\decision-making\decision_wet_all.dta", replace

* *********************************************************************
* 5 - end matter
* **********************************************************************

* close the log
	log	close	