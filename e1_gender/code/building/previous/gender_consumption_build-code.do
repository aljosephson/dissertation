* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 12 October 2020
* Stata v.16.1

* does
	* builds consumption variables from malawi kitchen sink and world bank team 

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
	log using		"$logs/building_joint_variables-consumption", append

* **********************************************************************
* 1 - consumption indices from each round
* **********************************************************************

* pull in Malawi kitchen sink data

* 2009
	use				"$fil\consumption\ihs3_summary.dta", clear
	gen 			year = 2009
	destring		case_id, replace 
	save			"$fil\consumption\ihs3_summary_09.dta", replace
	
* 2012 
	use				"$fil\consumption\Round 2 (2013) Consumption Aggregate.dta", clear
	gen 			year = 2012
	destring		case_id, replace 
	save			"$fil\consumption\ihs3_summary_12.dta", replace

* 2015	
	use				"$fil\consumption\IHS4 Consumption Aggregate.dta", clear
	gen 			year = 2015
	destring		case_id, replace 
	save			"$fil\consumption\ihs3_summary_15.dta", replace
	
	
* append all 
	use 			"$fil\consumption\ihs3_summary_09.dta", clear 
	append 			using "$fil\consumption\ihs_summary_12.dta"
	append 			using "$fil\consumption\ihs3_summary_15.dta"
	destring 		case_id, replace
	save 			"$fil\consumption\consumptionagg.dta", replace
	

* *********************************************************************
* 2 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	
