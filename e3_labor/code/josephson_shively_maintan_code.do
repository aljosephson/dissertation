* Project: Zimbabwe Labor Shocks 
* Created: August 2020
* Created by: alj
* Last edit: 24 August 2020 
* Stata v.16.1

* does
	* labels and renames as appropriate all variables 

* assumes
	* access to data file "data"

* to do 
	* working ... 
	
**********************************************************************

* read in data
	use				"$fil/data", clear
	

label var rc "respondent code"
label var yearpanel "year panel, 1 = 2004/05, 2 = 2012/13"
label var share_mig "share of household participating in migration activities"
label var share_off "share of household participating in off-farm activities"
label var share_farm "share of household participating in on-farm activities"
label var share_non "share of household participating in no activities"
label var lnshadow_migrant "log of shadow price, migrant wages"
label var lnshadow_offfarm "log of shadow price, off-farm wages"
label var lnshadow_farmlabor "log of shadow price, farm wages"
label var sqlnshadow_migrant "sq of log of shadow price, migrant wages"
label var sqlnshadow_offfarm "sq of log of shadow price, off-farm wages"
label var sqlnshadow_farmlabor "sq of log of shadow price, farm wages"
label var ae "number of adult equivalents in household"
label var hhage "age of head of household"
label var hhage "age of head of household, in years"
label var hhedu "education of head of household, in years"

* save as needed
	save 			"$fil/data", replace
	
**********************************************************************
