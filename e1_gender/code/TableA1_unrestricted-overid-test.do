* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 23 August 2021
* Created by: alj
* Stata v.16

* does
	* "unrestricted" overidentification test
	* corresponds with table A1 
	
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
* 2 - create consumption globals  
* *********************************************************************

* consumption aggregates based on WB aggregates provided in LSMS downloads
* consumption aggregates for: food, cigarettes and alcohol, clothing, recreation, education, health, housing and utilities (labeled transpo)

	global aggconsume (dlnconsume_agg davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq ///
		dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global foodconsume (dlnconsume_food davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq ///
		dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013) 
	global cigsal (dlnconsume_alctob davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq ///
		dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global clothing (dlnconsume_clothfoot davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq ///
		dlag1_wetqstart dtot dwetq dwetqstar  i.agroeczone2010 i.agroeczone2013)
	global recconsume (dlnconsume_rec davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq ///
		dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)	
	global educconsume(dlnconsume_educ davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq ///
		dlag1_wetqstart dtot dwetq dwetqstart i.agroeczone2010 i.agroeczone2013)
	global healthconsume (dlnconsume_health davg_tot davg_wetq davg_wetqstart dlag1_tot ///
		dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
	global transpoconsume (dlnconsume_houseutils davg_tot davg_wetq davg_wetqstart dlag1_tot ///
		dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart  i.agroeczone2010 i.agroeczone2013)
		
* **********************************************************************
* 3 - unrestricted regressions 
* *********************************************************************

	reg $aggconsume, vce(cluster y2_hhid) 
	est store INA
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $foodconsume, vce(cluster y2_hhid)
	est store INF
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $cigsal, vce(cluster y2_hhid)
	est store INC
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $clothing,  vce(cluster y2_hhid)
	est store INCL
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $recconsume,  vce(cluster y2_hhid)
	est store INR
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $educconsume,  vce(cluster y2_hhid)
	est store INED
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $healthconsume,  vce(cluster y2_hhid)
	est store INH
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

	reg $transpoconsume, vce(cluster y2_hhid)
	est store INT
	test davg_tot davg_wetq davg_wetqstart dlag1_tot dlag1_wetq dlag1_wetqstart dtot dwetq dwetqstart 

* **********************************************************************
* 4 - graph export   
* *********************************************************************

esttab INA INF INC INCL INR INED INH INT using table_unconstrainted.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.10 ** 0.05 *** 0.01) nogaps ///
	order() ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Joint Significance - F-Test"' `"Observations"' `"\(R^{2}\)"'))

********************************************************************************************

/* END */