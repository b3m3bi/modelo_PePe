extensions [ rnd ]

breed [ embarcaciones embarcacion ]
breed [ puertos puerto ]
breed [ plataformas plataforma ]
breed [ tortugas tortuga ]
breed [ logos logo ]
breed [ indicadores indicador ]

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
  dia
  mes

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
  ultimo_salario_mensual_promedio

  ;; union-find
  etiquetas

  ;; jugabilidad
  meses_crisis_pesca
  meses_crisis_hidrocarburo
  perdio?
  mensajes_juego
  memoria_mensajes
  umbrales_activos
  pesca_sostenible?
  biomasa_sostenible?
  hidrocarburo_sostenible?
  tortugas_sostenible?
  dias_pesca_sostenible
  dias_biomasa_sostenible
  dias_hidrocarburo_sostenible
  dias_tortugas_sostenible
  ganancia_minima_hidrocarburo_rentable

  ;; hidrocarburo
  numero_derrames
  produccion_mes_hidrocarburo
  ganancia_mes_hidrocarburo
  produccion_hidrocarburo_acumulada
  ganancia_hidrocarburo_acumulada

  ;; visualizacion
  num_zonas
]

patches-own [
  tipo
  zonificacion

  biomasa
  cambio_biomasa

  f
  parent
  transitable_embarcacion?

  etiqueta

  ruta_puerto_sitio
  ruta_sitio_puerto

  hidrocarburo
  derramado?
  tiempo_desde_derrame

  num_zona

  cap_carga
  tortugas_aqui

  prob_plataforma
]

embarcaciones-own [
  estado
  tiempo_restante_iteracion
  tiempo_descansado
  tipo_planeacion
  destino
  ruta
  indice_ruta
  mejor_sitio
  distancia_recorrida
  horas_en_mar
  capturas_viaje
  sitios_visitados
  ganancia
  ganancia_por_hora
  ganancia_por_hora_ultimo_viaje
  gasto_gas
  salario_mensual
  tortugas_matadas
  saldo_subsidio_gas
]

plataformas-own [
  produccion
  tiempo_inactivo
  activo?
]

indicadores-own [ elemento ]

to INICIALIZAR
  print "==============================\nInicializando simulación..."
  clear-all

  init_globales
  init_paisaje
  init_ecologia
  init_hidrocarburo
  init_zonificaion
  init_puerto
  init_plataformas
  init_embarcaciones
  init_rutas
  init_registros
  init_tortugas
  init_jugabilidad
  init_indicadores
  init_visualizacion

  colorear_celdas
  reset-ticks
  print "Ok..."
end

to EJECUTAR
  if ticks = 0 [reset-timer]

  if DETENER_SIMULACION? and (ticks != 0) and (ticks mod ((24 * (360 * ANOS_MAX_SIMULACION) / HORAS_ITERACION))) = 0  [
    if MOSTRAR_MENSAJES? [ user-message (word "Transcurrieron " ANOS_MAX_SIMULACION " años de simulación." ) ]
    print timer
    stop
  ]

  ;; jugabilidad
  if paso_un_dia? [ actualizar_tiempos_sostenibilidad ]
  if paso_un_mes? [ revisar_umbrales_juego ]
  if MOSTRAR_MENSAJES? and mensajes_juego != [] [ foreach mensajes_juego [ mj -> user-message mj ] set mensajes_juego [] ]
  if DETENER_SI_PIERDE? and perdio? [ stop ]

  ;; registros
  if paso_un_mes? [ reiniciar_registros_mensuales ]

  ;; pesca
  ask embarcaciones [ paso_embarcacion ]
  ;; ecología
  if paso_un_dia? [ ask celdas_mar [ dispersion ] ]
  if paso_un_ano? [ ask celdas_mar [ dinamica_poblacional ]]
  ;; hidrocarburo
  if paso_un_dia? [
    ask plataformas [ extraer_hidrocarburo ]
    dinamica_derrame
    calcular_ganancia_hidrocarburo
  ]
  if paso_un_mes? [ subsidiar_gasolina  ]

  ;; tortugas
  if paso_un_ano? [ ask tortugas [ reproducirse_tortuga ] ]
  if paso_un_dia? [
    ask tortugas [ moverse_tortuga ]
    mortalidad_sobrepoblacion
  ]

  mortalidad_sobrepoblacion

  colorear_celdas

  actualizar_fecha
  tick
end

