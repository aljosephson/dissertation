* Project: Zimbabwe Labor Shocks
* Created: August 2020
* Created by: alj
* Last edit: 18 September 2020 
* Stata v.16.1

* does
	* replicates all tables from Josephson and Shively 

* assumes
	* access to data file "data"

* to do 
	* done

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	fil		=	"C:\Users\aljosephson\Dropbox\Out for Review\Dissertation\Data - ICRISAT Zimbabwe\3_Labor Allocation\Replication" 
	global	code	=	"C:\Users\aljosephson\git\dissertation\e3_labor\code"
	global	logs	=	"C:\Users\aljosephson\git\dissertation\e3_labor\logs" 

* open log
	cap log 		close
	log using		"$logs/replication", append

* **********************************************************************
* 1 - read in clean data set
* **********************************************************************

* read in data
	use				"$fil/data", clear
	
* save as needed
	save 			"$fil/data", replace
	
* **********************************************************************
* 2 - replication of tables: main text
* **********************************************************************

* **********************************************************************
* 2a - summary statistics - shadow wage equations 
* **********************************************************************

* panel A
	tabstat 		wages_farmlabor femhead plough own_cattle free_seed intercrop fertqty area /// 
						no_farm_fulltime no_farm_parttime, stats (mean sd) by (yearpanel)	
* panel B
	tabstat 		wages_migrant avgmig_gender avgmig_age avgmig_yred multiple_mig ///
						migrant_internat migrant_dom no_migrants ///
						comm_migrantratio dist_VicFalls dist_Beitbridge dist_Mutare dist_Plumtree, stats (mean sd) by (yearpanel)	
* panel C 
	tabstat 		wages_offfarm avgoff_gender avgoff_age avgoff_yred multiple_off ///
						no_offfarm informal formal comm_offfarm, stats (mean sd) by (yearpanel)	 

* **********************************************************************
* 2b - summary statistics - labor share equations 
* **********************************************************************

* panel A
	tabstat 		share_mig share_off share_non share_farm, stats (mean sd) by (yearpanel)	 

* panel B
	tabstat 		ae hhage hhedu femhead, stats (mean sd) by (yearpanel)	 

* panel C
	tabstat 		workdeath commworkdeath shocktotal pershock, stats (mean sd) by (yearpanel)	 


* **********************************************************************
* 2c - allocation of labor (z-score rainfall)	
* **********************************************************************	

* define constraint + run regression 

	constraint 		def 1 [share_off]lnshadow_farm-[share_off]lnshadow_offfarm-[share_off]lnshadow_migrant- ///
						[share_farm]lnshadow_farm-[share_farm]lnshadow_offfarm-[share_farm]lnshadow_migrant- ///
						[share_mig]lnshadow_farm-[share_mig]lnshadow_offfarm-[share_mig]lnshadow_migrant- ///				
						[share_non]lnshadow_farm-[share_non]lnshadow_offfarm-[share_non]lnshadow_migrant = 0  
						
	bootstrap 		_b, reps(1000): /// 
						sureg (share_mig lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu multiple_mig dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr) ///
						(share_farm lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr) /// 
						(share_off lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu multiple_off dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr), isure constraint (1)

