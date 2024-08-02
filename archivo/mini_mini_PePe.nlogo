breed [ embarcaciones embarcacion ]
breed [ puertos puerto ]

directed-link-breed [ amistades amistad ]

globals [

  celdas_tierra
  celdas_mar

  celdas_restriccion
  celdas_libre
  celdas_protegido
  celdas_NA

  dias_transcurridos
  meses_transcurridos
  anos_transcurridos

  ;; registros
  capturas_mes
  captura_acumulada
  distancias_recorridas_mes
  distancia_recorrida_acumulada
  horas_en_mar_mes
  horas_en_mar_acumuladas
  gasto_gas_mes
  gasto_gas_acumulado
  ganancias_mes
  ganancia_acumulada
  num_viajes_mes
  num_viajes_acumulado

  paso_mes?
  paso_ano?

]

patches-own [
  tipo
  zonificacion

  biomasa
  cambio_biomasa

  f
  parent
  transitable_embarcacion?

  ruta_puerto_sitio
]

embarcaciones-own [
  estado

  mejor_sitio
  sitio_pesca
  destino
  ruta
  indice_ruta
  distancia_recorrida
  horas_en_mar
  ganancia
  ganancia_por_hora
  ganancia_por_hora_ultimo_viaje
  captura
  gasto_gas
]


to INICIALIZAR
  clear-all

  init_globales
  init_paisaje
  init_ecologia
  init_zonificaion
  init_puerto
  init_rutas
  init_embarcaciones
  init_registros

  colorear_celdas
  reset-ticks
end

to init_globales
  set dias_transcurridos 0
  set dias_transcurridos 0
  set meses_transcurridos 0
  set anos_transcurridos 0
end

to init_paisaje
  set celdas_tierra patches with [ pxcor > max-pxcor - LONG_TIERRA ]
  ask celdas_tierra [ set tipo "tierra" ]

  set celdas_mar patches with [ pxcor <= max-pxcor - LONG_TIERRA ]
  ask celdas_mar [ set tipo "mar" ]
end

to init_ecologia
  ask celdas_mar [
    set biomasa K
    set cambio_biomasa 0
  ]
end

to init_puerto
  create-puertos 1 [
    set shape "ancla"
    set size 1.5
    set color black
    setxy (max-pxcor - LONG_TIERRA + 1) (min-pycor + (world-height / 2))
    set tipo "puerto"
  ]
end

to init_zonificaion
  ask celdas_tierra [ set zonificacion "NA" ]
  ask celdas_mar [ set zonificacion "libre" ]

  ;; se inicializan las áreas protegidas
  let x_origen_zona_protegida (min [pxcor] of celdas_tierra) - 1
  let y_origen_zona_protegida (max [pycor] of patches)

;  ask patches with [
;    pxcor >  x_origen_zona_protegida - LARGO_ZONA_PROTEGIDA and
;    pxcor <= x_origen_zona_protegida and
;    pycor >  y_origen_zona_protegida - ANCHO_ZONA_PROTEGIDA and
;    pycor <= y_origen_zona_protegida
;  ][ set zonificacion "protegido" ]

  actualizar_zonificacion
end

to actualizar_zonificacion
  set celdas_restriccion patches with [ zonificacion = "restriccion" ]
  set celdas_libre patches with [ zonificacion = "libre" ]
  set celdas_protegido patches with [ zonificacion = "protegido" ]
  set celdas_NA patches with [ zonificacion = "NA" ]
end

to init_embarcaciones
  create-embarcaciones NUMERO_EMBARCACIONES [
    set shape "boat"
    move-to one-of puertos
    set estado "moviendose"
    set sitio_pesca one-of celdas_libre
    set mejor_sitio sitio_pesca
    set destino mejor_sitio
    set ruta [ruta_puerto_sitio] of destino
    set captura 0
  ]


  ifelse count embarcaciones > NUM_AMIGOS [
    ask embarcaciones [
      create-amistades-to (n-of NUM_AMIGOS other embarcaciones) [hide-link]
    ]
  ][
    print (word "Advertencia: No hay suficientes embarcaciones en el puerto para formar " NUM_AMIGOS " amistades. No se creará ninguna amistad.")
  ]
end

to init_rutas
  actualizar_transitables_embarcaciones
  ask celdas_libre [
    set ruta_puerto_sitio obtener_ruta_A_star ([patch-here] of one-of puertos) self
  ]
end

to init_registros
  set capturas_mes []
  set captura_acumulada 0
  set distancias_recorridas_mes []
  set distancia_recorrida_acumulada 0
  set horas_en_mar_mes []
  set horas_en_mar_acumuladas 0
  set gasto_gas_mes []
  set gasto_gas_acumulado 0
  set ganancias_mes []
  set ganancia_acumulada 0
  set num_viajes_mes 0
  set num_viajes_acumulado 0
end