to init_globales
  set dias_transcurridos 0
  set meses_transcurridos 0
  set anos_transcurridos 0
  set dia 0
  set mes 0
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
  ifelse count embarcaciones > 0 [ set ultimo_salario_mensual_promedio mean [salario_mensual ] of embarcaciones ][ set ultimo_salario_mensual_promedio 0]

  set produccion_mes_hidrocarburo []
  set ganancia_mes_hidrocarburo []
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

  let long_area_protegida round ( PORCENTAJE_ANP * (world-width - LONG_TIERRA) / 50 )

  ask patches with [
    pxcor >  x_origen_zona_protegida - long_area_protegida and
    pxcor <= x_origen_zona_protegida and
    pycor >  y_origen_zona_protegida - ANCHO_ZONA_PROTEGIDA and
    pycor <= y_origen_zona_protegida
  ][ set zonificacion "protegido" ]

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
    set color red
    set size 1.1
    move-to one-of puertos

    set estado "descansando"
    set tiempo_restante_iteracion HORAS_ITERACION
    set tiempo_descansado HORAS_DESCANSAR
    set tipo_planeacion ""
    set destino nobody
    set ruta []
    set indice_ruta 0
    set mejor_sitio one-of celdas_libre
    set distancia_recorrida 0
    set horas_en_mar 0
    set capturas_viaje []
    set sitios_visitados []
    set ganancia 0
    set ganancia_por_hora 0
    set ganancia_por_hora_ultimo_viaje 0
    set gasto_gas 0
    set saldo_subsidio_gas SUBSIDIO_MENSUAL_GASOLINA
    set salario_mensual SALARIO_MIN_MENSUAL
  ]

  ifelse count embarcaciones > NUM_AMIGOS [
    ask embarcaciones [ create-amistades-to (n-of NUM_AMIGOS other embarcaciones) [hide-link] ]
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

to init_hidrocarburo
  ask celdas_mar [
    set hidrocarburo HIDROCARBURO_INICIAL
    set derramado? false
    set tiempo_desde_derrame 0
  ]
end

to init_plataformas
  let intentos_crear_mundo 1
  let intentos_maximos 1000
  print (word "Intento " intentos_crear_mundo " de crear un mapa jugable.")
  instalar_plataformas
  while [ not todos_los_sitios_son_accesibles? and (intentos_crear_mundo <= intentos_maximos) ][
    ask plataformas [ die ]
    ask celdas_libre [ set zonificacion "libre" ]
    instalar_plataformas
    set intentos_crear_mundo intentos_crear_mundo + 1
    print (word "Intento " intentos_crear_mundo " de crear un mapa jugable.")
  ]
  if intentos_crear_mundo > intentos_maximos [
    user-message "Es difícil generar un mapa con los parámetros introducidos. /n Los mapas geneados no son jugables (los pescadores no se pueden mover en él). /n Intenta inicializar de nuevo el modelo y/o cambiar los parámetros del modelo."
    stop
  ]
  actualizar_zonificacion
end


to instalar_plataformas
;  let centro max-pxcor - LONG_TIERRA - 10
;  let radio 15

  ask celdas_mar [
    ifelse abs (CENTRO_MAX_PROB_PLATAFORMAS - pxcor) > RADIO_PROB_PLATAFORMAS [
      set prob_plataforma 0
    ][
     set prob_plataforma (1 / RADIO_PROB_PLATAFORMAS ) * (RADIO_PROB_PLATAFORMAS - abs (CENTRO_MAX_PROB_PLATAFORMAS - pxcor))
    ]
  ]

  ask rnd:weighted-n-of NUMERO_PLATAFORMAS celdas_libre [prob_plataforma] [
    sprout-plataformas 1 [
    set shape "plataforma"
    set color gray - 4
    set produccion 0
    set tiempo_inactivo 0
    set activo? true
    ask celdas_libre at-points vecindad_moore RADIO_RESTRICCION true [
      set zonificacion "restriccion"
      ]
    ]
  ]
end


to init_tortugas

  let x_cor_costa max-pxcor - LONG_TIERRA
  let x_cor_final 0
  let _m (MAX_CAP_CARGA - MIN_CAP_CARGA) / (x_cor_costa - x_cor_final)
  let _b MIN_CAP_CARGA

  ask celdas_mar [
    let ruido 0 ; random-normal 0 0.5
    set cap_carga ((pxcor * _m ) + _b)
    if cap_carga < 0 [ set cap_carga 0 ]
    if cap_carga > MAX_CAP_CARGA [ set cap_carga MAX_CAP_CARGA ]
  ]

  create-tortugas POB_INICIAL_TORTUGAS [
    set shape "tortuga"
    set color brown
    set size 0.4
    move-to one-of celdas_mar
  ]
end

to init_jugabilidad
  set perdio? false
  set mensajes_juego []
  set mensajes_juego []
  set memoria_mensajes n-values 4 [false]

  (ifelse
    RONDA = "Ronda 1 (Pesca)"            [ set umbrales_activos (list true true false false) ]
    RONDA = "Ronda 2 (Petróleo)"         [ set umbrales_activos (list true true true false) ]
    RONDA = "Ronda 3 (Conservación)"     [ set umbrales_activos (list true true true true) ]
    RONDA = "Ronda 4 (Manejo sectorial)" [ set umbrales_activos (list true true true true) ]
    RONDA = "Ronda 5 (Co-manejo)"        [ set umbrales_activos (list true true true true) ]
    [ set umbrales_activos (list true true true true) ]
    )

  set meses_crisis_pesca 0
  set meses_crisis_hidrocarburo 0

  let ganancia_maxima_hidrocarburo HIDROCARBURO_INICIAL * TASA_DECLINACION_HIDROCARBURO * PRECIO_HIDROCARBURO * count plataformas * 30
  set ganancia_minima_hidrocarburo_rentable ganancia_maxima_hidrocarburo * PROCENTAJE_GANANCIA_MINIMA_HIDROCARBURO / 100

  set pesca_sostenible? true
  set biomasa_sostenible? true
  set hidrocarburo_sostenible? true
  set tortugas_sostenible? true

  set dias_pesca_sostenible 0
  set dias_biomasa_sostenible 0
  set dias_hidrocarburo_sostenible 0
  set dias_tortugas_sostenible 0
end

to init_indicadores
  let elementos ["pesca" "biomasa" "hidrocarburo" "tortugas" ]
  let inicio_x world-width - 2
  let inicio_y (world-height / 2 ) + 4

  let pos (list (list inicio_x inicio_y) (list inicio_x (inicio_y - 2)) (list inicio_x (inicio_y - 4)) (list inicio_x (inicio_y - 6)))
  let _shapes [ "boat" "camaron" "plataforma" "tortuga" ]
  let _colors (list red pink (gray - 4) (brown + 1) )
  let hay_agentes (list (any? embarcaciones) true (any? plataformas) (any? tortugas))
  let poner? (map [[umbral hay] -> umbral and hay] umbrales_activos hay_agentes)

  (foreach elementos pos _shapes _colors poner? [
    [el p s c p?] ->
    if p? [
      create-indicadores 1 [
        set elemento el
        actualizar_indicador el "viable"
        set size 1.5
        setxy (item 0 p) (item 1 p) - 2
      ]
      create-logos 1 [
        set shape s
        set color c
        set size 2
        set heading 0
        setxy ((item 0 p) - 2) (item 1 p) - 2
      ]
    ]
  ])
end

to init_visualizacion
  formar_vecindades
  dibujar_bordes_zonas
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
    colorear_zona_restringida_protegida
  ]

  if COLOREAR_POR = "biomasa y zonificacion" [
    colorear_biomasa
    colorear_zona_restringida_protegida
  ]

  if COLOREAR_POR = "biomasa y derrames" [
    colorear_biomasa
    colorear_derrames
  ]

  if COLOREAR_POR = "hidrocarburo" [
    ask patches [ set pcolor scale-color black hidrocarburo HIDROCARBURO_INICIAL 0 ]
  ]

  if COLOREAR_POR = "derrames" [
    ask patches [
      set pcolor white
    ]
    colorear_derrames
  ]

  if COLOREAR_POR = "biomasa, zonificacion y derrames" [
    colorear_biomasa
    colorear_zona_restringida_protegida
    colorear_derrames
  ]

  if COLOREAR_POR = "habitat tortugas" [
    ask patches [ set pcolor scale-color sky cap_carga (MAX_CAP_CARGA * 2) 0  ]
  ]
  if COLOREAR_POR = "tortugas aqui" [
    ask patches [ set pcolor scale-color yellow tortugas_aqui 7000 0 ]
  ]
  if COLOREAR_POR = "prob plataforma" [
    ask patches [ set pcolor scale-color gray prob_plataforma 1 0 ]
  ]
end

to colorear_derrames
  if any? celdas_mar with [ derramado? ][
    ask celdas_mar with [ derramado? ] [
      set pcolor black
    ]
  ]
end

to colorear_biomasa
  ask patches [ set pcolor scale-color cyan biomasa (K * 2) 0 ]
end

to colorear_zona_restringida_protegida
  ask celdas_protegido   [ set pcolor yellow + 2 ]
  ask celdas_restriccion [ set pcolor red + 1 ]
end

to paso_embarcacion
  set tiempo_restante_iteracion HORAS_ITERACION
  ejecutar_estado
end

to ejecutar_estado
  if tiempo_restante_iteracion >  0 [
    (ifelse
      estado = "descansando"   [ descansar ]
      estado = "planeando"     [ planear ]
      estado = "moviendose"    [ moverse ]
      estado = "pescando"      [ pescar ]
      estado = "desembarcando" [ desembarcar ]
    )
    ejecutar_estado
  ]
end

to descansar
  if not pesca_sostenible? and INACTIVAR_PESCA_COLAPSO? [ set tiempo_restante_iteracion 0  stop ]
  let tiempo_descanso_iteracion 0
  ifelse HORAS_DESCANSAR - tiempo_descansado > tiempo_restante_iteracion [
    ;; si el tiempo restante de la iteración es menor al necesario para descansar
    ;; entonces descanso todo el tiempo y me quedo descansando...
    set tiempo_descanso_iteracion tiempo_restante_iteracion
  ][
    ;; si el tiempo restante de la iteración es mayor o igual al necesario para
    ;; descansar entonces solo descanso el rato suficiente y me pongo a planear...
    set tiempo_descanso_iteracion HORAS_DESCANSAR - tiempo_descansado
    set estado "planeando"
    set tipo_planeacion "inicio"
  ]
  set tiempo_descansado tiempo_descansado + tiempo_descanso_iteracion
  set tiempo_restante_iteracion tiempo_restante_iteracion - tiempo_descanso_iteracion
end

to planear
  (ifelse
    tipo_planeacion = "inicio" [
      set destino seleccionar_sitio_pesca_EEI
      set ruta [ruta_puerto_sitio] of destino
    ]
    tipo_planeacion = "regreso" [
      set destino [patch-here] of one-of puertos
      set ruta reverse [ruta_puerto_sitio] of patch-here
    ])
  set indice_ruta 0
  set estado "moviendose"
