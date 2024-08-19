#' ---
#' title: "Análisis de sensibilidad"
#' output:
#'   html_document:
#'     toc: true
#' ---

#' ## Descripción de experimentos
#' Se exploraron 200 escenarios que representan todas las combinaciones de
#' las siguientes variables y rangos:
#' 1. `NUMERO_EMBARCACIONES`: 25, 50, 75, 100, 125, 150, 175, 200
#' 2. `NUMERO_PLATAFORMAS`: 0, 5, 10, 15, 20
#' 3. `LONGITUD_AREA_PROTEGIDA`: 0, 10, 20, 30, 40
#'
#' Cada simulación duró 20 años y se realizaron 30 repeticiones por escenario.
#'
#' En las simulaciones se utilizaron los siguientes parámetros base:
#'
#' | Submodelo | Parámetro | Valor |
#' |-|-|-|
#' | pesca | HORAS_DESCANSAR | 12 |
#' | pesca | PROB_EXPLORAR | 0.2 |
#' | pesca | RADIO_EXPLORAR | 3 |
#' | pesca | NUM_AMIGOS | 2 |
#' | pesca | DIAS_MAXIMOS_EN_MAR | 5 |
#' | pesca | CAPTURABILIDAD | 0.01 |
#' | pesca | VELOCIDAD | 0.5 |
#' | pesca | CAPACIDAD_MAXIMA | 1 |
#' | pesca | LITROS_POR_DISTANCIA | 1 |
#' | pesca | LITROS_POR_HORA_PESCA | 1 |
#' | pesca | NUM_TRIPULANTES | 3 |
#' | pesca | PRECIO_BIOMASA | 10000 |
#' | pesca | PRECIO_LITRO_GAS | 30 |
#' | ecología | K | 50 |
#' | ecología | M | 0.0001 |
#' | ecología | R | 0.8 |
#' | hidrocarburo | HODROCARBURO_INICIAL | 20000 |
#' | hidrocarburo | EXTRACCION_MAX_HIDROCARBURO | 5 |
#' | hidrocarburo | TASA_DECLINACION_HIDROCARBURO | 0.001 |
#' | hidrocarburo | PROB_OCURRENCIA_DERRAME | 0.025 |
#' | hidrocarburo | PROB_EXTENSION_DERRAME | 0.35 |
#' | hidrocarburo | PROB_MORTALIDAD_DERRAME | 0.75 |
#' | hidrocarburo | TIEMPO_DERRAMADO | 50 |
#' | hidrocarburo | COSTO_POR_CELDA_DERRAMADA | 10000 |
#' | hidrocarburo | COSTO_OPERACION_PLATAFORMA | 1000 |
#' | hidrocarburo | PRECIO_HIDROCARBURO | 10000 |
#' | hidrocarburo | RADIO_RESTRICCION | 3 |
#' | hidrocarburo | SUBSIDIO_MENSUAL_GASOLINA | 0 |
#' | hidrocarburo | CENTRO_MAX_PROB_PLATAFORMAS | 25 |
#' | hidrocarburo | RADIO_PROB_PLATAFORMAS | 15 |
#' | tortugas | POB_INICIAL_TORTUGAS | 200 |
#' | tortugas | NUM_DESCENDIENTES | 1 |
#' | tortugas | MAX_CAPACIDAD_CARGA | 5 |
#' | tortugas | PROB_MORTALIDAD_TORTUGA_PESCA | 0.006 |
#' | tortugas | PROB_MORTALIDAD_TORTUGA_DERRAME | 0.10 |
#' | zonificación | ANCHO_ZONA_PROTEGIDA | 19 |
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
library(tidyverse)
library(knitr)
library(viridis)
library(ggsci)
library(janitor)

knitr::opts_chunk$set(echo = FALSE,
                      fig.dim = c(9,7),
                      dpi = 300,
                      warning = FALSE)

#+ import_data, include = FALSE
data <- read_csv("data/mini_PePeCoGoMx analisis_todo_02-table.csv", skip = 6)

