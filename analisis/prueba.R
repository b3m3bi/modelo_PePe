#' ---
#' title: "Análisis de sensibilidad"
#' output:
#'   html_document:
#'     toc: true
#' ---

#' # Pesca
#' Se realizaron simulaciones para identificar las trayectorias del submodelo
#' de pesca con un conjunto de parámetros base. Lo único que se vario en las
#' simulaciones es el número de embarcaiones de 10 a 200 con saltos de 10.

#' ## Parámetros base
#' En las simulaciones se utilizaron los siguientes parámetros base:
#'
#' | Submodelo | Parámetro | Valor |
#' |-|-|-|
#' | pesca | HORAS_DESCANSAR | 12 |
#' | pesca | PROB_EXPLORAR | 0.2 |
#' | pesca | RADIO_EXPLORAR | 3 |
#' | pesca | NUM_AMIGOS | 2 |
#' | pesca | **NUMERO_EMBARCACIONES** | varia |
#' | pesca | DIAS_MAXIMOS_EN_MAR | 5 |
#' | pesca | CAPTURABILIDAD | 0.01 |
#' | pesca | VELOCIDAD | 0.5 |
#' | pesca | CAPACIDAD_MAXIMA | 1 |
#' | pesca | LITROS_POR_DISTANCIA | 1 |
#' | pesca | LITROS_POR_HORA_PESCA | 1 |
#' | pesca | NUM_TRIPULANTES | 3 |
#' | pesca | PRECIO_BIOMASA | 10000 |
#' | pesca | PRECIO_LITRO_GAS | 20 |
#' | ecología | K | 50 |
#' | ecología | M | 0.001 |
#' | ecología | R | 0.6 |
#' | hidrocarburo | **NUMERO_PLATAFORMAS** | 0 |
#' | hidrocarburo | HODROCARBURO_INICIAL | 20000 |
#' | hidrocarburo | EXTRACCION_MAX_HIDROCARBURO | 10 |
#' | hidrocarburo | TASA_DECLINACION_HIDROCARBURO | 0.001 |
#' | hidrocarburo | PROB_OCURRENCIA_DERRAME | 0.025 |
#' | hidrocarburo | PROB_EXTENSION_DERRAME | 0.35 |
#' | hidrocarburo | PROB_MORTALIDAD_DERRAME | 0.5 |
#' | hidrocarburo | TIEMPO_DERRAMADO | 50 |
#' | hidrocarburo | COSTO_OPERACION_PLATAFORMA | 1000 |
#' | hidrocarburo | PRECIO_HIDROCARBURO | 10000 |
#' | hidrocarburo | RADIO_RESTRICCION | 4 |
#' | hidrocarburo | SUBSIDIO_MENSUAL_GASOLINA | 0 |
#' | tortugas | **LARGO_ZONA_PROTEGIDA** | 0 |
#' | tortugas | **ANCHO_ZONA_PROTEGIDA** | 0 |
#' | tortugas | POB_INICIAL_TORTUGAS | 150 |
#' | tortugas | NUM_DESCENDIENTES | 1 |
#' | tortugas | CAPACIDAD_CARGA | 2 |
#' | tortugas | PROB_MORTALIDAD_TORTUGA_PESCA | 0.008 |
#' | tortugas | PROB_MORTALIDAD_TORTUGA_DERRAME | 0.15 |
#' | mundo | HORAS_ITERACION | 24 |
#' | mundo | LONGITUD_CELDA | 1 |
#' | mundo | LONGITUD_TIERRA | 6 |
#' | jugabilidad | SALARIO_MIN_MENSUAL | 7000 |
#' | jugabilidad | MAX_MESES_CRISIS_PESCA | 12 |
#' | jugabilidad | PORCENTAJE_BIOMASA_CRISIS | 50 |
#' | jugabilidad | PORCENTAJE_BIOMASA_COLAPSO | 25 |
#' | jugabilidad | MAX_MESES_CRISIS_HIDROCARBURO | 12 |
#' | jugabilidad | PORCENTAJE_TORTUGAS_CRISIS | 50 |
#' | jugabilidad | PORCENTAJE_TORTUGAS_COLAPSO | 25 |

#+ setup, include = FALSE
setwd("/home/lggj/PARA/proyectos/PePe_ecosur/modelo_PePe/analisis/")

