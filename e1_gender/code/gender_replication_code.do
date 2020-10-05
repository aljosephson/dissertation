* Project: Zimbabwe Labor Shocks
* Created: October 2020
* Created by: alj
* Last edit: 5 October 2020
* Stata v.16.1

* does
	* creates all tables from Josephson

* assumes
	* access to data file "..."

* to do 
	* all of it
	* code and data can be made available on github and googledrive 

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\..." 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e3_labor\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e3_labor\logs" 

* open log
	cap log 		close
	log using		"$logs/joint_gender_replication", append

* **********************************************************************
* 1 - read in clean data set
* **********************************************************************

* read in data
	use				"$fil/...", clear
	
* **********************************************************************
* 2 - replication of tables: main text
* **********************************************************************

* **********************************************************************
* 3 - replication of tables: appendix 
* **********************************************************************

* *********************************************************************
* 4 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	