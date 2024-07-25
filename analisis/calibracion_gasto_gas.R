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

data <- read_csv(
    "./data/mini_PePeCoGoMx calibracion_gasto_gas-table.csv",
    skip = 6)

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

cols_salida <- names(data[, 12:ncol(data)])

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


ggplot(data,
       aes(x = as.factor(k),
           y = gasto_gas_viaje,
           fill = as.factor(numero_plataformas))) +
    geom_boxplot() +
    facet_grid(cols = vars(r),
               rows = vars(m)) +
    scale_color_ucscgb() +
    ## scale_color_brewer(palette = "RdYlBu") +
    ## scale_color_viridis(discrete = TRUE, option = "inferno") +
    theme_bw() +
    theme(panel.spacing = unit(0.6, "lines"))
