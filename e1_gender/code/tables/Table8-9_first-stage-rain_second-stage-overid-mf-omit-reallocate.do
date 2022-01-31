/* BEGIN */

********************************************************************************************

* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 31 January 2022
* Created by: alj
* Stata v.16

* does
	* first stage rainfall estimates for OMIT joint income & REALLOCATE joint income 
	* second stage overidentification test for male, female for OMIT joint income  & REALLOCATE joint income 
	* corresponds with tables 8 and 9 - panel 1 (OMIT), panel 2 (REALLOCATE)
	
* assumes
	* data_jointtest.dta 
	* data_reallocatetest.dta 

* TO DO:
	* anonymize pre-submission 
	* update table numbers with new manuscript numbers 
	* mht ?? 

	
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
* 2 - OMIT joint income
* *********************************************************************

* **********************************************************************
* 2a - first stage - OMIT joint income 
* *********************************************************************

* set globals for male and female

	local fincomeo (dlnvaluefemale_ospec dtotalr i.ssa_aez09 i.ssa_aez12)
	local mincomeo (dlnvaluemale_ospec dtotalr i.ssa_aez09 i.ssa_aez12)

* reg and F-test
* save estimates and predict xb 

	reg `fincomeo', vce (cluster case_id) 
	est store INJFo
	predict xbfemaleo, xb
	
	reg `mincomeo', vce (cluster case_id)
	est store INJMo
	predict xbmaleo, xb

* in paper: not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)


/*
esttab INJM INJF INJJ using table1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/

	label variable xbmaleo "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemaleo "\hspace{0.1cm} Predicted change in female income"

* **********************************************************************
* 2b - second stage - TABLE XX
* *********************************************************************

* male and female 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads

	local aggconsume (dlnconsume_agg xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local foodconsume (dlnconsume_food xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local cigsal (dlnconsume_alctob xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local clothing (dlnconsume_clothfoot xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local recconsume (dlnconsume_rec xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local educconsume (dlnconsume_educ xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)	
	local healthconsume (dlnconsume_health xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local houseconsume (dlnconsume_houseutils xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local transpoconsume (dlnconsume_transpo xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local commconsume (dlnconsume_comm xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local hotresconsume (dlnconsume_hotres xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local miscconsume (dlnconsume_misc xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)

* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg `aggconsume'
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	est store AGCONJ

	reg `foodconsume'
	test xbmaleo xbfemaleo
	est store CONFOJ
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ CONFOJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [CONFOJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [CONFOJ_mean]xbfemaleo) 

	reg `cigsal'	
	est store CIGSJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ CIGSJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [CIGSJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [CIGSJ_mean]xbfemaleo)
	
	reg `clothing'
	est store CLJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ CLJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [CLJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [CLJ_mean]xbfemaleo) 

	reg `recconsume' 
	est store RECJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ RECJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [RECJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [RECJ_mean]xbfemaleo) 

	reg `educconsume'
	est store EDUCJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJ EDUCJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [EDUCJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [EDUCJ_mean]xbfemaleo) 

	reg `healthconsume' 
	est store HEAJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ HEAJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [HEAJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [HEAJ_mean]xbfemaleo) 

	reg `houseconsume'  
	est store HOUSEJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ HOUSEJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [HOUSEJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [HOUSEJ_mean]xbfemaleo)
	
	reg `transpoconsume'  
	est store TRANSJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ TRANSJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [TRANSJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [TRANSJ_mean]xbfemaleo) 
		
	reg `transpoconsume'  
	est store COMJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ COMJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [COMJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [COMJ_mean]xbfemaleo) 
		
	reg `transpoconsume'  
	est store HRESJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ HRESJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [HRESJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [HRESJ_mean]xbfemaleo)
						
	reg `miscconsume'  
	est store MISJ
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJ MISJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmaleo = [MISJ_mean]xbmaleo) ([AGCONJ_mean]xbfemaleo = [MISJ_mean]xbfemaleo) 
					
	
/*
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table3.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/	

* **********************************************************************
* 4 - data - REALLOCATE joint income
* *********************************************************************

* read in data 

	use "C:\Users\aljosephson\Dropbox\Out for Review\DISE1_Gender\Data - LSMS Malawi\data_reallocatetest.dta", clear

* **********************************************************************
* 5 - first stage - REALLOCATE joint income 
* *********************************************************************

	global fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart   i.agroeczone2010 i.agroeczone2013)
	global mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)

* male, female 

	reg $fincome, vce (cluster y2_hhid) 
	est store INJF 
	test davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	predict xbfemale, xb

	reg $mincome, vce (cluster y2_hhid)
	est store INJJ
	test davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	predict xbmale, xb

*not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)

/*
esttab INJF INJJ using tableincomemf_1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order() ///
	stats(r2, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"\(R^{2}\)"'))
*/
	
	label variable xbmale "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemale "\hspace{0.1cm} Predicted change in female income"

********************************************************************************************	


* **********************************************************************
* 6 - second stage - REALLOCATE joint income 
* *********************************************************************

* male and female - REALLOCATE joint 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads
* consumption aggregates for: food, cigarettes and alcohol, clothing, recreation, education, health, housing and utilities (labeled transpo)

	global aggconsume (dlnconsume_agg xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global foodconsume (dlnconsume_food xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global cigsal (dlnconsume_alctob xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global clothing (dlnconsume_clothfoot xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global recconsume (dlnconsume_rec xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global educconsume (dlnconsume_educ xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global healthconsume (dlnconsume_health xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global houseconsume (dlnconsume_houseutils xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
   
* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg $aggconsume
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	est store AGCONJ

	reg $foodconsume
	test xbmale xbfemale 
	est store CONFOJ
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ CONFOJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [CONFOJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CONFOJ_mean]xbfemale) 
	
	reg $cigsal
	est store CIGSJ
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ CIGSJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [CIGSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CIGSJ_mean]xbfemale) 
	
	reg $clothing
	est store CLJ
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ CLJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [CLJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CLJ_mean]xbfemale)

	reg $recconsume 
	est store RECJ
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ RECJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [RECJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [RECJ_mean]xbfemale) 

	reg $educconsume
	est store EDUCJ
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ EDUCJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [EDUCJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [EDUCJ_mean]xbfemale) 

	reg $healthconsume 
	est store HEAJ
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ HEAJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [HEAJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HEAJ_mean]xbfemale) 

	reg $houseconsume  
	est store TRANSJ
	test xbmale xbfemale 
	qui: boottest xbmale, reps (10000)  
	qui: boottest xbfemale, reps (10000)  
	suest AGCONJ TRANSJ, vce(cluster y2_hhid)
	testnl ([AGCONJ_mean]xbmale = [TRANSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [TRANSJ_mean]xbfemale) 

/*
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using tableconsumptionmf_1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/	

********************************************************************************************

/* END */