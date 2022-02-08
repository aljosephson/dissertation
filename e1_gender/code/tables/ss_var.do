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


* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	