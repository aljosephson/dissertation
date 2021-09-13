* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 15 October 2020
* Stata v.16.1

* does
	* builds introduction of overall agriculture data (rs maize, rs production)
	* at the plot level 
	* overall agriculture data derived from world bank lsms kitchen sink 

* assumes
	* access to data file(s) "..."

* to do 
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
	log using		"$logs/building_joint_variables-production_plot", append

* **********************************************************************
* 1 - agricultural production data
* **********************************************************************

* pull in Malawi kitchen sink data

* add year information for appending files together 

* 2009
	use				"$fil\Cleaned_LSMS\rs_hh_lp1-plot.dta", clear
	*gen 			year = 2009
	destring 		case_id, replace
	save			"$fil\Cleaned_LSMS\rs_hh_lp1-plot.dta", replace

* 2012 
	use				"$fil\Cleaned_LSMS\rs_hh_lp2-plot.dta", clear
	*gen 			year = 2012
	save			"$fil\Cleaned_LSMS\rs_hh_lp2-plot.dta", replace	
	
* 2015 
	use				"$fil\Cleaned_LSMS\rs_hh_lp3-plot.dta", clear
	*gen 			year = 2015
	save			"$fil\Cleaned_LSMS\rs_hh_lp3-plot.dta", replace	
	
* append all 
	use 			"$fil\Cleaned_LSMS\rs_hh_lp1-plot.dta", clear 
	append 			using "$fil\Cleaned_LSMS\rs_hh_lp2-plot.dta"
	append 			using "$fil\Cleaned_LSMS\rs_hh_lp3-plot.dta"
	save 			"$fil\Cleaned_LSMS\rs_hh_plot.dta", replace

* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	
