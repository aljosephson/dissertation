* Project: Zimbabwe Labor Shocks 
* Created: August 2020
* Created by: alj
* Last edit: 15 September 2020 
* Stata v.16.1

* does
	* labels and renames as appropriate all variables 

* assumes
	* access to data file "data"

* to do 
	* done 
	
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
label var multiple_mig "=1 if multiple migrants in household, =0 otherwise"
label var multiple_off "=1 if multiple off-farm labor participants in household, =0 otherwise"
label var dist_VicFalls "distance (km) to Victoria Falls"
label var dist_Mutare "distance (km) to Mutare"
label var dist_Beitbridge "distance (km) to Beitbridge"
label var dist_Plumtree "distance (km) to Plumtree"
label var femhead "=1 if head of household is woman, =0 otherwise"
label var workdeath "idio shock1: experience death of houeshold member 5-65"
label var commworkdeath "cov shock1: community ratio of death experience"
label var shocktotal "cov shock2: measured rainfall shock"
label var yearbin "=1 if yearpanel == 2, =0 otherwise"
label var did_workdeathyr "diff. int. of workdeath and yearbin"
label var did_comworkdeathyr "diff. int. of commworkdeath and yearbin"
label var did_shockyr "diff. int. of shocktotal and yearbin"
label var pershock "cov shock3: perceived rainfall shock"
label var plough "=1 if own plough, =0 otherwise"
label var own_cattle "=1 if own cattle, =0 otherwise"
label var area "total landholding area (ha)"
label var migrant_internat "=1 if hh has international migrants, =0 otherwise"
label var migrant_dom "=1 if hh has domestic migrants, =0 otherwise"
label var formal "=1 if hh participates in formal labor market, =0 otherwise"
label var informal "=1 if hh participates in informal labor market, =0 otherwise"
label var comm_migrantratio "ratio of migrants from the community"
label var no_offfarm "number of off-farm labor participants"
label var comm_offfarm "ratio of off-farm participation from the community"
label var free_seed "=1 if hh got free seed, =0 otherwise"
label var intercrop "=1 if intercrop, =0 if otherwise"
label var mplough "time average of plough ownership"
label var mfemhead "time average female headed houeshold"
label var mmigrant_internat "time average of international migrant"
label var mmigrant_dom "time average of domestic migrant"
label var mae "time average of adult equivalents"
label var mhhage "time average of household head age"
label var mhhedu "time average of head of household education"
label var did_pershock "diff. int. of perceived shock and yearbin"
label var pershockint "interaction of shocktotal and perceived shock"
label var did_pershockint "diff. int. of perceived shock, shocktotal, and yearbin"
label var shadow_farmlabor "shadow value of farm labor"
label var shadow_migrant "shadow value of migrant labor"
label var shadow_offfarm "shadow value of off-farm labor"
label var mshadow_farmlabor "time average of farm labor shadow value"
label var mshadow_migrant "time average of migrant labor shadow value"
label var mshadow_offfarm "time average of off-farm labor shadow value"
label var lnwage_farm "log of farm wages"
label var lnwage_offfarm "log of off-farm wages"
label var lnwage_mig "log of migration wages"
label var sqlnwage_farm "sq of log of farm wages"
label var sqlnwage_offfarm "sq of log of off-farm wages"
label var sqlnwage_mig "sq of log of migrant wages"

* save as needed
	save 			"$fil/data", replace
	
**********************************************************************