end

to moverse
  ifelse patch-here = destino [
    ;; ya llegue a mi destino
    ifelse destino = [patch-here] of one-of puertos
    [ set estado "desembarcando" ]
    [ set estado "pescando" ]
  ][
    ;; avanzo una unidad de velocidad hacia mi destino
    let tamanio_paso VELOCIDAD / LONGITUD_CELDA
    let distancia_avanzada 0

    let llegue? false
    while [ distancia_avanzada < tamanio_paso and not llegue? ] [
      let siguiente_celda (item indice_ruta ruta)
      face siguiente_celda
      let distancia_avanzo min (list (tamanio_paso - distancia_avanzada) (distance siguiente_celda))
      jump distancia_avanzo

      set distancia_avanzada distancia_avanzada + distancia_avanzo
      set distancia_recorrida distancia_recorrida + distancia_avanzo

      ;; reviso si ya llegué al centro o no de la siguiente celda
      if distance siguiente_celda = 0 [
        ;; si ya llegué cambio de indice
        set indice_ruta indice_ruta + 1

        ;; puede que llegue al destino y me hayan sobrado pasos, por lo que me detengo
        if patch-here = destino [ set llegue? true ]
      ]
    ]
    set horas_en_mar horas_en_mar + 1
    set tiempo_restante_iteracion tiempo_restante_iteracion - 1
  ]
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

to pescar
  ;; pesco
  let captura_sitio biomasa * CAPTURABILIDAD
  set biomasa biomasa - captura_sitio
  set capturas_viaje lput captura_sitio capturas_viaje

  ;; mortalidad tortugas
  if any? tortugas-here and random-float 1.0 < PROB_MORTALIDAD_TORTUGA_PESCA [
    ask one-of tortugas-here [ die ]
    set tortugas_matadas tortugas_matadas + 1
  ]

  set horas_en_mar horas_en_mar + 1
  set tiempo_restante_iteracion tiempo_restante_iteracion - 1
  set sitios_visitados lput patch-here sitios_visitados

  ;; decido qué pasa después...
  ifelse sum capturas_viaje >= CAPACIDAD_MAXIMA [
    ;; ya se llenó el barco...
    ;; regreso el extra de la última captura...
    let cantidad_regresar sum capturas_viaje - CAPACIDAD_MAXIMA
    let ultima_captura last capturas_viaje
    set biomasa biomasa + cantidad_regresar
    set capturas_viaje replace-item ((length capturas_viaje) - 1) capturas_viaje (ultima_captura - cantidad_regresar)

    set tipo_planeacion "regreso"
  ][
    ifelse horas_en_mar / 24 >= DIAS_MAXIMOS_EN_MAR [
      ;; ya estuve mucho tiempo en el mar... planea el regreso
      set tipo_planeacion "regreso"
    ][
      ;; planea la siguiente pesca...
      set tipo_planeacion "continuar"
    ]
  ]
  set estado "planeando"
end

to desembarcar
  let ingresos_captura (sum capturas_viaje) * PRECIO_BIOMASA
  set gasto_gas PRECIO_LITRO_GAS * LITROS_POR_DISTANCIA * LONGITUD_CELDA * distancia_recorrida + LITROS_POR_HORA_PESCA * (length sitios_visitados)

  if saldo_subsidio_gas > 0 [
    ifelse saldo_subsidio_gas - gasto_gas > 0 [
      set saldo_subsidio_gas saldo_subsidio_gas - gasto_gas
      set gasto_gas 0
    ][
     set saldo_subsidio_gas 0
     set gasto_gas gasto_gas - saldo_subsidio_gas
    ]
  ]

  set ganancia ingresos_captura - gasto_gas
  set ganancia_por_hora ganancia / horas_en_mar
  set salario_mensual salario_mensual + (ganancia / NUM_TRIPULANTES)

  if ganancia_por_hora > ganancia_por_hora_ultimo_viaje [
    set mejor_sitio (item (obtener_indice_max capturas_viaje) sitios_visitados)
  ]

  registrar_viaje

  set ganancia_por_hora_ultimo_viaje ganancia_por_hora
  set capturas_viaje []
  set sitios_visitados []
  set horas_en_mar 0
  set distancia_recorrida 0

  set estado "descansando"
  set tiempo_descansado 0
  set tiempo_restante_iteracion tiempo_restante_iteracion - 1
end

to registrar_viaje
  set capturas_mes lput (sum capturas_viaje) capturas_mes
  set captura_acumulada captura_acumulada + (sum capturas_viaje)
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

to reiniciar_registros_mensuales
  set capturas_mes []
  set distancias_recorridas_mes []
  set horas_en_mar_mes []
  set gasto_gas_mes []
  set ganancias_mes []
  set num_viajes_mes 0

  set produccion_mes_hidrocarburo []
  set ganancia_mes_hidrocarburo []

  ifelse count embarcaciones > 0 [ set ultimo_salario_mensual_promedio mean [salario_mensual ] of embarcaciones ][ set ultimo_salario_mensual_promedio 0]
  ask embarcaciones [ set salario_mensual 0 ]
end

to dispersion
  set cambio_biomasa sum [(biomasa - [biomasa] of myself) * M] of neighbors with [ tipo = "mar" ]
  set biomasa biomasa + cambio_biomasa
end

to dinamica_poblacional
  set biomasa biomasa + (biomasa * R * (1 - (biomasa / K)))
end

to-report obtener_indice_max [ lista ]
  let maximo max lista
  report position maximo lista
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
  report (HORAS_ITERACION * ticks mod 24) = 0
end

to-report paso_un_mes?
  report (ticks mod (24 * 30 / HORAS_ITERACION)) = 0
end

to-report paso_un_ano?
  report (ticks mod (24 * 360 / HORAS_ITERACION)) = 0
end

to actualizar_fecha
  if paso_un_dia? [
    set dias_transcurridos dias_transcurridos + 1
    set dia dia + 1
  ]
  if paso_un_mes? [
    set meses_transcurridos meses_transcurridos + 1
    set dia 1
    set mes mes + 1
  ]
  if paso_un_ano? [
    if ticks != 0 [ set anos_transcurridos anos_transcurridos + 1 ]
    set mes 1
  ]
end