* recover missing values 
* recover predicted shares as well as coefficients and standard errors   
* for omitted (non) share equation for model							 
		   
	predict 			shat_off, equation(share_off)
	predict 			shat_mig, equation(share_mig)
	predict 			shat_farm, equation(share_farm)
	generate 			shat_non = 1 - shat_off - shat_mig - shat_farm
	sum		 			shat_non shat_off shat_mig shat_farm share_non share_off share_mig share_farm

	quietly  			lincom 1-[share_off]_cons - [share_mig]_cons - [share_farm]_cons
							scalar b0=r(estimate)
							scalar e0=r(se)
							scalar t0=b0/e0
	quietly 			lincom  -([share_off]lnshadow_farmlabor + [share_mig]lnshadow_farmlabor + [share_farm]lnshadow_farmlabor)
							scalar b1=r(estimate)
							scalar e1=r(se)
							scalar t1=b1/e1
	quietly 			lincom  -([share_off]lnshadow_migrant + [share_mig]lnshadow_migrant + [share_farm]lnshadow_migrant)
							scalar b2=r(estimate)
							scalar e2=r(se)
							scalar t2=b2/e2
	quietly  			lincom  -([share_off]lnshadow_offfarm + [share_mig]lnshadow_offfarm + [share_farm]lnshadow_offfarm)
							scalar b3=r(estimate)
							scalar e3=r(se)
							scalar t3=b3/e3
	quietly  			lincom  -([share_off]sqlnshadow_farmlabor + [share_mig]sqlnshadow_farmlabor + [share_farm]sqlnshadow_farmlabor)
							scalar b25=r(estimate)
							scalar e25=r(se)
							scalar t25=b25/e25
	quietly  			lincom  -([share_off]sqlnshadow_migrant + [share_mig]sqlnshadow_migrant + [share_farm]sqlnshadow_migrant)
							scalar b26=r(estimate)
							scalar e26=r(se)
							scalar t26=b26/e26
	quietly  			lincom  -([share_off]sqlnshadow_offfarm + [share_mig]sqlnshadow_offfarm + [share_farm]sqlnshadow_offfarm)
							scalar b27=r(estimate)
							scalar e27=r(se)
							scalar t27=b27/e27
	quietly  			lincom  -([share_off]ae + [share_mig]ae + [share_farm]ae)
							scalar b4=r(estimate)
							scalar e4=r(se)
							scalar t4=b4/e4
	quietly  			lincom  -([share_off]hhage + [share_mig]hhage + [share_farm]hhage)
							scalar b5=r(estimate)
							scalar e5=r(se)
							scalar t5=b5/e5
	quietly  			lincom  -([share_off]hhedu + [share_mig]hhedu + [share_farm]hhedu)
							scalar b6=r(estimate)
							scalar e6=r(se)
							scalar t6=b6/e6	
	quietly  			lincom  -([share_off]workdeath + [share_mig]workdeath + [share_farm]workdeath)
							scalar b9=r(estimate)
							scalar e9=r(se)
							scalar t9=b9/e9			 
	quietly  			lincom  -([share_off]commworkdeath + [share_mig]commworkdeath + [share_farm]commworkdeath)
							scalar b10=r(estimate)
							scalar e10=r(se)
							scalar t10=b10/e10
	quietly  			lincom  -([share_off]shocktotal + [share_mig]shocktotal + [share_farm]shocktotal)
							scalar b11=r(estimate)
							scalar e11=r(se)
							scalar t11=b11/e11
	quietly  			lincom  -([share_off]dist_Plumtree + [share_mig]dist_Plumtree + [share_farm]dist_Plumtree)
							scalar b12=r(estimate)
							scalar e12=r(se)
							scalar t12=b12/e12
	quietly  			lincom  -([share_off]dist_Mutare+ [share_mig]dist_Mutare + [share_farm]dist_Mutare)
							scalar b13=r(estimate)
							scalar e13=r(se)
							scalar t13=b13/e13	
	quietly  			lincom  -([share_off]dist_Beitbridge + [share_mig]dist_Beitbridge + [share_farm]dist_Beitbridge)
							scalar b14=r(estimate)
							scalar e14=r(se)
							scalar t14=b14/e14		 
	quietly  			lincom  -([share_off]dist_VicFalls + [share_mig]dist_VicFalls + [share_farm]dist_VicFalls)
							scalar b15=r(estimate)
							scalar e15=r(se)
							scalar t15=b15/e15
	quietly  			lincom  -([share_off]yearbin + [share_mig]yearbin + [share_farm]yearbin)
							scalar b16=r(estimate)
							scalar e16=r(se)
							scalar t16=b16/e16	
	quietly 			lincom -([share_off]did_workdeathyr + [share_mig]did_workdeathyr + [share_farm]did_workdeathyr)
							scalar b17=r(estimate)
							scalar e17=r(se)
							scalar t17=b17/e17	
	quietly 			lincom -([share_off]did_comworkdeathyr + [share_mig]did_comworkdeathyr + [share_farm]did_comworkdeathyr)
							scalar b18=r(estimate)
							scalar e18=r(se)
							scalar t18=b18/e18	
	quietly				lincom -([share_off]did_shockyr + [share_mig]did_shockyr + [share_farm]did_shockyr)
							scalar b19=r(estimate)
							scalar e19=r(se)
							scalar t19=b19/e19		 
	quietly 			lincom -([share_off]femhead + [share_mig]femhead + [share_farm]femhead)
							scalar b23=r(estimate)
							scalar e23=r(se)
							scalar t23=b23/e23	
		 	                        