#+ include = FALSE
library(ggplot2)
library(knitr)
library(dplyr)
knitr::opts_chunk$set(echo = FALSE,
                      fig.dim = c(9,3),
                      dpi = 300,
                      warning = FALSE)

#+ include = FALSE
filepath <- "./data/mini_PePeCoGoMx analisis_pesca_00-table.csv"
data_pesca <- read.csv(filepath, skip = 6)

nombres_salidas <- c(
    "total_capturas_mes",
    "captura_acumulada",
    "num_viajes_mes",
    "num_viajes_acumulado",
    "total_distancias_recorridas_mes",
    "distancia_recorrida_acumulada",
    "total_horas_en_mar_mes",
    "horas_en_mar_acumuladas",
    "total_gasto_gas_mes",
    "gasto_gas_acumulado",
    "total_ganancias_mes",
    "ganancia_acumulada",
    "salario_mensual_promedio",
    "biomasa_total",
    "num_tortugas",
    "produccion_mes_hidrocarburo_total",
    "ganancia_mes_hidrocarburo_total",
    "produccion_hidrocarburo_acumulada",
    "ganancia_hidrocarburo_acumulada",
    "numero_derrames",
    "dias_pesca_sostenible",
    "dias_biomasa_sostenible",
    "dias_hidrocarburo_sostenible",
    "dias_tortugas_sostenible")
names(data_pesca) <- c(names(data_pesca)[1:9], nombres_salidas)

#+ 
data_pesca <- data_pesca %>%
    mutate(captura_por_viaje = total_capturas_mes / num_viajes_mes,
           horas_en_mar_por_viaje = total_horas_en_mar_mes / num_viajes_mes,
           dist_recorrida_viaje = total_distancias_recorridas_mes / num_viajes_mes,
           gasto_gas_viaje = total_gasto_gas_mes / num_viajes_mes,
           ganancia_viaje = total_ganancias_mes / num_viajes_mes)

#+ 
agg <- aggregate(do.call(cbind, data_pesca[, 10:ncol(data_pesca)]) ~ meses_transcurridos + NUMERO_EMBARCACIONES, data = data_pesca, FUN = mean)

#' ## Series de tiempo

grafica_serie_tiempo <- function(data, columna, y_label){
    ggplot(data,
           aes(x = meses_transcurridos,
               y = get(columna),
               color = as.factor(NUMERO_EMBARCACIONES))) +
        geom_line() +
        labs(x = "Mes",
             y = y_label,
             color = "Número de embarcaciones") +
        guides(color = guide_legend(ncol = 2)) + 
        theme_classic()
}

#' ### Captura total
grafica_serie_tiempo(agg, "total_capturas_mes", "Captura total (ton)")

#' ### Captura por viaje
grafica_serie_tiempo(agg, "captura_por_viaje", "Captura por viaje (ton)")

#' ### Biomasa total
grafica_serie_tiempo(agg, "biomasa_total", "Biomasa total (ton)") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "gray", linetype = 3 )

#' ### Numero de viajes
grafica_serie_tiempo(agg, "num_viajes_mes", "Número de viajes")

#' ### Horas en mar por viaje
grafica_serie_tiempo(agg,
                     "horas_en_mar_por_viaje",
                     "Horas en mar por viaje")

#' ### Distancia recorrida por viaje
grafica_serie_tiempo(agg,
                     "dist_recorrida_viaje",
                     "Distancia recorrida por viaje (celdas)")

#' ### Gasto en gasolina por viaje
grafica_serie_tiempo(agg,"gasto_gas_viaje","Gasto en gasolina por viaje ($ MXN)")

#' ### Ganancia por viaje
grafica_serie_tiempo(agg,"ganancia_viaje","Ganancia por viaje ($ MXN)")


#' ### Salario promedio mensual
grafica_serie_tiempo(agg,
                     "salario_mensual_promedio",
                     "Salario mensual promedio ($ MXN)") +
    geom_hline(yintercept =  7000, color = "gray", linetype = 3 )

#' ## Acumulados y finales

grafica_cajas <- function(data,columna,y_label){
    ggplot(data,
           aes(x = as.factor(NUMERO_EMBARCACIONES),
               y = get(columna))) +
           geom_boxplot() +
           labs(x = "Número de embarcaciones",
                y = y_label) +
           theme_classic()
}

