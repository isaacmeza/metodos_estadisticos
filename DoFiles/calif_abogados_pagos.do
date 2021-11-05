use  "$directorio\DB\base_calidad_abogados.dta", clear

********************************************************************************
*Payments according to TOR

/*EVALUACIONES COMPLETAS: $100 pesos por demanda con calificaciones y
justificaciones completas, y las predicciones del apartado 3.b de estos
t�rminos de referencia completas (en el tiempo requerido en el apartado 5)*/

egen eval_compl = rownonmiss(preg1calif preg1justificacion preg2calif preg2justificacion preg3calif preg3justificacion preg4calif preg4justificacion preg5calif preg5justificacion califglobal prediccionmonto1 prediccionmonto2 fecha_fin prediccion_seleccion1 prediccion_seleccion2), strok
sort nombre fecha_fin
by nombre: gen pago_eval_compl = (eval_compl==16)
tab pago_eval_compl


/*CALIFICACIONES CONSISTENTES: $50 pesos si la calificaci�n global de la
demanda difiere menos de 1 punto de la calificaci�n que otro abogado
an�nimo le d� a la misma demanda*/
bysort nombre_archivo_original : gen desviacion_calif = abs(califglobal[1]-califglobal[2])
bysort nombre_archivo_original : gen pago_calif_consistente = (abs(califglobal[1]-califglobal[2])<=1)
tab pago_calif_consistente


/*PREDICCIONES: $50 pesos por cada una de las 5 predicciones descritas en el
apartado 3.b*/

/*
Para la primera predicci�n se tomar� en cuenta una serie de pron�sticos
estad�sticos con la que contamos. En cada demanda nuestro pron�stico
asigna un n�mero de puntos (probabilidad) para cada modo de t�rmino
(laudo y recibir cantidad positiva, laudo y recibir nada, conciliaci�n,
desistimiento y caducidad). Tambi�n sabemos el modo de t�rmino real.
Si el n�mero que t� elijas respecto al modo de t�rmino real se encuentra
en un rango +/- 20% de la predicci�n estad�stica que tenemos respecto
a ese modo de t�rmino, podr�s obtener el pago.
*/


gen pago_prediccion_calc = .
replace pago_prediccion_calc = inrange(predicciona, pr_em_5*(80), pr_em_5*(120)) ///
	if end_mode==5
replace pago_prediccion_calc = inrange(prediccionb, pr_em_3*(80), pr_em_3*(120)) ///
	if end_mode==3
replace pago_prediccion_calc = inrange(prediccionc, pr_em_1*(80), pr_em_1*(120)) ///
	if end_mode==1
replace pago_prediccion_calc = inrange(predicciond, pr_em_2*(80), pr_em_2*(120)) ///
	if end_mode==2
replace pago_prediccion_calc = inrange(prediccione, pr_em_4*(80), pr_em_4*(120)) ///
	if end_mode==4

	
*Si las predicciones no suman 100 se descalifican
egen sum_pred=rowtotal(predicciona prediccionb prediccionc predicciond prediccione)
replace pago_prediccion_calc=0 if sum_pred!=100
tab pago_prediccion_calc



/*
Para la segunda y tercera predicci�n obtendr�s el pago si aciertas en el
resultado de lo que verdaderamente ocurri� en la demanda.
*/
gen pago_prediccion_juez = .
replace pago_prediccion_juez = 1 ///
	if prediccion_seleccion1==1 & (!missing(totaldictaminador)) & modo_termino==3
replace pago_prediccion_juez = 1 ///
	if prediccion_seleccion1==2 & (missing(totaldictaminador)) & modo_termino==3

qui su pr_winning_judge, d
local med=r(p50)	
gen calc_prediccion_juez = .
replace calc_prediccion_juez = 1 ///
	if pr_winning_judge>`med' & (!missing(totaldictaminador)) & modo_termino==3
replace calc_prediccion_juez = 1 ///
	if pr_winning_judge<=`med' & (missing(totaldictaminador)) & modo_termino==3


gen pago_prediccion_resultado = .
replace pago_prediccion_resultado = 1 ///
	if prediccion_seleccion2==1 & (end_mode==3) & modo_termino==3
replace pago_prediccion_resultado = 1 ///
	if prediccion_seleccion2==2 & (end_mode==5) & modo_termino==3

su pr_pos_rec, d
local med=r(p50)		
gen calc_prediccion_resultado = .
replace calc_prediccion_resultado = 1 ///
	if pr_pos_rec<=`med' & (end_mode==3) & modo_termino==3
replace calc_prediccion_resultado = 1 ///
	if pr_pos_rec>`med' & (end_mode==5) & modo_termino==3


/*
Para la cuarta predicci�n obtendr�s el pago en caso de que el juicio
acabara en laudo, el trabajador cobrara una cantidad positiva y la
cantidad que digas se encuentre en un rango de +/- 20% alrededor del
monto que en realidad obtuvo el trabajador.
*/

gen pago_prediccion_cant = .
replace pago_prediccion_cant = inrange(prediccionmonto1, liq_total_tope*(0.8), liq_total_tope*(1.2)) ///
	if end_mode==5
replace pago_prediccion_cant = inrange(prediccionmonto2, liq_total_tope*(0.8), liq_total_tope*(1.2)) ///
	if end_mode==1
tab pago_prediccion_cant

gen calc_prediccion_cant_ols = .
replace calc_prediccion_cant_ols = inrange(pr_liq_total_ols, liq_total_tope*(0.8), liq_total_tope*(1.2)) ///
	if end_mode==5 | end_mode==1


********************************************************************************
*Prediction table percentage

gen cr=(inlist(end_mode,3,5))
gen sett=(end_mode==1)

*Info by lawyer
collapse (sum) pago_prediccion*  ///
			(sum) calc_prediccion* (sum) cr (sum) sett , by(nombre)

*Relative terms
replace pago_prediccion_calc=pago_prediccion_calc/125*100
replace pago_prediccion_juez=pago_prediccion_juez/cr*100
replace pago_prediccion_resultado=pago_prediccion_resultado/cr*100
replace pago_prediccion_cant=pago_prediccion_cant/(cr+sett)*100

egen total_lawyer=rowmean(pago_prediccion*)

replace calc_prediccion_juez=calc_prediccion_juez/cr*100
replace calc_prediccion_resultado=calc_prediccion_resultado/cr*100
replace calc_prediccion_cant=calc_prediccion_cant/(cr+sett)*100

egen total_calc=rowmean(calc_prediccion*)


order nombre pago_prediccion_calc pago_prediccion_juez calc_prediccion_juez ///
	pago_prediccion_resultado calc_prediccion_resultado ///
	pago_prediccion_cant  calc_prediccion_cant total_lawyer total_calc	


