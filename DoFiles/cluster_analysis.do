
use "$directorio\DB\lawyer_dataset_collapsed.dta", clear


*Variable name cleaning
foreach var of varlist mean_perc* {
	local nvar=substr("`var'",11,.)
	rename `var' `nvar'
	}

foreach var of varlist sd_perc* {
	local nvar=substr("`var'",9,.)
	rename `var' sd_`nvar'
	}

foreach var of varlist mean_ratio* {
	local nvar=substr("`var'",12,.)
	rename `var' `nvar'
	}
	
foreach var of varlist sd_ratio* {
	local nvar=substr("`var'",10,.)
	rename `var' sd_`nvar'
	}

foreach var of varlist mean_* {
	local nvar=substr("`var'",6,.)
	rename `var' `nvar'
	}
	
foreach var of varlist sd_* {
	local nvar=substr("`var'",4,.)
	rename `var' sd_`nvar'
	}	
	

********************************************************************************
	

*****************************************
* 				    PCA                 *
*****************************************

*Variables to include in PCA
local input_varlist rel_procu rel_ent dw_scian dw_giro_procu indem  prima_antig ///
	    hextra sarimssinf   ///
	codem reinst
local output_varlist pos_rec settlement cr win_asked  ///
	win_minley win_cprocu duration


*Exclusion SD from varlist
*(we exclude all benefits for the sd)
local exclude= "indem sal_caidos prima_antig prima_vac hextra prima_dom desc_sem desc_ob sarimssinf utilidades nulidad codem reinst"

local sd_varlist = " "
foreach var of varlist `input_varlist' `output_varlist' {
	*Exclude from varlist SD, those in `exclude'
	if strpos("`exclude'", "`var'")==0	{
		local sd_varlist = "`sd_varlist' sd_`var'"
		}
	}	

	
*Label variables 
	
	
*PCA 	
factor `input_varlist' `output_varlist' `sd_varlist', pcf		

*Cronbach’s alpha
alpha `input_varlist' `output_varlist' `sd_varlist'

*Screeplot
screeplot, yline(1)

*Factors to retain
local fc = " "
forvalues i=1/`e(f)' {
	local fc = "`fc' f`i'"
	}
predict `fc'

*Loadingplot
graph matrix f*
loadingplot, fac(4) combined
 
********************************************************************************

 
*****************************************
* 				   CLUSTER              *
***************************************** 
 
 
*Exploratory cluster analysis. This will assess the number of cluster we will take 
	*Hierarchical clustering
cluster completelinkage f*, name(L2clnk)
	*Dendogram 
cluster dendrogram L2clnk,  xlabel(,angle(90) labsize(*.75)) cutnumber(10) ///
	scheme(s2mono) graphregion(color(white))



cap drop g3
*Initialization of group centers (we take the 1st factor median/terciles to cluster around)
cap drop ini_g3
xtile ini_g3=f1, nq(3)
cluster k f*, k(3) name(g3)  mea(abs) start(group(ini_g3))

twoway (scatter f1 f2  if g3==1,  mlabpos(0) msymbol(circle)  color(cranberry)) ///
		(scatter f1 f2  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f2  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f1 f2  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m1, replace)
		
twoway (scatter f1 f3  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f3  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f3  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f1 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m2, replace)
		
twoway (scatter f1 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f1 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m3, replace)
		
twoway (scatter f2 f3  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f2 f3  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f2 f3  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f2 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m4, replace)
		
twoway (scatter f2 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f2 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f2 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f2 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m5, replace)
		
twoway (scatter f3 f4  if g3==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f3 f4  if g3==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f3 f4  if g3==3,  mlabpos(0) msymbol(triangle) color(green)) ///
		(scatter f3 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///
						, scheme(s2mono) ///
			graphregion(color(white)) legend(off) name(m6, replace)
		
	
	
graph combine m1 m2 m3 m4 m5 m6	, name(tres, replace) scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\cluster_3.pdf", replace


****************


cap drop g2
cap drop ini_g2
xtile ini_g2=f1, nq(2)
cluster k f*, k(2) name(g2)  mea(abs) start(group(ini_g2))



twoway (scatter f1 f2  if g2==1,  mlabpos(0) msymbol(circle) color(cranberry)) ///
		(scatter f1 f2  if g2==2,  mlabpos(0) msymbol(square) color(ltblue)) ///
		(scatter f1 f2  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///			
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m1, replace)
		
twoway (scatter f1 f3  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f1 f3  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f1 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///	
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m2, replace)
		
twoway (scatter f1 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f1 f4  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f1 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m3, replace)
		
twoway (scatter f2 f3  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f2 f3  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f2 f3  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m4, replace)
		
twoway (scatter f2 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f2 f4  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f2 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m5, replace)
		
twoway (scatter f3 f4  if g2==1,  mlabpos(0) color(cranberry)) ///
		(scatter f3 f4  if g2==2,  mlabpos(0) color(ltblue)) ///
		(scatter f3 f4  if inlist(id,$lista1,$lista2,$lista3,$lista4,$lista5 ///
									,$lista6,$lista7,$lista8,$lista9,$lista10),  msymbol(diamond) ///
						mlcolor(black) mlabpos(0) color(purple)) ///				
		, scheme(s2mono) graphregion(color(white)) legend(off) name(m6, replace)
		
	
	
graph combine m1 m2 m3 m4 m5 m6, name(dos, replace) scheme(s2mono) graphregion(color(white))
graph export "$directorio\Figuras\cluster_2.pdf", replace

*Correlation between clustering
tab g2 g3
discard

 
********************************************************************************

 
