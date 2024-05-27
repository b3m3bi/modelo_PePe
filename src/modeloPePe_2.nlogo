__includes [
  "./entidades/puertos.nls"
  "./entidades/celdas.nls"
  "./entidades/embarcaciones.nls"
  "./entidades/plataformas.nls"
  "./entidades/tortugas.nls"
  "./submodelos/paisaje.nls"
  "./submodelos/ecologia.nls"
  "./submodelos/hidrocarburo.nls"
  "./submodelos/zonificacion.nls"
  "./utils/visualizacion.nls"
  "./utils/globales_ayudadoras.nls"
  "./utils/A_star_pathfinder.nls"
  "./utils/registros_y_salidas.nls"
  "./utils/helper_functions.nls"
  "./utils/criterios_juego.nls"
]

to INICIALIZAR

  print "==========================\nInicializando modelo..."

  clear-all

  init_globales
  init_paisaje
  init_puertos
  init_regiones

  init_habitats
  init_ecologia

  init_zonificacion

  init_hidrocarburo
  init_plataformas

  init_embarcaciones
  init_registros_diarios_todo
  init_A_star_pathfinder

  init_tortugas

  init_umbrales_juego

  colorear_celdas
  dibujar_regiones
  colocar_etiquetas_regiones


  reset-ticks

  print "Inicialización completada.\n=========================="
end


to EJECUTAR
  if ticks = 0 [ reset-timer ]
  if perdio? [
    user-message mensaje_fin_juego
    stop
  ]

  if paso_un_dia [
    init_registros_diarios_puertos
    init_registros_diarios_todo
  ]
  if paso_un_mes [
    ask embarcaciones [ actualizar_estado_economico ]
    init_registros_mensuales_embarcaciones
  ]

  ask embarcaciones [ dinamica_iteracion_embarcacion ]

  if paso_un_dia [ dispersion ]
  if paso_un_ano [ dinamica_poblacional ]

  if paso_un_dia [
    ask plataformas [
      extraer_hidrocarburo
    ]
    dinamica_derrame
  ]

  if paso_un_mes [
    subsidiar_gasolina
  ]
  registro_puertos_a_total

  if paso_un_dia [
    dinamica_tortugas
  ]

  colorear_celdas

  actualizar_fecha

  revisar_umbrales_juego
  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
190
10
627
448
-1
-1
13.0
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
32
0
32
1
1
1
ticks
30.0

BUTTON
5
10
180
43
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
5
45
180
78
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
5
80
180
125
COLOREAR_POR
COLOREAR_POR
"tipo" "biomasa total" "biomasa total especie" "zonificacion" "biomasa, zonificacion y derrames" "hidrocarburo" "derrames" "habitat tortugas"
2

SLIDER
1480
120
1655
153
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
630
10
905
43
NUM_EMBARCACIONES_PUERTO_1
NUM_EMBARCACIONES_PUERTO_1
0
300
300.0
1
1
NIL
HORIZONTAL

SLIDER
910
10
1185
43
NUM_EMBARCACIONES_PUERTO_2
NUM_EMBARCACIONES_PUERTO_2
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
1195
10
1470
43
NUM_EMBARCACIONES_PUERTO_3
NUM_EMBARCACIONES_PUERTO_3
0
100
15.0
1
1
NIL
HORIZONTAL

MONITOR
5
180
160
225
total embarcaciones
count embarcaciones
0
1
11

SLIDER
1815
15
1990
48
HORAS_DESCANSAR
HORAS_DESCANSAR
0
168
24.0
1
1
NIL
HORIZONTAL

CHOOSER
1815
50
1990
95
SELECCION_SITIO_PESCA
SELECCION_SITIO_PESCA
"EEI" "aleatorio"
0

SLIDER
1480
10
1655
43
LONG_REGION_1
LONG_REGION_1
0
50
10.0
1
1
NIL
HORIZONTAL

SLIDER
1480
45
1655
78
LONG_REGION_2
LONG_REGION_2
0
50
15.0
1
1
NIL
HORIZONTAL

SLIDER
1480
80
1655
113
LONG_REGION_3
LONG_REGION_3
0
50
20.0
1
1
NIL
HORIZONTAL