data <-
    data %>%
    janitor::clean_names() %>%
    mutate(captura_viaje =
               sum_capturas_mes / num_viajes_mes,
           horas_en_mar_viaje =
               sum_horas_en_mar_mes / num_viajes_mes,
           distancia_recorrida_viaje =
               sum_distancias_recorridas_mes / num_viajes_mes,
           gasto_gas_viaje =
               sum_gasto_gas_mes / num_viajes_mes,
           ganancia_viaje =
               sum_ganancias_mes / num_viajes_mes) %>%
    mutate_all(~replace(., is.nan(.), 0))

cols_salida <- names(data[, 9:ncol(data)])

data_mean_series <- data %>%
    group_by(numero_embarcaciones,
             numero_plataformas,
             largo_zona_protegida,
             meses_transcurridos) %>%
    summarize_at(cols_salida, mean)

#' ## Series de tiempo
#+ grafica_serie_tiempo, include = FALSE
graficar_serie_tiempo <-
    function(data,
             y,
             y_label,
             title = ""){
        ggplot(data,
               aes(x = meses_transcurridos,
                   y = get(y),
                   color = as.factor(numero_embarcaciones))) +
            geom_line() +
            facet_grid(cols = vars(numero_plataformas),
                       rows = vars(largo_zona_protegida)) +
            labs(title = title,
                 x = "Mes",
                 y = y_label,
                 color = "Número de embarcaciones") +
            scale_color_ucscgb() +
            ## scale_color_brewer(palette = "RdYlBu") +
            ## scale_color_viridis(discrete = TRUE, option = "inferno") +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  axis.text.x = element_text(angle = 90))
    }

#' ### Captura total
#'
#' Para todos los escenarios explorados se observa que conforme aumenta
#' el número de embarcaciones aumenta la captura durante los primeros meses.
#' Posteriormente las capturas bajan rápidamente. Para todos los escenarios
#' tener más de 100 embarcaciones resulta en reducciones abruptas en las
#' capturas (en algunos casos 100 embarcaciones tambien generan cambios
#' abruptos).
#'
#' Conforme aumenta el número de plataformas las capturas parecen reducirse.
#' Las condiciones de disminución abrupta (más de 100 embarcaciones) se
#' mantienen, solo que a partir de 10 plataformas el cambio parece ser menos
#' abrupto. 
#'
#' Al aumentar el tamaño de la zona protegida las capturas disminuyen.
#' A partir de una longitud de zona protegida de 30 el escenario con 100
#' embarcaciones que sin zona protegida no colapsaban se aproxima al colapso
#' al final de la simulación. Con 40 de zona protegida el verde colapsa a la
#' mitad de la simulación. Parece haber un efecto conjunto de la zona protegida
#' y el número de plataformas: conforme aumentan ambos la caida aburpta de la
#' captura se alcanza más rápido.
#' 
#+ fig_captura_total 
graficar_serie_tiempo(data_mean_series,
                      "sum_capturas_mes",
                      "Captura (ton)",
                      "Captura total")

#' ### Captura por viaje
#'
#' La captura por viaje tiende a disminuir conforme aumenta el número de
#' embarcaciones. Esta tendencia aumenta conforme aumenta el número de plataformas
#' y el tamaño de la zona protegida.
#' 
#+
graficar_serie_tiempo(data_mean_series,
                      "captura_viaje",
                      "Captura (ton)",
                      "Captura promedio por viaje")
#' ### Biomasa total
#'
#' Al inicio de las simulaciones la biomasa disminuye conforme aumenta el
#' número de embarcaciones. El umbral del 25% se alcanza solamente cuando
#' no hay zonas protegidas para los casos con 100 o más embarcaciones. Al avanzar
#' la simulación la biomasa se recupera en los casos cuando la pesca colapsa. 
#' 
#+
graficar_serie_tiempo(data_mean_series,
                      "sum_biomasa_of_patches",
                      "Biomasa (ton)",
                      "Biomasa total") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "black", linetype = 3)