to revisar_umbrales_juego

  set mensajes_juego []

  if any? embarcaciones and (item 0 umbrales_activos) [
    ifelse mean [ salario_mensual ] of embarcaciones < SALARIO_MIN_MENSUAL [
      set meses_crisis_pesca meses_crisis_pesca + 1
    ][
      set meses_crisis_pesca 0
    ]
    ifelse meses_crisis_pesca >= 1 or meses_crisis_pesca >= MAX_MESES_CRISIS_PESCA [
      ifelse  meses_crisis_pesca >= MAX_MESES_CRISIS_PESCA [
        set perdio? true
        set pesca_sostenible? false
        if not (item 0 memoria_mensajes) [
          set memoria_mensajes replace-item 0 memoria_mensajes true
          let mensaje_juego (word "Colapso de la industria pesquera: El ingreso promedio de los pescadores fue menor a $" SALARIO_MIN_MENSUAL " durante " meses_crisis_pesca " meses seguidos.")
          set mensajes_juego lput mensaje_juego mensajes_juego
        ]
        actualizar_indicador "pesca" "colapso"
      ][
        actualizar_indicador "pesca" "crisis"
      ]
    ][
      actualizar_indicador "pesca" "viable"
    ]
  ]

  if (item 1 umbrales_activos) [
    ifelse sum [biomasa] of patches < K * count celdas_mar * PORCENTAJE_BIOMASA_CRISIS / 100 [
      ifelse sum [biomasa] of patches < K * count celdas_mar * PORCENTAJE_BIOMASA_COLAPSO / 100 [
        set perdio? true
        set biomasa_sostenible? false
        if not (item 1 memoria_mensajes) [
          set memoria_mensajes replace-item 1 memoria_mensajes true
          let mensaje_juego (word "Sobrepesca: El recurso pesquero es menor al " PORCENTAJE_BIOMASA_COLAPSO "% del inicial. El recurso pesquero está en un estado crítico.")
          set mensajes_juego lput mensaje_juego mensajes_juego
        ]
        actualizar_indicador "biomasa" "colapso"
      ][
        actualizar_indicador "biomasa" "crisis"
      ]
    ][
      actualizar_indicador "biomasa" "viable"
    ]
  ]

  if any? plataformas and (item 2 umbrales_activos)[

    ifelse sum ganancia_mes_hidrocarburo < ganancia_minima_hidrocarburo_rentable and ticks != 0 [
      set meses_crisis_hidrocarburo meses_crisis_hidrocarburo + 1
    ][
      set meses_crisis_hidrocarburo 0
    ]

    ifelse meses_crisis_hidrocarburo > MAX_MESES_CRISIS_HIDROCARBURO [
      ;; si ya pasó el tiempo rentable
      set hidrocarburo_sostenible? false
      ifelse produccion_hidrocarburo_acumulada >= OBJETIVO_MIN_PRODUCCION_HIDROCARBURO * 1000 [
        ;; se cumplió el objetivo mínimo de producción antes de terminar el tiempo útil
        if not (item 2 memoria_mensajes) [
          set memoria_mensajes replace-item 2 memoria_mensajes true
          let mensaje_juego (word "Se cumplió el objetivo de producción durante el tiempo rentable de las plataformas. Se debían producir al menos " OBJETIVO_MIN_PRODUCCION_HIDROCARBURO " miles de barriles y se obtuvieron " round (produccion_hidrocarburo_acumulada / 1000) " miles de barriles.")
          set mensajes_juego lput mensaje_juego mensajes_juego
        ]
        actualizar_indicador "hidrocarburo" "viable"
      ][
        ;; no se cumplió el objetivo mínimo de producción antes de terminar el tiempo útil
        set perdio? true
        if not (item 2 memoria_mensajes) [
          set memoria_mensajes replace-item 2 memoria_mensajes true
          let mensaje_juego (word "No se cumplió el objetivo de producción durante el tiempo rentable de las plataformas. Se debían producir al menos " OBJETIVO_MIN_PRODUCCION_HIDROCARBURO " miles de barriles y se obtuvieron solo " round (produccion_hidrocarburo_acumulada / 1000) " miles de barriles.")
          set mensajes_juego lput mensaje_juego mensajes_juego
        ]
        actualizar_indicador "hidrocarburo" "colapso"
      ]
    ][
      ;; si no ha pasado el tiempo rentable
      ifelse produccion_hidrocarburo_acumulada >= OBJETIVO_MIN_PRODUCCION_HIDROCARBURO * 1000  or anos_transcurridos < ANO_ADVERTENCIA_OBJETIVO_HIDROCARBURO [
        ;; ya se cumplió el objetivo o no ha pasado tanto tiempo no hay por qué alarmarse
        actualizar_indicador "hidrocarburo" "viable"
      ][
        ;; ya estamos cerca del límite, alarmarse
        actualizar_indicador "hidrocarburo" "crisis"
      ]
    ]
  ]

  if any? tortugas and (item 3 umbrales_activos)[
    ifelse count tortugas < POB_INICIAL_TORTUGAS * PORCENTAJE_TORTUGAS_CRISIS / 100 [
      ifelse count tortugas < POB_INICIAL_TORTUGAS * PORCENTAJE_TORTUGAS_COLAPSO / 100 [
        set perdio? true
        set tortugas_sostenible? false
        if not (item 3 memoria_mensajes) [
          set memoria_mensajes replace-item 3 memoria_mensajes true
          let mensaje_juego (word "Colapso biológico: la población de tortugas se redujo más del " (100 - PORCENTAJE_TORTUGAS_COLAPSO ) "%. La población de tortugas está en un estado crítico.")
          set mensajes_juego lput mensaje_juego mensajes_juego
        ]
        actualizar_indicador "tortugas" "colapso"
      ][
        actualizar_indicador "tortugas" "crisis"
      ]
    ][
      actualizar_indicador "tortugas" "viable"
    ]
  ]
end

to actualizar_indicador [ ele edo ]
  ask indicadores with [ elemento = ele ][
    (ifelse
      edo = "viable" [ set shape "face happy" set color lime ]
      edo = "crisis" [ set shape "face neutral" set color yellow ]
      edo = "colapso" [ set shape "face sad" set color red ])
  ]
end

to actualizar_tiempos_sostenibilidad
  if any? embarcaciones and pesca_sostenible? [ set dias_pesca_sostenible dias_pesca_sostenible + 1]
  if biomasa_sostenible? [ set dias_biomasa_sostenible dias_biomasa_sostenible + 1 ]
  if any? plataformas and hidrocarburo_sostenible? [ set dias_hidrocarburo_sostenible dias_hidrocarburo_sostenible + 1 ]
  if any? tortugas and tortugas_sostenible? [ set dias_tortugas_sostenible dias_tortugas_sostenible + 1 ]
end

to-report todos_los_sitios_son_accesibles?
  formar_componentes
  let celdas_navegables patches with [zonificacion = "libre" or tipo = "puerto" ]
  ifelse length remove-duplicates [etiqueta] of celdas_navegables = 1
  [ report true ]
  [ report false ]
end

to-report encontrar [x]
  let y x
  while [ (item y etiquetas) != y ][
    set y (item y etiquetas)
  ]
  while [ (item x etiquetas) != x ][
    let z (item x etiquetas)
    set etiquetas replace-item x etiquetas y
    set x z
  ]
  report y
end

to union [x y]
  set etiquetas replace-item (encontrar x) etiquetas (encontrar y)
end

to formar_componentes
  let etiqueta_max 0
  set etiquetas range count patches
  ask patches [ set etiqueta 0 ]

  foreach sort patches [
    p ->
    ask p [
      if zonificacion = "libre" or tipo = "puerto" [
        let atras patch-at-heading-and-distance 270 1
        let arriba patch-at-heading-and-distance 0 1
        (ifelse
          (atras = nobody or [etiqueta] of atras = 0) and (arriba = nobody or [etiqueta] of arriba = 0) [
            set etiqueta_max etiqueta_max + 1
            set etiqueta etiqueta_max
          ]
          (atras != nobody and [etiqueta] of atras != 0) and (arriba = nobody or [etiqueta] of arriba = 0) [
            set etiqueta encontrar [etiqueta] of atras
          ]
          (atras = nobody or [etiqueta] of atras = 0) and (arriba != nobody and [etiqueta] of arriba != 0) [
            set etiqueta encontrar [etiqueta] of arriba
          ]
          [
            union [etiqueta] of atras [etiqueta] of arriba
            set etiqueta encontrar [etiqueta] of atras
          ]
        )
      ]
    ]
  ]
  foreach sort patches [
    p -> ask p [ set etiqueta encontrar etiqueta ]
  ]
end

to calcular_ganancia_hidrocarburo
  if any? plataformas with [ activo? ][
    let precio_hidrocarburo_hoy random-normal PRECIO_HIDROCARBURO VARIANZA_PRECIO_HIDROCARBURO
    ;  let ingreso_dia_hidrocarburo sum [produccion] of plataformas * PRECIO_HIDROCARBURO
    let ingreso_dia_hidrocarburo sum [produccion] of plataformas * precio_hidrocarburo_hoy
    let costo_dia_hidrocarburo (count plataformas ) * COSTO_OPERACION_PLATAFORMA
    let balance (ingreso_dia_hidrocarburo - costo_dia_hidrocarburo)
    set ganancia_mes_hidrocarburo lput balance ganancia_mes_hidrocarburo
    set ganancia_hidrocarburo_acumulada ganancia_hidrocarburo_acumulada + balance
  ]