data <- data_pesca
#' ### Captura acumulada final
grafica_cajas(data[data$meses_transcurridos ==  max(data$meses_transcurridos), ],
              "captura_acumulada",
              "Captura acumulada (ton)")

#' ### Biomasa final
grafica_cajas(data[data$meses_transcurridos ==  max(data$meses_transcurridos), ],
              "biomasa_total",
              "Biomasa total (ton)") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "gray", linetype = 3 )

#' ### Ganancia acumulada final
grafica_cajas(data[data$meses_transcurridos ==  max(data$meses_transcurridos), ],
              "ganancia_acumulada",
              "Ganancia acumulada ($ MXN)")

#' ### Número tortugas acumulado
grafica_cajas(data, "num_tortugas", "Número de tortugas") +
    geom_hline(yintercept = 0.25 * 150, color = "gray", linetype = 3)

#' ## Tiempos de sostenibilidad
#' ### Tiempo pesca sostenible
grafica_cajas(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
              "dias_pesca_sostenible",
              "Días pesca sostenible")

#' ### Tiempo biomasa sostenible
grafica_cajas(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
              "dias_biomasa_sostenible",
              "Días biomasa sostenible")

#' ### Tiempo tortugas sostenible
grafica_cajas(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
              "dias_tortugas_sostenible",
              "Días tortugas sostenible")

#' ## Trayectorias representativas
#' Para el conjunto de parametros base se identificó que la cantidad óptima
#' de embarcaciones es 100. Esto se debe a que con este valor no se supera
#' ninguno de los umbrales de sostenibilidad y se obtienen altas capturas
#' y ganancias acumuladas.
#'
#' A partir de estas simulaciones se pueden identificar 4 escenarios a los
#' que se podrían acotar las exploraciones:
#' 
#' 1. *Sub-pesca*: con 50 embarcaciones, no se supera ningún umbral de
#' juego, se obtiene un alto salario mensual, pero la captura y ganancia
#' acumuladas son bajas.
#' 2. *Óptimo*: con 100 embarcaciones, no se supera ningún umbral de juego,
#' se obtiene un salario mensual aceptable, la captura y ganancia acumuladas
#' son altos (más altos que con 50).
#' 3. *Sobre-pesca límite*: con 150 embarcaciones, se superan todos los
#' umbrales de juego a partir de los 15 años, se obtienen las máximas capturas y ganancias acumuladas pero no son sostenibles.
#' 4. *Sobre-pesca extrema*: con 200 embarcaciones, se superan todos los
#' umbrales de juego en menos de 10 años, se obteienen ganancias acumuladas
#' menores a con 150 pero similares a con 100.
#'
#' En las siguientes gráficas se muestran las trayectorias representativas
#' promedio de 30 simulaciones y sus máximos y mínimos.

#+ 
grafica_trayectoria <- function(data, columna, y_label, num_embarcaciones) {
  resumen_trayectorias <-
    data %>%
    filter(NUMERO_EMBARCACIONES == num_embarcaciones) %>%
    group_by(NUMERO_EMBARCACIONES, meses_transcurridos) %>%
    summarise(promedio = mean(get(columna)),
              minimo = min(get(columna)),
              maximo = max(get(columna)),
              .groups = 'drop')
  
  ggplot(resumen_trayectorias,
         aes(x = meses_transcurridos,
             y = promedio,
             color = as.factor(NUMERO_EMBARCACIONES),
             fill = as.factor(NUMERO_EMBARCACIONES))) +
    geom_ribbon(aes(ymin = minimo, ymax = maximo), alpha = 0.25, colour = NA) +
    geom_line() +
    labs(x = "Meses",
         y = y_label,
         color = "Número de embarcaciones",
         fill = "Número de embarcaciones") +
    theme_classic()
}

num_embarcaciones <- c(50,100,150,200)

#' ### Captura total
grafica_trayectoria(data,
                    "total_capturas_mes",
                    "Captura total (ton)",
                    num_embarcaciones)

#' ### Captura por viaje
grafica_trayectoria(data,
                    "captura_por_viaje",
                    "Captura por viaje (ton)",
                    num_embarcaciones)
    
#' ### Biomasa
grafica_trayectoria(data, "biomasa_total", "Biomasa (ton)", num_embarcaciones) +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "gray", linetype = 3 )