CHOOSER
630
45
905
90
REGION_PESCA_EMBARCACIONES_PUERTO_1
REGION_PESCA_EMBARCACIONES_PUERTO_1
1 2 3
0

CHOOSER
910
45
1185
90
REGION_PESCA_EMBARCACIONES_PUERTO_2
REGION_PESCA_EMBARCACIONES_PUERTO_2
1 2 3
1

CHOOSER
1195
45
1470
90
REGION_PESCA_EMBARCACIONES_PUERTO_3
REGION_PESCA_EMBARCACIONES_PUERTO_3
1 2 3
2

SLIDER
1815
100
1987
133
RADIO_EXPLORAR
RADIO_EXPLORAR
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
1815
135
1987
168
EPSILON
EPSILON
0
1
0.3
0.01
1
NIL
HORIZONTAL

SWITCH
1815
170
2027
203
CAMBIAR_SITIO_PESCA?
CAMBIAR_SITIO_PESCA?
0
1
-1000

SLIDER
1815
205
1987
238
NUM_AMIGOS
NUM_AMIGOS
0
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
1815
240
1987
273
VELOCIDAD
VELOCIDAD
0
100
10.0
1
1
NIL
HORIZONTAL

CHOOSER
630
160
905
205
ARTES_PESCA_PUERTO_1
ARTES_PESCA_PUERTO_1
"ESPECIE 1" "ESPECIE 2" "ESPECIE 3" "ESPECIE 1 y ESPECIE 2 y ESPECIE 3"
3

SLIDER
630
90
905
123
CAPTURABILIDAD_PUERTO_1
CAPTURABILIDAD_PUERTO_1
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
630
125
905
158
CAPACIDAD_MAXIMA_PUERTO_1
CAPACIDAD_MAXIMA_PUERTO_1
1
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
630
210
907
243
DIAS_MAXIMOS_EN_MAR_PUERTO_1
DIAS_MAXIMOS_EN_MAR_PUERTO_1
1
20
5.0
1
1
NIL
HORIZONTAL

CHOOSER
2045
15
2232
60
DISTRIBUCION_ESPECIES
DISTRIBUCION_ESPECIES
"homogenea" "partes iguales" "dif spp en cada region"
2

SLIDER
2045
75
2217
108
NUM_ESPECIES
NUM_ESPECIES
1
3
3.0
1
1
NIL
HORIZONTAL

INPUTBOX
2040
115
2195
185
BIOMASAS_INICIALES
[1000 1000 1000]
1
0
String

SLIDER
2040
355
2250
388
PRECIO_BIOMASA
PRECIO_BIOMASA
0
10000
4000.0
100
1
NIL
HORIZONTAL

SLIDER
2040
390
2250
423
PRECIO_LITRO_GAS
PRECIO_LITRO_GAS
0
10
5.0
0.01
1
NIL
HORIZONTAL

SLIDER
2040
425
2250
458
LITROS_POR_DISTANCIA
LITROS_POR_DISTANCIA
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
2040
460
2250
493
LITROS_POR_HORA_PESCA
LITROS_POR_HORA_PESCA
0
100
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
2195
115
2345
185
Ks
[1000 1000 1000]
1
0
String

PLOT
15
445
220
595
captura total
dias
captura total
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" ";;if paso_un_dia [plotxy dias sum capturas_dia_todo]"
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_dia and any? puertos with [num_puerto = 0] [plotxy dias sum [capturas_dia_puerto] of one-of puertos with [num_puerto = 0]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_dia and any? puertos with [num_puerto = 1] [plotxy dias sum [capturas_dia_puerto] of one-of puertos with [num_puerto = 1]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_dia and any? puertos with [num_puerto = 2] [plotxy dias sum [capturas_dia_puerto] of one-of puertos with [num_puerto = 2]]"

PLOT
425
445
630
595
gasto gasolina promedio
dias
gasto gasolina 
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" ";;if paso_un_dia and gastos_gasolina_dia_todo != [] [ plotxy dias mean gastos_gasolina_dia_todo ]"
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 0] [\nifelse [gastos_gasolina_dia_puerto ] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias mean [gastos_gasolina_dia_puerto ] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 1] [\nifelse [gastos_gasolina_dia_puerto ] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias mean [gastos_gasolina_dia_puerto ] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 2] [\nifelse [gastos_gasolina_dia_puerto ] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias mean [gastos_gasolina_dia_puerto ] of one-of puertos with [num_puerto = 2]]\n[plotxy dias 0 ]]"