end

to extraer_hidrocarburo
  if not hidrocarburo_sostenible? and INACTIVAR_HIDROCARBURO_COLAPSO? [ set activo? false set color gray + 2]

  ifelse activo? and tiempo_inactivo <= 0 [
;    set produccion min (list EXTRACCION_MAX_HIDROCARBURO (hidrocarburo * TASA_DECLINACION_HIDROCARBURO))
    set produccion hidrocarburo * TASA_DECLINACION_HIDROCARBURO
    set produccion_mes_hidrocarburo lput produccion produccion_mes_hidrocarburo
    set produccion_hidrocarburo_acumulada produccion_hidrocarburo_acumulada + produccion
    set hidrocarburo hidrocarburo - produccion
  ][
    set produccion 0
  ]
end

to dinamica_derrame
  if any? celdas_mar with [ derramado? ][ extender_derrame ]

  if any? plataformas with [ tiempo_inactivo = 0 and activo? ] and random-float 1.0 < PROB_OCURRENCIA_DERRAME [
    let origen one-of plataformas with [ tiempo_inactivo = 0 and activo? ]
    ask origen [ set tiempo_inactivo TIEMPO_DERRAMADO set color gray + 3 ]
    ask [patch-here] of origen [ derramar_celda ]
    set numero_derrames numero_derrames + 1
  ]

  if any? plataformas with [ tiempo_inactivo > 0 and activo? ][
    ask plataformas with [ tiempo_inactivo > 0 ] [
      set tiempo_inactivo tiempo_inactivo - 1
      if tiempo_inactivo <= 0 [ set color gray - 4 ]
    ]
  ]
end

to derramar_celda
  set derramado? true
  set tiempo_desde_derrame 0
  set biomasa biomasa - (biomasa * PROB_MORTALIDAD_DERRAME)
  set ganancia_mes_hidrocarburo lput (- COSTO_POR_CELDA_DERRAMADA) ganancia_mes_hidrocarburo
end

to extender_derrame
  let celdas_derramado celdas_mar with [derramado?]
  ask celdas_derramado with [tiempo_desde_derrame = 1 ][
    ask neighbors4 with [ tipo = "mar" and not derramado?][
      if random-float 1.0 < PROB_EXTENSION_DERRAME [ derramar_celda ]
    ]
  ]
  ask celdas_derramado [
    if random-float 1.0 < PROB_MORTALIDAD_TORTUGA_DERRAME [
      ask tortugas-here [ die ]
    ]
    set tiempo_desde_derrame tiempo_desde_derrame + 1
    if tiempo_desde_derrame > TIEMPO_DERRAMADO [
      set derramado? false
      set tiempo_desde_derrame -999
    ]
  ]
end

to moverse_tortuga
  face one-of celdas_mar at-points vecindad_moore 1 false
  jump 1
  set tortugas_aqui tortugas_aqui + 1
end

to reproducirse_tortuga
  hatch NUM_DESCENDIENTES
end

to mortalidad_sobrepoblacion
  ask celdas_mar [
    if count tortugas-here > cap_carga [
      ask n-of (count tortugas-here - cap_carga) tortugas-here [ die ]
    ]
  ]
end

to formar_vecindades
  ask patches [ set num_zona -9999 ]
  let zona 1
  ask celdas_mar [
    if ((zonificacion = "restriccion" or  zonificacion = "protegido") and num_zona = -9999) [
      formar_vecindad zona
      set zona zona + 1
    ]
  ]
  set num_zonas max [num_zona] of patches
end

to formar_vecindad [ zona ]
  set num_zona zona
  ask neighbors4 with [ zonificacion = [zonificacion] of myself and num_zona = -9999 ][
    formar_vecindad zona
  ]
end

to dibujar_borde_zona [_num_zona ]
  ask patches with [ num_zona = _num_zona][
    sprout 1 [
      set heading 0
      if zonificacion = "restriccion" [ set color red ]
      if zonificacion = "protegido"   [ set color yellow ]
      set pen-size 1.5
      setxy (xcor - 0.5) (ycor - 0.5)
      repeat 4 [
        let cuadro_izquierda patch-left-and-ahead 45 0.5
        ifelse (cuadro_izquierda != nobody and [num_zona] of cuadro_izquierda != [num_zona] of myself) or cuadro_izquierda = nobody
        [pen-down]
        [pen-up]
        fd .99
        rt 90
      ]
      die
    ]
  ]
end

to dibujar_bordes_zonas
;  clear-drawing
  foreach (range 1 (num_zonas + 1)) [
    i -> dibujar_borde_zona i
  ]
end

to subsidiar_gasolina
  if any? plataformas with [ activo? ]  [
    ask embarcaciones [
      set saldo_subsidio_gas SUBSIDIO_MENSUAL_GASOLINA
      set ganancia_mes_hidrocarburo lput (- SUBSIDIO_MENSUAL_GASOLINA) ganancia_mes_hidrocarburo
    ]
  ]
end

to exportar_imagen
  if EXPORTAR_IMAGEN? and ticks mod TICKS_EXPORTAR = 0 [
    export-view ( word RUTA_IMGS ("/img-") (agregar-ceros (word ticks "") 4) (".png"))
  ]
end

to-report agregar-ceros [ cadena numero-ceros ]
  if length cadena >= numero-ceros [
    report cadena
  ]
  report agregar-ceros ( insert-item 0 cadena "0" ) numero-ceros
end
@#$#@#$#@
GRAPHICS-WINDOW
235
100
818
609
-1
-1
12.5
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
45
0
39
1
1
1
ticks
30.0

BUTTON
10
305
225
340
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
10
345
225
380
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
1455
550
1717
595
COLOREAR_POR
COLOREAR_POR
"tipo" "zonificacion" "biomasa" "hidrocarburo" "derrames" "biomasa y zonificacion" "biomasa y derrames" "biomasa, zonificacion y derrames" "habitat tortugas" "tortugas aqui" "prob plataforma"
7

SLIDER
10
125
225
158
NUMERO_EMBARCACIONES
NUMERO_EMBARCACIONES
0
200
0.0
25
1
NIL
HORIZONTAL

MONITOR
3065
485
3185
530
NIL
dias_transcurridos
17
1
11

MONITOR
350
45
410
94
dia
dia
17
1
12

MONITOR
295
45
352
94
mes
mes
17
1
12

MONITOR
240
45
297
94
año
anos_transcurridos
17
1
12

PLOT
1270
255
1485
405
Recurso pesquero
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
"biomasa" 1.0 0 -14835848 true "" "if paso_un_mes? [plotxy meses_transcurridos sum [biomasa] of patches]"
"umbral colapso" 1.0 0 -1604481 true "" "plotxy meses_transcurridos count celdas_mar * K * PORCENTAJE_BIOMASA_COLAPSO / 100"
"umbral crisis" 1.0 0 -723837 true "" "plotxy meses_transcurridos count celdas_mar * K * PORCENTAJE_BIOMASA_CRISIS / 100"

MONITOR
3065
530
3185
575
NIL
timer
2
1
11

PLOT
830
255
1045
405
Captura total
mes
ton
0.0
10.0
0.0
1.0
true
false
"" "set-plot-y-range 0 2000"
PENS
"total" 1.0 0 -13345367 true "" "if paso_un_mes? [ plotxy dias_transcurridos sum capturas_mes ]"

