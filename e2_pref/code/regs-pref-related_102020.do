
****************************************************************************************************************************************
****************************************************************************************************************************************

*REGRESSIONS
*ANALYSIS
*DOUBLE HURDLE
*MAIZE AND SORGHUM AND MILLET AND DIVERSITY/CROP COUNT

*SORGHUM
*FEBRUARY 2020
*alj

****************************************************************************************************************************************
****************************************************************************************************************************************

*SUMMARY STATS 

tabstat plot_area div_index count_crop, statistics( mean sd p50) by(yearpanel)


*need to break up into smaller sections to compare 

*sorghum
keep if sorghum == 1
tabstat growsorghum staple_plotarea, statistics( mean sd p50) by(yearpanel)

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear

*maize
keep if maize == 1
tabstat growmaize staple_plotarea, statistics( mean sd p50) by(yearpanel)

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear

*millet 
keep if millet == 1
tabstat growmillet staple_plotarea, statistics( mean sd p50) by(yearpanel)

*return to full sample for rest of variables
use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear

tabstat head_age head_edu femhead num_cattle plough rec_ext worker offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor, statistics( mean sd p50) by(yearpanel)

tabstat sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 , statistics( mean sd p50) by(yearpanel)

tabstat tot_season shock sd_rain, statistics( mean sd p50) by(yearpanel)


****************************************************************************************************************************************
****************************************************************************************************************************************


use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear
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


****************************************************************************************************************************************
****************************************************************************************************************************************

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_Jan-Feb 2020\Data\hh-crop_21Feb.dta", clear
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
eststo sorgshortmargins: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3  millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post

probit $sorg1, vce(robust)
eststo sorgshortmargins: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post

*CRE
craggit $sorg1m, sec ($sorg2m) vce(robust)
est store sorgmeasurem

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

****************************************************************************************************************************************
****************************************************************************************************************************************

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear
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

****************************************************************************************************************************************
****************************************************************************************************************************************

*even fewer households grow millet ... 
*having issues converging with dh 

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear
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

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear
keep if millet == 1

probit $millet1m, vce(robust)
eststo milletshortmarginsm: margins, dydx(sorg_staple1 sorg_staple2 sorg_staple3 maize_staple1 maize_staple2 maize_staple3 millet_staple1 millet_staple2 millet_staple3 ///
tot_season shock sd_rain plot_area head_age head_edu femhead num_cattle plough rec_ext worker /// 
offfarm_labor onfarmfull_labor onfarmpart_labor migrant_labor div_index) post
est store milletprobitm1

drop if staple_plotarea == 0 
reg $millet2m, vce(robust)
est store millet2m

*tobit 

use "C:\Users\aljosephson\Dropbox\Out for Review\DISE2_Sorghum\_January 2020\Data\hh-crop_5Feb.dta", clear
keep if millet == 1

*tobit $millet1 
*est store millettobit

tobit $millet1m, vce(robust)
est store millettobitm

lrtest millet2m millettobitm, force

****************************************************************************************************************************************
****************************************************************************************************************************************
