* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 12 October 2020
* Stata v.16.1

* does
	* builds introduction of overall agriculture data (rs maize, rs production)
	* combines with previously built - stuff sold information 
	* overall agriculture data derived from world bank lsms kitchen sink 

* assumes
	* access to data file(s) "..."

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
	log using		"$logs/building_joint_variables-production", append

* **********************************************************************
* 1 - agricultural production data
* **********************************************************************

* pull in Malawi kitchen sink data
* includes all years 

	use				"$fil\Cleaned_LSMS\mwi_lp.dta", clear
	
* drop all rainfall information + temperature information (for now)
* since these aren't identified

	drop 			v* tp* rf*
	
	save 			"$fil\production-and-sales\totalproduction_all.dta", replace
	
* **********************************************************************
* 2 - sale production data
* **********************************************************************

* pull in Malawi kitchen sink data

* add year information for appending files together 

*2012
	use				"$fil\Cleaned_LSMS\rs_hh_lp1.dta", clear
	gen 			year = 2012
	keep 			y2_hhid year rs_cropsales*
	merge 			1:m y2_hhid using "$fil\Cleaned_LSMS\hh_lp1.dta"
	keep 			y2_hhid year case_id region district ea_id rs_cropsales*
	destring 		case_id, replace
	save			"$fil\Cleaned_LSMS\rs_hh_lp1_sales.dta", replace

* 2009 
	use				"$fil\Cleaned_LSMS\rs_hh_lp2.dta", clear
	gen 			year = 2009
	keep 			case_id year rs_cropsales*
	merge 			1:m case_id using "$fil\Cleaned_LSMS\hh_lp2.dta"
	keep 			year case_id region district ea_id rs_cropsales*
	destring 		case_id, replace
	save			"$fil\Cleaned_LSMS\rs_hh_lp2_sales.dta", replace
	
* 2015 
	use				"$fil\Cleaned_LSMS\rs_hh_lp3.dta", clear
	gen 			year = 2015
	keep 			y3_hhid year rs_cropsales*
	merge 			1:m y3_hhid using "$fil\Cleaned_LSMS\hh_lp3.dta"
	keep 			year y2_hhid y3_hhid case_id region district ea_id rs_cropsales*
	destring 		case_id, replace
	save			"$fil\Cleaned_LSMS\rs_hh_lp3_sales.dta", replace	
	
* append all 
	use 			"$fil\Cleaned_LSMS\rs_hh_lp2_sales.dta", clear 
	append 			using "$fil\Cleaned_LSMS\rs_hh_lp1_sales.dta"
	append 			using "$fil\Cleaned_LSMS\rs_hh_lp3_sales.dta"
	save 			"$fil\Cleaned_LSMS\rs_hh_sales.dta", replace
	
* merge into main file 
	
	use 			"$fil\production-and-sales\totalproduction_all.dta", clear
	*** obs = 4163
	merge 			m:1 year case_id y2_hhid y3_hhid using "$fil\Cleaned_LSMS\rs_hh_sales.dta"
	*** matched 3250, from using not matched 2867 (???) and from master 913 not matched
	*** not sure why this is the case - but moving forward anyway 
	drop 			if _merge == 2
	drop 			_merge 
	*** same number of obs 
	save 			"$fil\production-and-sales\totalproduction-sales_all.dta", replace
	
* replace missing values of sold
* assume if nothing there, then sold nothing
	replace 		rs_cropsales_value = 0 if rs_cropsales_value == . 
	replace 		rs_cropsales_valuei = 0 if rs_cropsales_valuei == . 
	
* generate percent sold 
	gen 			soldvaluei_share = rs_cropsales_valuei / rs_harvest_valueimp
	bys year: 		sum soldvaluei_share 
	*** need to deal with these observations which are greater than 0 
	replace 		soldvaluei_share = . if soldvaluei_share > 1 
	*** change 52 observations to missing
	bys year: 		sum soldvaluei_share 
	*** averages now 12, 13, 12 percent, by year - capped at 0 / 1
	
	save 			"$fil\production-and-sales\totalproduction-sales_all.dta", replace

* *********************************************************************
* 7 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	