#' ### Numero viajes
grafica_trayectoria(data, "num_viajes_mes", "Número de viajes", num_embarcaciones)

#' ### Horas en mar por viaje
grafica_trayectoria(data,
                    "horas_en_mar_por_viaje",
                    "Horas en mar por viaje",
                    num_embarcaciones)

#' ### Distancia recorrida por viaje
grafica_trayectoria(data,
                    "dist_recorrida_viaje",
                    "Distancia recorrida por viaje (celdas)",
                    num_embarcaciones)

#' ### Gasto en gasolina por viaje
grafica_trayectoria(data,
                    "gasto_gas_viaje",
                    "Gasto en gasolina por viaje ($MXN)",
                    num_embarcaciones)

#' ### Ganancia por viaje
grafica_trayectoria(data,
                    "ganancia_viaje",
                    "Ganancia por viaje ($MXN)",
                    num_embarcaciones)

#' ### Salario mensual promedio
grafica_trayectoria(data,
                    "salario_mensual_promedio",
                    "Salario mensual ($ MXN)",
                    num_embarcaciones) + 
    geom_hline(yintercept =  7000, color = "gray", linetype = 3 )

#' ### Tortugas
grafica_trayectoria(data,
                    "num_tortugas",
                    "Número de tortugas",
                    num_embarcaciones)  +
    geom_hline(yintercept = 0.25 * 150, color = "gray", linetype = 3)



#' # Pesca y petroleo

filepath <- "./data/mini_PePeCoGoMx analisis_petroleo_00-table.csv"
data_petroleo <- read.csv(filepath, skip = 6)

nombres_salidas <- c(
    "total_capturas_mes",
    "captura_acumulada",
    "num_viajes_mes",
    "num_viajes_acumulado",
    "total_distancias_recorridas_mes",
    "distancia_recorrida_acumulada",
    "total_horas_en_mar_mes",
    "horas_en_mar_acumuladas",
    "total_gasto_gas_mes",
    "gasto_gas_acumulado",
    "total_ganancias_mes",
    "ganancia_acumulada",
    "salario_mensual_promedio",
    "biomasa_total",
    "num_tortugas",
    "produccion_mes_hidrocarburo_total",
    "ganancia_mes_hidrocarburo_total",
    "produccion_hidrocarburo_acumulada",
    "ganancia_hidrocarburo_acumulada",
    "numero_derrames",
    "dias_pesca_sostenible",
    "dias_biomasa_sostenible",
    "dias_hidrocarburo_sostenible",
    "dias_tortugas_sostenible")
names(data_petroleo) <- c(names(data_petroleo)[1:10], nombres_salidas)

#+ 
data_petroleo <- data_petroleo %>%
    mutate(captura_por_viaje = total_capturas_mes / num_viajes_mes,
           horas_en_mar_por_viaje = total_horas_en_mar_mes / num_viajes_mes,
           dist_recorrida_viaje = total_distancias_recorridas_mes / num_viajes_mes,
           gasto_gas_viaje = total_gasto_gas_mes / num_viajes_mes,
           ganancia_viaje = total_ganancias_mes / num_viajes_mes)


data_pesca <- data_pesca %>%
    filter(NUMERO_EMBARCACIONES == num_embarcaciones) %>%
    mutate(RADIO_RESTRICCION = 0, .after = NUMERO_PLATAFORMAS)

data_pesca_petroleo <- rbind(data_pesca,data_petroleo)

data <- data_pesca_petroleo
#+ 
agg <- aggregate(do.call(cbind, data[, 10:ncol(data)]) ~ meses_transcurridos + NUMERO_EMBARCACIONES + NUMERO_PLATAFORMAS + RADIO_RESTRICCION, data = data, FUN = mean)

ggplot(agg,
       aes(x = meses_transcurridos,
           y = total_capturas_mes,
           color = as.factor(NUMERO_EMBARCACIONES))) +
    geom_line() +
    facet_grid(rows = vars(NUMERO_PLATAFORMAS), cols = vars(RADIO_RESTRICCION))

ggplot(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
       aes(x = as.factor(NUMERO_EMBARCACIONES),
           y = dias_pesca_sostenible)) +
       geom_boxplot() +
       facet_grid(rows = vars(NUMERO_PLATAFORMAS), cols = vars(RADIO_RESTRICCION))