PLOT
830
405
1045
555
Gasto en gasolina por viaje
mes
$
0.0
10.0
0.0
10000.0
true
false
"" "set-plot-y-range 0 3000"
PENS
"media" 1.0 0 -13345367 true "" "if paso_un_mes? [ ifelse gasto_gas_mes != [] [ plotxy meses_transcurridos mean gasto_gas_mes ][ plotxy meses_transcurridos 0 ]]"

SLIDER
1790
40
1975
73
HORAS_DESCANSAR
HORAS_DESCANSAR
0
120
12.0
1
1
NIL
HORIZONTAL

SLIDER
1790
75
1975
108
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
1790
110
1975
143
RADIO_EXPLORAR
RADIO_EXPLORAR
0
10
3.0
1
1
NIL
HORIZONTAL

SLIDER
1790
250
1975
283
VELOCIDAD
VELOCIDAD
0
100
0.5
0.5
1
NIL
HORIZONTAL

SLIDER
1790
215
1975
248
CAPTURABILIDAD
CAPTURABILIDAD
0
.1
0.01
0.001
1
NIL
HORIZONTAL

SLIDER
1790
285
1975
318
CAPACIDAD_MAXIMA
CAPACIDAD_MAXIMA
1
3
1.0
1
1
NIL
HORIZONTAL

SLIDER
1790
180
1975
213
DIAS_MAXIMOS_EN_MAR
DIAS_MAXIMOS_EN_MAR
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
1790
145
1975
178
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
1790
425
1975
458
PRECIO_BIOMASA
PRECIO_BIOMASA
0
20000
10000.0
100
1
NIL
HORIZONTAL

SLIDER
1790
460
1975
493
PRECIO_LITRO_GAS
PRECIO_LITRO_GAS
0
1000
25.0
5
1
NIL
HORIZONTAL

SLIDER
1790
320
1975
353
LITROS_POR_DISTANCIA
LITROS_POR_DISTANCIA
0
10
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
1790
355
1975
388
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
2000
45
2157
110
K
50.0
1
0
Number

INPUTBOX
2000
110
2157
175
M
0.001
1
0
Number

INPUTBOX
2000
175
2157
240
R
0.575
1
0
Number

PLOT
3000
155
3200
275
ganancia/viaje promedio
mes
$
0.0
10.0
0.0
10.0
true
false
"" "set-plot-y-range -1000 10000 "
PENS
"media" 1.0 0 -13345367 true "" "if paso_un_mes? [ifelse ganancias_mes != [] [plotxy meses_transcurridos mean ganancias_mes ][ plotxy meses_transcurridos 0 ]]"
"0" 1.0 0 -4539718 true "" "plotxy meses_transcurridos 0"

SLIDER
1790
390
1975
423
NUM_TRIPULANTES
NUM_TRIPULANTES
0
6
3.0
1
1
NIL
HORIZONTAL

PLOT
3000
275
3200
395
total viajes
mes
num. viajes
0.0
10.0
0.0
10.0
true
false
"" "set-plot-y-range 0 2100"
PENS
"total" 1.0 0 -16777216 true "" "if paso_un_mes? [ plotxy meses_transcurridos num_viajes_mes ]"

PLOT
830
105
1045
255
Ingreso mensual 
mes
$
0.0
10.0
0.0
20000.0
true
false
"" "set-plot-y-range 0 50000"
PENS
"media" 1.0 0 -13345367 true "" "if paso_un_mes? and any? embarcaciones [ plotxy meses_transcurridos (mean [salario_mensual] of embarcaciones) ]"
"umbral" 1.0 0 -1604481 true "" "plotxy meses_transcurridos SALARIO_MIN_MENSUAL"
"0" 1.0 0 -4539718 true "" "plotxy meses_transcurridos 0"

SLIDER
2740
110
2965
143
SALARIO_MIN_MENSUAL
SALARIO_MIN_MENSUAL
0
10000
7500.0
100
1
NIL
HORIZONTAL

TEXTBOX
1795
15
1945
33
PESCA
12
0.0
1

TEXTBOX
2000
20
2150
38
ECOLOGIA
12
0.0
1

TEXTBOX
2745
15
2895
33
JUGABILIDAD
12
0.0
1

SLIDER
2455
405
2670
438
LONG_TIERRA
LONG_TIERRA
0
10
6.0
1
1
NIL
HORIZONTAL

TEXTBOX
2455
380
2605
398
PAISAJE
12
0.0
1

SLIDER
2455
440
2670
473
ANCHO_ZONA_PROTEGIDA
ANCHO_ZONA_PROTEGIDA
0
40
19.0
1
1
NIL
HORIZONTAL

SLIDER
2455
300
2635
333
HORAS_ITERACION
HORAS_ITERACION
1
24
24.0
1
1
NIL
HORIZONTAL

SLIDER
2455
335
2635
368
LONGITUD_CELDA
LONGITUD_CELDA
1
20
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
2455
275
2605
293
GLOBALES
12
0.0
1

SLIDER
2740
145
2965
178
MAX_MESES_CRISIS_PESCA
MAX_MESES_CRISIS_PESCA
1
24
6.0
1
1
NIL
HORIZONTAL

SWITCH
2740
40
2965
73
DETENER_SI_PIERDE?
DETENER_SI_PIERDE?
0
1
-1000

SWITCH
2740
75
2965
108
MOSTRAR_MENSAJES?
MOSTRAR_MENSAJES?
0
1
-1000

SLIDER
2740
215
2965
248
PORCENTAJE_BIOMASA_CRISIS
PORCENTAJE_BIOMASA_CRISIS
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
2740
250
2965
283
PORCENTAJE_BIOMASA_COLAPSO
PORCENTAJE_BIOMASA_COLAPSO
0
100
25.0
1
1
%
HORIZONTAL

TEXTBOX
15
105
165
123
PESCA
12
0.0
1

TEXTBOX
10
230
160
248
CONSERVACION
12
0.0
1

SWITCH
2740
180
2965
213
INACTIVAR_PESCA_COLAPSO?
INACTIVAR_PESCA_COLAPSO?
0
1
-1000

