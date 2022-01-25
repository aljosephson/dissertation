/* BEGIN */

* Project: Joint Household Resources - Malawi 
* Created: 24 January 2022
* Created by: alj
* Last edit: 24 January 2022
* Stata v.16.1

* does
	* adapts weather variables for inclusion  
	
* assumes
	* access to weather project git: https://github.com/jdavidm/weather_project 

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
	log using		"$logs/weather", append

* data are available through https://github.com/jdavidm/weather_project 
	
	use 			"G:\My Drive\weather_project\regression_data\malawi\mwi_sp.dta", clear	

* **********************************************************************
* 1 - weather variables 
* **********************************************************************

* evidence from https://openknowledge.worldbank.org/handle/10986/36643 suggests source, etc.
* will use: CPC, household bilinear 
* RF2 = CPC, X1 = HH BILIN 

	keep 			region district urban cluster ea_id case_id y2_hhid year hhweight *_rf2_x1

	rename 			v01_rf2_x1 mean
	rename 			v02_rf2_x1 median
	rename 			v03_rf2_x1 variance
	rename 			v04_rf2_x1 skew
	rename 			v05_rf2_x1 total
	rename 			v06_rf2_x1 dev_total
	rename 			v07_rf2_x1 z_total
	rename 			v08_rf2_x1 raindays
	rename 			v09_rf2_x1 dev_raindays
	rename 			v10_rf2_x1 noraindays
	rename 			v11_rf2_x1 dev_noraindays
	rename 			v12_rf2_x1 per_raindays
	rename 			v13_rf2_x1 devper_raindays
	rename 			v14_rf2_x1 dryspell

* *********************************************************************
* 2 - end matter
* **********************************************************************

		save 			"$fil\geovar\rain_2yr", replace	

* close the log
	log	close	
	
/* END */	