* recover coefs and standard errors from restrictions *	 
	quietly  			lincom  -([share_off]lnshadow_offfarm + [share_off]lnshadow_migrant + [share_off]lnshadow_farmlabor)
							scalar b20=r(estimate)
							scalar e20=r(se)
							scalar t20=b20/e20
	quietly  			lincom  -([share_mig]lnshadow_offfarm + [share_mig]lnshadow_migrant + [share_mig]lnshadow_farmlabor)
							scalar b21=r(estimate)
							scalar e21=r(se)
							scalar t21=b21/e21
	quietly  			lincom  -([share_farm]lnshadow_offfarm + [share_farm]lnshadow_migrant + [share_farm]lnshadow_farmlabor)
							scalar b24=r(estimate)
							scalar e24=r(se)
							scalar t24=b24/e24
	quietly  			lincom   [share_off]lnshadow_offfarm + [share_off]lnshadow_migrant + [share_off]lnshadow_farmlabor ///
							+[share_mig]lnshadow_offfarm + [share_mig]lnshadow_migrant + [share_mig]lnshadow_farmlabor  /// 
							+[share_farm]lnshadow_offfarm + [share_farm]lnshadow_migrant + [share_farm]lnshadow_farmlabor 
								scalar b22=r(estimate)
								scalar e22=r(se)
								scalar t22=b22/e22

	matrix 				define eq1=(b0\b1\b2\b3\b4\b5\b6\b9\b10\b11\b12\b13\b14\b15\b16\b17\b18\b19\b20\b21\b22\b23\b24\b25\b26\b27),(e0\e1\e2\e3\e4\e5\e6\e9\e10\e11\e12\e13\e14\e15\e16\e17\e18\e19\e20\e21\e22\e23\e24\e25\e26\e27),(t0\t1\t2\t3\t4\t5\t6\t9\t10\t11\t12\t13\t14\t15\t16\t17\t18\t19\t20\t21\t22\t23\t24\t25\t26\t27)

	*matname 			eq1 beta se t, col(.) 
	matname 			eq1 _con lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ae hhage hhedu femhead ///
							workdeath commworkdeath shocktotal dist_Plumtree dist_Mutare dist_Beitbridge dist_VicFalls yearbin did_workdeathyr did_comworkdeathyr did_shock /// 
							b_onfarm_offfarm b_onfarm_migrant b_onfarm_non b_onfarm_onfarm, row(.) e

	matrix 				list eq1

* **********************************************************************
* 2d - allocation of labor (perceived rainfall)
* **********************************************************************
* read in data
	use				"$fil/data", clear

* run regression 

		constraint 		def 1 [share_off]lnshadow_farm-[share_off]lnshadow_offfarm-[share_off]lnshadow_migrant- ///
							[share_farm]lnshadow_farm-[share_farm]lnshadow_offfarm-[share_farm]lnshadow_migrant- ///
							[share_mig]lnshadow_farm-[share_mig]lnshadow_offfarm-[share_mig]lnshadow_migrant- ///				
							[share_non]lnshadow_farm-[share_non]lnshadow_offfarm-[share_non]lnshadow_migrant = 0  

		bootstrap 		_b, reps(1000): /// 
							sureg (share_mig lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_mig dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock) ///
							(share_farm lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock) /// 
							(share_off lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_off dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock), isure constraint (1)

