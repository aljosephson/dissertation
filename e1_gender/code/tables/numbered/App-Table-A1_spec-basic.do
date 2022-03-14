/* BEGIN */

* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 14 March 2022
* Created by: alj
* Stata v.16

* does
	* "unrestricted" overidentification test
	* corresponds with table A1 
	
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
	
* **********************************************************************
* 2 - create consumption lcoals  
* *********************************************************************

* create consmption aggregates 
* consumption aggregates based on WB aggregates provided in LSMS downloads

	local aggconsume (dlnconsume_agg dtotalr i.ssa_aez09 i.ssa_aez12)
	local foodconsume (dlnconsume_food dtotalr i.ssa_aez09 i.ssa_aez12)
	local cigsal (dlnconsume_alctob dtotalr i.ssa_aez09 i.ssa_aez12)
	local clothing (dlnconsume_clothfoot dtotalr i.ssa_aez09 i.ssa_aez12)
	local recconsume (dlnconsume_rec dtotalr i.ssa_aez09 i.ssa_aez12)
	local educconsume (dlnconsume_educ dtotalr i.ssa_aez09 i.ssa_aez12)	
	local healthconsume (dlnconsume_health dtotalr i.ssa_aez09 i.ssa_aez12)
	local houseconsume (dlnconsume_houseutils dtotalr i.ssa_aez09 i.ssa_aez12)
	local transpoconsume (dlnconsume_transpo dtotalr i.ssa_aez09 i.ssa_aez12)
	local commconsume (dlnconsume_comm dtotalr i.ssa_aez09 i.ssa_aez12)
	local hotresconsume (dlnconsume_hotres dtotalr i.ssa_aez09 i.ssa_aez12)
*	local miscconsume (dlnconsume_misc dtotalr i.ssa_aez09 i.ssa_aez12)
		
* **********************************************************************
* 3 - unrestricted regressions 
* *********************************************************************

	reg `aggconsume', vce(cluster case_id) 
	est store INA

	reg `foodconsume', vce(cluster case_id) 
	est store INF

	reg `cigsal', vce(cluster case_id)
	est store INC

	reg `clothing',  vce(cluster case_id)
	est store INCL

	reg `recconsume',  vce(cluster case_id)
	est store INR

	reg `educconsume',  vce(cluster case_id)
	est store INED

	reg `healthconsume',  vce(cluster case_id)
	est store INH

	reg `houseconsume', vce(cluster case_id)
	est store INT
	
	reg `transpoconsume', vce(cluster case_id)
	est store ITS
	
	reg `commconsume', vce(cluster case_id)
	est store ICC 
	
	reg `hotresconsume', vce(cluster case_id)
	est store IHR
	
esttab INA INF INC INCL INR INED INH INT ITS ICC IHR using app_a1.tex, replace f ///
	label booktabs b(5) se(5) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.05 ** 0.01) nogaps ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))

********************************************************************************************

/* END */