#' ### Número de viajes
#'
#' El número de viajes se comporta de manera idéntica a la captura total. Esto
#' indica que la reducción en la captura total en el modelo se debe principalmente
#' a la reducción en el número de viajes que se realizan.
#+
graficar_serie_tiempo(data_mean_series,
                      "num_viajes_mes",
                      "Número de viajes",
                      "Número total de viajes")

#' ### Horas en mar promedio por viaje
#'
#' Las horas promedio en mar aumentan de manera asintótica conforme avanza la
#' simulación. En los casos donde la pesquería colapsa se las horas en mar
#' disminuyen hasta cero.
#'
#' Conforme aumenta el número de plataformas el número promedio de horas en el mar
#' tiende a disminuir. Aunque para los escenarios con pocas embarcaciones si
#' parece aumentar ligeramente.
#'
#' Conforme aumenta el tamaño del área protegida en los escenarios con pocas
#' embarcaciones las horas en mar tienden a aumentar. 

#+
graficar_serie_tiempo(data_mean_series,
                      "horas_en_mar_viaje",
                      "Horas en mar promedio por viaje",
                      "Horas en mar promedio por viaje")

#' ### Distancia recorrida promedio por viaje
#'
#' La distancia recorrida por viaje aumenta con el número de embarcaciones.
#' Conforme auentan el número de plataformas y el tamaño de la zona protegida
#' la distancia recorrida no aumenta.
#+
graficar_serie_tiempo(data_mean_series,
                      "distancia_recorrida_viaje",
                      "Distancia recorrida por viaje (celdas)",
                      "Distancia recorrida promedio por viaje")

#' ### Gasto en gasolina promedio por viaje
#'
#' El gasto en gasolina se comporta igual que la distancia recorrida por viaje.
#' No tiende a aumentar conforme se aumenta el número de plataformas y zonas
#' protegidas.
#' 
#+
graficar_serie_tiempo(data_mean_series,
                      "gasto_gas_viaje",
                      "Gasto en gasolina por viaje ($ MXN)",
                      "Gasto en gasolina por viaje")

#' ### Ganancia por viaje
#'
#' Las ganancias aumentan conforme se disminuye el número de embarcaciones. Esto
#' se puede entender como resultado de que las capturas por viaje son mayores
#' cuando hay menos embarcaciones. Las plataformas y áreas protegidas disminuyen
#' las ganancias.
#'
#+
graficar_serie_tiempo(data_mean_series,
                      "ganancia_viaje",
                      "Ganancia por viaje ($ MXN)",
                      "Ganancia por viaje")

#' ### Salario mensual promedio
#'
#' Se comporta igual que la ganancia: el salario mensual aumenta conforme
#' disminuye el número de embarcaciones, y el número de plataformas y largo
#' de zona protegida disminuyen el salario.
#' 
#+
graficar_serie_tiempo(data_mean_series,
                      "mean_salario_mensual_of_embarcaciones",
                      "Salario mensual promedio ($MXN)",
                      "Salario mensual promedio") +
    geom_hline(yintercept = 7000, color = "black", linetype = 3)


#' ## Acumulado y total
#+ grafica_caja, include = FALSE 
graficar_caja <-
    function(data, y, y_label, title = ""){
        ggplot(data,
               aes(x = as.factor(numero_embarcaciones),
                   y = get(y),
                   fill = as.factor(numero_embarcaciones))) +
            geom_boxplot() +
            labs(title = title,
                 x = "Número de embarcaciones",
                 y = y_label) +
            facet_grid(cols = vars(numero_plataformas),
                       rows = vars(largo_zona_protegida)) +
            scale_color_ucscgb() +
            ## scale_color_brewer(palette = "RdYlBu") +
            ## scale_color_viridis(discrete = TRUE, option = "inferno") +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  legend.position = "none")
    }

#+ data_final
data_final <-
    data %>%
    filter(meses_transcurridos == max(data$meses_transcurridos))