MONITOR
535
45
650
94
años
;(word \n;(round (floor dias_biomasa_sostenible / 360))\n;\" / \"\n;(round (floor (dias_biomasa_sostenible / 30) mod 12)))\ndias_biomasa_sostenible / 360
1
1
12

TEXTBOX
15
165
165
183
PETROLEO
12
0.0
1

SLIDER
10
185
225
218
NUMERO_PLATAFORMAS
NUMERO_PLATAFORMAS
0
20
0.0
5
1
NIL
HORIZONTAL

SLIDER
2170
395
2440
428
RADIO_RESTRICCION
RADIO_RESTRICCION
3
6
3.0
1
1
pixeles
HORIZONTAL

PLOT
1050
105
1265
255
Produccion total petroleo
mes
barriles
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" "if paso_un_mes? [plotxy meses_transcurridos sum produccion_mes_hidrocarburo ]"

SLIDER
2170
150
2440
183
PROB_OCURRENCIA_DERRAME
PROB_OCURRENCIA_DERRAME
0
1
0.025
0.001
1
NIL
HORIZONTAL

SLIDER
2170
185
2440
218
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
2170
220
2440
253
PROB_MORTALIDAD_DERRAME
PROB_MORTALIDAD_DERRAME
0
1
0.75
0.01
1
NIL
HORIZONTAL

SLIDER
2170
255
2440
288
TIEMPO_DERRAMADO
TIEMPO_DERRAMADO
0
100
50.0
1
1
NIL
HORIZONTAL

MONITOR
3065
395
3200
440
NIL
numero_derrames
17
1
11

SLIDER
2170
290
2440
323
COSTO_POR_CELDA_DERRAMADA
COSTO_POR_CELDA_DERRAMADA
0
100000
10000.0
1000
1
NIL
HORIZONTAL

SLIDER
2170
360
2440
393
PRECIO_HIDROCARBURO
PRECIO_HIDROCARBURO
0
20000
100.0
100
1
NIL
HORIZONTAL

PLOT
1050
255
1265
405
Ganancia petroleo
mes
$ (millones)
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" "if paso_un_mes? [ plotxy meses_transcurridos sum ganancia_mes_hidrocarburo / 1000000 ]"
"minimo" 1.0 0 -1604481 true "" "if paso_un_mes? [ plotxy meses_transcurridos ganancia_minima_hidrocarburo_rentable / 1000000]"

SLIDER
2170
325
2440
358
COSTO_OPERACION_PLATAFORMA
COSTO_OPERACION_PLATAFORMA
0
10000
10000.0
100
1
NIL
HORIZONTAL

SLIDER
2740
285
2965
318
MAX_MESES_CRISIS_HIDROCARBURO
MAX_MESES_CRISIS_HIDROCARBURO
0
24
1.0
1
1
NIL
HORIZONTAL

MONITOR
1225
45
1340
94
años
dias_hidrocarburo_sostenible / 360
1
1
12

TEXTBOX
2175
20
2325
38
HIDROCARBURO
12
0.0
1

SWITCH
2740
320
2965
353
INACTIVAR_HIDROCARBURO_COLAPSO?
INACTIVAR_HIDROCARBURO_COLAPSO?
0
1
-1000

TEXTBOX
2450
20
2600
38
TORTUGAS
12
0.0
1

SLIDER
2450
40
2730
73
POB_INICIAL_TORTUGAS
POB_INICIAL_TORTUGAS
0
1000
200.0
50
1
NIL
HORIZONTAL

SLIDER
2450
75
2730
108
NUM_DESCENDIENTES
NUM_DESCENDIENTES
0
5
1.0
1
1
NIL
HORIZONTAL

PLOT
1270
105
1485
255
Número de tortugas
meses
tortugas
0.0
10.0
0.0
10.0
true
false
"set-plot-y-range 0 500" ""
PENS
"total" 1.0 0 -10899396 true "" "if paso_un_mes? [ plotxy meses_transcurridos (count tortugas) ]"
"umbral crisis" 1.0 0 -723837 true "" "if paso_un_mes? [ plotxy meses_transcurridos (POB_INICIAL_TORTUGAS * PORCENTAJE_TORTUGAS_CRISIS / 100) ]"
"umbral colapso" 1.0 0 -1069655 true "" "if paso_un_mes? [ plotxy meses_transcurridos (POB_INICIAL_TORTUGAS * PORCENTAJE_TORTUGAS_COLAPSO / 100) ]"

SLIDER
2450
145
2730
178
PROB_MORTALIDAD_TORTUGA_PESCA
PROB_MORTALIDAD_TORTUGA_PESCA
0
0.01
0.006
0.001
1
NIL
HORIZONTAL

SLIDER
2740
355
2965
388
PORCENTAJE_TORTUGAS_CRISIS
PORCENTAJE_TORTUGAS_CRISIS
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
2740
390
2965
423
PORCENTAJE_TORTUGAS_COLAPSO
PORCENTAJE_TORTUGAS_COLAPSO
0
100
25.0
1
1
%
HORIZONTAL

SLIDER
2450
180
2730
213
PROB_MORTALIDAD_TORTUGA_DERRAME
PROB_MORTALIDAD_TORTUGA_DERRAME
0
1
0.25
0.01
1
NIL
HORIZONTAL

MONITOR
1340
45
1455
94
tortugas
count tortugas
0
1
12

BUTTON
1455
505
1612
550
NIL
COLOREAR_CELDAS
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
2170
430
2440
463
SUBSIDIO_MENSUAL_GASOLINA
SUBSIDIO_MENSUAL_GASOLINA
0
20000
0.0
5000
1
NIL
HORIZONTAL

MONITOR
420
45
535
94
ton
sum [biomasa] of patches
0
1
12

MONITOR
650
45
765
94
ton
captura_acumulada
0
1
12

MONITOR
3065
440
3200
485
NIL
ganancia_acumulada
0
1
11

MONITOR
880
45
995
94
km
distancia_recorrida_acumulada / num_viajes_acumulado
2
1
12

MONITOR
1110
45
1225
94
$ (millones)
ganancia_hidrocarburo_acumulada / 1000000
2
1
12

MONITOR
995
45
1112
94
miles de barriles
produccion_hidrocarburo_acumulada / 1000
0
1
12

MONITOR
1270
410
1400
455
area restringida (km2)
count celdas_restriccion
0
1
11

MONITOR
1270
455
1400
500
area protegida (km2)
count celdas_protegido
0
1
11

INPUTBOX
1790
545
1985
615
ANOS_MAX_SIMULACION
20.0
1
0
Number

SWITCH
1790
510
1985
543
DETENER_SIMULACION?
DETENER_SIMULACION?
0
1
-1000

SLIDER
2450
110
2730
143
MAX_CAP_CARGA
MAX_CAP_CARGA
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
2170
465
2440
498
CENTRO_MAX_PROB_PLATAFORMAS
CENTRO_MAX_PROB_PLATAFORMAS
0
40
20.0
1
1
NIL
HORIZONTAL

SLIDER
2170
500
2440
533
RADIO_PROB_PLATAFORMAS
RADIO_PROB_PLATAFORMAS
0
40
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
435
10
540
51
Recurso\ndisponible
12
75.0
1

TEXTBOX
550
10
657
50
Tiempo Biom. Sost.
12
75.0
1

TEXTBOX
680
20
785
46
Captura
12
105.0
1

TEXTBOX
790
10
895
41
Ingreso \nmensual
12
105.0
1

MONITOR
765
45
880
94
$
ultimo_salario_mensual_promedio
2
1
12

TEXTBOX
900
10
1006
41
Distancia recorrida
12
105.0
1

TEXTBOX
1025
10
1130
41
Producción\nacumulada
12
25.0
1

TEXTBOX
1130
10
1235
40
Ganancia acumulada
12
25.0
1

TEXTBOX
1365
10
1470
41
Tortugas \nmarinas
12
55.0
1

TEXTBOX
1245
10
1350
41
Tiempo\nrentabilidad
12
25.0
1

PLOT
3000
35
3200
155
Distancia por viaje
mes
celdas
0.0
10.0
0.0
10.0
true
false
"" "set-plot-y-range 0 100"
PENS
"media" 1.0 0 -13345367 true "" "if paso_un_mes? [ ifelse distancias_recorridas_mes != [] [ plotxy meses_transcurridos mean distancias_recorridas_mes ][ plotxy meses_transcurridos 0 ]]"

PLOT
1050
405
1265
555
Producción acumulada petroleo
mes
barriles (miles)
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if paso_un_mes? [plotxy meses_transcurridos produccion_hidrocarburo_acumulada ]"
"objetivo_min" 1.0 0 -1604481 true "" "if paso_un_mes? [plotxy meses_transcurridos OBJETIVO_MIN_PRODUCCION_HIDROCARBURO * 1000 ]"

SWITCH
2460
515
2650
548
EXPORTAR_IMAGEN?
EXPORTAR_IMAGEN?
1
1
-1000

INPUTBOX
2650
490
2840
550
TICKS_EXPORTAR
1.0
1
0
Number

INPUTBOX
2460
550
2980
610
RUTA_IMGS
/home/lggj/PARA/proyectos/PePe_ecosur/figuras/animaciones/tortugas
1
0
String

CHOOSER
10
50
227
95
RONDA
RONDA
"Ronda 1 (Pesca)" "Ronda 2 (Petróleo)" "Ronda 3 (Conservación)" "Ronda 4 (Manejo sectorial)" "Ronda 5 (Co-manejo)" "NA"
0

TEXTBOX
240
20
390
38
Tiempo transcurrido
12
0.0
1

SLIDER
10
250
225
283
PORCENTAJE_ANP
PORCENTAJE_ANP
0
50
0.0
5
1
%
HORIZONTAL

SLIDER
3260
305
3547
338
VARIANZA_PRECIO_HIDROCARBURO
VARIANZA_PRECIO_HIDROCARBURO
0
1000
50.0
10
1
NIL
HORIZONTAL

INPUTBOX
3260
135
3495
195
TASA_DECLINACION_HIDROCARBURO
3.198E-4
1
0
Number

INPUTBOX
3260
75
3495
135
HIDROCARBURO_INICIAL
3126954.346
1
0
Number

SLIDER
3260
270
3580
303
OBJETIVO_MIN_PRODUCCION_HIDROCARBURO
OBJETIVO_MIN_PRODUCCION_HIDROCARBURO
0
100000
25000.0
1000
1
mil
HORIZONTAL

SLIDER
3260
235
3580
268
PROCENTAJE_GANANCIA_MINIMA_HIDROCARBURO
PROCENTAJE_GANANCIA_MINIMA_HIDROCARBURO
0
100
5.0
1
1
%
HORIZONTAL

SLIDER
3260
200
3580
233
ANO_ADVERTENCIA_OBJETIVO_HIDROCARBURO
ANO_ADVERTENCIA_OBJETIVO_HIDROCARBURO
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
2450
220
2622
253
MIN_CAP_CARGA
MIN_CAP_CARGA
0
10
1.0
1
1
NIL
HORIZONTAL

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
  <experiment name="analisis_pesca_00" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <timeLimit steps="7200"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <steppedValueSet variable="NUMERO_EMBARCACIONES" first="25" step="25" last="200"/>
    <enumeratedValueSet variable="NUMERO_PLATAFORMAS">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="analisis_petroleo_00" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>file-open (word  "../analisis/data/" behaviorspace-experiment-name ".txt" )
file-write behaviorspace-run-number
ask plataformas
[ file-write (list xcor ycor) ]
file-print ""
file-close</postRun>
    <timeLimit steps="7200"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <steppedValueSet variable="NUMERO_EMBARCACIONES" first="50" step="50" last="200"/>
    <steppedValueSet variable="NUMERO_PLATAFORMAS" first="5" step="5" last="20"/>
    <steppedValueSet variable="RADIO_RESTRICCION" first="3" step="1" last="5"/>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ANCHO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="analisis_todo_00" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>file-open (word  "../analisis/data/" behaviorspace-experiment-name ".txt" )
file-write behaviorspace-run-number
ask plataformas
[ file-write (list xcor ycor) ]
file-print ""
file-close</postRun>
    <timeLimit steps="7200"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <steppedValueSet variable="NUMERO_EMBARCACIONES" first="25" step="25" last="200"/>
    <steppedValueSet variable="NUMERO_PLATAFORMAS" first="0" step="5" last="20"/>
    <steppedValueSet variable="LARGO_ZONA_PROTEGIDA" first="0" step="10" last="40"/>
  </experiment>
  <experiment name="analisis_todo_00_part_1" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>file-open (word  "../analisis/data/" behaviorspace-experiment-name ".txt" )
file-write behaviorspace-run-number
ask plataformas
[ file-write (list xcor ycor) ]
file-print ""
file-close</postRun>
    <timeLimit steps="7200"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <steppedValueSet variable="NUMERO_EMBARCACIONES" first="150" step="25" last="200"/>
    <steppedValueSet variable="NUMERO_PLATAFORMAS" first="0" step="5" last="20"/>
    <steppedValueSet variable="LARGO_ZONA_PROTEGIDA" first="0" step="10" last="40"/>
  </experiment>
  <experiment name="analisis_todo_00_part_2" repetitions="30" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>file-open (word  "../analisis/data/" behaviorspace-experiment-name ".txt" )
file-write behaviorspace-run-number
ask plataformas
[ file-write (list xcor ycor) ]
file-print ""
file-close</postRun>
    <timeLimit steps="7200"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <enumeratedValueSet variable="NUMERO_EMBARCACIONES">
      <value value="125"/>
    </enumeratedValueSet>
    <steppedValueSet variable="NUMERO_PLATAFORMAS" first="5" step="5" last="20"/>
    <steppedValueSet variable="LARGO_ZONA_PROTEGIDA" first="0" step="10" last="40"/>
  </experiment>
  <experiment name="analisis_todo_02" repetitions="10" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>file-open (word  "../analisis/data/" behaviorspace-experiment-name ".txt" )
file-write behaviorspace-run-number
ask plataformas
[ file-write (list xcor ycor) ]
file-print ""
file-close</postRun>
    <timeLimit steps="7200"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <steppedValueSet variable="NUMERO_EMBARCACIONES" first="50" step="50" last="200"/>
    <steppedValueSet variable="NUMERO_PLATAFORMAS" first="0" step="5" last="20"/>
    <steppedValueSet variable="LARGO_ZONA_PROTEGIDA" first="0" step="10" last="30"/>
  </experiment>
  <experiment name="calibracion_gasto_gas" repetitions="5" runMetricsEveryStep="false">
    <setup>INICIALIZAR</setup>
    <go>EJECUTAR</go>
    <postRun>file-open (word  "../analisis/data/" behaviorspace-experiment-name ".txt" )
file-write behaviorspace-run-number
ask plataformas
[ file-write (list xcor ycor) ]
file-print ""
file-close</postRun>
    <timeLimit steps="3600"/>
    <metric>dias_transcurridos</metric>
    <metric>meses_transcurridos</metric>
    <metric>anos_transcurridos</metric>
    <metric>sum capturas_mes</metric>
    <metric>captura_acumulada</metric>
    <metric>num_viajes_mes</metric>
    <metric>num_viajes_acumulado</metric>
    <metric>sum distancias_recorridas_mes</metric>
    <metric>distancia_recorrida_acumulada</metric>
    <metric>sum horas_en_mar_mes</metric>
    <metric>horas_en_mar_acumuladas</metric>
    <metric>sum gasto_gas_mes</metric>
    <metric>gasto_gas_acumulado</metric>
    <metric>sum ganancias_mes</metric>
    <metric>ganancia_acumulada</metric>
    <metric>(mean [salario_mensual] of embarcaciones)</metric>
    <metric>sum [biomasa] of patches</metric>
    <metric>count tortugas</metric>
    <metric>sum produccion_mes_hidrocarburo</metric>
    <metric>sum ganancia_mes_hidrocarburo</metric>
    <metric>produccion_hidrocarburo_acumulada</metric>
    <metric>ganancia_hidrocarburo_acumulada</metric>
    <metric>numero_derrames</metric>
    <metric>dias_pesca_sostenible</metric>
    <metric>dias_biomasa_sostenible</metric>
    <metric>dias_hidrocarburo_sostenible</metric>
    <metric>dias_tortugas_sostenible</metric>
    <runMetricsCondition>(ticks mod (24 * 30 / HORAS_ITERACION)) = 0</runMetricsCondition>
    <enumeratedValueSet variable="NUMERO_EMBARCACIONES">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NUMERO_PLATAFORMAS">
      <value value="0"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="LARGO_ZONA_PROTEGIDA">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="K">
      <value value="50"/>
      <value value="100"/>
      <value value="150"/>
      <value value="200"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="M">
      <value value="0.001"/>
      <value value="5.0E-4"/>
      <value value="1.0E-4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="R">
      <value value="0.6"/>
      <value value="0.8"/>
      <value value="1"/>
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
