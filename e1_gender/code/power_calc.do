/* BEGIN */

* Project: dissertation e1
* Created on: 24 October 2023
* Created by: alj
* Edited by: alj
* Last edit: 24 October 2023
* Stata v.18

* does
	* sample MDE code 
	* possible power calculation 

* assumes
	* ssc power 

* TO DO:
	* done 

************************************************************************
**# 0 - example calculations - baraguay and household 
************************************************************************

* example calculations
* examples coming from IRRI work on extension advice 

* more details on code: https://www.stata.com/features/overview/power-and-sample-size/ 
* more details on code: https://dimewiki.worldbank.org/Power_Calculations_in_Stata 

* using twomeans 
* first variable (0.27) is the average 
* k1 and k2 represent the numbers of control and treatment clusters, respectively 
* kratio is ratio of k1/k2 - 1 is default 
* sd is standard deviation - assuming equality between treatment and control groups 
* m1 is the cluster size in the control (could also specify m2)
* mratio is ratio of m1/m2 - 1 is default 
* power - varies (will show a range)
* could also here change sample size 
* rho is ICC assuming equality between treatment and control - this comes from experimental data from IRRI 
*** we can also calculate ICC: https://www.stata.com/features/overview/intraclass-correlation-coefficients/ 

* baragays level 
* baragays = similar to county 
*power twomeans .27, k1(52(8)80) kratio(1) sd(.44) m1(5) mratio(1) power(0.7 0.8 0.9) rho(0.31537) graph(y(delta) /// 
	title("") xline(65, lcolor(maroon) lstyle(solid) ) /// 
	legend(pos(6) cols(3))) 

* household level 
*power twomeans .27, k1(56) k2(56) sd(.44) m1(1(1)15) mratio(1) power(0.7 0.8 0.9) rho(0.31537) graph(y(delta) /// 
	title("") xline(10, lcolor(maroon) lstyle(solid) ) /// 
	legend(pos(6) cols(3))) 

************************************************************************

*** SAMPLE INFORMATION FROM DUFLO AND UDRY
* 0.34 is average effect for group of interest
* 0.25 is average effect in control group 
* 0.5 is standard deviation 

power twomeans 0.207 (0.10(0.05)0.25), sd(0.5) power(0.7 0.8 0.9) graph

/* END */