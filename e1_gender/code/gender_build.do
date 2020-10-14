* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 12 October 2020
* Stata v.16.1

* does
	* combines files on (1) production, (2) decision making, (3) consumption, (4) geovars, (5) household  

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
	log using		"$logs/building_joint_variables-production", append

* *********************************************************************
* 3 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	