PLOT
220
445
425
595
ganancia total
dias
ganancia promedio
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"promedio" 1.0 0 -16777216 true "" ";;if paso_un_dia and ganancias_dia_todo != [] [ plotxy dias mean ganancias_dia_todo ] "
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 0] [\nifelse [ganancias_dia_puerto] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias [sum ganancias_dia_puerto] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 1] [\nifelse [ganancias_dia_puerto] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias [sum ganancias_dia_puerto] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 2] and \n[ganancias_dia_puerto] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias [sum ganancias_dia_puerto] of one-of puertos with [num_puerto = 2]]"
"0" 1.0 0 -4539718 true "" "if paso_un_dia [ plotxy dias 0 ]"

CHOOSER
1715
305
2032
350
SELELECCION_SITIO_PESCA_CONTINUACION
SELELECCION_SITIO_PESCA_CONTINUACION
"EEI" "mejor vecino" "un vecino" "vecino cercano no visitado"
2

CHOOSER
1715
355
1907
400
SELECCION_MEJOR_SITIO
SELECCION_MEJOR_SITIO
"inicio de viaje" "mayor captura en viaje"
1

INPUTBOX
2040
200
2170
275
Ms
[.001 .001 .001]
1
0
String

PLOT
630
295
835
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
"especie 1" 1.0 0 -11221820 true "" "if paso_un_dia and _num_especies > 0 [plotxy dias sum[item 0 biomasas] of patches]"
"especie 2" 1.0 0 -13791810 true "" "if paso_un_dia and _num_especies > 1 [plotxy dias sum[item 1 biomasas] of patches]"
"especie 3" 1.0 0 -14070903 true "" "if paso_un_dia and _num_especies > 2 [plotxy dias sum[item 2 biomasas] of patches]"

INPUTBOX
2040
275
2170
345
Rs
[0.7 0.7 0.7]
1
0
String

MONITOR
5
280
160
325
total de dias transcurridos
dias
0
1
11

MONITOR
5
235
60
280
año
ano
0
1
11

SLIDER
910
90
1185
123
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
910
125
1185
158
CAPACIDAD_MAXIMA_PUERTO_2
CAPACIDAD_MAXIMA_PUERTO_2
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
1195
90
1470
123
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
1195
125
1470
158
CAPACIDAD_MAXIMA_PUERTO_3
CAPACIDAD_MAXIMA_PUERTO_3
0
100
1.0
1
1
NIL
HORIZONTAL

CHOOSER
910
160
1185
205
ARTES_PESCA_PUERTO_2
ARTES_PESCA_PUERTO_2
"ESPECIE 1" "ESPECIE 2" "ESPECIE 3" "ESPECIE 1 y ESPECIE 2 y ESPECIE 3"
1

CHOOSER
1195
160
1470
205
ARTES_PESCA_PUERTO_3
ARTES_PESCA_PUERTO_3
"ESPECIE 1" "ESPECIE 2" "ESPECIE 3" "ESPECIE 1 y ESPECIE 2 y ESPECIE 3"
2

SLIDER
910
210
1190
243
DIAS_MAXIMOS_EN_MAR_PUERTO_2
DIAS_MAXIMOS_EN_MAR_PUERTO_2
1
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
1195
210
1475
243
DIAS_MAXIMOS_EN_MAR_PUERTO_3
DIAS_MAXIMOS_EN_MAR_PUERTO_3
1
20
10.0
1
1
NIL
HORIZONTAL

