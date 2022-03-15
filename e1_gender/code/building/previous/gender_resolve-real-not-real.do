/* BEGIN */

********************************************************************************************

* Project: alj - intrahousehold mgmt of joint resources 
* Created on: 20 September 2021
* Edited on: 20 September 2021
* Created by: alj
* Stata v.16

* does
	* examines file -0 (old file) compared to no suffix (new file)
	* try to resolve differences observed in figures 
	
* assumes
	* data_jointtest.dta 
	* data_jointtest-0.dta

* TO DO:
	* none 
	
* **********************************************************************
* 1 - read in data 
* **********************************************************************
clear 

* read in data 

	*use "C:\Users\aljosephson\Dropbox\Out for Review\DISE1_Gender\Data - LSMS Malawi\data_jointtest-O.dta", clear 
	*** corresponds with not real 
	
	*use "C:\Users\aljosephson\Dropbox\Out for Review\DISE1_Gender\Data - LSMS Malawi\data_jointtest.dta", clear 
	*** corresponds with real and test 
	
* **********************************************************************
* 2 - log transform + difference 
* **********************************************************************

* with real 
	gen lnvaluejoint2010 = asinh(valuejoint2010)
	gen lnvaluejoint2013 = asinh(valuejoint2013_real)
	gen lnvaluefemale2010 = asinh(valuefemale2010)
	gen lnvaluefemale2013 = asinh(valuefemale2013_real)
	gen lnvaluemale2010 = asinh(valuemale2010)
	gen lnvaluemale2013 = asinh(valuemale2013_real)
	
* not real 
	gen lnvaluejoint2010 = asinh(valuejoint2010)
	gen lnvaluejoint2013 = asinh(valuejoint2013)
	gen lnvaluefemale2010 = asinh(valuefemale2010)
	gen lnvaluefemale2013 = asinh(valuefemale2013)
	gen lnvaluemale2010 = asinh(valuemale2010)
	gen lnvaluemale2013 = asinh(valuemale2013)
	
* not real - test
	gen lnvaluejoint2010t = asinh(valuejoint2010)
	gen lnvaluejoint2013t = asinh(valuejoint2013)
	gen lnvaluefemale2010t = asinh(valuefemale2010)
	gen lnvaluefemale2013t = asinh(valuefemale2013)
	gen lnvaluemale2010t = asinh(valuemale2010)
	gen lnvaluemale2013t = asinh(valuemale2013)
	
* difference 
	gen dlnvaluejoint = lnvaluejoint2013 - lnvaluejoint2010
	gen dlnvaluefemale = lnvaluefemale2013 - lnvaluefemale2010
	gen dlnvaluemale = lnvaluemale2013 - lnvaluemale2010
	
* difference - test
	gen dlnvaluejointt = lnvaluejoint2013t - lnvaluejoint2010t
	gen dlnvaluefemalet = lnvaluefemale2013t - lnvaluefemale2010t
	gen dlnvaluemalet = lnvaluemale2013t - lnvaluemale2010t
	
********************************************************************************************

/* END */