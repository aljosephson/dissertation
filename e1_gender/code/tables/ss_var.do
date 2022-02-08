* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 8 February 2022
* Stata v.16.1

* does
	* summary statistics for income, expenditure, rain 
	* for creating Table 2
	
* assumes
	* reg_ready-final.dta

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
	log using		"$logs/tables", append
	
* **********************************************************************
* 1 - create sum stat table 
* **********************************************************************	

	use 			"$fil\regression-ready\reg_ready-final.dta", clear
	
* panel 1 - income 

* panel 1a - joint specification 
	tabstat 		  valuefemale_jspec09 valuemale_jspec09 valuejoint_jspec09 /// 
						 valuefemale_jspec12 valuemale_jspec12 valuejoint_jspec12, statistics(mean sd)
* panel 1b - omitted specification 
	tabstat 			valuefemale_ospec09 valuemale_ospec09 valuefemale_ospec12 valuemale_ospec12, statistics (mean sd)
* panel 1c - realloated specification
	tabstat 			valuefemale_rspec09 valuemale_rspec09 valuefemale_rspec12 valuemale_rspec12, statistics (mean sd)

						  

* panel 2 - expenditure 

	tabstat 			foodexp09 foodexp12 alctobexp09 alctobexp12 clothexp09 clothexp12 houseutilsexp09 houseutilsexp12  ///
						healthexp09 healthexp12 transpoexp09 transpoexp12 commexp09 commexp12 recexp09 recexp12 eduexp09 ///
						eduexp12 hotelrestexp09 hotelrestexp12 miscexp09 miscexp12, statistics (mean sd)   
						

* panel 3 - rainfall 	

	tabstat 			totalr09 totalr12, statistics (mean sd)


* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	