PLOT
630
445
835
595
distancia recorrida promedio
dias
distancia recorrida
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 0] [\nifelse [distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias [mean distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 1] [\nifelse [distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias [mean distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 2] [\nifelse [distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias [mean distancias_recorridas_dia_puerto] of one-of puertos with [num_puerto = 2]]\n[plotxy dias 0 ]]"

PLOT
835
445
1040
595
horas en mar promedio
dias
horas en mar
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 0] [\nifelse [horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 0]  != []\n[plotxy dias [mean horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 0]]\n[plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 1] [\nifelse [horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 1]  != []\n[plotxy dias [mean horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 1]]\n[plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 2] [\nifelse [horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 2]  != []\n[plotxy dias [mean horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 2]]\n[plotxy dias 0 ]]"

INPUTBOX
1720
405
1950
480
TRIPULANTES_POR_EMBARCACION
[5 5 5]
1
0
String

PLOT
1240
445
1440
595
salario mensual pescador
dias
salario
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_mes and \nany? puertos with [num_puerto = 0][\nifelse any? embarcaciones with [[num_puerto] of mi_puerto = 0 and activo?] \n[ plotxy dias mean [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 0 and activo?]]\n[ plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if ticks = 0 or paso_un_mes and \nany? puertos with [num_puerto = 1][\nifelse any? embarcaciones with [[num_puerto] of mi_puerto = 1 and activo?] \n[ plotxy dias mean [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 1 and activo?]]\n[ plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if ticks = 0 or paso_un_mes and \nany? puertos with [num_puerto = 2][\nifelse any? embarcaciones with [[num_puerto] of mi_puerto = 2 and activo?] \n[ plotxy dias mean [salario_mensual_tripulacion] of embarcaciones with [[num_puerto] of mi_puerto = 2 and activo?]]\n[ plotxy dias 0 ]]"
"umbral" 1.0 0 -4539718 true "" "if ticks = 0 or paso_un_mes [plotxy dias 7000 ]"

PLOT
1040
445
1240
595
viajes finalizados
dias
número de viajes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"puerto 1" 1.0 0 -2064490 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 0] [\nifelse [horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 0]  != []\n[ plotxy dias mean [viajes_finalizados_dia_puerto] of puertos with [num_puerto = 0]]\n[ plotxy dias 0 ]]"
"puerto 2" 1.0 0 -8630108 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 1] [\nifelse [horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 1]  != []\n[ plotxy dias mean [viajes_finalizados_dia_puerto] of puertos with [num_puerto = 1]]\n[ plotxy dias 0 ]]"
"puerto 3" 1.0 0 -13345367 true "" "if paso_un_dia and \nany? puertos with [num_puerto = 2] [\nifelse [horas_en_mar_dia_puerto] of one-of puertos with [num_puerto = 2]  != []\n[ plotxy dias mean [viajes_finalizados_dia_puerto] of puertos with [num_puerto = 2]]\n[ plotxy dias 0 ]]"

SLIDER
2270
200
2487
233
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
635
250
860
283
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
865
250
1100
283
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
1100
250
1297
283
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
125
350
190
395
NIL
timer
17
1
11

MONITOR
125
395
190
440
minutos
timer / 60
17
1
11

SLIDER
1310
250
1560
283
RADIO_RESTRICCION_PLATAFORMAS
RADIO_RESTRICCION_PLATAFORMAS
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
2270
235
2567
268
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
1035
295
1240
445
producción diaria hidrocarburo total
dias
produccion
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 1 -16777216 true "" "if paso_un_dia [ plotxy dias sum [produccion_dia] of plataformas ]"

SLIDER
2270
270
2532
303
COSTO_OPERACION_POR_CELDA
COSTO_OPERACION_POR_CELDA
0
1000
200.0
10
1
NIL
HORIZONTAL

SLIDER
2270
305
2535
338
COSTO_TRANSPORTE_POR_UNIDAD_DISTANCIA
COSTO_TRANSPORTE_POR_UNIDAD_DISTANCIA
0
1000
300.0
10
1
NIL
HORIZONTAL

SLIDER
2270
340
2442
373
PRECIO_CRUDO
PRECIO_CRUDO
0
10000
10000.0
100
1
NIL
HORIZONTAL

PLOT
2495
345
2695
495
ganancia diaria hidrocarburo
dias
ganacia
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" "if paso_un_dia [ plotxy dias sum [ganancia_dia] of plataformas ]"
"0" 1.0 0 -7500403 true "" "if paso_un_dia [ plotxy dias 0 ]"

BUTTON
5
125
137
158
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
1310
285
1560
318
SUBSIDIO_MENSUAL_GASOLINA
SUBSIDIO_MENSUAL_GASOLINA
0
20000
0.0
100
1
NIL
HORIZONTAL

SLIDER
2015
515
2280
548
UMBRAL_BIOMASA_SOSTENIBLE
UMBRAL_BIOMASA_SOSTENIBLE
0
100
10.0
1
1
%
HORIZONTAL

SLIDER
2015
550
2280
583
UMBRAL_NUMERO_EMBARCACIONES
UMBRAL_NUMERO_EMBARCACIONES
0
100
90.0
1
1
%
HORIZONTAL

SLIDER
1310
320
1497
353
NUM_PLATAFORMAS
NUM_PLATAFORMAS
0
30
10.0
1
1
NIL
HORIZONTAL

CHOOSER
1310
355
1487
400
REGION_PLATAFORMAS
REGION_PLATAFORMAS
1 2 3
0

SLIDER
1550
485
1802
518
PROB_OCURRENCIA_DERRAME
PROB_OCURRENCIA_DERRAME
0
1
0.02
0.01
1
NIL
HORIZONTAL

SLIDER
1550
520
1787
553
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
1550
555
1747
588
TIEMPO_DERRAMADO
TIEMPO_DERRAMADO
0
100
60.0
1
1
NIL
HORIZONTAL

SLIDER
1550
590
1802
623
TASA_MORTALIDAD_DERRAME
TASA_MORTALIDAD_DERRAME
0
1
0.75
0.01
1
NIL
HORIZONTAL

PLOT
835
295
1035
445
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
"total" 1.0 0 -13840069 true "" "if paso_un_dia [ plotxy dias count tortugas ]"

SLIDER
2375
10
2657
43
TAMANIO_POB_INICIAL_TORTUGAS
TAMANIO_POB_INICIAL_TORTUGAS
0
300
150.0
1
1
NIL
HORIZONTAL

SLIDER
2375
45
2557
78
INICIO_MIGRACION
INICIO_MIGRACION
0
360
181.0
1
1
NIL
HORIZONTAL

SLIDER
2375
80
2662
113
CAPACIDAD_DE_CARGA_TORTUGAS
CAPACIDAD_DE_CARGA_TORTUGAS
1
5
5.0
1
1
NIL
HORIZONTAL

SLIDER
2375
115
2685
148
PROB_MORTALIDAD_TORTUGA_POR_PESCA
PROB_MORTALIDAD_TORTUGA_POR_PESCA
0
1
0.05
0.01
1
NIL
HORIZONTAL

SLIDER
2375
155
2657
188
NUM_DESCENDIENTES_TORTUGAS
NUM_DESCENDIENTES_TORTUGAS
1
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
2330
530
2642
563
MESES_PARA_COLAPSO_EMBARCACION
MESES_PARA_COLAPSO_EMBARCACION
0
12
3.0
1
1
NIL
HORIZONTAL

SWITCH
1565
180
1715
213
VEDA_ENE_FEB
VEDA_ENE_FEB
1
1
-1000

MONITOR
60
235
110
280
mes
time:show fecha \"MM\"
2
1
11

MONITOR
110
235
160
280
día
time:show fecha \"dd\"
17
1
11

SWITCH
1565
215
1715
248
VEDA_MAR_ABR
VEDA_MAR_ABR
1
1
-1000

SWITCH
1565
250
1715
283
VEDA_MAY_JUN
VEDA_MAY_JUN
1
1
-1000

SWITCH
1565
285
1715
318
VEDA_JUL_AGO
VEDA_JUL_AGO
1
1
-1000

SWITCH
1565
320
1715
353
VEDA_SEP_OCT
VEDA_SEP_OCT
1
1
-1000

SWITCH
1565
355
1715
388
VEDA_NOV_DIC
VEDA_NOV_DIC
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
Polygon -7500403 true true 45 195 45 210 60 255 105 285 165 285 165 75 135 75 135 255 120 255 75 225 75 210 60 195
Polygon -7500403 true true 255 195 255 210 240 255 195 285 135 285 135 75 165 75 165 255 180 255 225 225 225 210 240 195
Circle -7500403 true true 116 11 67
Rectangle -7500403 true true 75 105 225 135

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

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

boat
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

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

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

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
