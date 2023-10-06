* Project: alj - intrahousehold mgmt of joint resources 
* Created on: ... 2016 
* Edited on: 8 April 2022
* Created by: alj
* Stata v.16

	@@ -16,8 +16,7 @@
	* data_reallocatetest.dta 

* TO DO:
	* done 

* **********************************************************************
* 0 - setup
	@@ -97,7 +96,6 @@ esttab INJMo INJFo using table3_spec_mfo_rain.tex, replace f ///
	local transpoconsumeo (dlnconsume_transpo xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local commconsumeo (dlnconsume_comm xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)
	local hotresconsumeo (dlnconsume_hotres xbmaleo xbfemaleo i.ssa_aez09 i.ssa_aez12)

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
	
esttab AGCONJo CONFOJo CIGSJo CLJo RECJo EDUCJo HEAJo HOUSEJo TRANSJo COMJo HRESJo using table4_spec_mfo.tex, replace f ///
	label booktabs b(3) se(3) eqlabels(none) alignment(S)  ///
	drop(3* _cons) ///
	star(* 0.05 ** 0.01) nogaps ///
	order(xbmaleo xbfemaleo) ///
	stats(F N r2, fmt(3 0 3) layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") labels(`"Overidentification - F-Test"' `"Observations"' `"\(R^{2}\)"'))
	
********************************************************************************************
/* END */