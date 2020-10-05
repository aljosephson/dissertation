* Project: Joint Household Resources - Malawi 
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
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\DISE1_Gender\Data - LSMS Malawi" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e3_labor\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e3_labor\logs" 

* open log
	cap log 		close
	log using		"$logs/joint_gender_replication", append

* **********************************************************************
* 1 - read in clean data set
* **********************************************************************

* read in data
* need to create single data set - right now multiples referenced 
	
* **********************************************************************
* 2 - replication of tables: main text - general 
* **********************************************************************

* **********************************************************************
* 2a - primary crop cultivation by gender 
* **********************************************************************

* **********************************************************************
* 2b - summary statistics 
* **********************************************************************

* income 

* percent expenditure 

* rainfall 

* **********************************************************************
* 3 - replication of tables: main text - general - crops sold 
* **********************************************************************

* **********************************************************************
* 3a - first stage - rainfall estimates (MFJ) 
* **********************************************************************

	use				"$fil/data_jointest_16April2020.dta", clear

* set globals	
	global 			jincome (dlnvaluejoint davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* joint							
	reg 			$jincome, vce (cluster y2_hhid)
	test			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est 			store INJM
	predict 		xbjoint, xb

* female 
	reg 			$fincome, vce (cluster y2_hhid) 
	test 			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est 			store INJF
	predict 		xbfemale, xb

* male 
	reg 			$mincome, vce (cluster y2_hhid)
	test 			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est 			store INJJ
	predict 		xbmale, xb

* not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)

/*
esttab INJM INJF INJJ using table_sold_mfj_stage1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 

* **********************************************************************
* 3b - restricted overid tests (MFJ)
* **********************************************************************

	global 			aggconsume (dlnconsume_agg xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			foodconsume (dlnconsume_food xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			cigsal (dlnconsume_alctob xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			clothing (dlnconsume_clothfoot xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			recconsume (dlnconsume_rec xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			educconsume (dlnconsume_educ xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			healthconsume (dlnconsume_health xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			houseconsume (dlnconsume_houseutils xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
    
* aggregate 	
	reg 			$aggconsume
	est 			store AGCONJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
	
* food 
	reg				$foodconsume
	est 			store CONFOJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 
	suest 			AGCONJ CONFOJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CONFOJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
							[CONFOJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CONFOJ_mean]xbjoint)

* cigarettes and alcohol 
	reg 			$cigsal
	est 			store CIGSJ
	test			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 
	suest 			AGCONJ CIGSJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CIGSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
						[CIGSJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CIGSJ_mean]xbjoint)

* clothing 						
	reg 			$clothing
	est 			store CLJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 
	suest 			AGCONJ CLJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CLJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
						[CLJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CLJ_mean]xbjoint)

* recreation  						
	reg 			$recconsume 
	est 			store RECJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 	
	suest 			AGCONJ RECJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [RECJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
						[RECJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [RECJ_mean]xbjoint)

* education 	
	reg 			$educconsume
	est 			store EDUCJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 	
	suest 			AGCONJ EDUCJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [EDUCJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
						[EDUCJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [EDUCJ_mean]xbjoint)

* health 	
	reg 			$healthconsume 
	est 			store HEAJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 
	suest 			AGCONJ HEAJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [HEAJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
						[HEAJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [HEAJ_mean]xbjoint)

* housing and utilities 	
	reg 			$houseconsume  
	est 			store TRANSJ
	test 			xbmale xbfemale xbjoint
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	*qui: boottest xbjoint
* test against aggregate 
	suest 			AGCONJ TRANSJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [TRANSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = ///
						[TRANSJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [TRANSJ_mean]xbjoint)

/*	
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table3.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/

* **********************************************************************
* 3c - first stage - raifall estimates (MFomit) + (MFreallocate) 
* **********************************************************************

* **********************************************************************
* 3d -  restricted overid (MFomit) + (MFreallocate) 
* **********************************************************************

* **********************************************************************
* 3e -  restricted overid (matrilineal)
* **********************************************************************

* **********************************************************************
* 3f -  restricted overid (female headed)
* **********************************************************************

* **********************************************************************
* 4 - replication of tables: main text - general - all crops 
* **********************************************************************




* **********************************************************************
* 5 - replication of tables: appendix 
* **********************************************************************

* **********************************************************************
* 5a - unrestricted overid (sold crops)
* **********************************************************************

* **********************************************************************
* 5b - first stage - rainfall estimates (matrilineal) + sold crops
* **********************************************************************

* **********************************************************************
* 5c - first stage - rainfall estimates (female headed) + sold crops
* **********************************************************************




* *********************************************************************
* 6 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	