* recover missing values 
* recover predicted shares as well as coefficients and standard errors   
* for omitted (non) share equation for model	
			   
	predict 			shat_off, equation(share_off)
	predict 			shat_mig, equation(share_mig)
	predict 			shat_farm, equation(share_farm)
	generate 			shat_non = 1 - shat_off - shat_mig - shat_farm
	sum		 			shat_non shat_off shat_mig shat_farm share_non share_off share_mig share_farm

	quietly  			lincom 1-[share_off]_cons - [share_mig]_cons - [share_farm]_cons
							scalar b0=r(estimate)
							scalar e0=r(se)
							scalar t0=b0/e0
	quietly 			lincom  -([share_off]lnshadow_farmlabor + [share_mig]lnshadow_farmlabor + [share_farm]lnshadow_farmlabor)
							scalar b1=r(estimate)
							scalar e1=r(se)
							scalar t1=b1/e1
	quietly 			lincom  -([share_off]lnshadow_migrant + [share_mig]lnshadow_migrant + [share_farm]lnshadow_migrant)
							scalar b2=r(estimate)
							scalar e2=r(se)
							scalar t2=b2/e2
	quietly  			lincom  -([share_off]lnshadow_offfarm + [share_mig]lnshadow_offfarm + [share_farm]lnshadow_offfarm)
							scalar b3=r(estimate)
							scalar e3=r(se)
							scalar t3=b3/e3
	quietly  			lincom  -([share_off]sqlnshadow_farmlabor + [share_mig]sqlnshadow_farmlabor + [share_farm]sqlnshadow_farmlabor)
							scalar b25=r(estimate)
							scalar e25=r(se)
							scalar t25=b25/e25
	quietly  			lincom  -([share_off]sqlnshadow_migrant + [share_mig]sqlnshadow_migrant + [share_farm]sqlnshadow_migrant)
							scalar b26=r(estimate)
							scalar e26=r(se)
							scalar t26=b26/e26
	quietly  			lincom  -([share_off]sqlnshadow_offfarm + [share_mig]sqlnshadow_offfarm + [share_farm]sqlnshadow_offfarm)
							scalar b27=r(estimate)
							scalar e27=r(se)
							scalar t27=b27/e27
	quietly  			lincom  -([share_off]ae + [share_mig]ae + [share_farm]ae)
							scalar b4=r(estimate)
							scalar e4=r(se)
							scalar t4=b4/e4
	quietly  			lincom  -([share_off]hhage + [share_mig]hhage + [share_farm]hhage)
							scalar b5=r(estimate)
							scalar e5=r(se)
							scalar t5=b5/e5
	quietly  			lincom  -([share_off]hhedu + [share_mig]hhedu + [share_farm]hhedu)
							scalar b6=r(estimate)
							scalar e6=r(se)
							scalar t6=b6/e6	
	quietly  			lincom  -([share_off]workdeath + [share_mig]workdeath + [share_farm]workdeath)
							scalar b9=r(estimate)
							scalar e9=r(se)
							scalar t9=b9/e9			 
	quietly  			lincom  -([share_off]commworkdeath + [share_mig]commworkdeath + [share_farm]commworkdeath)
							scalar b10=r(estimate)
							scalar e10=r(se)
							scalar t10=b10/e10
	quietly  			lincom  -([share_off]pershock + [share_mig]pershock + [share_farm]pershock)
							scalar b11=r(estimate)
							scalar e11=r(se)
							scalar t11=b11/e11
	quietly  			lincom  -([share_off]dist_Plumtree + [share_mig]dist_Plumtree + [share_farm]dist_Plumtree)
							scalar b12=r(estimate)
							scalar e12=r(se)
							scalar t12=b12/e12
	quietly  			lincom  -([share_off]dist_Mutare+ [share_mig]dist_Mutare + [share_farm]dist_Mutare)
							scalar b13=r(estimate)
							scalar e13=r(se)
							scalar t13=b13/e13	
	quietly  			lincom  -([share_off]dist_Beitbridge + [share_mig]dist_Beitbridge + [share_farm]dist_Beitbridge)
							scalar b14=r(estimate)
							scalar e14=r(se)
							scalar t14=b14/e14		 
	quietly  			lincom  -([share_off]dist_VicFalls + [share_mig]dist_VicFalls + [share_farm]dist_VicFalls)
							scalar b15=r(estimate)
							scalar e15=r(se)
							scalar t15=b15/e15
	quietly  			lincom  -([share_off]yearbin + [share_mig]yearbin + [share_farm]yearbin)
							scalar b16=r(estimate)
							scalar e16=r(se)
							scalar t16=b16/e16	
	quietly 			lincom -([share_off]did_workdeathyr + [share_mig]did_workdeathyr + [share_farm]did_workdeathyr)
							scalar b17=r(estimate)
							scalar e17=r(se)
							scalar t17=b17/e17	
	quietly 			lincom -([share_off]did_comworkdeathyr + [share_mig]did_comworkdeathyr + [share_farm]did_comworkdeathyr)
							scalar b18=r(estimate)
							scalar e18=r(se)
							scalar t18=b18/e18	
	quietly				lincom -([share_off]did_pershock + [share_mig]did_pershock + [share_farm]did_pershock)
							scalar b19=r(estimate)
							scalar e19=r(se)
							scalar t19=b19/e19		 
	quietly 			lincom -([share_off]femhead + [share_mig]femhead + [share_farm]femhead)
							scalar b23=r(estimate)
							scalar e23=r(se)
							scalar t23=b23/e23	
		 	                        