to EJECUTAR

  ask embarcaciones [ paso_embarcacion ]

  if paso_un_dia? [ ask celdas_mar [ dispersion ]  ]
  if paso_un_ano? [ ask celdas_mar [ dinamica_poblacional ] print "en dinamica poblacional"]
  actualizar_fecha

  if paso_un_dia? [ ask embarcaciones [ set estado "moviendose" ] ]
  colorear_celdas
  tick
end

to colorear_celdas
  if COLOREAR_POR = "tipo" [
    ask celdas_tierra [ set pcolor green ]
    ask celdas_mar [ set pcolor sky ]
  ]

  if COLOREAR_POR = "biomasa" [ colorear_biomasa ]

  if COLOREAR_POR = "zonificacion" [
    ask celdas_NA [ set pcolor white ]
    ask celdas_libre [ set pcolor blue ]
  ]

  if COLOREAR_POR = "biomasa y zonificacion" [
    colorear_biomasa
    colorear_zona_restringida_protegida
  ]

end

to colorear_biomasa
  ask patches [ set pcolor scale-color sky biomasa (K * 2) 0 ]
end

to colorear_zona_restringida_protegida
  ask celdas_protegido   [ set pcolor lime + 2 ]
  ask celdas_restriccion [ set pcolor red + 1 ]
end


to paso_embarcacion
  (
    ifelse
    estado = "moviendose"  [ moverse ]
    estado = "pescando"    [ pescar ]
    estado = "desembarcar" [ desembarcar ]
  )
end

to moverse
  move-to (item indice_ruta ruta)
  set  indice_ruta indice_ruta + 1
  set distancia_recorrida distancia_recorrida + 1
  set horas_en_mar horas_en_mar + 1
  if patch-here = destino [
    ifelse patch-here = [patch-here] of one-of puertos
    [ set estado "desembarcar" ]
    [ set estado "pescando" ]
  ]
end

to pescar
  set captura biomasa * CAPTURABILIDAD
  set biomasa biomasa - captura
  set destino [patch-here] of one-of puertos
  set ruta reverse ruta_puerto_sitio
  set indice_ruta 0
  set estado "moviendose"
end

to desembarcar

  set gasto_gas PRECIO_LITRO_GAS * LITROS_POR_DISTANCIA * distancia_recorrida
  let ingresos_captura captura * PRECIO_BIOMASA
  set ganancia ingresos_captura - gasto_gas
  set ganancia_por_hora ganancia / horas_en_mar

  if ganancia_por_hora > ganancia_por_hora_ultimo_viaje [
    set mejor_sitio sitio_pesca
  ]

  registrar_viaje
  set ganancia_por_hora_ultimo_viaje ganancia_por_hora

  set captura 0

  set sitio_pesca seleccionar_sitio_pesca_EEI
  set ruta [ruta_puerto_sitio] of sitio_pesca
  set destino sitio_pesca
  set distancia_recorrida 0
  set indice_ruta 0
  set estado "finalizado"
end


to registrar_viaje
  set capturas_mes lput captura capturas_mes
  set captura_acumulada captura_acumulada + captura
  set distancias_recorridas_mes lput distancia_recorrida distancias_recorridas_mes
  set distancia_recorrida_acumulada distancia_recorrida_acumulada + distancia_recorrida
  set horas_en_mar_mes lput horas_en_mar horas_en_mar_mes
  set horas_en_mar_acumuladas horas_en_mar_acumuladas + horas_en_mar
  set gasto_gas_mes lput gasto_gas gasto_gas_mes
  set gasto_gas_acumulado gasto_gas_acumulado + gasto_gas
  set ganancias_mes lput ganancia ganancias_mes
  set ganancia_acumulada ganancia_acumulada + ganancia
  set num_viajes_mes num_viajes_mes + 1
  set num_viajes_acumulado num_viajes_acumulado + 1
end


to-report seleccionar_sitio_pesca_EEI
  ifelse random-float 1.0 < PROB_EXPLORAR [
    ;; explorar
    report one-of [celdas_libre at-points vecindad_moore RADIO_EXPLORAR true] of mejor_sitio
  ][
    ifelse any? out-amistad-neighbors [
      let amigo_mas_exitoso max-one-of out-amistad-neighbors [ganancia_por_hora]
      ifelse [ganancia_por_hora] of amigo_mas_exitoso > ganancia_por_hora [
        ;; imitar
        report [mejor_sitio] of amigo_mas_exitoso
      ][
        ;; explotar
        report mejor_sitio
      ]
    ][
      ;; no tengo amigos, exploto el mio
      report mejor_sitio
    ]
  ]
end



to-report obtener_ruta_A_star [inicio final]
  let open (patch-set inicio)
  let closed nobody

  while [count open != 0][
    let current min-one-of open [f]
    set closed (patch-set closed current)

    if current = final [ report reconstrurir_ruta_A_star inicio final ]

    set open open with [ not member? self (patch-set current)]

    ask current [
      ask neighbors with [ transitable_embarcacion? ][
        if member? self closed [stop]
        let tentative_g_cost ([g_cost inicio] of myself) + distance myself
        if tentative_g_cost < g_cost inicio or not member? self open [
          set f tentative_g_cost + h_cost final
          set parent current
          set open (patch-set open self)
        ]
      ]
    ]
  ]
