__includes [
  "./entidades/puertos.nls"
  "./entidades/celdas.nls"
  "./entidades/embarcaciones.nls"
  "./entidades/plataformas.nls"
  "./entidades/tortugas.nls"
  "./entidades/buques.nls"
  "./submodelos/paisaje.nls"
  "./submodelos/ecologia.nls"
  "./submodelos/hidrocarburo.nls"
  "./submodelos/zonificacion.nls"
  "./submodelos/vedas.nls"
  "./utils/visualizacion.nls"
  "./utils/globales_ayudadoras.nls"
  "./utils/A_star_pathfinder.nls"
  "./utils/registros_y_salidas.nls"
  "./utils/helper_functions.nls"
  "./utils/criterios_juego.nls"
]

extensions [ profiler ]

to INICIALIZAR

  reset-timer
  print "==========================\nInicializando modelo..."

  clear-all

  if not PRUEBA? [
    init_ronda
    init_variables_jugables
    ;; TODO: inicializar parámetros fijos
    ;init_parametros
  ]

  init_globales
  init_celdas
  init_A_star_pathfinder
  init_paisaje
  init_regiones
  init_ecologia
  init_tortugas
  init_hidrocarburo
  init_zonificacion
  init_puertos
  init_plataformas
  init_buques
  init_embarcaciones
  init_vedas
  init_rutas
  init_registros
  init_umbrales_juego

  init_indicadores

  init_visualizacion
  colorear_celdas
  colocar_etiquetas_regiones
  reset-ticks

  print (word "Inicialización completada.\nTiempo: " timer " seg\n==========================")
end


to EJECUTAR
  if ticks = 0 [ reset-timer ]
  if PRUEBA? [
    if ticks = 0 [ profiler:start ]
    if ano = ANOS_PRUEBA [ profiler:stop print profiler:report print timer profiler:reset stop ]
  ]
  ;; jugabilidad
  if paso_un_dia? [ actualizar_tiempos_sostenibilidad ]
  if paso_un_mes? [ revisar_umbrales_juego ]
  if MOSTRAR_MENSAJES? and mensajes_juego != [] [ foreach mensajes_juego [ m -> user-message m ] set mensajes_juego []]
  if DETENER_SI_PIERDE? and perdio? [ stop ]
  ;; se resetean los registros
  if paso_un_dia? [
    ask puertos [ reset_registros_diarios_puerto ]
    reset_registros_diarios_todo
    reset_registros_diarios_hidrocarburo
  ]
  if paso_un_mes? and ticks != 0 [
    ;; cada inicio de mes se actualiza el estado económico y luego se resetean los registros del mes
    ask embarcaciones [
      actualizar_estado_economico
      reset_registros_mensuales_embarcacion
    ]
    registros_promedios_mensuales
    ask puertos [ reset_registros_mensuales_puerto  ]
    ask plataformas [ actualizar_estado_plataformas ]
    reset_registros_mensuales_hidrocarburo
  ]
  ;;pesca
  ask embarcaciones [ dinamica_iteracion_embarcacion ]
  ;; ecología
  if paso_un_dia? [
    dispersion
    dinamica_poblacional
  ]
  ;; petroleo
  if paso_un_dia? [ ask plataformas [ extraer_hidrocarburo ] ]
  ask buques [ dinamica_iteracion_buque ]
  if paso_un_dia? [
;    calcular_balance_hidrocarburo
    dinamica_derrame
  ]
  if paso_un_mes? [ subsidiar_gasolina  ]
  ;; tortugas
  if paso_un_dia? [ dinamica_tortugas ]
  ;; se actualiza la fecha, Nótese que con tick se actualizan las gráficas
  ;; y se exportan los datos por lo que debe graficarse y exportarse antes de que se reseteen los
  ;; registros mensuales (que ocurren al iniciar la iteración)
  actualizar_fecha
  ;; visualizacion
  colorear_celdas
  tick
;  if paso_un_dia? [ print (word "Paso un día, tick = " ticks "; dia =" (time:get "day" fecha) "; dia año = " (time:get "dayofyear" fecha) ) ]
;  if paso_un_ano? and any? embarcaciones [ print mean [tortugas_matadas] of embarcaciones / ano ]
end
@#$#@#$#@
GRAPHICS-WINDOW
320
65
832
494
-1
-1
14.0
1
10
1
1
1
0
0
0
1
0
35
0
29
1
1
1
ticks
30.0

BUTTON
15
355
165
400
NIL
INICIALIZAR
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
165
355
310
400
NIL
EJECUTAR
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
310
520
580
565
COLOREAR_POR
COLOREAR_POR
"tipo" "biomasa total" "biomasa total especie" "zonificacion" "biomasa, zonificacion y derrames" "biomasa y derrames" "hidrocarburo" "derrames"
4

SLIDER
2490
560
2665
593
NUM_PUERTOS
NUM_PUERTOS
1
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
2720
40
2995
73
NUM_EMBARCACIONES_PUERTO_1
NUM_EMBARCACIONES_PUERTO_1
0
1000
300.0
1
1
NIL
HORIZONTAL

SLIDER
3000
40
3275
73
NUM_EMBARCACIONES_PUERTO_2
NUM_EMBARCACIONES_PUERTO_2
0
500
0.0
1
1
NIL
HORIZONTAL

SLIDER
3280
40
3555
73
NUM_EMBARCACIONES_PUERTO_3
NUM_EMBARCACIONES_PUERTO_3
0
500
0.0
1
1
NIL
HORIZONTAL

MONITOR
920
10
1010
55
embarcaciones
count embarcaciones
0
1
11

CHOOSER
2490
215
2715
260
SELECCION_SITIO_PESCA
SELECCION_SITIO_PESCA
"EEI en radio" "EEI en region" "EEI en radio y region" "aleatorio"
0

SLIDER
2490
455
2665
488
LONG_REGION_1
LONG_REGION_1
0
50
50.0
1
1
NIL
HORIZONTAL

SLIDER
2490
490
2665
523
LONG_REGION_2
LONG_REGION_2
0
50
12.0
1
1
NIL
HORIZONTAL

SLIDER
2490
525
2665
558
LONG_REGION_3
LONG_REGION_3
0
50
13.0
1
1
NIL
HORIZONTAL

CHOOSER
2720
75
2995
120
REGION_PESCA_EMBARCACIONES_PUERTO_1
REGION_PESCA_EMBARCACIONES_PUERTO_1
1 2 3
0

CHOOSER
3000
75
3275
120
REGION_PESCA_EMBARCACIONES_PUERTO_2
REGION_PESCA_EMBARCACIONES_PUERTO_2
1 2 3
1

CHOOSER
3280
75
3555
120
REGION_PESCA_EMBARCACIONES_PUERTO_3
REGION_PESCA_EMBARCACIONES_PUERTO_3
1 2 3
2

SLIDER
2490
40
2715
73
RADIO_EXPLORAR
RADIO_EXPLORAR
0
10
1.0
1
1
pixeles
HORIZONTAL

SLIDER
2490
75
2715
108
EPSILON
EPSILON
0
1
0.2
0.01
1
NIL
HORIZONTAL

SWITCH
2490
260
2715
293
CAMBIAR_SITIO_PESCA?
CAMBIAR_SITIO_PESCA?
1
1
-1000

SLIDER
2490
145
2715
178
NUM_AMIGOS
NUM_AMIGOS
0
5
2.0
1
1
amigos
HORIZONTAL