* recover coefs and standard errors from restrictions *	 
	quietly  			lincom  -([share_off]lnshadow_offfarm + [share_off]lnshadow_migrant + [share_off]lnshadow_farmlabor)
							scalar b20=r(estimate)
							scalar e20=r(se)
							scalar t20=b20/e20
	quietly  			lincom  -([share_mig]lnshadow_offfarm + [share_mig]lnshadow_migrant + [share_mig]lnshadow_farmlabor)
							scalar b21=r(estimate)
							scalar e21=r(se)
							scalar t21=b21/e21
	quietly  			lincom  -([share_farm]lnshadow_offfarm + [share_farm]lnshadow_migrant + [share_farm]lnshadow_farmlabor)
							scalar b24=r(estimate)
							scalar e24=r(se)
							scalar t24=b24/e24
	quietly  			lincom   [share_off]lnshadow_offfarm + [share_off]lnshadow_migrant + [share_off]lnshadow_farmlabor ///
							+[share_mig]lnshadow_offfarm + [share_mig]lnshadow_migrant + [share_mig]lnshadow_farmlabor  /// 
							+[share_farm]lnshadow_offfarm + [share_farm]lnshadow_migrant + [share_farm]lnshadow_farmlabor 
								scalar b22=r(estimate)
								scalar e22=r(se)
								scalar t22=b22/e22

	matrix 				define eq1=(b0\b1\b2\b3\b4\b5\b6\b9\b10\b11\b12\b13\b14\b15\b16\b17\b18\b19\b20\b21\b22\b23\b24\b25\b26\b27),(e0\e1\e2\e3\e4\e5\e6\e9\e10\e11\e12\e13\e14\e15\e16\e17\e18\e19\e20\e21\e22\e23\e24\e25\e26\e27),(t0\t1\t2\t3\t4\t5\t6\t9\t10\t11\t12\t13\t14\t15\t16\t17\t18\t19\t20\t21\t22\t23\t24\t25\t26\t27)

	*matname 			eq1 beta se t, col(.) 
	matname 			eq1 _con lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ae hhage hhedu femhead ///
							workdeath commworkdeath pershock dist_Plumtree dist_Mutare dist_Beitbridge dist_VicFalls yearbin did_workdeathyr did_comworkdeathyr did_pershock /// 
							b_onfarm_offfarm b_onfarm_migrant b_onfarm_non b_onfarm_onfarm, row(.) e

	matrix 				list eq1


* **********************************************************************
* 2e - allocation of labor (perceived rainfall) control for dif. 
* **********************************************************************

* examine interaction between perceived shock and actual shock 
* add triple interaction with year as well 
		
* read in data
	use				"$fil/data", clear

* run regression 

		constraint 		def 1 [share_off]lnshadow_farm-[share_off]lnshadow_offfarm-[share_off]lnshadow_migrant- ///
						[share_farm]lnshadow_farm-[share_farm]lnshadow_offfarm-[share_farm]lnshadow_migrant- ///
						[share_mig]lnshadow_farm-[share_mig]lnshadow_offfarm-[share_mig]lnshadow_migrant- ///				
						[share_non]lnshadow_farm-[share_non]lnshadow_offfarm-[share_non]lnshadow_migrant = 0  
						

		bootstrap 		_b, reps(1000): /// 
							sureg (share_mig lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_mig dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint) ///
							(share_farm lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint) /// 
							(share_off lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_off dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint), ///
							isure constraint (1)

