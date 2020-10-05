* Project: Joint Household Resources - Malawi 
* Created: October 2020
* Created by: alj
* Last edit: 5 October 2020
* Stata v.16.1

* does
	* creates all tables from Josephson

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
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\DISE1_Gender\Data - LSMS Malawi" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e1_gender\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e1_gender\logs" 

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
* 3a - male, female, joint specification 
* **********************************************************************

	use				"$fil/data_jointest_16April2020.dta", clear
	
* ************************* FIRST STAGE ***************************

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

*** not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)
*** applies to all tables below 

/*
esttab INJM INJF INJJ using table_sold_mfj_stage1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 
	
* ************************* OVERID TESTS ***************************

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
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_sold_mfj_overid.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/
	*** update code within table to reflect new output location 
	
* **********************************************************************
* 3b - MF specification (omit joint)
* **********************************************************************

	use				"$fil/data_jointest_16April2020.dta", clear
	
* ************************* FIRST STAGE ***************************
	
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* female	
	reg 			$fincome, vce (cluster y2_hhid) 
	test 			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est 			store INJF
	predict 		xbfemale, xb

* male 	
	reg 			$mincome, vce (cluster y2_hhid)
	test 			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est				store INJJ
	predict 		xbmale, xb

/*
esttab INJF INJJ using table_sold_mfomit_firststage.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 
	
* ************************* OVERID TESTS ***************************
	
	global 			aggconsume (dlnconsume_agg xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			foodconsume (dlnconsume_food xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			cigsal (dlnconsume_alctob xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			clothing (dlnconsume_clothfoot xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			recconsume (dlnconsume_rec xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			educconsume (dlnconsume_educ xbmale xbfemale i.agroeczone2010 i.agroeczone2013)	
	global 			healthconsume (dlnconsume_health xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			houseconsume (dlnconsume_houseutils xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
   
* aggregate  
	reg 			$aggconsume
	est 			store AGCONJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	
* food 
	reg 			$foodconsume
	est 			store CONFOJ
	test			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ CONFOJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CONFOJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CONFOJ_mean]xbfemale) 

* cigarettes and alcohol 	
	reg 			$cigsal
	est 			store CIGSJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ CIGSJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CIGSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CIGSJ_mean]xbfemale) 

	reg 			$clothing
	est 			store CLJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ CLJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CLJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CLJ_mean]xbfemale) 

* recreation 	
	reg 			$recconsume 
	est 			store RECJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ RECJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [RECJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [RECJ_mean]xbfemale) 

* education 	
	reg 			$educconsume
	est 			store EDUCJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ EDUCJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [EDUCJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [EDUCJ_mean]xbfemale) 

* health 
	reg 			$healthconsume 
	est 			store HEAJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ HEAJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [HEAJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HEAJ_mean]xbfemale) 

* housing and utilities 	
	reg 			$houseconsume  
	est 			store TRANSJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ TRANSJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [TRANSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [TRANSJ_mean]xbfemale) 

/*
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_mfomit_overidtests.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/		
	*** update code within table to reflect new output location 
	
* **********************************************************************
* 3c -  MF specification (reallocate joint)
* **********************************************************************

	use				"$fil/data_mftest_16April2020.dta", clear
	
* ************************* FIRST STAGE ***************************
	
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* female	
	reg 			$fincome, vce (cluster y2_hhid) 
	test 			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est 			store INJF
	predict 		xbfemale, xb

* male 	
	reg 			$mincome, vce (cluster y2_hhid)
	test 			davg_tot = davg_wetq = davg_wetqstart = dlag1_tot = dlag1_wetq = dlag1_wetqstart = dtot =  dwetq =  dwetqstart 
	est				store INJJ
	predict 		xbmale, xb

/*
esttab INJF INJJ using table_sold_mfreallocate_firststage.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 
	
* ************************* OVERID TESTS ***************************
	
	global 			aggconsume (dlnconsume_agg xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			foodconsume (dlnconsume_food xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			cigsal (dlnconsume_alctob xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			clothing (dlnconsume_clothfoot xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			recconsume (dlnconsume_rec xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			educconsume (dlnconsume_educ xbmale xbfemale i.agroeczone2010 i.agroeczone2013)	
	global 			healthconsume (dlnconsume_health xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			houseconsume (dlnconsume_houseutils xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
   
* aggregate  
	reg 			$aggconsume
	est 			store AGCONJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
	
* food 
	reg 			$foodconsume
	est 			store CONFOJ
	test			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ CONFOJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CONFOJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CONFOJ_mean]xbfemale) 

* cigarettes and alcohol 	
	reg 			$cigsal
	est 			store CIGSJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ CIGSJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CIGSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CIGSJ_mean]xbfemale) 

	reg 			$clothing
	est 			store CLJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ CLJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [CLJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [CLJ_mean]xbfemale) 

* recreation 	
	reg 			$recconsume 
	est 			store RECJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ RECJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [RECJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [RECJ_mean]xbfemale) 

* education 	
	reg 			$educconsume
	est 			store EDUCJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ EDUCJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [EDUCJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [EDUCJ_mean]xbfemale) 

* health 
	reg 			$healthconsume 
	est 			store HEAJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ HEAJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [HEAJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [HEAJ_mean]xbfemale) 

* housing and utilities 	
	reg 			$houseconsume  
	est 			store TRANSJ
	test 			xbmale xbfemale 
	*qui: boottest xbmale 
	*qui: boottest xbfemale 
* test against aggregate 
	suest 			AGCONJ TRANSJ, vce(robust)
	testnl 			([AGCONJ_mean]xbmale = [TRANSJ_mean]xbmale) ([AGCONJ_mean]xbfemale = [TRANSJ_mean]xbfemale) 

/*
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_mfreallocate_overidtests.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/		
	*** update code within table to reflect new output location 

* **********************************************************************
* 3d - matrilineal specification 
* **********************************************************************

* first stage included in appendix
* second stage included in main text 

* **********************************************************************
* 3di - matrilineal == 0  
* **********************************************************************

	use				"$fil/data_mftest_16April2020-matri.dta", clear
	
* ************************* FIRST STAGE ***************************

	global 			jincome (dlnvaluejoint davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* drop matrilineal households
* defined by passage through women 							
	keep 			if matri == 0						

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

/*
esttab INJM INJF INJJ using table_sold_matri0_stage1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 

* ************************* OVERID TESTS ***************************

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
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_sold_matri0_overid.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/
	*** update code within table to reflect new output location 

* **********************************************************************
* 3dii - matrilineal == 1 
* **********************************************************************

	use				"$fil/data_mftest_16April2020-matri.dta", clear
	
* ************************* FIRST STAGE ***************************

	global 			jincome (dlnvaluejoint davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* keep matrilineal households
* defined by passage through women 							
	keep 			if matri == 1						

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

/*
esttab INJM INJF INJJ using table_sold_matri1_stage1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 

* ************************* OVERID TESTS ***************************

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
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_sold_matri1_overid.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/
	*** update code within table to reflect new output location 


* **********************************************************************
* 3e - female headed specification 
* **********************************************************************

* first stage included in appendix
* second stage included in main text 

* **********************************************************************
* 3ei - female headed == 0  
* **********************************************************************

	use				"$fil/data_mftest_16April2020-femhead.dta", clear
	
* ************************* FIRST STAGE ***************************

	global 			jincome (dlnvaluejoint davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* keep male-headed households
	keep 			if femhead == 0						

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


/*
esttab INJM INJF INJJ using table_sold_femhead0_stage1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 

* ************************* OVERID TESTS ***************************

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
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_sold_femhead0_overid.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/
	*** update code within table to reflect new output location 

* **********************************************************************
* 3eii - female headed == 1 
* **********************************************************************

	use				"$fil/data_mftest_16April2020-femhead.dta", clear
	
* ************************* FIRST STAGE ***************************

	global 			jincome (dlnvaluejoint davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			fincome (dlnvaluefemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			mincome (dlnvaluemale davg_tot davg_wetq davg_wetqstart ///
							dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)

* keep female-headed households
	keep 			if femhead == 1					

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


/*
esttab INJM INJF INJJ using table_sold_femhead1_stage1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/
	*** update code within table to reflect new output location 

* ************************* OVERID TESTS ***************************

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
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using table_sold_femhead1_overid.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/
	*** update code within table to reflect new output location 

* **********************************************************************
* 4 - replication of tables: main text - general - all crops 
* **********************************************************************

*** NEED TO DO! 

* **********************************************************************
* 5 - replication of tables: appendix 
* **********************************************************************

* **********************************************************************
* 5a - unrestricted overid (sold crops)
* **********************************************************************

	use				"$fil/data_jointest_16April2020.dta", clear

	global 			aggconsume (dlnconsume_agg davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global 			foodconsume (dlnconsume_food davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013) 
	global 			cigsal (dlnconsume_alctob davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global 			clothing (dlnconsume_clothfoot davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstar  i.agroeczone2010 i.agroeczone2013)
	global 			recconsume (dlnconsume_rec davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global 			educconsume(dlnconsume_educ davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global 			healthconsume (dlnconsume_health davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global 			transpoconsume (dlnconsume_houseutils davg_tot davg_wetq davg_wetqstart ///
						dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)

	reg 			$aggconsume, vce(cluster y2_hhid) 
	est 			store INA
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$foodconsume, vce(cluster y2_hhid)
	est 			store INF
	test			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$cigsal, vce(cluster y2_hhid)
	est 			store INC
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$clothing,  vce(cluster y2_hhid)
	est 			store INCL
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$recconsume,  vce(cluster y2_hhid)
	est 			store INR
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$educconsume,  vce(cluster y2_hhid)
	est 			store INED
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$healthconsume,  vce(cluster y2_hhid)
	est 			store INH
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg 			$transpoconsume, vce(cluster y2_hhid)
	est 			store INT
	test 			davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

/*
esttab INA INF INC INCL INR INED INH INT using table_unconstrainted.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order() ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" ///
	"\multicolumn{1}{c}{@}") labels(`"Joint Significance - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/ 

* **********************************************************************
* 6 - tables and tests not included in text
* **********************************************************************

* **********************************************************************
* 6a - price tests
* **********************************************************************

* only price test in this version differentiates between male and female
* could extent with xbjoint, as appropriate 
* this should build off of a file where xbmale, xbfemale, xbjoint are estimated 

	global 			maize (dlnmaizeprice xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			cloth (dlnclothprice xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			pants (dlnpantsprice xbmale xbfemale xbjoint i.agroeczone2010 i.agroeczone2013)
	global 			cigs (dlncigprice xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			beer (dlnbeerprice xbmale xbfemale i.agroeczone2010 i.agroeczone2013)
	global 			grind (dlngrindprice xbmale xbfemale i.agroeczone2010 i.agroeczone2013)

* maize 	
	reg 			$maize, vce(cluster y2_hhid)
	est 			store MA
	test 			xbmale xbfemale 
	
* clothing 	
	reg 			$cloth, vce(cluster y2_hhid)
	est 			store CHI
	test 			xbmale xbfemale 

* pant, specifically 	
	reg 			$pants,  vce(cluster y2_hhid)
	est 			store PANTS
	test 			xbmale xbfemale 

* cigarettes
	reg 			$cigs, vce(cluster y2_hhid)
	est 			store CIGS
	test 			xbmale xbfemale 

* beer 	
	reg 			$beer, vce(cluster y2_hhid)
	est 			store BEER
	test 			xbmale xbfemale 

* mealie meal (ground maize)	
	reg 			$grind, vce(cluster y2_hhid)
	est 			store GRIND
	test 			xbmale xbfemale 

/*
esttab MA CHI CIGS BEER GRIND using table_price-tests.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") ///
	labels(`"Joint Significance F-Test"' `"Observations"' `"\(R^{2}\)"'))
	*/ 

* *********************************************************************
* 7 - end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	