SLIDER
2490
180
2715
213
VELOCIDAD
VELOCIDAD
0
100
5.0
0.1
1
km/hora
HORIZONTAL

SLIDER
2720
120
2995
153
CAPTURABILIDAD_PUERTO_1
CAPTURABILIDAD_PUERTO_1
0
1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
2720
155
2995
188
CAPACIDAD_MAXIMA_PUERTO_1
CAPACIDAD_MAXIMA_PUERTO_1
1
100
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
2720
255
2995
288
HORAS_MAXIMAS_EN_MAR_PUERTO_1
HORAS_MAXIMAS_EN_MAR_PUERTO_1
1
480
120.0
1
1
NIL
HORIZONTAL

CHOOSER
2290
405
2475
450
DISTRIBUCION_ESPECIES
DISTRIBUCION_ESPECIES
"homogenea" "partes iguales" "dif spp en cada region"
0

SLIDER
2290
40
2475
73
NUM_ESPECIES
NUM_ESPECIES
1
3
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
2290
75
2475
140
BIOMASAS_INICIALES
[5000 5000 5000]
1
0
String

SLIDER
2720
440
2945
473
PRECIO_LITRO_GAS
PRECIO_LITRO_GAS
0
30
0.01
0.01
1
$
HORIZONTAL

SLIDER
2720
475
2945
508
LITROS_POR_DISTANCIA
LITROS_POR_DISTANCIA
0
10
10.0
0.1
1
NIL
HORIZONTAL

SLIDER
2720
510
2945
543
LITROS_POR_HORA_PESCA
LITROS_POR_HORA_PESCA
0
5
5.0
0.01
1
NIL
HORIZONTAL

INPUTBOX
2290
140
2475
205
Ks
[500 500 500]
1
0
String

PLOT
845
125
1005
245
captura total
dias
ton
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" ";;if paso_un_dia [plotxy dias sum capturas_dia_todo]"
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and any? puertos with [num_puerto = 0] [plotxy dias sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_mes? and any? puertos with [num_puerto = 1] [plotxy dias sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 1]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_mes? and any? puertos with [num_puerto = 2] [plotxy dias sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 2]]"
"pen-4" 1.0 0 -7500403 true "" ";;if paso_un_dia and any? puertos with [num_puerto = 0] [plotxy dias sum [capturas_dia_puerto] of one-of puertos with [num_puerto = 0]]"
"pen-5" 1.0 0 -4539718 true "" ";;if paso_un_dia? and any? puertos with [num_puerto = 0] [plotxy dias sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]]"
"pen-7" 1.0 0 -955883 true "" ";;if member? ticks ticks_registros_mes\n;;[ plotxy dias sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]] "
"pen-8" 1.0 0 -2674135 true "" "if member? ticks  [ 0 31 60 91 121 152 182 213 244 274 305 335 366 397 425 456 486 517 547 578 609 639 670 700 731 762 790 821 851 882 912 943 974 1004 1035 1065 1096 1127 1155 1186 1216 1247 1277 1308 1339 1369 1400 1430 1461 1492 1521 1552 1582 1613 1643 1674 1705 1735 1766 1796 1827 1858 1886 1917 1947 1978 2008 2039 2070 2100 2131 2161 2192 2223 2251 2282 2312 2343 2373 2404 2435 2465 2496 2526 2557 2588 2616 2647 2677 2708 2738 2769 2800 2830 2861 2891 2922 2953 2982 3013 3043 3074 3104 3135 3166 3196 3227 3257 3288 3319 3347 3378 3408 3439 3469 3500 3531 3561 3592 3622 3653 ] \n[ plotxy dias sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]] "