* recover missing values 
* recover predicted shares as well as coefficients and standard errors   
* for omitted (non) share equation for model	
			   
	predict 			shat_off, equation(share_off)
	predict 			shat_mig, equation(share_mig)
	predict 			shat_farm, equation(share_farm)
	generate 			shat_non = 1 - shat_off - shat_mig - shat_farm
	sum		 			shat_non shat_off shat_mig shat_farm share_non share_off share_mig share_farm

	quietly  			lincom 1-[share_off]_cons - [share_mig]_cons - [share_farm]_cons
							scalar b0=r(estimate)
							scalar e0=r(se)
							scalar t0=b0/e0
	quietly 			lincom  -([share_off]lnshadow_farmlabor + [share_mig]lnshadow_farmlabor + [share_farm]lnshadow_farmlabor)
							scalar b1=r(estimate)
							scalar e1=r(se)
							scalar t1=b1/e1
	quietly 			lincom  -([share_off]lnshadow_migrant + [share_mig]lnshadow_migrant + [share_farm]lnshadow_migrant)
							scalar b2=r(estimate)
							scalar e2=r(se)
							scalar t2=b2/e2
	quietly  			lincom  -([share_off]lnshadow_offfarm + [share_mig]lnshadow_offfarm + [share_farm]lnshadow_offfarm)
							scalar b3=r(estimate)
							scalar e3=r(se)
							scalar t3=b3/e3
	quietly  			lincom  -([share_off]sqlnshadow_farmlabor + [share_mig]sqlnshadow_farmlabor + [share_farm]sqlnshadow_farmlabor)
							scalar b25=r(estimate)
							scalar e25=r(se)
							scalar t25=b25/e25
	quietly  			lincom  -([share_off]sqlnshadow_migrant + [share_mig]sqlnshadow_migrant + [share_farm]sqlnshadow_migrant)
							scalar b26=r(estimate)
							scalar e26=r(se)
							scalar t26=b26/e26
	quietly  			lincom  -([share_off]sqlnshadow_offfarm + [share_mig]sqlnshadow_offfarm + [share_farm]sqlnshadow_offfarm)
							scalar b27=r(estimate)
							scalar e27=r(se)
							scalar t27=b27/e27							
	quietly  			lincom  -([share_off]ae + [share_mig]ae + [share_farm]ae)
							scalar b4=r(estimate)
							scalar e4=r(se)
							scalar t4=b4/e4
	quietly  			lincom  -([share_off]hhage + [share_mig]hhage + [share_farm]hhage)
							scalar b5=r(estimate)
							scalar e5=r(se)
							scalar t5=b5/e5
	quietly  			lincom  -([share_off]hhedu + [share_mig]hhedu + [share_farm]hhedu)
							scalar b6=r(estimate)
							scalar e6=r(se)
							scalar t6=b6/e6	
	quietly  			lincom  -([share_off]workdeath + [share_mig]workdeath + [share_farm]workdeath)
							scalar b9=r(estimate)
							scalar e9=r(se)
							scalar t9=b9/e9			 
	quietly  			lincom  -([share_off]commworkdeath + [share_mig]commworkdeath + [share_farm]commworkdeath)
							scalar b10=r(estimate)
							scalar e10=r(se)
							scalar t10=b10/e10
	quietly  			lincom  -([share_off]pershock + [share_mig]pershock + [share_farm]pershock)
							scalar b11=r(estimate)
							scalar e11=r(se)
							scalar t11=b11/e11
	quietly  			lincom  -([share_off]shocktotal + [share_mig]shocktotal + [share_farm]shocktotal)
							scalar b28=r(estimate)
							scalar e28=r(se)
							scalar t28=b28/e28
	quietly  			lincom  -([share_off]pershockint + [share_mig]pershockint + [share_farm]pershockint)
							scalar b29=r(estimate)
							scalar e29=r(se)
							scalar t29=b29/e29	
	quietly  			lincom  -([share_off]dist_Plumtree + [share_mig]dist_Plumtree + [share_farm]dist_Plumtree)
							scalar b12=r(estimate)
							scalar e12=r(se)
							scalar t12=b12/e12
	quietly  			lincom  -([share_off]dist_Mutare+ [share_mig]dist_Mutare + [share_farm]dist_Mutare)
							scalar b13=r(estimate)
							scalar e13=r(se)
							scalar t13=b13/e13	
	quietly  			lincom  -([share_off]dist_Beitbridge + [share_mig]dist_Beitbridge + [share_farm]dist_Beitbridge)
							scalar b14=r(estimate)
							scalar e14=r(se)
							scalar t14=b14/e14		 
	quietly  			lincom  -([share_off]dist_VicFalls + [share_mig]dist_VicFalls + [share_farm]dist_VicFalls)
							scalar b15=r(estimate)
							scalar e15=r(se)
							scalar t15=b15/e15
	quietly  			lincom  -([share_off]yearbin + [share_mig]yearbin + [share_farm]yearbin)
							scalar b16=r(estimate)
							scalar e16=r(se)
							scalar t16=b16/e16	
	quietly 			lincom -([share_off]did_workdeathyr + [share_mig]did_workdeathyr + [share_farm]did_workdeathyr)
							scalar b17=r(estimate)
							scalar e17=r(se)
							scalar t17=b17/e17	
	quietly 			lincom -([share_off]did_comworkdeathyr + [share_mig]did_comworkdeathyr + [share_farm]did_comworkdeathyr)
							scalar b18=r(estimate)
							scalar e18=r(se)
							scalar t18=b18/e18	
	quietly				lincom -([share_off]did_pershock + [share_mig]did_pershock + [share_farm]did_pershock)
							scalar b19=r(estimate)
							scalar e19=r(se)
							scalar t19=b19/e19		 						
	quietly				lincom -([share_off]did_shockyr + [share_mig]did_shockyr + [share_farm]did_shockyr)
							scalar b30=r(estimate)
							scalar e30=r(se)
							scalar t30=b30/e30							
	quietly				lincom -([share_off]did_pershockint + [share_mig]did_pershockint + [share_farm]did_pershockint)
							scalar b31=r(estimate)
							scalar e31=r(se)
							scalar t31=b31/e31												
	quietly 			lincom -([share_off]femhead + [share_mig]femhead + [share_farm]femhead)
							scalar b23=r(estimate)
							scalar e23=r(se)
							scalar t23=b23/e23	
		 	                        