#' ### Captura acumulada
#+
graficar_caja(data_final,
                        "captura_acumulada",
                        "Captura acumulada (ton)",
                        "Captura acumulada (final)")

#+
graficar_caja(data_final,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (final)") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "black", linetype = 3)

#+
graficar_caja(data,
              "sum_biomasa_of_patches",
              "Biomasa total (ton)",
              "Biomasa total (toda la simulación)") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "black", linetype = 3)

graficar_caja(data_final,
              "gasto_gas_acumulado",
              "Gasto en gasolina ($ MXN)",
              "Gasto en gasolina acumulada (final)")

graficar_caja(data,
              "sum_gasto_gas_mes",
              "Gasto en gasolina por viaje ($ MXN)",
              "Gasto en gasolina por viaje (toda la simulación)")

#+
graficar_caja(data_final,
              "ganancia_acumulada",
              "Ganancia acumulada ($ MXN)",
              "Ganancia acumulada (final)")

#+
graficar_caja(data,
              "count_tortugas",
              "Número de tortugas",
              "Número de tortugas (toda la simulación)") +
    geom_hline(yintercept = 0.25 * 200, color = "black", linetype = 3)

#+
graficar_caja(data_final,
              "dias_pesca_sostenible",
              "Días pesca sostenible",
              "Días pesca sostenible")

#+
graficar_caja(data_final,
              "dias_biomasa_sostenible",
              "Días biomasa sostenible",
              "Días biomasa sostenible")

#+
graficar_caja(data_final,
              "dias_hidrocarburo_sostenible",
              "Días hidrocarburo sostenible",
              "Días hidrocarburo sostenible")

#+
graficar_caja(data_final,
              "dias_tortugas_sostenible",
              "Días tortugas sostenible",
              "Días tortugas sostenible")

#' ## Trayectorias de juego
obtener_trayectoria <-
    function(tiempo_pesca,
             tiempo_biomasa,
             tiempo_hidrocarburo,
             tiempo_tortugas,
             tiempo_max,
             ordenado = FALSE){
        return(
            tibble(
                name = c('P', 'B', 'H', 'T'),
                tiempo = c(tiempo_pesca,
                           tiempo_biomasa,
                           tiempo_hidrocarburo,
                           tiempo_tortugas)) %>%
            arrange(if(ordenado) tiempo) %>%
            mutate(code = ifelse(
                       name == "H" & tiempo == 0,
                       NA,
                       ifelse(
                           tiempo < tiempo_max,
                           name,
                           NA))) %>%
            filter(!is.na(code)) %>%
            pull(code) %>%
            paste(collapse = "")
        )
    }

data_final_trayectorias <-
    data %>%
    filter(meses_transcurridos == max(meses_transcurridos)) %>%
    rowwise() %>%
    mutate(trayectoria =
               obtener_trayectoria(dias_pesca_sostenible,
                                   dias_biomasa_sostenible,
                                   dias_hidrocarburo_sostenible,
                                   dias_tortugas_sostenible,
                                   max(dias_transcurridos)),
           trayectoria_ordenada =
               obtener_trayectoria(dias_pesca_sostenible,
                                   dias_biomasa_sostenible,
                                   dias_hidrocarburo_sostenible,
                                   dias_tortugas_sostenible,
                                   max(dias_transcurridos),
                                   TRUE))

ggplot(data_final_trayectorias,
       aes(x = as.factor(numero_embarcaciones),
           fill = as.factor(trayectoria))) +
    geom_bar(position = "stack") +
    facet_grid(cols = vars(as.factor(numero_plataformas)),
               rows = vars(as.factor(largo_zona_protegida))) +
    labs(x = "Número de embarcaciones",
         y = "Conteo",
         fill = "Trayectoria") +
    theme_bw() +
    ## scale_fill_viridis(discrete = TRUE, option = "magma")
    scale_fill_ucscgb()
    ## scale_fill_brewer(palette = "RdYlBu")

## ggsave("trayectorias.png",
##        dpi = 300)
       
