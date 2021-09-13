* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 26 September 2021
* Created by: alj
* Stata v.16

* does
	* first stage rainfall estimates
	* second stage overidentification test for male, female, joint 
	* corresponds with tables 5 and 6 
	
* assumes
	* data_jointtest.dta 

* TO DO:
	* anonymize pre-submission 
	
* **********************************************************************
* 1 - data 
* *********************************************************************

* read in data 

	use "C:\Users\aljosephson\Dropbox\Out for Review\DISE1_Gender\Data - LSMS Malawi\data_jointtest.dta", clear

* **********************************************************************
* 2 - first stage 
* *********************************************************************

* set globals for male, female, and joint 

	global jincome (dlnvaluejoint davg_tot davg_wetqstart dlag1_tot dlag1_wetqstart dtot dwetqstart i.agroeczone2010 i.agroeczone2013)
	global fincome (dlnvaluefemale davg_tot davg_wetqstart dlag1_tot dlag1_wetqstart dtot dwetqstart i.agroeczone2010 i.agroeczone2013)
	global mincome (dlnvaluemale davg_tot davg_wetqstart dlag1_tot dlag1_wetqstart dtot dwetqstart i.agroeczone2010 i.agroeczone2013)

* reg and F-test
* save estimates and predict xb 

	reg $jincome, vce (cluster y2_hhid)
	test davg_tot = davg_wetqstart = dlag1_tot = dlag1_wetqstart = dtot =  dwetqstart 
	est store INJM
	predict xbjoint, xb

	reg $fincome, vce (cluster y2_hhid) 
	test davg_tot = davg_wetqstart = dlag1_tot = dlag1_wetqstart = dtot =  dwetqstart 
	est store INJF
	predict xbfemale, xb
	
	reg $mincome, vce (cluster y2_hhid)
	test davg_tot = davg_wetqstart = dlag1_tot = dlag1_wetqstart = dtot =  dwetqstart 
	est store INJJ
	predict xbmale, xb

* in paper: not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)

* export table 
/*
esttab INJM INJF INJJ using table1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/

* **********************************************************************
* 3 - second stage 
* *********************************************************************

* male, female, and joint 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads
* consumption aggregates for: food, cigarettes and alcohol, clothing, recreation, education, health, housing and utilities (labeled transpo)

	global aggconsume (dlnconsume_agg xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global foodconsume (dlnconsume_food xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global cigsal (dlnconsume_alctob xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global clothing (dlnconsume_clothfoot xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global recconsume (dlnconsume_rec xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global educconsume (dlnconsume_educ xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)	
	global healthconsume (dlnconsume_health xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global houseconsume (dlnconsume_houseutils xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	
* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg $aggconsume
	test xbmale xbfemale xbjoint
	est store AGCONJ

	reg $foodconsume
	test xbmale xbfemale xbjoint
	est store CONFOJ
	suest AGCONJ CONFOJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [CONFOJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CONFOJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CONFOJ_mean]xbjoint)
	
*** PERSISTANT PROBLEM: "nonstandard vce (bootstrap)" for estimation of AGCONJ and CONFOJ	

*** NOTHING WORKS
	
	reg $cigsal
	est store CIGSJ
	test xbmale xbfemale xbjoint
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	qui: boottest xbjoint, reps (10000) 
	suest AGCONJ CIGSJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [CIGSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CIGSJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CIGSJ_mean]xbjoint)
	
	reg $clothing
	est store CLJ
	test xbmale xbfemale xbjoint
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	qui: boottest xbjoint, reps (10000) 
	suest AGCONJ CLJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [CLJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CLJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CLJ_mean]xbjoint)

	reg $recconsume 
	est store RECJ
	test xbmale xbfemale xbjoint
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	qui: boottest xbjoint, reps (10000) 
	suest AGCONJ RECJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [RECJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [RECJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [RECJ_mean]xbjoint)

	reg $educconsume
	est store EDUCJ
	test xbmale xbfemale xbjoint
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	qui: boottest xbjoint, reps (10000) 
	suest AGCONJ EDUCJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [EDUCJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [EDUCJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [EDUCJ_mean]xbjoint)

	reg $healthconsume 
	est store HEAJ
	test xbmale xbfemale xbjoint
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	qui: boottest xbjoint, reps (10000) 
	suest AGCONJ HEAJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [HEAJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HEAJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [HEAJ_mean]xbjoint)

	reg $houseconsume  
	est store TRANSJ
	test xbmale xbfemale xbjoint
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	qui: boottest xbjoint, reps (10000) 
	suest AGCONJ TRANSJ, vce(robust)
	testnl ([AGCONJ_mean]xbmale = [TRANSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [TRANSJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [TRANSJ_mean]xbjoint)

* export table 
/*	
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table3.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	
********************************************************************************************

/* END */