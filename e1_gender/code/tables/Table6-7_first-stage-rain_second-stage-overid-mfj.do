/* BEGIN */

********************************************************************************************

* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 27 January 2022
* Created by: alj
* Stata v.16

* does
	* first stage rainfall estimates
	* second stage overidentification test for male, female, joint 
	* corresponds with tables 6 and 7  (add more?)
	
* assumes
	* reg_ready-final.dta 

* TO DO:
	* anonymize pre-submission 
	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - LSMS Malawi\_replication2020" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e1_gender\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e1_gender\logs" 

* open log
	cap log 		close
	log using		"$logs/regs", append	
	
* **********************************************************************
* 1 - data 
* *********************************************************************
clear 

* read in data 

 	use 			"$fil\regression-ready\reg_ready-final", replace	
	
* **********************************************************************
* 2 - first stage - TABLE 6
* *********************************************************************

* set globals for male, female, and joint 

	global jincome (dlnvaluejoint_jspec dtotalr i.ssa_aez09 i.ssa_aez12)
	global fincome (dlnvaluefemale_jspec dtotalr i.ssa_aez09 i.ssa_aez12)
	global mincome (dlnvaluemale_jspec dtotalr i.ssa_aez09 i.ssa_aez12)

* reg and F-test
* save estimates and predict xb 

	reg $jincome, vce (cluster case_id)
	est store INJJ
	predict xbjoint, xb

	reg $fincome, vce (cluster case_id) 
	est store INJF
	predict xbfemale, xb
	
	reg $mincome, vce (cluster case_id)
	est store INJM 
	predict xbmale, xb

* in paper: not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)


/*
esttab INJM INJF INJJ using table1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/

	label variable xbmale "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemale "\hspace{0.1cm} Predicted change in female income"
	label variable xbjoint "\hspace{0.1cm} Predicted change in joint income"

* **********************************************************************
* 3 - second stage - TABLE 7
* *********************************************************************

* male, female, and joint 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads
* consumption aggregates for: food, cigarettes and alcohol, clothing, recreation, education, health, housing and utilities (labeled transpo)

	global aggconsume (dlnconsume_agg xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global foodconsume (dlnconsume_food xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global cigsal (dlnconsume_alctob xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global clothing (dlnconsume_clothfoot xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global recconsume (dlnconsume_rec xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global educconsume (dlnconsume_educ xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)	
	global healthconsume (dlnconsume_health xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global houseconsume (dlnconsume_houseutils xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global transpoconsume (dlnconsume_transpo xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global commconsume (dlnconsume_comm xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global hotresconsume (dlnconsume_hotres xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)
	global miscconsume (dlnconsume_misc xbmale xbfemale xbjoint i.ssa_aez09 i.ssa_aez12)

* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg $aggconsume
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	est store AGCONJ

	reg $foodconsume
	test xbmale xbfemale xbjoint
	est store CONFOJ
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000)  
	suest AGCONJ CONFOJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [CONFOJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CONFOJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CONFOJ_mean]xbjoint)
	
	reg $cigsal
	est store CIGSJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ CIGSJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [CIGSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CIGSJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CIGSJ_mean]xbjoint)
	
	reg $clothing
	est store CLJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ CLJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [CLJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CLJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [CLJ_mean]xbjoint)

	reg $recconsume 
	est store RECJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ RECJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [RECJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [RECJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [RECJ_mean]xbjoint)

	reg $educconsume
	est store EDUCJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ EDUCJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [EDUCJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [EDUCJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [EDUCJ_mean]xbjoint)

	reg $healthconsume 
	est store HEAJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ HEAJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [HEAJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HEAJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [HEAJ_mean]xbjoint)

	reg $houseconsume  
	est store HOUSEJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ HOUSEJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [HOUSEJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HOUSEJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [HOUSEJ_mean]xbjoint)
	
	reg $transpoconsume  
	est store TRANSJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ TRANSJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [TRANSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [TRANSJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [TRANSJ_mean]xbjoint)
		
	reg $commconsume  
	est store COMJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ COMJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [COMJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [COMJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [COMJ_mean]xbjoint)
		
	reg $hotresconsume  
	est store HRESJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ HRESJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [HRESJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HRESJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [HRESJ_mean]xbjoint)
						
	reg $miscconsume  
	est store MISJ
	test xbmale xbfemale xbjoint
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ MISJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [MISJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [MISJ_mean]xbfemale) ([AGCONJ_mean]xbjoint = [MISJ_mean]xbjoint)
					
	
/*	
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ HOUSEJ TRANSJ COMJ HRESJ MISJ using table3.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	
********************************************************************************************

/* END */