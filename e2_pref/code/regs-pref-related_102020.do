
* Project: Preferences, Crop Choice - Zimbabwe
* Created: February 2020
* Created by: alj
* Last edit: 20 October 2020
* Stata v.16.1

* does
	* runs all tables reported in Josephson & Ricker-Gilbert  

* assumes
	* access to data file(s) previously created (e.g. hh-crop_21Feb) 

* to do 
	* clean up data files (if sharing)
	* code and data can be made available on github and googledrive 

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_Jan-Feb 2020\Data" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e2_pref\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e2_pref\logs" 

* open log
	cap log 		close
*	log using		"$logs/sorg_regs", append
	
* **********************************************************************
* summary statistics 
* **********************************************************************
	
use "$fil\hh-crop_21Feb.dta", clear
	

*SUMMARY STATS 

tabstat plot_area div_index count_crop, statistics( mean sd p50) by(yearpanel)


*need to break up into smaller sections to compare 

*sorghum
keep if sorghum == 1
tabstat growsorghum staple_plotarea, statistics( mean sd p50) by(yearpanel)

use "$fil\hh-crop_21Feb.dta", clear

*maize
keep if maize == 1
tabstat growmaize staple_plotarea, statistics( mean sd p50) by(yearpanel)

use "$fil\hh-crop_21Feb.dta", clear

*millet 
keep if millet == 1
tabstat growmillet staple_plotarea, statistics( mean sd p50) by(yearpanel)

*return to full sample for rest of variables
use "$fil\hh-crop_21Feb.dta", clear

tabstat head_age head_edu femhead num_cattle plough rec_ext worker offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor, statistics( mean sd p50) by(yearpanel)

tabstat sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 , statistics( mean sd p50) by(yearpanel)

tabstat tot_season shock sd_rain, statistics( mean sd p50) by(yearpanel)


* **********************************************************************
* alt spec  
* **********************************************************************

use "$fil\hh-crop_21Feb.dta", clear
xtset yearpanel 

*diversity index 
*how does diversity, crop portfolio - affected by other elements?

*normal
xtreg div_index sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor ///
Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho, vce(robust)

*CRE
xtreg div_index sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho, vce(robust)

* excluded from final paper
/*
*crop count
*how is growing more crops affected by other elements?

*normal
xtreg count_crop sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor ///
Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho

*CRE
xtreg count_crop sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho
*/

* **********************************************************************
* sorghum 
* **********************************************************************

use "$fil\hh-crop_21Feb.dta", clear
keep if sorghum == 1

