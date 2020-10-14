* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 14 October 2020
* Stata v.16.1

* does
	* builds respondent decision maker variable 
	* just clean up for now - will merge with production data before determining genders (since only need if ACTUALLY produce something)

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
	log using		"$logs/building_joint_variables", append

* **********************************************************************
* 1 - identify decision makers (Y1)
* **********************************************************************

* for each plot:
* identify managers (decision maker), owner [can identify joint ownership]

* primary wet season 

	use				"$fil\LSMS\AG_MOD_D.dta", clear

* determine plot id and relevant decision maker variables 	

* save decision maker 1 and 2 - need to merge with household base file 
	
	keep 			case_id ea_id ag_d00 ag_d01 ag_d02 ag_d04a ag_d04b
	rename 			ag_d00 plotid
	
	save 			"$fil\decision-making\decision_wet_y1.dta", replace
	
* combined with household file to learn about gender, etc.  

* primary manager 
	rename 			ag_d01 id_code 
	merge 			m:m case_id id_code using "$fil\household\hhbase_y1.dta"
	
* secondary manager 
	rename 			ag_d02 id_code
	merge m:m 		case_id ea_id id_code using "$fil\hhbase_y1.dta"
	
	
	keep 			if _merge == 3
	drop 			_merge
	
	sort case_id plotid id_code
	by case_id plotid id_code: gen female_dec = 1 if hh_b03 == 2
	replace female_dec = 0 if female_dec == .
	by case_id plotid id_code: gen male_dec = 1 if hh_b03 == 1
	replace male_dec = 0 if male_dec == .
	save "C:\Users\Anna\Dropbox\Dissertation\Data - LSMS Malawi\Plot\Decision - Wet, Y1.dta"

* gender of plot owners: 1 
rename ag_d04a id_code
rename id_code id_code_plotmanager
rename ag_d04a id_code
drop hh_b03
merge m:m case_id ea_id id_code using "C:\Users\Anna\Dropbox\Dissertation\Data - LSMS Malawi\Household\_BASE ROSTER.dta"
drop if _merge == 2
drop _merge
sort case_id plotid id_code
by case_id plotid id_code: gen female_own1 = 1 if hh_b03 == 2
replace female_own1 = 0 if female_own1 == .
by case_id plotid id_code: gen male_own1 = 1 if hh_b03 == 1
replace male_own1 = 0 if male_own1 == .

* gender of plot owners: 2 
drop hh_b03
rename id_code id_code_own1
rename ag_d04b id_code
merge m:m case_id ea_id id_code using "C:\Users\Anna\Dropbox\Dissertation\Data - LSMS Malawi\Household\_BASE ROSTER.dta"
drop if _merge == 2
drop _merge
sort case_id plotid id_code
by case_id plotid id_code: gen female_own2 = 1 if hh_b03 == 2
replace female_own2= 0 if female_own2 == .
by case_id plotid id_code: gen male_own2 = 1 if hh_b03 == 1
replace male_own2 = 0 if male_own2 == .
drop hh_b03
gen female_own = 1 if female_own1 == 1 & female_own2 == 1
tab female_own
replace female_own = 0 if female_own == .
gen male_own = 1 if male_own1 == 1 & male_own2 == 1
tab male_own
replace male_own = 0 if male_own == .
gen joint_own = 1 if male_own == 0 & female_own == 0
replace joint_own = 0 if joint_own == .
save "C:\Users\Anna\Dropbox\Dissertation\Data - LSMS Malawi\Plot\Decision, Own - all - Wet, Y1.dta"

rename female_own1 female_primary
rename female_primary female_primaryown
rename male_own1 male_primaryown
drop female_own2 male_own2
corr female_dec female_primaryown
corr male_dec male_primaryown
save "C:\Users\Anna\Dropbox\Dissertation\Data - LSMS Malawi\Plot\Decision, Own - Wet, Y1.dta", replace

* *********************************************************************
* 7 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	