end

to actualizar_transitables_embarcaciones
  ;; se define que celdas serán transitables para las embarcaciones
  ask patches [ set transitable_embarcacion? false ]
  ask patches with [ zonificacion = "libre" or zonificacion = "protegido" or tipo = "puerto" ][
    set transitable_embarcacion? true
  ]
end

to-report reconstrurir_ruta_A_star [inicio final]
  let celda_actual final
  let _ruta (list celda_actual)

  while [celda_actual != inicio][
    let padre_celda_actual [parent] of celda_actual
    ask celda_actual [ set _ruta fput parent _ruta ]
    set celda_actual padre_celda_actual
  ]
  report _ruta
end

to-report g_cost [inicio]
  report distance inicio
end

to-report h_cost [final]
  report distance final
end

to-report vecindad_moore [n centro?]
  let coor (range (- n) (n + 1))
  let vecindad []
  foreach coor [
    x -> foreach coor [
      y -> set vecindad lput (list x y) vecindad
    ]
  ]
  ifelse centro? [ report vecindad ][ report remove [0 0] vecindad ]
end

to-report paso_un_dia?
  report not any? embarcaciones with [ estado != "finalizado" ]
end

to-report paso_un_mes?
  ifelse ticks != 0 and dias_transcurridos mod 30  = 0 [
    ifelse ticks != 0 and not paso_mes? [
      set paso_mes? true
      report true
    ][
      report false
    ]
  ][
    set paso_mes? false
    report false
  ]
end

to-report paso_un_ano?
  ifelse ticks != 0  and dias_transcurridos mod 360 = 0 [
    ifelse ticks != 0 and not paso_ano? [
      set paso_ano? true
      report true
    ][
      report false
    ]
  ][
    set paso_ano? false
    report false
  ]
end

to actualizar_fecha
  if paso_un_dia? [ set dias_transcurridos dias_transcurridos + 1 ]
  if paso_un_mes? [ set meses_transcurridos meses_transcurridos + 1 ]
  if paso_un_ano? [ set anos_transcurridos anos_transcurridos + 1 ]
end


to dispersion
  set cambio_biomasa sum [(biomasa - [biomasa] of myself) * M] of neighbors with [ tipo = "mar" ]
  set biomasa biomasa + cambio_biomasa
end

to dinamica_poblacional
  set biomasa biomasa + (biomasa * R * (1 - (biomasa / K)))
end
@#$#@#$#@
GRAPHICS-WINDOW
329
18
709
399
-1
-1
12.0
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
30
0
30
1
1
1
ticks
30.0

BUTTON
62
52
173
85
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
62
100
158
133
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

SLIDER
734
86
906
119
LONG_TIERRA
LONG_TIERRA
0
10
1.0
1
1
NIL
HORIZONTAL

INPUTBOX
1276
28
1437
105
K
100.0
1
0
Number

CHOOSER
335
420
529
465
COLOREAR_POR
COLOREAR_POR
"biomasa" "zonificacion" "biomasa y zonificacion" "tipo"
0

SLIDER
998
199
1170
232
CAPTURABILIDAD
CAPTURABILIDAD
0
1
0.01
0.01
1
NIL
HORIZONTAL

SLIDER
48
166
283
199
NUMERO_EMBARCACIONES
NUMERO_EMBARCACIONES
0
500
148.0
1
1
NIL
HORIZONTAL

MONITOR
195
404
320
449
NIL
dias_transcurridos
17
1
11

SLIDER
995
100
1167
133
PROB_EXPLORAR
PROB_EXPLORAR
0
1
0.2
0.01
1
NIL
HORIZONTAL

SLIDER
997
166
1169
199
NUM_AMIGOS
NUM_AMIGOS
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
996
133
1168
166
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
1004
316
1183
349
PRECIO_LITRO_GAS
PRECIO_LITRO_GAS
0
10
9.0
1
1
NIL
HORIZONTAL

SLIDER
998
231
1209
264
LITROS_POR_DISTANCIA
LITROS_POR_DISTANCIA
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
1005
349
1184
382
PRECIO_BIOMASA
PRECIO_BIOMASA
0
1000
1000.0
1
1
NIL
HORIZONTAL

INPUTBOX
1277
105
1432
174
M
0.001
1
0
Number

INPUTBOX
1277
174
1432
246
R
1.0
1
0
Number

PLOT
809
463
1009
613
biomasa total
tiempo
biomasa
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -13791810 true "" "plotxy dias_transcurridos sum [biomasa] of patches"

MONITOR
195
448
351
493
NIL
meses_transcurridos - 1
17
1
11

MONITOR
196
494
344
539
NIL
anos_transcurridos - 1
17
1
11

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
0
@#$#@#$#@