* recover coefs and standard errors from restrictions *	 
	quietly  			lincom  -([share_off]lnshadow_offfarm + [share_off]lnshadow_migrant + [share_off]lnshadow_farmlabor)
							scalar b20=r(estimate)
							scalar e20=r(se)
							scalar t20=b20/e20
	quietly  			lincom  -([share_mig]lnshadow_offfarm + [share_mig]lnshadow_migrant + [share_mig]lnshadow_farmlabor)
							scalar b21=r(estimate)
							scalar e21=r(se)
							scalar t21=b21/e21
	quietly  			lincom  -([share_farm]lnshadow_offfarm + [share_farm]lnshadow_migrant + [share_farm]lnshadow_farmlabor)
							scalar b24=r(estimate)
							scalar e24=r(se)
							scalar t24=b24/e24
	quietly  			lincom   [share_off]lnshadow_offfarm + [share_off]lnshadow_migrant + [share_off]lnshadow_farmlabor ///
							+[share_mig]lnshadow_offfarm + [share_mig]lnshadow_migrant + [share_mig]lnshadow_farmlabor  /// 
							+[share_farm]lnshadow_offfarm + [share_farm]lnshadow_migrant + [share_farm]lnshadow_farmlabor 
								scalar b22=r(estimate)
								scalar e22=r(se)
								scalar t22=b22/e22

	matrix 				define eq1=(b0\b1\b2\b3\b4\b5\b6\b9\b10\b11\b12\b13\b14\b15\b16\b17\b18\b19\b20\b21\b22\b23\b24\b25\b26\b27\b28\b29\b30\b31),(e0\e1\e2\e3\e4\e5\e6\e9\e10\e11\e12\e13\e14\e15\e16\e17\e18\e19\e20\e21\e22\e23\e24\e25\e26\e27\e28\e29\e30\e31),(t0\t1\t2\t3\t4\t5\t6\t9\t10\t11\t12\t13\t14\t15\t16\t17\t18\t19\t20\t21\t22\t23\t24\t25\t26\t27\t28\t29\t30\t31)

	*matname 			eq1 beta se t, col(.) 
	matname 			eq1 _con lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ae hhage hhedu femhead ///
							workdeath commworkdeath pershock shock pershockint dist_Plumtree dist_Mutare dist_Beitbridge dist_VicFalls yearbin ///
							did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint /// 
							b_onfarm_offfarm b_onfarm_migrant b_onfarm_non b_onfarm_onfarm, row(.) e

	matrix 				list eq1
	

* **********************************************************************
* 3 - replication of tables: supplemental text
* **********************************************************************

* **********************************************************************
* 3a - calculation of shadow wages 
* **********************************************************************

* read in data
	use				"$fil/data", clear
	
	drop 			shadow_farmlabor shadow_migrant shadow_offfarm /// 
					mshadow_farmlabor mshadow_migrant mshadow_offfarm

* set panel 
	xtset 			yearpanel 
	
	gen 			lnwages_farmlabor = asinh(wages_farmlabor)
	gen			lnwages_migrant = asinh(wages_migrant)
	gen 			lnwages_offfarm = asinh(wages_offfarm)

* estimate shadow wage for farm labor 
	xtreg 			lnwages_farmlabor plough femhead own_cattle free_seed intercrop fertqty area /// 
						no_farm_fulltime no_farm_parttime mplough mfemhead mown_cattle mfree_seed ///
						mintercrop mfertqty marea mno_farm_fulltime mno_farm_parttime

	predict 		xb1, xb
	egen 			xb1mean = mean (xb1), by (district ward)
	replace 		xb1 = xb1mean if xb1 == .
	gen 			x_farm = _b[no_farm_fulltime]

* estimate shadow wage for migrant labor 
	xtreg 			lnwages_migrant avgmig_gender avgmig_age avgmig_yred multiple_mig ///
						migrant_internat migrant_dom no_migrants ///
						comm_migrantratio dist_VicFalls dist_Beitbridge dist_Mutare dist_Plumtree /// 
						mavgmig_gender mavgmig_age mavgmig_yred mmultiple_mig mmigrant_internat ///
						mmigrant_dom mno_migrants mcomm_migrantratio

	predict 		xb2, xb
	egen 			xb2mean = mean (xb2), by (district ward)
	replace 		xb2 = xb2mean if xb2 == .
	gen 			x_migrant = _b[no_migrants]

