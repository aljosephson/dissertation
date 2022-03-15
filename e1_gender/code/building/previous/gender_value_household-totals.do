* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 16 October 2020
* Stata v.16.1

* does
	* combines files on (1) production, (2) decision making, (3) consumption, (4) geovars, (5) household  
	* for plot-level 

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
	log using		"$logs/building_joint_variables-data_plot-for-oldanalysis", append
	
* **********************************************************************
* 1 - year 1
* **********************************************************************

	use 			"$fil\Cleaned_LSMS\rs_hh_lp1-plot.dta", clear

	keep 			case_id plotid harvest_valueimp harvest_valuehaimp 
	rename 			harvest_valueimp valueharvest2010
	rename 			harvest_valuehaimp valueyield2010	
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\y1production", replace	
	
* **********************************************************************
* 2 - year 2
* **********************************************************************

	use 			"$fil\Cleaned_LSMS\rs_hh_lp2-plot.dta", clear

	keep 			y2_hhid plotid harvest_valueimp harvest_valuehaimp 
	rename 			harvest_valueimp valueharvest2013
	rename 			harvest_valuehaimp valueyield2013	
	
compress
describe
summarize 
	
	save 			"$fil\production-and-sales\y2production", replace	

* *********************************************************************
* 4 - add information on production
* **********************************************************************

* merge into og file 

	use				"$fil/data_jointest_16April2020.dta", clear
	
	merge 			m:m case_id using "$fil\production-and-sales\y1production"
	drop 			if _merge == 2
	drop 			_merge 
	*** drops 1522 from using 
	
	merge 			m:m y2_hhid using "$fil\production-and-sales\y2production"
	drop 			if _merge == 2
	drop 			_merge 
	*** drops 2034 from using 
	
* clean up for analysis 

* 2010 
* joint 
	gen 			valuejointharv2010 = valueharvest2010 if valuejoint2010 != 0 
	gen				valuejointyield2010 = valueyield2010 if valuejoint2010 !=0
* male 	
	gen 			valuemaleharv2010 = valueharvest2010 if valuemale2010 != 0 
	gen				valuemaleyield2010 = valueyield2010 if valuemale2010 !=0	
*female 	
	gen 			valuefemaleharv2010 = valueharvest2010 if valuefemale2010 != 0 
	gen				valuefemaleyield2010 = valueyield2010 if valuefemale2010 !=0	

* 2013
* joint 
	gen 			valuejointharv2013 = valueharvest2013 if valuejoint2013 != 0 
	gen				valuejointyield2013 = valueyield2013 if valuejoint2013 !=0
* male 	
	gen 			valuemaleharv2013 = valueharvest2013 if valuemale2013 != 0 
	gen				valuemaleyield2013 = valueyield2013 if valuemale2013 !=0	
*female 	
	gen 			valuefemaleharv2013 = valueharvest2013 if valuefemale2013 != 0 
	gen				valuefemaleyield2013 = valueyield2013 if valuefemale2013 !=0	
	
* difference 
* joint 
	gen 			dvaluejointharv = valuejointharv2013 - valuejointharv2010
	gen 			dvaluejointyield = valuejointyield2013 - valuejointyield2010
* male 
	gen				dvaluemaleharv = valuemaleharv2013 - valuemaleharv2010
	gen				dvaluemaleyield = valuemaleyield2013 - valuemaleyield2010
*female 
	gen 			dvaluefemaleharv = valuefemaleharv2013 - valuefemaleharv2010
	gen 			dvaluefemaleyield = valuefemaleyield2013 - valuefemaleyield2010
	
* log 
* joint 
	gen 			dlnvaluejointharv = asinh(dvaluejointharv)
	gen 			dlnvaluejointyield = asinh(dvaluejointyield)
* male 
	gen 			dlnvaluemaleharv = asinh(dvaluemaleharv)
	gen 			dlnvaluemaleyield = asinh(dvaluemaleyield)
* female 	
	gen 			dlnvaluefemaleharv = asinh(dvaluefemaleharv)
	gen 			dlnvaluefemaleyield = asinh(dvaluefemaleyield)
	
	save				"$fil/data_jointest_16October2020.dta", replace

	
* *********************************************************************
* 3 - end matter
* **********************************************************************


* close the log
	log	close	