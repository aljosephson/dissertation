/* BEGIN */

* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 16 February 2022
* Created by: alj
* Stata v.16

* does
	* first stage rainfall estimates for mf specification 
	* second stage overidentification test for for mf specification 
	* considers if matrilineal or not 
	
* assumes
	* reg_ready-final.dta 

* TO DO:
	* anonymize pre-submission 
	* update table numbers with new manuscript numbers  
	
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
	
	keep 			if matril == 0 

* **********************************************************************
* 1a - first stage - NON-MATRILINEAL - OMIT joint income 
* *********************************************************************

* set local for male and female

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


esttab INJMo INJFo using table8_mfspec_o_rain.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order() ///
	stats(r2, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"\(R^{2}\)"'))

	label variable xbmaleo "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemaleo "\hspace{0.1cm} Predicted change in female income"	
	
* **********************************************************************
* 1b - second stage - NON-MATRILINEAL - OMIT joint income
* *********************************************************************

* male and female 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads

	local aggconsumeo (dlnconsume_agg xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local foodconsumeo (dlnconsume_food xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local cigsalo (dlnconsume_alctob xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local clothingo (dlnconsume_clothfoot xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local recconsumeo (dlnconsume_rec xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local educconsumeo (dlnconsume_educ xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)	
	local healthconsumeo (dlnconsume_health xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local houseconsumeo (dlnconsume_houseutils xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local transpoconsumeo (dlnconsume_transpo xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local commconsumeo (dlnconsume_comm xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local hotresconsumeo (dlnconsume_hotres xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
*	local miscconsumeo (dlnconsume_misc xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)

* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg `aggconsumeo'
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	est store AGCONJo

	reg `foodconsumeo'
	test xbmaleo xbfemaleo
	est store CONFOJo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo CONFOJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [CONFOJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [CONFOJo_mean]xbfemaleo) 

	reg `cigsalo'	
	est store CIGSJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo CIGSJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [CIGSJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [CIGSJo_mean]xbfemaleo)
	
	reg `clothingo'
	est store CLJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo CLJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [CLJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [CLJo_mean]xbfemaleo) 

	reg `recconsumeo' 
	est store RECJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJo RECJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [RECJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [RECJo_mean]xbfemaleo) 

	reg `educconsumeo'
	est store EDUCJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJo EDUCJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [EDUCJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [EDUCJo_mean]xbfemaleo) 

	reg `healthconsumeo' 
	est store HEAJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo HEAJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [HEAJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [HEAJo_mean]xbfemaleo) 

	reg `houseconsumeo'  
	est store HOUSEJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo HOUSEJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [HOUSEJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [HOUSEJo_mean]xbfemaleo)
	
	reg `transpoconsumeo'  
	est store TRANSJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo TRANSJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [TRANSJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [TRANSJo_mean]xbfemaleo) 
		
	reg `commconsumeo'  
	est store COMJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo COMJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [COMJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [COMJo_mean]xbfemaleo) 
		
	reg `hotresconsumeo'  
	est store HRESJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo HRESJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [HRESJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [HRESJo_mean]xbfemaleo)
						

esttab AGCONJo CONFOJo CIGSJo CLJo RECJo EDUCJo HEAJo HOUSEJo TRANSJo COMJo HRESJo using table8_mfspec_o.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification Test"' `"Observations"' `"\(R^{2}\)"'))

/*
* **********************************************************************
* 2 - data 
* *********************************************************************
* read in data 

 	use 			"$fil\regression-ready\reg_ready-final", clear	
	
	keep 			if matril == 1
	
* **********************************************************************
* 2a - first stage - MATRILINEAL - OMIT joint income
* *********************************************************************

* set local for male and female

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
esttab INJM INJF INJJ using tableincomematri0_1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order() ///
	stats(r2, fmt(0 3) layout("\multicolumn{1}{c}{@}") labels(`"\(R^{2}\)"'))
*/
	
	label variable xbmaleo "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemaleo "\hspace{0.1cm} Predicted change in female income"
	
* **********************************************************************
* 2b - second stage - MATRILINEAL - OMIT joint income 
* *********************************************************************

* male and female 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads

	local aggconsumeo (dlnconsume_agg xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local foodconsumeo (dlnconsume_food xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local cigsalo (dlnconsume_alctob xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local clothingo (dlnconsume_clothfoot xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local recconsumeo (dlnconsume_rec xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local educconsumeo (dlnconsume_educ xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)	
	local healthconsumeo (dlnconsume_health xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local houseconsumeo (dlnconsume_houseutils xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local transpoconsumeo (dlnconsume_transpo xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local commconsumeo (dlnconsume_comm xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local hotresconsumeo (dlnconsume_hotres xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local miscconsumeo (dlnconsume_misc xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)

* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg `aggconsumeo'
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	est store AGCONJo

	reg `foodconsumeo'
	test xbmaleo xbfemaleo
	est store CONFOJo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo CONFOJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [CONFOJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [CONFOJo_mean]xbfemaleo) 

	reg `cigsalo'	
	est store CIGSJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo CIGSJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [CIGSJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [CIGSJo_mean]xbfemaleo)
	
	reg `clothingo'
	est store CLJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo CLJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [CLJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [CLJo_mean]xbfemaleo) 

	reg `recconsumeo' 
	est store RECJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJo RECJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [RECJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [RECJo_mean]xbfemaleo) 

	reg `educconsumeo'
	est store EDUCJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJo EDUCJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [EDUCJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [EDUCJo_mean]xbfemaleo) 

	reg `healthconsumeo' 
	est store HEAJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo HEAJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [HEAJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [HEAJo_mean]xbfemaleo) 

	reg `houseconsumeo'  
	est store HOUSEJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo HOUSEJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [HOUSEJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [HOUSEJo_mean]xbfemaleo)
	
	reg `transpoconsumeo'  
	est store TRANSJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo TRANSJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [TRANSJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [TRANSJo_mean]xbfemaleo) 
		
	reg `transpoconsumeo'  
	est store COMJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo COMJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [COMJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [COMJo_mean]xbfemaleo) 
		
	reg `transpoconsumeo'  
	est store HRESJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo HRESJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [HRESJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [HRESJo_mean]xbfemaleo)
						
	reg `miscconsumeo'  
	est store MISJo
	test xbmaleo xbfemaleo
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJo MISJo, vce(cluster y2_hhid)
	testnl ([AGCONJo_mean]xbmaleo = [MISJo_mean]xbmaleo) ([AGCONJo_mean]xbfemaleo = [MISJo_mean]xbfemaleo) 
				

/*
esttab AGCONJ CONFOJ CIGSJ CLJ RECJ EDUCJ HEAJ TRANSJ using tableconsumptionmfjmatri0_1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale xbjoint) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/ 


* **********************************************************************
* 3 - REALLOCATE joint income
* *********************************************************************

clear 

* read in data 

 	use 			"$fil\regression-ready\reg_ready-final", replace		
	
	keep 			if matril == 0 

* **********************************************************************
* 3a - first stage 
* *********************************************************************

* set local for male and female

	local fincomer (dlnvaluefemale_rspec dtotalr i.ssa_aez09 i.ssa_aez12)
	local mincomer (dlnvaluemale_rspec dtotalr i.ssa_aez09 i.ssa_aez12)

* reg and F-test
* save estimates and predict xb 

	reg `fincomer', vce (cluster case_id) 
	est store INJFr
	predict xbfemaler, xb
	
	reg `mincomer', vce (cluster case_id)
	est store INJMr
	predict xbmaler, xb

* in paper: not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)

/*
esttab INJMr INJFr using table1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/

	label variable xbmaler "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemaler "\hspace{0.1cm} Predicted change in female income"

	
* **********************************************************************
* 3b - second stage - TABLE XX 
* *********************************************************************

* male and female - REALLOCATE joint 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads

	local aggconsumer (dlnconsume_agg xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local foodconsumer (dlnconsume_food xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local cigsalr (dlnconsume_alctob xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local clothingr (dlnconsume_clothfoot xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local recconsumer (dlnconsume_rec xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local educconsumer (dlnconsume_educ xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)	
	local healthconsumer (dlnconsume_health xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local houseconsumer (dlnconsume_houseutils xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local transpoconsumer (dlnconsume_transpo xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local commconsumer (dlnconsume_comm xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local hotresconsumer (dlnconsume_hotres xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local miscconsumer (dlnconsume_misc xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)

* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg `aggconsumer'
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	est store AGCONJr

	reg `foodconsumer'
	test xbmaler xbfemaler
	est store CONFOJr
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr CONFOJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [CONFOJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [CONFOJr_mean]xbfemaler) 

	reg `cigsalr'	
	est store CIGSJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr CIGSJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [CIGSJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [CIGSJr_mean]xbfemaler)
	
	reg `clothingr'
	est store CLJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr CLJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [CLJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [CLJr_mean]xbfemaler) 

	reg `recconsumer' 
	est store RECJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJr RECJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [RECJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [RECJr_mean]xbfemaler) 

	reg `educconsumer'
	est store EDUCJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJr EDUCJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [EDUCJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [EDUCJr_mean]xbfemaler) 

	reg `healthconsumer' 
	est store HEAJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr HEAJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [HEAJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [HEAJr_mean]xbfemaler) 

	reg `houseconsumer'  
	est store HOUSEJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr HOUSEJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [HOUSEJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [HOUSEJr_mean]xbfemaler)
	
	reg `transpoconsumer'  
	est store TRANSJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr TRANSJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [TRANSJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [TRANSJr_mean]xbfemaler) 
		
	reg `transpoconsumer'  
	est store COMJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr COMJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [COMJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [COMJr_mean]xbfemaler) 
		
	reg `transpoconsumer'  
	est store HRESJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr HRESJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [HRESJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [HRESJr_mean]xbfemaler)
						
	reg `miscconsumer'  
	est store MISJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr MISJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [MISJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [MISJr_mean]xbfemaler) 
	

/*
esttab *** NEED TO UPDATE *** using tableconsumptionmf_1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
*/	



* **********************************************************************
* 4 - REALLOCATE joint income
* *********************************************************************

clear 

* read in data 

 	use 			"$fil\regression-ready\reg_ready-final", replace		
	
	keep 			if matril == 1 

* **********************************************************************
* 4a - first stage 
* *********************************************************************

* set local for male and female

	local fincomer (dlnvaluefemale_rspec dtotalr i.ssa_aez09 i.ssa_aez12)
	local mincomer (dlnvaluemale_rspec dtotalr i.ssa_aez09 i.ssa_aez12)

* reg and F-test
* save estimates and predict xb 

	reg `fincomer', vce (cluster case_id) 
	est store INJFr
	predict xbfemaler, xb
	
	reg `mincomer', vce (cluster case_id)
	est store INJMr
	predict xbmaler, xb

* in paper: not reporting F tests, in line with (https://www.nber.org/econometrics_minicourse_2018/2018si_methods.pdf)

/*
esttab INJMr INJFr using table1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart) ///
	stats(N r2, fmt(0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Observations"' `"\(R^{2}\)"'))
*/

	label variable xbmaler "\hspace{0.1cm} Predicted change in male income"
	label variable xbfemaler "\hspace{0.1cm} Predicted change in female income"

	
* **********************************************************************
* 4b - second stage - TABLE XX 
* *********************************************************************

* male and female - REALLOCATE joint 

* create consmption aggregates - same process as for unrestricted test (Table A1)
* consumption aggregates based on WB aggregates provided in LSMS downloads

	local aggconsumer (dlnconsume_agg xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local foodconsumer (dlnconsume_food xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local cigsalr (dlnconsume_alctob xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local clothingr (dlnconsume_clothfoot xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local recconsumer (dlnconsume_rec xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local educconsumer (dlnconsume_educ xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)	
	local healthconsumer (dlnconsume_health xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local houseconsumer (dlnconsume_houseutils xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local transpoconsumer (dlnconsume_transpo xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local commconsumer (dlnconsume_comm xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local hotresconsumer (dlnconsume_hotres xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)
	local miscconsumer (dlnconsume_misc xbmaler xbfemaler i.ssa_aez09 i.ssa_aez12)

* regressions and wald tests 	
* nl tests: compare specific consumption with aggregate 
  
	reg `aggconsumer'
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	est store AGCONJr

	reg `foodconsumer'
	test xbmaler xbfemaler
	est store CONFOJr
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr CONFOJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [CONFOJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [CONFOJr_mean]xbfemaler) 

	reg `cigsalr'	
	est store CIGSJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr CIGSJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [CIGSJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [CIGSJr_mean]xbfemaler)
	
	reg `clothingr'
	est store CLJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr CLJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [CLJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [CLJr_mean]xbfemaler) 

	reg `recconsumer' 
	est store RECJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJr RECJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [RECJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [RECJr_mean]xbfemaler) 

	reg `educconsumer'
	est store EDUCJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	*qui: boottest xbjoint, reps (10000) 
	suest AGCONJr EDUCJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [EDUCJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [EDUCJr_mean]xbfemaler) 

	reg `healthconsumer' 
	est store HEAJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr HEAJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [HEAJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [HEAJr_mean]xbfemaler) 

	reg `houseconsumer'  
	est store HOUSEJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr HOUSEJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [HOUSEJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [HOUSEJr_mean]xbfemaler)
	
	reg `transpoconsumer'  
	est store TRANSJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr TRANSJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [TRANSJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [TRANSJr_mean]xbfemaler) 
		
	reg `transpoconsumer'  
	est store COMJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr COMJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [COMJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [COMJr_mean]xbfemaler) 
		
	reg `transpoconsumer'  
	est store HRESJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr HRESJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [HRESJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [HRESJr_mean]xbfemaler)
						
	reg `miscconsumer'  
	est store MISJr
	test xbmaler xbfemaler
	*qui: boottest xbmale, reps (10000)  
	*qui: boottest xbfemale, reps (10000)  
	suest AGCONJr MISJr, vce(cluster y2_hhid)
	testnl ([AGCONJr_mean]xbmaler = [MISJr_mean]xbmaler) ([AGCONJr_mean]xbfemaler = [MISJr_mean]xbfemaler) 
	

/*
esttab *** NEED TO UPDATE *** using tableconsumptionmf_1.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order(xbmale xbfemale) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))

********************************************************************************************

/* END */