PLOT
845
365
1005
485
gasto gasolina promedio
dias
$
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" ";;if paso_un_dia and gastos_gasolina_dia_todo != [] [ plotxy dias mean gastos_gasolina_dia_todo ]"
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 0] [\nifelse [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias mean [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 1] [\nifelse [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias mean [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 2] [\nifelse [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias mean [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 2]]\n[plotxy dias 0 ]]"

PLOT
845
245
1005
365
ganancia total
dias
$
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"promedio" 1.0 0 -16777216 true "" ";;if paso_un_dia and ganancias_dia_todo != [] [ plotxy dias mean ganancias_dia_todo ] "
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 0] [\nifelse [ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias [sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 1] [\nifelse [ganancias_mes_puerto] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias [sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 2] and \n[ganancias_mes_puerto] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias [sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 2]]"
"0" 1.0 0 -4539718 true "" "if paso_un_dia? [ plotxy dias 0 ]"

CHOOSER
2490
295
2715
340
SELELECCION_SITIO_PESCA_CONTINUACION
SELELECCION_SITIO_PESCA_CONTINUACION
"EEI" "mejor vecino" "un vecino"
2

CHOOSER
2490
340
2715
385
SELECCION_MEJOR_SITIO
SELECCION_MEJOR_SITIO
"inicio de viaje" "mayor captura en viaje"
0

INPUTBOX
2290
340
2475
405
Ms
[.001 .001 .001]
1
0
String

PLOT
1375
285
1575
445
biomasa
dias
biomasa
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" ";;if paso_un_dia [plotxy dias sum [sum biomasas] of patches]"
"especie 1" 1.0 0 -11221820 true "" "if paso_un_dia? and _num_especies > 0 [plotxy dias sum[item 0 biomasas] of patches]"
"especie 2" 1.0 0 -13791810 true "" "if paso_un_dia? and _num_especies > 1 [plotxy dias sum[item 1 biomasas] of patches]"
"especie 3" 1.0 0 -14070903 true "" "if paso_un_dia? and _num_especies > 2 [plotxy dias sum[item 2 biomasas] of patches]"

INPUTBOX
2290
205
2475
270
Rs_min
[0.7 0.7 0.7]
1
0
String

MONITOR
770
10
835
55
total dias 
dias
0
1
11

MONITOR
315
10
365
55
año
ano
0
1
11

SLIDER
3000
120
3275
153
CAPTURABILIDAD_PUERTO_2
CAPTURABILIDAD_PUERTO_2
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
3000
155
3275
188
CAPACIDAD_MAXIMA_PUERTO_2
CAPACIDAD_MAXIMA_PUERTO_2
0
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
3280
120
3555
153
CAPTURABILIDAD_PUERTO_3
CAPTURABILIDAD_PUERTO_3
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
3280
155
3555
188
CAPACIDAD_MAXIMA_PUERTO_3
CAPACIDAD_MAXIMA_PUERTO_3
0
20
1.0
1
1
NIL
HORIZONTAL

SLIDER
3000
255
3275
288
HORAS_MAXIMAS_EN_MAR_PUERTO_2
HORAS_MAXIMAS_EN_MAR_PUERTO_2
1
480
1.0
1
1
NIL
HORIZONTAL

SLIDER
3280
255
3555
288
HORAS_MAXIMAS_EN_MAR_PUERTO_3
HORAS_MAXIMAS_EN_MAR_PUERTO_3
1
480
1.0
1
1
NIL
HORIZONTAL

PLOT
1005
125
1165
245
distancia recorrida promedio
dias
km
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 0] [\nifelse [distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias [mean distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0] *  longitud_celda]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 1] [\nifelse [distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias [mean distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 1] *  longitud_celda]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 2] [\nifelse [distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias [mean distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 2] *  longitud_celda]\n[plotxy dias 0 ]]"
"referencia zona 1" 1.0 0 -7500403 true "" "if paso_un_dia? [ plotxy dias 20 ]"

PLOT
1005
245
1165
365
horas en mar promedio
dias
hrs
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 0] [\nifelse [horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias [mean horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 1] [\nifelse [horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias [mean horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 2] [\nifelse [horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias [mean horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 2]]\n[plotxy dias 0 ]]"
"pen-3" 1.0 0 -7500403 true "" "if paso_un_dia? [ plotxy dias 8 ]"

PLOT
845
485
1005
605
salario mensual pescador
dias
$
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 0][\nifelse any? embarcaciones with [[num_puerto] of mi_puerto = 0 and activo?] \n[ plotxy dias mean [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0]]\n[ plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if ticks = 0 or paso_un_mes? and \nany? puertos with [num_puerto = 1][\nifelse any? embarcaciones with [[num_puerto] of mi_puerto = 1 and activo?] \n[ plotxy dias mean [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 1 ]]\n[ plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if ticks = 0 or paso_un_mes? and \nany? puertos with [num_puerto = 2][\nifelse any? embarcaciones with [[num_puerto] of mi_puerto = 2 and activo?] \n[ plotxy dias mean [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 2 ]]\n[ plotxy dias 0 ]]"
"umbral" 1.0 0 -4539718 true "" "if ticks = 0 or paso_un_mes? [plotxy dias SALARIO_MENSUAL_MINIMO_ACEPTABLE ]"

PLOT
1005
365
1165
485
viajes finalizados promedio
dias
num
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 0] [\nifelse [horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0]  != []\n[ plotxy dias sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES ]\n[ plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 1] [\nifelse [horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 1]  != []\n[ plotxy dias sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 1]]\n[ plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_mes? and \nany? puertos with [num_puerto = 2] [\nifelse [horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 2]  != []\n[ plotxy dias mean [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 2]]\n[ plotxy dias 0 ]]"
"pen-3" 1.0 0 -7500403 true "" "if paso_un_dia? [ plotxy dias 15 ]"

SLIDER
1990
40
2275
73
HIDROCARBURO_INICIAL
HIDROCARBURO_INICIAL
0
10000
10000.0
100
1
NIL
HORIZONTAL

BUTTON
1990
575
2225
608
NIL
SELECCIONAR_ZONAS_PROTEGER
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1990
540
2225
573
NIL
SELECCIONAR_ZONAS_RESTRICCION
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
1990
505
2225
538
NIL
COLOCAR_PLATAFORMAS
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
575
10
640
55
NIL
timer
2
1
11

MONITOR
640
10
705
55
minutos
timer / 60
2
1
11

SLIDER
15
215
310
248
RADIO_RESTRICCION_PLATAFORMAS
RADIO_RESTRICCION_PLATAFORMAS
0
10
3.0
1
1
pixeles
HORIZONTAL

SLIDER
1990
75
2275
108
TASA_DECLINACION_HIDROCARBURO
TASA_DECLINACION_HIDROCARBURO
0
0.01
0.001
0.001
1
NIL
HORIZONTAL

PLOT
1170
125
1370
285
producción diaria hidrocarburo 
dias
barriles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 1 -16777216 true "" "if paso_un_dia? [ plotxy dias produccion_dia_hidrocarburo]"

SLIDER
1990
110
2275
143
COSTO_TRANSPORTE_POR_UNIDAD_DISTANCIA
COSTO_TRANSPORTE_POR_UNIDAD_DISTANCIA
0
1000
500.0
10
1
NIL
HORIZONTAL

SLIDER
1990
145
2275
178
PRECIO_CRUDO
PRECIO_CRUDO
0
100000
100000.0
100
1
$
HORIZONTAL

BUTTON
580
520
710
565
NIL
colorear_celdas
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
3880
335
4175
368
SUBSIDIO_MENSUAL_GASOLINA
SUBSIDIO_MENSUAL_GASOLINA
0
20000
0.0
100
1
$/embarcacion
HORIZONTAL

SLIDER
15
180
310
213
NUMERO_DE_PLATAFORMAS
NUMERO_DE_PLATAFORMAS
0
30
0.0
1
1
plataformas
HORIZONTAL

CHOOSER
3880
230
4175
275
REGION_DE_PLATAFORMAS
REGION_DE_PLATAFORMAS
1 2 3
0

SLIDER
1990
180
2275
213
MAX_PROB_OCURRENCIA_DERRAME
MAX_PROB_OCURRENCIA_DERRAME
0
1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
1990
250
2275
283
PROB_EXTENSION_DERRAME
PROB_EXTENSION_DERRAME
0
1
0.35
0.01
1
NIL
HORIZONTAL

SLIDER
1990
285
2275
318
TIEMPO_DERRAMADO
TIEMPO_DERRAMADO
0
100
50.0
1
1
NIL
HORIZONTAL

SLIDER
1990
320
2275
353
TASA_MORTALIDAD_DERRAME
TASA_MORTALIDAD_DERRAME
0
1
0.5
0.01
1
NIL
HORIZONTAL

PLOT
1375
445
1575
605
numero de tortugas
dias
tortugas
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -13840069 true "" "if paso_un_dia? [ plotxy dias count tortugas ]"

SLIDER
1695
35
1975
68
TAMANIO_POB_INICIAL_TORTUGAS
TAMANIO_POB_INICIAL_TORTUGAS
0
300
100.0
1
1
NIL
HORIZONTAL

SLIDER
1695
105
1975
138
CAPACIDAD_CARGA_TORTUGAS
CAPACIDAD_CARGA_TORTUGAS
1
20
2.0
1
1
NIL
HORIZONTAL

SLIDER
1695
275
1975
308
PROB_MORTALIDAD_TORTUGA_POR_PESCA
PROB_MORTALIDAD_TORTUGA_POR_PESCA
0
0.1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
1695
70
1975
103
NUM_DESCENDIENTES_TORTUGAS
NUM_DESCENDIENTES_TORTUGAS
1
5
1.0
1
1
NIL
HORIZONTAL

SLIDER
3565
160
3845
193
MESES_PARA_COLAPSO_EMBARCACION
MESES_PARA_COLAPSO_EMBARCACION
0
12
2.0
1
1
NIL
HORIZONTAL

SWITCH
3225
375
3335
408
VEDA_ENE
VEDA_ENE
1
1
-1000

MONITOR
365
10
415
55
mes
time:show fecha \"MM\"
2
1
11

MONITOR
415
10
465
55
día
time:show fecha \"dd\"
17
1
11

SWITCH
3225
445
3335
478
VEDA_MAR
VEDA_MAR
1
1
-1000

SWITCH
3335
375
3445
408
VEDA_MAY
VEDA_MAY
1
1
-1000

SWITCH
3335
445
3445
478
VEDA_JUL
VEDA_JUL
1
1
-1000

SWITCH
3445
375
3555
408
VEDA_SEP
VEDA_SEP
1
1
-1000

SWITCH
3445
445
3555
478
VEDA_NOV
VEDA_NOV
1
1
-1000

PLOT
1170
285
1370
445
produccion acumulada petroleo
dias
barriles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "if paso_un_dia? [ plotxy dias produccion_total_hidrocarburo ]"

PLOT
1170
445
1370
605
ganancia petroleo
dias
$ (MDP)
0.0
10.0
0.0
1000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if paso_un_mes? [ plotxy dias ganancia_mes_hidrocarburo ]\n"
"umbral" 1.0 0 -7500403 true "" "if paso_un_dia? [ plotxy dias 0]"

CHOOSER
3880
185
4175
230
REGION_DONDE_PESCAR
REGION_DONDE_PESCAR
"Linea de costa: camarón" "Plataformas: escama" "Profundo: huachinango"
0

TEXTBOX
20
60
170
78
SECTOR PESQUERO
12
0.0
1

SLIDER
15
80
310
113
NUMERO_EMBARCACIONES
NUMERO_EMBARCACIONES
0
300
300.0
10
1
embarcaciones
HORIZONTAL

CHOOSER
15
115
310
160
TIPO_DE_EMBARCACIONES
TIPO_DE_EMBARCACIONES
"pequeña escala (1 ton, 3 tripulantes)" "semi-industrial (10 ton, 5 tripulantes)"
0

SLIDER
2720
290
2995
323
TAMANIO_TRIPULACION_PUERTO_1
TAMANIO_TRIPULACION_PUERTO_1
3
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
3000
290
3275
323
TAMANIO_TRIPULACION_PUERTO_2
TAMANIO_TRIPULACION_PUERTO_2
3
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
3280
290
3555
323
TAMANIO_TRIPULACION_PUERTO_3
TAMANIO_TRIPULACION_PUERTO_3
3
10
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
2490
10
2640
28
PESCA
12
0.0
1

TEXTBOX
20
165
170
183
SECTOR PETROLERO
12
0.0
1

INPUTBOX
2720
370
2945
440
PRECIOS_KILO_BIOMASA
[10 20 20 ]
1
0
String

SLIDER
3565
125
3845
158
SALARIO_MENSUAL_MINIMO_ACEPTABLE
SALARIO_MENSUAL_MINIMO_ACEPTABLE
0
20000
7000.0
1000
1
$/mes
HORIZONTAL

PLOT
1005
485
1165
605
estado económico embarcaciones
dias
num
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"viable" 1.0 0 -13840069 true "" "if paso_un_mes? [ plotxy dias count embarcaciones with [ estado_economico = \"viable\" ]]"
"crisis" 1.0 0 -1184463 true "" "if paso_un_mes? [ plotxy dias count embarcaciones with [ estado_economico = \"crisis\" ]]"
"quiebra" 1.0 0 -2674135 true "" "if paso_un_mes? [ plotxy dias count embarcaciones with [ estado_economico = \"quiebra\" ]]"

SLIDER
3880
275
4175
308
GASTO_EN_MANTENIMIENTO
GASTO_EN_MANTENIMIENTO
0
5
0.0
1
1
MDP/plataforma
HORIZONTAL

SLIDER
1990
215
2275
248
MIN_PROB_OCURRENCIA_DERRAME
MIN_PROB_OCURRENCIA_DERRAME
0
1
0.005
0.001
1
NIL
HORIZONTAL

MONITOR
1210
305
1275
350
derrames
num_derrames
0
1
11

TEXTBOX
2290
10
2440
28
ECOLOGIA PESCA
12
0.0
1

TEXTBOX
1995
10
2145
28
HIDROCARBUROS
12
0.0
1

CHOOSER
15
10
310
55
RONDA
RONDA
"NA" "Ronda 1, 2, 3 (sector pesquero)" "Ronda 1, 2, 3 (sector petrolero)" "Ronda 1, 2, 3 (sector conservación)" "Ronda 4 (exclusión)" "Ronda 5 (reconversión)" "Ronda 6 (coexistencia)" "Ronda 7 (comanejo)"
0

TEXTBOX
20
255
170
273
SECTOR CONSERVACIÓN
12
0.0
1

TEXTBOX
845
25
915
43
ENTRADAS
12
0.0
1

TEXTBOX
845
70
920
88
SALIDAS
12
0.0
1

MONITOR
1010
10
1095
55
región pesca
REGION_PESCA_EMBARCACIONES_PUERTO_1
17
1
11

MONITOR
1105
10
1180
55
plataformas
count plataformas
17
1
11

MONITOR
1180
10
1260
55
región plataformas
REGION_DE_PLATAFORMAS
17
1
11

MONITOR
1275
10
1350
55
área restricción
count patches with [ zonificacion = \"restriccion\" ]
17
1
11

MONITOR
1350
10
1477
55
área protegida (ha)
count patches with [ zonificacion = \"protegido\" ] * (longitud_celda ^ 2) * 100
0
1
11

MONITOR
1010
60
1075
105
captura
(word (round captura_prom_ultimo_mes) \" ton\")
0
1
11

MONITOR
1075
60
1145
105
ganancia
(word \"$ \" round ganancia_prom_ultimo_mes)
0
1
11

MONITOR
1145
60
1220
105
gasto gasolina
(word \"$ \" round gasto_gasolina_prom_ultimo_mes)
0
1
11

MONITOR
1450
60
1530
105
biomasa
sum [sum biomasas] of patches
0
1
11

MONITOR
1530
60
1610
105
tortugas
count tortugas
0
1
11

MONITOR
1375
110
1565
155
NIL
tiempo_pesca_sostenible
0
1
11

MONITOR
1375
155
1565
200
NIL
tiempo_hidrocarburo_sostenible
0
1
11

MONITOR
1375
200
1565
245
NIL
tiempo_biomasa_sostenible
17
1
11

TEXTBOX
2495
400
2645
418
PAISAJE
12
0.0
1

TEXTBOX
1700
10
1850
28
ECOLOGIA TORTUGAS
12
0.0
1

SLIDER
1695
175
1975
208
DIA_REPRODUCCION_TORTUGAS
DIA_REPRODUCCION_TORTUGAS
1
365
182.0
1
1
NIL
HORIZONTAL

TEXTBOX
3570
105
3720
123
JUGABILIDAD
12
0.0
1

INPUTBOX
2290
450
2475
515
DIAS_REPRODUCCION
[180 200 200 ]
1
0
String

INPUTBOX
2290
270
2475
340
Rs_max
[0.7 0.7 0.7]
1
0
String

INPUTBOX
2720
190
2995
255
ESPECIES_PESCA_PUERTO_1
[ 1 0 0 ]
1
0
String

INPUTBOX
3000
190
3275
255
ESPECIES_PESCA_PUERTO_2
[1 1 1]
1
0
String

INPUTBOX
3280
190
3555
255
ESPECIES_PESCA_PUERTO_3
[1 1 1]
1
0
String

SLIDER
2490
420
2665
453
LONG_TIERRA
LONG_TIERRA
1
6
6.0
1
1
NIL
HORIZONTAL

SWITCH
1695
380
1815
413
PRUEBA?
PRUEBA?
1
1
-1000

SLIDER
1990
390
2275
423
VELOCIDAD_BUQUES
VELOCIDAD_BUQUES
0
10
0.48
0.01
1
NIL
HORIZONTAL

INPUTBOX
1695
415
1815
480
ANOS_PRUEBA
100.0
1
0
Number

SLIDER
15
270
310
303
ANCHO_ZONA_PROTEGIDA
ANCHO_ZONA_PROTEGIDA
0
17
0.0
1
1
pixeles
HORIZONTAL

SLIDER
15
305
310
338
LARGO_ZONA_PROTEGIDA
LARGO_ZONA_PROTEGIDA
0
35
23.0
1
1
pixeles
HORIZONTAL

TEXTBOX
1990
480
2140
498
EDICIÓN INTERACTIVA
12
0.0
1

MONITOR
920
60
1010
105
embarcaciones activas
count embarcaciones with [ activo? ]
17
1
11

SLIDER
2720
325
2995
358
HORAS_DESCANSAR_PUERTO_1
HORAS_DESCANSAR_PUERTO_1
0
300
12.0
1
1
NIL
HORIZONTAL

SLIDER
3000
325
3275
358
HORAS_DESCANSAR_PUERTO_2
HORAS_DESCANSAR_PUERTO_2
0
100
72.0
1
1
NIL
HORIZONTAL

SLIDER
3280
325
3555
358
HORAS_DESCANSAR_PUERTO_3
HORAS_DESCANSAR_PUERTO_3
0
100
72.0
1
1
NIL
HORIZONTAL

TEXTBOX
3875
15
4405
166
Region 1:\nviajar 5-6 veces a la semana -> HORAS_DESCANSAR_PUERTO_1 = 30 -> 5.6 veces por semana, 1.6-4.2-9 horas en mar..., 9-45-30 km\nRegion 2:\nviajar 2-3 veces a la semana -> HORAS_DESCANSAR_PUERTO_1 = 72 -> 2.5 veces por semana, 2-4.6-9 horas en mar..., 32-73-? km\nRegion 3:\nviajar 0.5 veces a la semana -> HORAS_DESCANSAR_PUERTO_1 = 300 -> 0.6 veces por semana, 3.3-6-? horas en mar..., 87-93-? km
12
0.0
1

SWITCH
3880
370
4175
403
VEDA_TEMPORAL
VEDA_TEMPORAL
1
1
-1000

SWITCH
3225
410
3335
443
VEDA_FEB
VEDA_FEB
1
1
-1000

SWITCH
3225
480
3335
513
VEDA_ABR
VEDA_ABR
1
1
-1000

SWITCH
3335
410
3445
443
VEDA_JUN
VEDA_JUN
1
1
-1000

SWITCH
3335
480
3445
513
VEDA_AGO
VEDA_AGO
1
1
-1000

SWITCH
3445
410
3555
443
VEDA_OCT
VEDA_OCT
1
1
-1000

SWITCH
3445
480
3555
513
VEDA_DIC
VEDA_DIC
1
1
-1000

TEXTBOX
3885
315
4035
333
POLÍTICAS
12
0.0
1

SWITCH
1695
480
1885
513
DETENER_SI_PIERDE?
DETENER_SI_PIERDE?
1
1
-1000

MONITOR
1375
245
1565
290
NIL
tiempo_tortugas_sostenible
17
1
11

SWITCH
1695
515
1885
548
MOSTRAR_MENSAJES?
MOSTRAR_MENSAJES?
1
1
-1000

SWITCH
2290
515
2475
548
BIOMASA_INICIAL_K?
BIOMASA_INICIAL_K?
0
1
-1000

SLIDER
1990
355
2275
388
MORTALIDAD_TORTUGAS_DERRAME
MORTALIDAD_TORTUGAS_DERRAME
0
1
0.15
0.01
1
NIL
HORIZONTAL

INPUTBOX
1695
210
1975
275
MESES_MIGRACION
[ 5 10 ]
1
0
String

SLIDER
2490
110
2715
143
PROB_EXP_REGION
PROB_EXP_REGION
0
1
0.1
0.01
1
NIL
HORIZONTAL

MONITOR
3560
40
3740
85
tortugas matadas/ embarcacion
mean [tortugas_matadas] of embarcaciones
2
1
11

SLIDER
3565
230
3845
263
BIOMASA_CRISIS
BIOMASA_CRISIS
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
3565
265
3845
298
BIOMASA_COLAPSO
BIOMASA_COLAPSO
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
3565
300
3845
333
PESCA_COLAPSO
PESCA_COLAPSO
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
3565
335
3845
368
TORTUGAS_CRISIS
TORTUGAS_CRISIS
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
3565
370
3845
403
TORTUGAS_COLAPSO
TORTUGAS_COLAPSO
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
3565
440
3845
473
HIDROCARBURO_COLAPSO
HIDROCARBURO_COLAPSO
0
100
0.0
1
1
%
HORIZONTAL

SLIDER
3565
195
3845
228
MESES_PARA_COLAPSO_PLATAFORMA
MESES_PARA_COLAPSO_PLATAFORMA
0
12
3.0
1
1
NIL
HORIZONTAL

SLIDER
3565
405
3845
438
HIDROCARBURO_CRISIS
HIDROCARBURO_CRISIS
0
100
75.0
1
1
%
HORIZONTAL

SLIDER
1695
140
1975
173
TIEMPO_BUFFER_TORTUGAS
TIEMPO_BUFFER_TORTUGAS
0
180
90.0
1
1
dias
HORIZONTAL

SLIDER
1990
425
2277
458
EXTRACCION_MAX_HIDROCARBURO
EXTRACCION_MAX_HIDROCARBURO
0
100
5.0
1
1
NIL
HORIZONTAL

MONITOR
1280
60
1360
105
horas en mar
horas_en_mar_prom_ultimo_mes
2
1
11

MONITOR
1220
60
1282
105
distancia
(word precision distancia_recorrida_prom_ultimo_mes 2 \" km\")
0
1
11

MONITOR
1360
60
1450
105
numero viajes promedio
precision viajes_prom_ultimo_mes 2
2
1
11

SWITCH
3665
500
3905
533
INACTIVAR_PESCA?
INACTIVAR_PESCA?
1
1
-1000

SWITCH
3665
535
3905
568
INACTIVAR_HIDROCARBURO?
INACTIVAR_HIDROCARBURO?
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ancla
false
0
Polygon -1 true false 120 240 90 225 75 195 45 180 30 210 45 270 105 300 195 300 255 270 270 210 255 180 225 195 210 210 195 240
Rectangle -1 true false 60 90 240 150
Rectangle -1 true false 120 75 180 300
Circle -1 true false 108 3 85
Polygon -7500403 true true 45 195 45 210 60 255 105 285 165 285 165 75 135 75 135 255 120 255 75 225 75 210 60 195
Polygon -7500403 true true 255 195 255 210 240 255 195 285 135 285 135 75 165 75 165 255 180 255 225 225 225 210 240 195
Circle -7500403 true true 116 11 67
Rectangle -7500403 true true 75 105 225 135

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

barco
false
1
Polygon -7500403 true false 30 150 150 180 270 150 150 210
Polygon -1 true false 90 240 90 240 30 150 150 210 90 240 90 240
Polygon -1 true false 210 240 210 240 270 150 150 210 210 240 210 240
Polygon -7500403 true false 90 240 210 240 150 210 90 240
Polygon -2674135 true true 150 210 150 120 210 180
Polygon -2674135 true true 150 210 150 120 90 180

barco crisis
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -1184463 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

barco quiebra
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -2674135 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

barco viable
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13840069 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

barco1
false
1
Polygon -7500403 true false 45 180 60 165 255 165 270 180 45 180
Polygon -1 true false 60 180 45 180 45 195 60 195 90 225 225 225 255 195 270 195 270 180 255 180
Polygon -1 true false 45 180 270 180 270 195 45 195 45 180 45 180
Rectangle -6459832 true false 150 60 165 180
Polygon -2674135 true true 150 60 90 150 150 165 150 60
Polygon -2674135 true true 165 60 225 150 165 165 165 60

boat
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat 3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

buque
false
0
Polygon -2674135 true false 0 150 45 150 120 150 300 150 300 195 270 240 30 240 0 180
Rectangle -16777216 true false 0 150 300 195
Rectangle -1 true false 15 105 90 150
Rectangle -16777216 true false 45 75 60 105
Rectangle -16777216 true false 15 75 90 90

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

camaron
false
0
Polygon -13791810 true false 120 60 180 135 210 45
Polygon -11221820 true false 210 45 255 120 180 135 180 135
Polygon -11221820 true false 255 120 180 135 255 195
Polygon -11221820 true false 180 135 180 240 255 195
Polygon -11221820 true false 180 180 180 240 105 210
Polygon -11221820 true false 150 195 60 180 105 210
Polygon -11221820 true false 120 195 60 135 60 180
Polygon -13791810 true false 60 180 30 150 30 120 60 165
Polygon -13791810 true false 60 165 45 120 45 90 75 150
Circle -16777216 true false 165 60 30
Polygon -13791810 true false 180 135 135 150 180 150
Polygon -13791810 true false 180 150 135 165 180 165
Polygon -13791810 true false 180 165 135 180 180 180

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

crab
false
0
Polygon -7500403 true true 60 135 30 105 60 60 60 120 75 120 75 60 105 105 75 135
Polygon -7500403 true true 225 135 195 105 225 60 225 120 240 120 240 60 270 105 240 135
Polygon -7500403 true true 150 135 240 165 225 210 150 210
Polygon -7500403 true true 150 135 60 165 75 210 150 210
Rectangle -7500403 true true 60 135 75 165
Rectangle -7500403 true true 225 135 240 165
Rectangle -7500403 true true 195 210 210 240
Rectangle -7500403 true true 90 210 105 240
Rectangle -7500403 true true 165 210 180 240
Rectangle -7500403 true true 120 210 135 240
Circle -1 true false 90 165 30
Circle -1 true false 180 165 30
Polygon -1 true false 135 180 165 180 150 195

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

escama
false
0
Polygon -11221820 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -11221820 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -11221820 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -13791810 true false 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

huachinango
false
0
Polygon -13791810 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -13791810 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -13791810 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -13345367 true false 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

plataforma
false
0
Polygon -1 true false 150 30 15 255 285 255
Polygon -7500403 true true 151 99 225 223 75 224

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tortuga
true
0
Polygon -13840069 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -13840069 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -13840069 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -13840069 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -13840069 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

vacio
true
0

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="calibracion_pesca_00" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>export-view (word "/home/lggj/PARA/proyectos/PePe_ecosur/modelo_PePe/calibarcion/output/imgs/" behaviorspace-experiment-name "-"  behaviorspace-run-number)</postRun>
    <timeLimit steps="366"/>
    <metric>sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>([sum distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0] *  longitud_celda) / NUMERO_EMBARCACIONES</metric>
    <metric>[sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>[sum horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 0]</metric>
    <metric>sum [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>count embarcaciones with [ estado_economico = "viable" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "crisis" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "quiebra" ]</metric>
    <metric>sum[item 0 biomasas] of patches</metric>
    <metric>sum[item 1 biomasas] of patches</metric>
    <metric>sum[item 2 biomasas] of patches</metric>
    <metric>count tortugas</metric>
    <metric>tiempo_pesca_sostenible</metric>
    <metric>tiempo_hidrocarburo_sostenible</metric>
    <metric>tiempo_biomasa_sostenible</metric>
    <metric>tiempo_tortugas_sostenible</metric>
    <metric>num_derrames</metric>
    <metric>produccion_mes_hidrocarburo</metric>
    <metric>produccion_total_hidrocarburo</metric>
    <metric>ganancia_mes_hidrocarburo</metric>
    <runMetricsCondition>member? ticks [ 0 31  60  91 121 152 182 213 244 274 305 335 366 ]</runMetricsCondition>
    <enumeratedValueSet variable="RONDA">
      <value value="&quot;NA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_EMBARCACIONES">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DONDE_PESCAR">
      <value value="&quot;Linea de costa: camarón&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_DE_PLATAFORMAS">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DE_PLATAFORMAS">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GASTO_EN_MANTENIMIENTO">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_TEMPORAL">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SUBSIDIO_MENSUAL_GASOLINA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TIPO_DE_EMBARCACIONES">
      <value value="&quot;pequeña escala (1 ton, 3 tripulantes)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RADIO_RESTRICCION_PLATAFORMAS">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUM_ESPECIES">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ks">
      <value value="&quot;[1000 1000 1000]&quot;"/>
      <value value="&quot;[2000 2000 2000]&quot;"/>
      <value value="&quot;[3000 3000 3000]&quot;"/>
      <value value="&quot;[4000 4000 4000]&quot;"/>
      <value value="&quot;[5000 5000 5000]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BIOMASAS_INICIALES">
      <value value="&quot;[1000 1000 1000]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="BIOMASA_INICIAL_K?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Rs_min">
      <value value="&quot;[0.4 0.4 0.4]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Rs_max">
      <value value="&quot;[0.6 0.6 0.6]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ms">
      <value value="&quot;[.0025 .0025 .0025]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DISTRIBUCION_ESPECIES">
      <value value="&quot;dif spp en cada region&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DIAS_REPRODUCCION">
      <value value="&quot;[180 200 200 ]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TAMANIO_POB_INICIAL_TORTUGAS">
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PROB_MORTALIDAD_TORTUGA_POR_PESCA">
      <value value="0.008"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUM_DESCENDIENTES_TORTUGAS">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MAX_CAPACIDAD_CARGA_TORTUGAS">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DIA_REPRODUCCION_TORTUGAS">
      <value value="182"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RADIO_EXPLORAR">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="EPSILON">
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUM_AMIGOS">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SELECCION_SITIO_PESCA">
      <value value="&quot;EEI&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SELELECCION_SITIO_PESCA_CONTINUACION">
      <value value="&quot;un vecino&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SELECCION_MEJOR_SITIO">
      <value value="&quot;mayor captura en viaje&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAMBIAR_SITIO_PESCA?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VELOCIDAD">
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="5"/>
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_ENE">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_FEB">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_MAR">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_ABR">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_MAY">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_JUN">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_JUL">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_AGO">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_SEP">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_OCT">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_NOV">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_DIC">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PRECIOS_KILO_BIOMASA">
      <value value="&quot;[2 2 2]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PRECIO_LITRO_GAS">
      <value value="25"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LITROS_POR_DISTANCIA">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LITROS_POR_HORA_PESCA">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUM_EMBARCACIONES_PUERTO_1">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_PESCA_EMBARCACIONES_PUERTO_1">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAPTURABILIDAD_PUERTO_1">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAPACIDAD_MAXIMA_PUERTO_1">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ESPECIES_PESCA_PUERTO_1">
      <value value="&quot;[ 0 0 1 ]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_MAXIMAS_EN_MAR_PUERTO_1">
      <value value="4"/>
      <value value="8"/>
      <value value="12"/>
      <value value="16"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TAMANIO_TRIPULACION_PUERTO_1">
      <value value="5"/>
    </enumeratedValueSet>
    <steppedValueSet variable="HORAS_DESCANSAR_PUERTO_1" first="12" step="12" last="60"/>
    <enumeratedValueSet variable="NUM_EMBARCACIONES_PUERTO_2">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_PESCA_EMBARCACIONES_PUERTO_2">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAPTURABILIDAD_PUERTO_2">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAPACIDAD_MAXIMA_PUERTO_2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ESPECIES_PESCA_PUERTO_2">
      <value value="&quot;[1 1 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_MAXIMAS_EN_MAR_PUERTO_2">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TAMANIO_TRIPULACION_PUERTO_2">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_DESCANSAR_PUERTO_2">
      <value value="72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUM_EMBARCACIONES_PUERTO_3">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_PESCA_EMBARCACIONES_PUERTO_3">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAPTURABILIDAD_PUERTO_3">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CAPACIDAD_MAXIMA_PUERTO_3">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ESPECIES_PESCA_PUERTO_3">
      <value value="&quot;[1 1 1]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_MAXIMAS_EN_MAR_PUERTO_3">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TAMANIO_TRIPULACION_PUERTO_3">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_DESCANSAR_PUERTO_3">
      <value value="72"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UMBRAL_INGRESO_MIN_PETROLEO">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SALARIO_MENSUAL_MINIMO_ACEPTABLE">
      <value value="7000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MESES_PARA_COLAPSO_EMBARCACION">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PORCENTAJE_MAX_EMBARCACIONES_QUIEBRA">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MESES_PARA_COLAPSO_PETROLEO">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="UMBRAL_BIOMASA_SOSTENIBLE">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_MINIMO_TORTUGAS">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PRUEBA?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANOS_PRUEBA">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="DETENER_SI_PIERDE?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MOSTRAR_MENSAJES?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HIDROCARBURO_INICIAL">
      <value value="10000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TASA_DECLINACION_HIDROCARBURO">
      <value value="0.001"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PRECIO_CRUDO">
      <value value="8900"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MIN_PROB_OCURRENCIA_DERRAME">
      <value value="0.004"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="MAX_PROB_OCURRENCIA_DERRAME">
      <value value="0.04"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PROB_EXTENSION_DERRAME">
      <value value="0.36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TIEMPO_DERRAMADO">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="COSTO_TRANSPORTE_POR_UNIDAD_DISTANCIA">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VELOCIDAD_BUQUES">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TASA_MORTALIDAD_DERRAME">
      <value value="0.3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUM_PUERTOS">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LONG_TIERRA">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LONG_REGION_1">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LONG_REGION_2">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LONG_REGION_3">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="COLOREAR_POR">
      <value value="&quot;biomasa, zonificacion y derrames&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="calibracion_pesca_01" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <timeLimit steps="3652"/>
    <metric>sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>([sum distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0] *  longitud_celda) / NUMERO_EMBARCACIONES</metric>
    <metric>[sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>[sum horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 0]</metric>
    <metric>sum [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>count embarcaciones with [ estado_economico = "viable" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "crisis" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "quiebra" ]</metric>
    <metric>sum[item 0 biomasas] of patches</metric>
    <metric>sum[item 1 biomasas] of patches</metric>
    <metric>sum[item 2 biomasas] of patches</metric>
    <metric>count tortugas</metric>
    <metric>tiempo_pesca_sostenible</metric>
    <metric>tiempo_hidrocarburo_sostenible</metric>
    <metric>tiempo_biomasa_sostenible</metric>
    <metric>tiempo_tortugas_sostenible</metric>
    <metric>num_derrames</metric>
    <metric>produccion_mes_hidrocarburo</metric>
    <metric>produccion_total_hidrocarburo</metric>
    <metric>ganancia_mes_hidrocarburo</metric>
    <runMetricsCondition>member? ticks [ 31 60 91 121 152 182 213 244 274 305 335 366 396 424 455 485 516 546 577 608 638 669 699 730 761 789 820 850 881 911 942 973 1003 1034 1064 1095 1126 1154 1185 1215 1246 1276 1307 1338 1368 1399 1429 1460 1492 1521 1552 1582 1613 1643 1674 1705 1735 1766 1796 1827 1857 1885 1916 1946 1977 2007 2038 2069 2099 2130 2160 2191 2222 2250 2281 2311 2342 2372 2403 2434 2464 2495 2525 2556 2587 2615 2646 2676 2707 2737 2768 2799 2829 2860 2890 2921 2953 2982 3013 3043 3074 3104 3135 3166 3196 3227 3257 3288 3318 3346 3377 3407 3438 3468 3499 3530 3560 3591 3621 3652 ]</runMetricsCondition>
    <enumeratedValueSet variable="RONDA">
      <value value="&quot;NA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_EMBARCACIONES">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DONDE_PESCAR">
      <value value="&quot;Linea de costa: camarón&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_DE_PLATAFORMAS">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DE_PLATAFORMAS">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GASTO_EN_MANTENIMIENTO">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_TEMPORAL">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SUBSIDIO_MENSUAL_GASOLINA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TIPO_DE_EMBARCACIONES">
      <value value="&quot;pequeña escala (1 ton, 3 tripulantes)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RADIO_RESTRICCION_PLATAFORMAS">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ks">
      <value value="&quot;[1000 1000 1000]&quot;"/>
      <value value="&quot;[2000 2000 2000]&quot;"/>
      <value value="&quot;[3000 3000 3000]&quot;"/>
      <value value="&quot;[4000 4000 4000]&quot;"/>
      <value value="&quot;[5000 5000 5000]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VELOCIDAD">
      <value value="1"/>
      <value value="2"/>
      <value value="5"/>
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PRECIOS_KILO_BIOMASA">
      <value value="&quot;[1 1 1]&quot;"/>
      <value value="&quot;[2 2 2]&quot;"/>
      <value value="&quot;[3 3 3]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_MAXIMAS_EN_MAR_PUERTO_1">
      <value value="4"/>
      <value value="8"/>
      <value value="12"/>
      <value value="24"/>
    </enumeratedValueSet>
    <steppedValueSet variable="HORAS_DESCANSAR_PUERTO_1" first="12" step="12" last="36"/>
  </experiment>
  <experiment name="calibracion_pesca_02" repetitions="10" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <timeLimit steps="3652"/>
    <metric>sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>([sum distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0] *  longitud_celda) / NUMERO_EMBARCACIONES</metric>
    <metric>[sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>[sum horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 0]</metric>
    <metric>sum [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>count embarcaciones with [ estado_economico = "viable" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "crisis" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "quiebra" ]</metric>
    <metric>sum[item 0 biomasas] of patches</metric>
    <metric>sum[item 1 biomasas] of patches</metric>
    <metric>sum[item 2 biomasas] of patches</metric>
    <metric>count tortugas</metric>
    <metric>tiempo_pesca_sostenible</metric>
    <metric>tiempo_hidrocarburo_sostenible</metric>
    <metric>tiempo_biomasa_sostenible</metric>
    <metric>tiempo_tortugas_sostenible</metric>
    <metric>num_derrames</metric>
    <metric>produccion_mes_hidrocarburo</metric>
    <metric>produccion_total_hidrocarburo</metric>
    <metric>ganancia_mes_hidrocarburo</metric>
    <runMetricsCondition>member? ticks [ 0 31 60 91 121 152 182 213 244 274 305 335 366 396 424 455 485 516 546 577 608 638 669 699 730 761 789 820 850 881 911 942 973 1003 1034 1064 1095 1126 1154 1185 1215 1246 1276 1307 1338 1368 1399 1429 1460 1492 1521 1552 1582 1613 1643 1674 1705 1735 1766 1796 1827 1857 1885 1916 1946 1977 2007 2038 2069 2099 2130 2160 2191 2222 2250 2281 2311 2342 2372 2403 2434 2464 2495 2525 2556 2587 2615 2646 2676 2707 2737 2768 2799 2829 2860 2890 2921 2953 2982 3013 3043 3074 3104 3135 3166 3196 3227 3257 3288 3318 3346 3377 3407 3438 3468 3499 3530 3560 3591 3621 3652 ]</runMetricsCondition>
    <enumeratedValueSet variable="RONDA">
      <value value="&quot;NA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_EMBARCACIONES">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DONDE_PESCAR">
      <value value="&quot;Linea de costa: camarón&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_DE_PLATAFORMAS">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DE_PLATAFORMAS">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GASTO_EN_MANTENIMIENTO">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_TEMPORAL">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SUBSIDIO_MENSUAL_GASOLINA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TIPO_DE_EMBARCACIONES">
      <value value="&quot;pequeña escala (1 ton, 3 tripulantes)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RADIO_RESTRICCION_PLATAFORMAS">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ks">
      <value value="&quot;[1000 1000 1000]&quot;"/>
      <value value="&quot;[3000 3000 3000]&quot;"/>
      <value value="&quot;[5000 5000 5000]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VELOCIDAD">
      <value value="1"/>
      <value value="5"/>
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="PRECIOS_KILO_BIOMASA">
      <value value="&quot;[2 2 2]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_MAXIMAS_EN_MAR_PUERTO_1">
      <value value="4"/>
      <value value="8"/>
      <value value="16"/>
      <value value="24"/>
    </enumeratedValueSet>
    <steppedValueSet variable="HORAS_DESCANSAR_PUERTO_1" first="12" step="12" last="36"/>
  </experiment>
  <experiment name="calibracion_pesca_03" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <timeLimit steps="3653"/>
    <metric>fecha</metric>
    <metric>sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>([sum distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0] *  longitud_celda) / NUMERO_EMBARCACIONES</metric>
    <metric>[sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>[sum horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 0]</metric>
    <metric>sum [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>count embarcaciones with [ estado_economico = "viable" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "crisis" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "quiebra" ]</metric>
    <metric>sum[item 0 biomasas] of patches</metric>
    <metric>sum[item 1 biomasas] of patches</metric>
    <metric>sum[item 2 biomasas] of patches</metric>
    <metric>count tortugas</metric>
    <metric>tiempo_pesca_sostenible</metric>
    <metric>tiempo_hidrocarburo_sostenible</metric>
    <metric>tiempo_biomasa_sostenible</metric>
    <metric>tiempo_tortugas_sostenible</metric>
    <metric>num_derrames</metric>
    <metric>produccion_mes_hidrocarburo</metric>
    <metric>produccion_total_hidrocarburo</metric>
    <metric>ganancia_mes_hidrocarburo</metric>
    <metric>captura_acumulada</metric>
    <metric>ganancia_acumulada</metric>
    <metric>gasto_gasolina_acumulada</metric>
    <metric>horas_en_mar_acumulada</metric>
    <runMetricsCondition>member? ticks   [ 0 31 60 91 121 152 182 213 244 274 305 335 366 397 425 456 486 517 547 578 609 639 670 700 731 762 790 821 851 882 912 943 974 1004 1035 1065 1096 1127 1155 1186 1216 1247 1277 1308 1339 1369 1400 1430 1461 1492 1521 1552 1582 1613 1643 1674 1705 1735 1766 1796 1827 1858 1886 1917 1947 1978 2008 2039 2070 2100 2131 2161 2192 2223 2251 2282 2312 2343 2373 2404 2435 2465 2496 2526 2557 2588 2616 2647 2677 2708 2738 2769 2800 2830 2861 2891 2922 2953 2982 3013 3043 3074 3104 3135 3166 3196 3227 3257 3288 3319 3347 3378 3408 3439 3469 3500 3531 3561 3592 3622 3653 ]</runMetricsCondition>
    <enumeratedValueSet variable="RONDA">
      <value value="&quot;NA&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_EMBARCACIONES">
      <value value="300"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DONDE_PESCAR">
      <value value="&quot;Linea de costa: camarón&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_DE_PLATAFORMAS">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="REGION_DE_PLATAFORMAS">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="GASTO_EN_MANTENIMIENTO">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VEDA_TEMPORAL">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SUBSIDIO_MENSUAL_GASOLINA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TIPO_DE_EMBARCACIONES">
      <value value="&quot;pequeña escala (1 ton, 3 tripulantes)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RADIO_RESTRICCION_PLATAFORMAS">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="VELOCIDAD">
      <value value="1"/>
      <value value="3"/>
      <value value="6"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ks">
      <value value="&quot;[4000 4000 4000]&quot;"/>
      <value value="&quot;[5000 5000 5000]&quot;"/>
      <value value="&quot;[6000 6000 6000]&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_MAXIMAS_EN_MAR_PUERTO_1">
      <value value="4"/>
      <value value="8"/>
      <value value="12"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="HORAS_DESCANSAR_PUERTO_1">
      <value value="12"/>
      <value value="24"/>
      <value value="36"/>
      <value value="48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ms">
      <value value="&quot;[0.002 0.002 0.002]&quot;"/>
      <value value="&quot;[0.005 0.005 0.005]&quot;"/>
      <value value="&quot;[0.007 0.007 0.007]&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="calibracion_pesca_04" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <timeLimit steps="3653"/>
    <metric>fecha</metric>
    <metric>sum [capturas_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>([sum distancias_recorridas_mes_puerto] of one-of puertos with [num_puerto = 0] *  longitud_celda) / NUMERO_EMBARCACIONES</metric>
    <metric>[sum ganancias_mes_puerto] of one-of puertos with [num_puerto = 0]</metric>
    <metric>[sum horas_en_mar_mes_puerto] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [gastos_gasolina_mes_puerto ] of one-of puertos with [num_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>sum [viajes_finalizados_mes_puerto] of puertos with [num_puerto = 0]</metric>
    <metric>sum [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0] / NUMERO_EMBARCACIONES</metric>
    <metric>count embarcaciones with [ estado_economico = "viable" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "crisis" ]</metric>
    <metric>count embarcaciones with [ estado_economico = "quiebra" ]</metric>
    <metric>sum[item 0 biomasas] of patches</metric>
    <metric>count tortugas</metric>
    <metric>tiempo_pesca_sostenible</metric>
    <metric>tiempo_hidrocarburo_sostenible</metric>
    <metric>tiempo_biomasa_sostenible</metric>
    <metric>tiempo_tortugas_sostenible</metric>
    <metric>num_derrames</metric>
    <metric>produccion_mes_hidrocarburo</metric>
    <metric>produccion_total_hidrocarburo</metric>
    <metric>ganancia_mes_hidrocarburo</metric>
    <metric>captura_acumulada</metric>
    <metric>ganancia_acumulada</metric>
    <metric>gasto_gasolina_acumulada</metric>
    <metric>horas_en_mar_acumulada</metric>
    <runMetricsCondition>member? ticks ticks_registros_mes</runMetricsCondition>
    <enumeratedValueSet variable="RONDA">
      <value value="&quot;NA&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="NUMERO_EMBARCACIONES" first="50" step="50" last="300"/>
    <enumeratedValueSet variable="TIPO_DE_EMBARCACIONES">
      <value value="&quot;pequeña escala (1 ton, 3 tripulantes)&quot;"/>
      <value value="&quot;semi-industrial (10 ton, 5 tripulantes)&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_DE_PLATAFORMAS">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="RADIO_RESTRICCION_PLATAFORMAS">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Ks">
      <value value="&quot;[100 100 100]&quot;"/>
      <value value="&quot;[300 300 300]&quot;"/>
      <value value="&quot;[600 600 600]&quot;"/>
      <value value="&quot;[900 900 900]&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