* estimate shadow wage for wage labor 
	xtreg 			lnwages_offfarm avgoff_gender avgoff_age avgoff_yred multiple_off ///
						no_offfarm informal formal comm_offfarm /// 
						mavgoff_gender mavgoff_age mavgoff_yred mmultiple_off ///
						mno_offfarm mo_informal mformal mcomm_offfarm

	predict			xb3, xb
	egen 			xb3mean = mean (xb3), by (district ward)
	replace 		xb3 = xb3mean if xb3 == .
	gen 			x_offfarm = _b[no_offfarm]

* calculate shadow wages 
	gen 			shadow_farmlabor = (xb1 / no_farm_fulltime1)*(x_farm)
	gen 			shadow_migrant = (xb2 / no_migrant1)*(x_migrant)
	gen 			shadow_offfarm = (xb3 / no_offfarm1)*(x_offfarm)

	egen 			mshadow_farmlabor = mean(shadow_farmlabor), by (rc id)
	egen 			mshadow_migrant = mean(shadow_migrant), by (rc id)
	egen 			mshadow_offfarm  = mean(shadow_offfarm), by (rc id)

	label 			variable shadow_migrant "\hspace{0.1cm} Migration Wages"
	label 			variable shadow_offfarm "\hspace{0.1cm} Off-Farm Wages"
	label 			variable shadow_farmlabor "\hspace{0.1cm} On-Farm Wages"	
	
* **********************************************************************
* 3b - shock exogeneity 
* **********************************************************************

* read in data
	use				"$fil/data", clear
	
* regressions for each of the four shocks 
	
	reg 			workdeath ae hhage hhedu femhead plough own_cattle ///
						mae mhhage mhhedu mfemhead mplough mown_cattle, cluster(district) 

	reg 			commworkdeath ae hhage hhedu femhead plough own_cattle ///
						mae mhhage mhhedu  mfemhead mplough mown_cattle, cluster(district) 

	reg 			shocktotal ae hhage hhedu femhead plough own_cattle ///
						mae mhhage mhhedu  mfemhead mplough mown_cattle, cluster(district) 
		
	reg 			pershock ae hhage hhedu femhead plough own_cattle ///
						mae mhhage mhhedu  mfemhead mplough mown_cattle, cluster(district) 

* **********************************************************************
* 3d - robust - analysis with CRE tobit 
* **********************************************************************						

* **********************************************************************
* 3di - allocation of labor (z-score rainfall)	
* **********************************************************************	 

		
* read in data
	use				"$fil/data", clear
		
	bootstrap 		_b, reps(1000): tobit share_mig lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu multiple_mig dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr

	bootstrap 		_b, reps(1000): tobit share_farm lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr

	bootstrap 		_b, reps(1000): tobit share_off lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu multiple_off dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr

	bootstrap 		_b, reps(1000): tobit share_non lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
						ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
						femhead workdeath commworkdeath shocktotal yearbin did_workdeathyr did_comworkdeathyr did_shockyr
						

* **********************************************************************
* 3dii - allocation of labor (perceived rainfall)
* **********************************************************************

* read in data
	use				"$fil/data", clear
	

	bootstrap 		_b, reps(1000): tobit share_mig lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_mig dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock 
						
	bootstrap 		_b, reps(1000):	tobit share_farm lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock
						
	bootstrap 		_b, reps(1000): tobit share_off lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_off dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock

	bootstrap 		_b, reps(1000): tobit share_non lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock yearbin did_workdeathyr did_comworkdeathyr did_pershock							

* **********************************************************************
* 3diii - allocation of labor (perceived rainfall) control for dif. 
* **********************************************************************

* examine interaction between perceived shock and actual shock 
* add triple interaction with year as well 
		
* read in data
	use				"$fil/data", clear

	bootstrap 		_b, reps(1000): tobit share_mig lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_mig dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint
							
	bootstrap 		_b, reps(1000): tobit share_farm lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint
							
	bootstrap 		_b, reps(1000): tobit share_off lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu multiple_off dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint

	bootstrap 		_b, reps(1000): tobit share_non lnshadow_migrant lnshadow_offfarm lnshadow_farmlabor sqlnshadow_migrant sqlnshadow_offfarm sqlnshadow_farmlabor ///
							ae hhage hhedu dist_VicFalls dist_Mutare dist_Beitbridge dist_Plumtree ///
							femhead workdeath commworkdeath pershock shocktotal pershockint yearbin did_workdeathyr did_comworkdeathyr did_pershock did_shockyr did_pershockint
							
* *********************************************************************
* 4 - end matter
* **********************************************************************

compress
describe
summarize 

* save main data file 
	save			"$fil/data_replication", replace

* close the log
	log	close	