*sorghum
global sorg1 (growsorghum sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
global sorg2 (lnstaple_plotarea sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
  
global sorg1m (growsorghum sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
global sorg2m (lnstaple_plotarea sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)

*normal   
craggit $sorg1, sec ($sorg2) vce(robust)
est store sorgmeasure

probit $sorg1, vce(robust)
eststo sorgshortmargins: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post


*CRE
craggit $sorg1m, sec ($sorg2m) vce(robust)
est store sorgmeasurem

*for all variables 
*need to bootstrap these 

*create new log - easier to make tables
* open log
	cap log 		close
	log using		"$logs/sorg_dhape", append

capture program drop myboot
program define myboot, rclass
preserve

craggit $sorg1m, sec ($sorg2m) vce(robust)

predict x2b, eq(Tier2)
predict sigma, eq(sigma)
gen IMR = normalden(x2b/sigma)/normal(x2b/sigma)

gen pe_ss1=_b[sorg_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss1

gen pe_ss2=_b[sorg_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss2

gen pe_ss3=_b[sorg_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss3

gen pe_ms1=_b[maize_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms1

gen pe_ms2=_b[maize_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms2

gen pe_ms3=_b[maize_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms3

gen pe_mis1=_b[millet_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mis1

gen pe_mis2=_b[millet_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms2

gen pe_mis3=_b[millet_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mis3

gen pe_tots=_b[tot_season]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_tots

gen pe_shock=_b[shock]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_shock

gen pe_sdr=_b[sd_rain]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_sdr

gen pe_plota=_b[plot_area]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_plota

gen pe_hage=_b[head_age]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_hage

gen pe_hedu=_b[head_edu]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_hedu 

gen pe_fem=_b[femhead]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_fem 

gen pe_cat=_b[num_cattle]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_cat

gen pe_plough=_b[plough]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_plough 

gen pe_rec=_b[rec_ext]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_rec

gen pe_work=_b[worker]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_work 

gen pe_offl=_b[offfarm_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_offl

gen pe_onf=_b[onfarmfull_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_onf

gen pe_onp=_b[onfarmpart_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_onp

gen pe_mig=_b[migrant_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mig

gen pe_div=_b[div_index]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_div 

sum pe_ss1
return scalar ape1=r(mean)
matrix ape1=r(ape1)

sum pe_ss2
return scalar ape2=r(mean)
matrix ape2=r(ape2)

sum pe_ss3
return scalar ape3=r(mean)
matrix ape3=r(ape3)

sum pe_ms1
return scalar ape4=r(mean)
matrix ape4=r(ape4)

sum pe_ms2
return scalar ape5=r(mean)
matrix ape5=r(ape5)

sum pe_ms3
return scalar ape6=r(mean)
matrix ape6=r(ape6)

sum pe_mis1
return scalar ape7=r(mean)
matrix ape7=r(ape7)

sum pe_mis2
return scalar ape8=r(mean)
matrix ape8=r(ape8)

sum pe_mis3
return scalar ape9=r(mean)
matrix ape9=r(ape9)

sum pe_tots
return scalar ape10=r(mean)
matrix ape10=r(ape10)

sum pe_shock
return scalar ape11=r(mean)
matrix ape11=r(ape11)

sum pe_sdr
return scalar ape12=r(mean)
matrix ape12=r(ape12)

sum pe_plota
return scalar ape13=r(mean)
matrix ape13=r(ape13)

sum pe_hage
return scalar ape14=r(mean)
matrix ape14=r(ape14)

sum pe_hedu
return scalar ape15=r(mean)
matrix ape15=r(ape15)

sum pe_fem 
return scalar ape16=r(mean)
matrix ape16=r(ape16)

sum pe_cat
return scalar ape17=r(mean)
matrix ape17=r(ape17)

sum pe_plough 
return scalar ape18=r(mean)
matrix ape18=r(ape18)

sum pe_rec
return scalar ape19=r(mean)
matrix ape19=r(ape19)

sum pe_work 
return scalar ape20=r(mean)
matrix ape20=r(ape20)

sum pe_offl
return scalar ape21=r(mean)
matrix ape21=r(ape21)

sum pe_onf
return scalar ape22=r(mean)
matrix ape22=r(ape22)

sum pe_onp
return scalar ape23=r(mean)
matrix ape23=r(ape23)

sum pe_mig
return scalar ape24=r(mean)
matrix ape24=r(ape24)

sum pe_div 
return scalar ape25=r(mean)
matrix ape25=r(ape25)

drop pe_ss1 pe_ss2 pe_ss3 pe_ms1 pe_ms2 pe_ms3 pe_mis1 pe_mis2 pe_mis3 pe_tots pe_shock pe_sdr ///
 pe_plota pe_hage pe_hedu pe_fem pe_cat pe_plough pe_rec pe_work pe_offl pe_onf pe_onp pe_mig pe_div 


restore
end 


bootstrap sorg_staple1=r(ape1) sorg_staple2=r(ape2) sorg_staple3=r(ape3) maize_staple1=r(ape4) maize_staple2=r(ape5) maize_staple3=r(ape6) /// 
millet_staple1=r(ape7) millet_stape2=r(ape8) millet_staple3=r(ape9) tot_season=r(ape10) shock=r(ape11) sd_rain=r(ape12) plot_area=r(ape13) head_age=r(ape14) head_edu=r(ape15) ///
femhead=r(ape16) num_cattle=r(ape17) plough=r(ape18) rec_ext=r(ape19) worker=r(ape20) offfarm_labor=r(ape21) onfarmfull_labor=r(ape22) onfarmpart_labor=r(ape23) ///
migrant_labor=r(ape24) div_index=r(ape25), reps(1000) seed(123) cluster(rc) : myboot

log close 

probit $sorg1m, vce(robust)
eststo sorgshortmarginsm: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post

*tobit 
*tobit $sorg1 
*est store sorgtobit

tobit $sorg1m, vce(robust)
est store sorgtobitm

*compare CRE to tobit 
lrtest sorgmeasurem sorgtobitm, force

* **********************************************************************
* maize
* **********************************************************************

use "$fil\hh-crop_21Feb.dta", clear
keep if maize == 1

*maize
*normal
global maize1 (growmaize sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
global maize2 (lnstaple_plotarea sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)

*CRE
global maize1m (growmaize sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
global maize2m (lnstaple_plotarea sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)


*normal   
craggit $maize1, sec ($maize2) vce(robust)
est store maizemeasure

probit $maize1, vce(robust)
eststo maizeshortmargins: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post

*CRE
craggit $maize1m, sec ($maize2m) vce(robust)
est store maizemeasurem

*create new log - easier to make tables
* open log
	cap log 		close
	log using		"$logs/maize_dhape", append

capture program drop myboot
program define myboot, rclass
preserve

craggit $maize1m, sec ($maize2m) vce(robust)

predict x2b, eq(Tier2)
predict sigma, eq(sigma)
gen IMR = normalden(x2b/sigma)/normal(x2b/sigma)

gen pe_ss1=_b[sorg_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss1

gen pe_ss2=_b[sorg_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss2

gen pe_ss3=_b[sorg_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss3

gen pe_ms1=_b[maize_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms1

gen pe_ms2=_b[maize_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms2

gen pe_ms3=_b[maize_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms3

gen pe_mis1=_b[millet_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mis1

gen pe_mis2=_b[millet_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms2

gen pe_mis3=_b[millet_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mis3

gen pe_tots=_b[tot_season]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_tots

gen pe_shock=_b[shock]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_shock

gen pe_sdr=_b[sd_rain]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_sdr

gen pe_plota=_b[plot_area]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_plota

gen pe_hage=_b[head_age]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_hage

gen pe_hedu=_b[head_edu]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_hedu 

gen pe_fem=_b[femhead]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_fem 

gen pe_cat=_b[num_cattle]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_cat

gen pe_plough=_b[plough]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_plough 

gen pe_rec=_b[rec_ext]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_rec

gen pe_work=_b[worker]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_work 

gen pe_offl=_b[offfarm_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_offl

gen pe_onf=_b[onfarmfull_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_onf

gen pe_onp=_b[onfarmpart_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_onp

gen pe_mig=_b[migrant_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mig

gen pe_div=_b[div_index]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_div 

sum pe_ss1
return scalar ape1=r(mean)
matrix ape1=r(ape1)

sum pe_ss2
return scalar ape2=r(mean)
matrix ape2=r(ape2)

sum pe_ss3
return scalar ape3=r(mean)
matrix ape3=r(ape3)

sum pe_ms1
return scalar ape4=r(mean)
matrix ape4=r(ape4)

sum pe_ms2
return scalar ape5=r(mean)
matrix ape5=r(ape5)

sum pe_ms3
return scalar ape6=r(mean)
matrix ape6=r(ape6)

sum pe_mis1
return scalar ape7=r(mean)
matrix ape7=r(ape7)

sum pe_mis2
return scalar ape8=r(mean)
matrix ape8=r(ape8)

sum pe_mis3
return scalar ape9=r(mean)
matrix ape9=r(ape9)

sum pe_tots
return scalar ape10=r(mean)
matrix ape10=r(ape10)

sum pe_shock
return scalar ape11=r(mean)
matrix ape11=r(ape11)

sum pe_sdr
return scalar ape12=r(mean)
matrix ape12=r(ape12)

sum pe_plota
return scalar ape13=r(mean)
matrix ape13=r(ape13)

sum pe_hage
return scalar ape14=r(mean)
matrix ape14=r(ape14)

sum pe_hedu
return scalar ape15=r(mean)
matrix ape15=r(ape15)

sum pe_fem 
return scalar ape16=r(mean)
matrix ape16=r(ape16)

sum pe_cat
return scalar ape17=r(mean)
matrix ape17=r(ape17)

sum pe_plough 
return scalar ape18=r(mean)
matrix ape18=r(ape18)

sum pe_rec
return scalar ape19=r(mean)
matrix ape19=r(ape19)

sum pe_work 
return scalar ape20=r(mean)
matrix ape20=r(ape20)

sum pe_offl
return scalar ape21=r(mean)
matrix ape21=r(ape21)

sum pe_onf
return scalar ape22=r(mean)
matrix ape22=r(ape22)

sum pe_onp
return scalar ape23=r(mean)
matrix ape23=r(ape23)

sum pe_mig
return scalar ape24=r(mean)
matrix ape24=r(ape24)

sum pe_div 
return scalar ape25=r(mean)
matrix ape25=r(ape25)

drop pe_ss1 pe_ss2 pe_ss3 pe_ms1 pe_ms2 pe_ms3 pe_mis1 pe_mis2 pe_mis3 pe_tots pe_shock pe_sdr ///
 pe_plota pe_hage pe_hedu pe_fem pe_cat pe_plough pe_rec pe_work pe_offl pe_onf pe_onp pe_mig pe_div 


restore
end 


bootstrap sorg_staple1=r(ape1) sorg_staple2=r(ape2) sorg_staple3=r(ape3) maize_staple1=r(ape4) maize_staple2=r(ape5) maize_staple3=r(ape6) /// 
millet_staple1=r(ape7) millet_stape2=r(ape8) millet_staple3=r(ape9) tot_season=r(ape10) shock=r(ape11) sd_rain=r(ape12) plot_area=r(ape13) head_age=r(ape14) head_edu=r(ape15) ///
femhead=r(ape16) num_cattle=r(ape17) plough=r(ape18) rec_ext=r(ape19) worker=r(ape20) offfarm_labor=r(ape21) onfarmfull_labor=r(ape22) onfarmpart_labor=r(ape23) ///
migrant_labor=r(ape24) div_index=r(ape25), reps(1000) seed(123) cluster(rc) : myboot

log close 

probit $maize1m, vce(robust)
eststo maizeshortmarginsm: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post

*tobit 
*tobit $maize1 
*est store maizetobit

tobit $maize1m, vce(robust)
est store maizetobitm

*compare CRE to tobit 
lrtest maizemeasurem maizetobitm, force

* **********************************************************************
* millet 
* **********************************************************************

use "$fil\hh-crop_21Feb.dta", clear
*even fewer households grow millet ... 
*having issues converging with dh 

keep if millet == 1

*millet
*normal 
global millet1 (growmillet sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
global millet2 (lnstaple_plotarea sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
  
*CRE
global millet1m (growmillet sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
global millet2m (lnstaple_plotarea sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index ///
mtot_season mshock msd_rain mplot_area mhead_age mhead_edu mfemhead mnum_cattle mplough mrec_ext mworker /// 
mofffarm_labor monfarmfull_labor monfarmpart_labor mmigrant_labor ///
  Chivi Zaka Gwanda Bulilima Binga Nkayi Tsholotsho year2)
  

*craggit $millet1, sec ($millet2) vce(robust)
*est store milletmeasure 

*not strictly correct, but can do it independently for whatever reason 

probit $millet1, vce(robust)
eststo milletshortmargins: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post
est store milletprobit1

drop if staple_plotarea == 0 
reg $millet2, vce(robust)
est store millet2

use "$fil\hh-crop_21Feb.dta", clear
keep if millet == 1

probit $millet1m, vce(robust)
eststo milletshortmarginsm: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post
est store milletprobitm1

drop if staple_plotarea == 0 
reg $millet2m, vce(robust)
est store millet2m

*create new log - easier to make tables
* open log
	cap log 		close
	log using		"$logs/millet_dhape", append


capture program drop myboot
program define myboot, rclass
preserve

reg $millet2m, vce(robust)

predict x2b, xb
predict sigma, eq(sigma)
gen IMR = normalden(x2b/sigma)/normal(x2b/sigma)

gen pe_ss1=_b[sorg_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss1

gen pe_ss2=_b[sorg_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss2

gen pe_ss3=_b[sorg_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ss3

gen pe_ms1=_b[maize_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms1

gen pe_ms2=_b[maize_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms2

gen pe_ms3=_b[maize_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms3

gen pe_mis1=_b[millet_staple1]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mis1

gen pe_mis2=_b[millet_staple2]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_ms2

gen pe_mis3=_b[millet_staple3]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mis3

gen pe_tots=_b[tot_season]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_tots

gen pe_shock=_b[shock]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_shock

gen pe_sdr=_b[sd_rain]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_sdr

gen pe_plota=_b[plot_area]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_plota

gen pe_hage=_b[head_age]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_hage

gen pe_hedu=_b[head_edu]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_hedu 

gen pe_fem=_b[femhead]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_fem 

gen pe_cat=_b[num_cattle]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_cat

gen pe_plough=_b[plough]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_plough 

gen pe_rec=_b[rec_ext]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_rec

gen pe_work=_b[worker]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_work 

gen pe_offl=_b[offfarm_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_offl

gen pe_onf=_b[onfarmfull_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_onf

gen pe_onp=_b[onfarmpart_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_onp

gen pe_mig=_b[migrant_labor]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_mig

gen pe_div=_b[div_index]*((1-(normalden(x2b/sigma)/normal(x2b/sigma))*(x2b/sigma+(normalden(x2b/sigma)/normal(x2b/sigma)))))
sum pe_div 

sum pe_ss1
return scalar ape1=r(mean)
matrix ape1=r(ape1)

sum pe_ss2
return scalar ape2=r(mean)
matrix ape2=r(ape2)

sum pe_ss3
return scalar ape3=r(mean)
matrix ape3=r(ape3)

sum pe_ms1
return scalar ape4=r(mean)
matrix ape4=r(ape4)

sum pe_ms2
return scalar ape5=r(mean)
matrix ape5=r(ape5)

sum pe_ms3
return scalar ape6=r(mean)
matrix ape6=r(ape6)

sum pe_mis1
return scalar ape7=r(mean)
matrix ape7=r(ape7)

sum pe_mis2
return scalar ape8=r(mean)
matrix ape8=r(ape8)

sum pe_mis3
return scalar ape9=r(mean)
matrix ape9=r(ape9)

sum pe_tots
return scalar ape10=r(mean)
matrix ape10=r(ape10)

sum pe_shock
return scalar ape11=r(mean)
matrix ape11=r(ape11)

sum pe_sdr
return scalar ape12=r(mean)
matrix ape12=r(ape12)

sum pe_plota
return scalar ape13=r(mean)
matrix ape13=r(ape13)

sum pe_hage
return scalar ape14=r(mean)
matrix ape14=r(ape14)

sum pe_hedu
return scalar ape15=r(mean)
matrix ape15=r(ape15)

sum pe_fem 
return scalar ape16=r(mean)
matrix ape16=r(ape16)

sum pe_cat
return scalar ape17=r(mean)
matrix ape17=r(ape17)

sum pe_plough 
return scalar ape18=r(mean)
matrix ape18=r(ape18)

sum pe_rec
return scalar ape19=r(mean)
matrix ape19=r(ape19)

sum pe_work 
return scalar ape20=r(mean)
matrix ape20=r(ape20)

sum pe_offl
return scalar ape21=r(mean)
matrix ape21=r(ape21)

sum pe_onf
return scalar ape22=r(mean)
matrix ape22=r(ape22)

sum pe_onp
return scalar ape23=r(mean)
matrix ape23=r(ape23)

sum pe_mig
return scalar ape24=r(mean)
matrix ape24=r(ape24)

sum pe_div 
return scalar ape25=r(mean)
matrix ape25=r(ape25)

drop pe_ss1 pe_ss2 pe_ss3 pe_ms1 pe_ms2 pe_ms3 pe_mis1 pe_mis2 pe_mis3 pe_tots pe_shock pe_sdr ///
 pe_plota pe_hage pe_hedu pe_fem pe_cat pe_plough pe_rec pe_work pe_offl pe_onf pe_onp pe_mig pe_div 


restore
end 


bootstrap sorg_staple1=r(ape1) sorg_staple2=r(ape2) sorg_staple3=r(ape3) maize_staple1=r(ape4) maize_staple2=r(ape5) maize_staple3=r(ape6) /// 
millet_staple1=r(ape7) millet_stape2=r(ape8) millet_staple3=r(ape9) tot_season=r(ape10) shock=r(ape11) sd_rain=r(ape12) plot_area=r(ape13) head_age=r(ape14) head_edu=r(ape15) ///
femhead=r(ape16) num_cattle=r(ape17) plough=r(ape18) rec_ext=r(ape19) worker=r(ape20) offfarm_labor=r(ape21) onfarmfull_labor=r(ape22) onfarmpart_labor=r(ape23) ///
migrant_labor=r(ape24) div_index=r(ape25), reps(1000) seed(123) cluster(rc) : myboot

log close 

*tobit 

use "$fil\hh-crop_21Feb.dta", clear
keep if millet == 1

*tobit $millet1 
*est store millettobit

tobit $millet1m, vce(robust)
est store millettobitm

lrtest millet2m millettobitm, force

* *********************************************************************
* end matter
* **********************************************************************

compress
describe
summarize 

* close the log
	log	close	