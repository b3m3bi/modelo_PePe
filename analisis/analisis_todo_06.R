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
data <- read_csv("data/modelo_PePe analisis_escenarios_01-table.csv", skip=6)
data2 <- read_csv("data/modelo_PePe analisis_125_embarcaciones-table.csv", skip=6)

data <- bind_rows(data,data2)

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

#' ## Series de tiempo

cols_salida <- names(data[, 72:ncol(data)])

data_mean_series <- data |>
    group_by(
        meses_transcurridos,
        numero_embarcaciones,
        numero_plataformas,
        porcentaje_anp) |>
    summarize_at(cols_salida, mean)

graficar_serie_tiempo_num_emb <-
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
                       rows = vars(porcentaje_anp)) +
            labs(title = title,
                 subtitle = "cols = número plataformas; rows = porcentaje ANP",
                 x = "Mes",
                 y = y_label,
                 color = "Número de embarcaciones") +
            scale_color_ucscgb() +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  axis.text.x = element_text(angle = 90))
    }

graficar_serie_tiempo_num_plat <-
    function(data,
             y,
             y_label,
             title = ""){
        ggplot(data,
               aes(x = meses_transcurridos,
                   y = get(y),
                   color = as.factor(numero_plataformas))) +
            geom_line() +
            facet_grid(cols = vars(numero_embarcaciones),
                       rows = vars(porcentaje_anp)) +
            labs(title = title,
                 subtitle = "cols = número embarcaciones; rows = porcentaje ANP",
                 x = "Mes",
                 y = y_label,
                 color = "Número de plataformas") +
            scale_color_ucscgb() +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  axis.text.x = element_text(angle = 90))
    }

graficar_serie_tiempo_por_anp <-
    function(data,
             y,
             y_label,
             title = ""){
        ggplot(data,
               aes(x = meses_transcurridos,
                   y = get(y),
                   color = as.factor(porcentaje_anp))) +
            geom_line() +
            facet_grid(cols = vars(numero_embarcaciones),
                       rows = vars(numero_plataformas)) +
            labs(title = title,
                 subtitle = "cols = número embarcaciones; rows = número plataformas",
                 x = "Mes",
                 y = y_label,
                 color = "Porcentaje ANP") +
            scale_color_ucscgb() +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  axis.text.x = element_text(angle = 90))
    }

#' ### Captura total
graficar_serie_tiempo_num_emb(data_mean_series,
                      "sum_capturas_mes",
                      "Captura (ton)",
                      "Captura total")

graficar_serie_tiempo_num_plat(data_mean_series,
                      "sum_capturas_mes",
                      "Captura (ton)",
                      "Captura total")

graficar_serie_tiempo_por_anp(data_mean_series,
                      "sum_capturas_mes",
                      "Captura (ton)",
                      "Captura total")

#' ### Captura por viaje
graficar_serie_tiempo_num_emb(data_mean_series,
                      "captura_viaje",
                      "Captura (ton)",
                      "Captura promedio por viaje")

graficar_serie_tiempo_num_plat(data_mean_series,
                      "captura_viaje",
                      "Captura (ton)",
                      "Captura promedio por viaje")

graficar_serie_tiempo_por_anp(data_mean_series,
                      "captura_viaje",
                      "Captura (ton)",
                      "Captura promedio por viaje")


#' ### Biomasa total
graficar_serie_tiempo_num_emb(data_mean_series,
                      "sum_biomasa_of_patches",
                      "Biomasa (ton)",
                      "Biomasa total") +
    geom_hline(yintercept = 0.40 * 40 * 40 * 80, color = "black", linetype = 3)

graficar_serie_tiempo_num_plat(data_mean_series,
                      "sum_biomasa_of_patches",
                      "Biomasa (ton)",
                      "Biomasa total") +
    geom_hline(yintercept = 0.40 * 40 * 40 * 80, color = "black", linetype = 3)

graficar_serie_tiempo_por_anp(data_mean_series,
                      "sum_biomasa_of_patches",
                      "Biomasa (ton)",
                      "Biomasa total") +
    geom_hline(yintercept = 0.40 * 40 * 40 * 80, color = "black", linetype = 3)


#' ### Número de viajes
graficar_serie_tiempo_num_emb(data_mean_series,
                      "num_viajes_mes",
                      "Número de viajes",
                      "Número total de viajes")

graficar_serie_tiempo_num_plat(data_mean_series,
                      "num_viajes_mes",
                      "Número de viajes",
                      "Número total de viajes")

graficar_serie_tiempo_por_anp(data_mean_series,
                      "num_viajes_mes",
                      "Número de viajes",
                      "Número total de viajes")


#' ### Horas en mar promedio por viaje
graficar_serie_tiempo_num_emb(data_mean_series,
                      "horas_en_mar_viaje",
                      "Horas en mar promedio por viaje",
                      "Horas en mar promedio por viaje")

graficar_serie_tiempo_num_plat(data_mean_series,
                      "horas_en_mar_viaje",
                      "Horas en mar promedio por viaje",
                      "Horas en mar promedio por viaje")

graficar_serie_tiempo_por_anp(data_mean_series,
                      "horas_en_mar_viaje",
                      "Horas en mar promedio por viaje",
                      "Horas en mar promedio por viaje")

#' ### Distancia recorrida promedio por viaje
graficar_serie_tiempo_num_emb(data_mean_series,
                      "distancia_recorrida_viaje",
                      "Distancia recorrida por viaje (celdas)",
                      "Distancia recorrida promedio por viaje")

graficar_serie_tiempo_num_plat(data_mean_series,
                               "distancia_recorrida_viaje",
                               "Distancia recorrida por viaje (celdas)",
                               "Distancia recorrida promedio por viaje")

graficar_serie_tiempo_por_anp(data_mean_series,
                               "distancia_recorrida_viaje",
                               "Distancia recorrida por viaje (celdas)",
                               "Distancia recorrida promedio por viaje")

#' ### Distancia recorrida promedio periodo
graficar_serie_tiempo_num_emb(data_mean_series,
                              "distancia_recorrida_mensual_promedio_periodo",
                              "Distancia recorrida por viaje (celdas)",
                              "Distancia recorrida promedio por viaje (promedio periodo)")

graficar_serie_tiempo_num_plat(data_mean_series,
                              "distancia_recorrida_mensual_promedio_periodo",
                              "Distancia recorrida por viaje (celdas)",
                              "Distancia recorrida promedio por viaje (promedio periodo)")

graficar_serie_tiempo_por_anp(data_mean_series,
                              "distancia_recorrida_mensual_promedio_periodo",
                              "Distancia recorrida por viaje (celdas)",
                              "Distancia recorrida promedio por viaje (promedio periodo)")

#' ### Gasto en gasolina promedio por viaje
graficar_serie_tiempo_num_emb(data_mean_series,
                      "gasto_gas_viaje",
                      "Gasto en gasolina por viaje ($ MXN)",
                      "Gasto en gasolina por viaje")

graficar_serie_tiempo_num_plat(data_mean_series,
                      "gasto_gas_viaje",
                      "Gasto en gasolina por viaje ($ MXN)",
                      "Gasto en gasolina por viaje")

graficar_serie_tiempo_por_anp(data_mean_series,
                      "gasto_gas_viaje",
                      "Gasto en gasolina por viaje ($ MXN)",
                      "Gasto en gasolina por viaje")


#' ### Ganancia por viaje
graficar_serie_tiempo_num_emb(data_mean_series,
                      "ganancia_viaje",
                      "Ganancia por viaje ($ MXN)",
                      "Ganancia por viaje")

graficar_serie_tiempo_num_plat(data_mean_series,
                      "ganancia_viaje",
                      "Ganancia por viaje ($ MXN)",
                      "Ganancia por viaje")

graficar_serie_tiempo_por_anp(data_mean_series,
                      "ganancia_viaje",
                      "Ganancia por viaje ($ MXN)",
                      "Ganancia por viaje")

#' ### Ingreso mensual promedio
graficar_serie_tiempo_num_emb(data_mean_series,
                      "mean_ingreso_mensual_of_embarcaciones",
                      "Ingreso mensual promedio ($MXN)",
                      "Ingreso mensual promedio") +
    geom_hline(yintercept = 7500, color = "black", linetype = 3)

graficar_serie_tiempo_num_plat(data_mean_series,
                      "mean_ingreso_mensual_of_embarcaciones",
                      "Ingreso mensual promedio ($MXN)",
                      "Ingreso mensual promedio") +
    geom_hline(yintercept = 7500, color = "black", linetype = 3)

graficar_serie_tiempo_por_anp(data_mean_series,
                      "mean_ingreso_mensual_of_embarcaciones",
                      "Ingreso mensual promedio ($MXN)",
                      "Ingreso mensual promedio") +
    geom_hline(yintercept = 7500, color = "black", linetype = 3)

#' ### Ingreso mensual promedio periodo
graficar_serie_tiempo_num_emb(data_mean_series,
                      "ingreso_mensual_promedio_periodo",
                      "Ingreso mensual promedio ($MXN)",
                      "Ingreso mensual promedio") +
    geom_hline(yintercept = 7500, color = "black", linetype = 3)

graficar_serie_tiempo_num_plat(data_mean_series,
                      "ingreso_mensual_promedio_periodo",
                      "Ingreso mensual promedio ($MXN)",
                      "Ingreso mensual promedio") +
    geom_hline(yintercept = 7500, color = "black", linetype = 3)

graficar_serie_tiempo_por_anp(data_mean_series,
                      "ingreso_mensual_promedio_periodo",
                      "Ingreso mensual promedio ($MXN)",
                      "Ingreso mensual promedio") +
    geom_hline(yintercept = 7500, color = "black", linetype = 3)


#' ### Número tortugas
graficar_serie_tiempo_num_emb(data_mean_series,
                              "count_tortugas",
                              "Número de tortugas",
                              "Número de tortugas") +
    geom_hline(yintercept = 200 * .3, color = "black", linetype = 3)

graficar_serie_tiempo_num_plat(data_mean_series,
                              "count_tortugas",
                              "Número de tortugas",
                              "Número de tortugas") +
    geom_hline(yintercept = 200 * .3, color = "black", linetype = 3)

graficar_serie_tiempo_por_anp(data_mean_series,
                              "count_tortugas",
                              "Número de tortugas",
                              "Número de tortugas") +
    geom_hline(yintercept = 200 * .3, color = "black", linetype = 3)


#' ### Número tortugas promedio periodo
# Se promedian los últimos 12 meses de la población de tortugas
data_mean_series <- data_mean_series %>%
  group_by(numero_embarcaciones, numero_plataformas, porcentaje_anp) %>%
  mutate(tortugas_promedio_periodo = zoo::rollapplyr(count_tortugas, width = 12, FUN = mean, fill = NA, partial = TRUE)) %>%
  ungroup()  # Desagrupar al final si es necesario

graficar_serie_tiempo_num_emb(data_mean_series,
                              "tortugas_promedio_periodo",
                              "Número de tortugas",
                              "Número de tortugas (promedio periodo)") +
    geom_hline(yintercept = 200 * .3, color = "black", linetype = 3)

graficar_serie_tiempo_num_plat(data_mean_series,
                              "tortugas_promedio_periodo",
                              "Número de tortugas",
                              "Número de tortugas (promedio periodo)") +
    geom_hline(yintercept = 200 * .3, color = "black", linetype = 3)

graficar_serie_tiempo_por_anp(data_mean_series,
                              "tortugas_promedio_periodo",
                              "Número de tortugas",
                              "Número de tortugas (promedio periodo)") +
    geom_hline(yintercept = 200 * .3, color = "black", linetype = 3)

#' ## Acumulado y total
graficar_caja_num_emb <-
    function(data, y, y_label, title = ""){
        ggplot(data,
               aes(x = as.factor(numero_embarcaciones),
                   y = get(y),
                   fill = as.factor(numero_embarcaciones))) +
            geom_boxplot() +
            labs(title = title,
                 subtitle = "cols = número plataformas; rows = porcentaje anp",
                 x = "Número de embarcaciones",
                 y = y_label) +
            facet_grid(cols = vars(numero_plataformas),
                       rows = vars(porcentaje_anp)) +
            scale_color_ucscgb() +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  legend.position = "none")
    }

graficar_caja_num_plat <-
    function(data, y, y_label, title = ""){
        ggplot(data,
               aes(x = as.factor(numero_plataformas),
                   y = get(y),
                   fill = as.factor(numero_plataformas))) +
            geom_boxplot() +
            labs(title = title,
                 subtitle = "cols = número embarcaciones; rows = porcentaje anp",
                 x = "Número de plataformas",
                 y = y_label) +
            facet_grid(cols = vars(numero_embarcaciones),
                       rows = vars(porcentaje_anp)) +
            scale_color_ucscgb() +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  legend.position = "none")
    }

graficar_caja_por_anp <-
    function(data, y, y_label, title = ""){
        ggplot(data,
               aes(x = as.factor(porcentaje_anp),
                   y = get(y),
                   fill = as.factor(porcentaje_anp))) +
            geom_boxplot() +
            labs(title = title,
                 subtitle = "cols = número embarcaciones; rows = número plataformas",
                 x = "Porcentaje ANP",
                 y = y_label) +
            facet_grid(cols = vars(numero_embarcaciones),
                       rows = vars(numero_plataformas)) +
            scale_color_ucscgb() +
            theme_bw() +
            theme(panel.spacing = unit(0.6, "lines"),
                  legend.position = "none")
    }

data_final <-
    data %>%
    filter(meses_transcurridos == max(data$meses_transcurridos))

#' ### Captura acumulada
graficar_caja_num_emb(data_final,
                        "captura_acumulada",
                        "Captura acumulada (ton)",
                        "Captura acumulada (final)")

graficar_caja_num_plat(data_final,
                        "captura_acumulada",
                        "Captura acumulada (ton)",
                        "Captura acumulada (final)")

graficar_caja_por_anp(data_final,
                        "captura_acumulada",
                        "Captura acumulada (ton)",
                        "Captura acumulada (final)")

#' ### Biomasa final
graficar_caja_num_emb(data_final,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (final)") +
    geom_hline(yintercept = 0.4 * 40 * 40 * 80, color = "black", linetype = 3)

graficar_caja_num_plat(data_final,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (final)") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "black", linetype = 3)

graficar_caja_por_anp(data_final,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (final)") +
    geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "black", linetype = 3)

#' ### Biomasa total (toda la simulación)
graficar_caja_num_emb(data,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (toda la simulación)") +
    geom_hline(yintercept = 0.4 * 40 * 40 * 80, color = "black", linetype = 3)

graficar_caja_num_emb(data,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (toda la simulación)") +
    geom_hline(yintercept = 0.4 * 40 * 40 * 80, color = "black", linetype = 3)

graficar_caja_num_plat(data,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (toda la simulación)") +
    geom_hline(yintercept = 0.4 * 40 * 40 * 80, color = "black", linetype = 3)

graficar_caja_por_anp(data,
                        "sum_biomasa_of_patches",
                        "Biomasa total (ton)",
                        "Biomasa total (toda la simulación)") +
    geom_hline(yintercept = 0.4 * 40 * 40 * 80, color = "black", linetype = 3)

#' ### Número de tortugas
graficar_caja_num_emb(data,
              "count_tortugas",
              "Número de tortugas",
              "Número de tortugas (toda la simulación)") +
    geom_hline(yintercept = 0.3 * 200, color = "black", linetype = 3)

graficar_caja_num_plat(data,
              "count_tortugas",
              "Número de tortugas",
              "Número de tortugas (toda la simulación)") +
    geom_hline(yintercept = 0.3 * 200, color = "black", linetype = 3)

graficar_caja_por_anp(data,
              "count_tortugas",
              "Número de tortugas",
              "Número de tortugas (toda la simulación)") +
    geom_hline(yintercept = 0.3 * 200, color = "black", linetype = 3)


#' Días pesca activa
graficar_caja_num_emb(data_final,
              "dias_pesca_sostenible",
              "Días pesca sostenible",
              "Días pesca sostenible")

graficar_caja_num_plat(data_final,
              "dias_pesca_sostenible",
              "Días pesca sostenible",
              "Días pesca sostenible")

graficar_caja_por_anp(data_final,
              "dias_pesca_sostenible",
              "Días pesca sostenible",
              "Días pesca sostenible")

#' Días biomasa sostenible
graficar_caja_num_emb(data_final,
              "dias_biomasa_sostenible",
              "Días biomasa sostenible",
              "Días biomasa sostenible")

graficar_caja_num_plat(data_final,
              "dias_biomasa_sostenible",
              "Días biomasa sostenible",
              "Días biomasa sostenible")

graficar_caja_por_anp(data_final,
              "dias_biomasa_sostenible",
              "Días biomasa sostenible",
              "Días biomasa sostenible")

#' Días hidrocarburo activo
graficar_caja_num_emb(data_final,
              "dias_hidrocarburo_sostenible",
              "Días hidrocarburo sostenible",
              "Días hidrocarburo sostenible")

graficar_caja_num_plat(data_final,
              "dias_hidrocarburo_sostenible",
              "Días hidrocarburo sostenible",
              "Días hidrocarburo sostenible")

graficar_caja_por_anp(data_final,
              "dias_hidrocarburo_sostenible",
              "Días hidrocarburo sostenible",
              "Días hidrocarburo sostenible")


#' Días tortugas sostenible
graficar_caja_num_emb(data_final,
              "dias_tortugas_sostenible",
              "Días tortugas sostenible",
              "Días tortugas sostenible")

graficar_caja_num_plat(data_final,
              "dias_tortugas_sostenible",
              "Días tortugas sostenible",
              "Días tortugas sostenible")

graficar_caja_por_anp(data_final,
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
                                   TRUE),
           primer_umbral = substr(trayectoria_ordenada,1,1),
           objetivo_hidro = produccion_hidrocarburo_acumulada < 25000 * 1000,
           primer_umbral_obj = ifelse(objetivo_hidro, paste(primer_umbral,"-no"), paste(primer_umbral,"-sí")))

ggplot(data_final_trayectorias,
       aes(x = as.factor(numero_embarcaciones),
           fill = as.factor(trayectoria))) +
    geom_bar(position = "stack") +
    facet_grid(cols = vars(as.factor(numero_plataformas)),
               rows = vars(as.factor(porcentaje_anp))) +
    labs(x = "Número de embarcaciones",
         y = "Conteo",
         fill = "Trayectoria") +
    theme_bw() +
    ## scale_fill_viridis(discrete = TRUE, option = "magma")
    scale_fill_ucscgb()
## scale_fill_brewer(palette = "RdYlBu")

ggplot(data_final_trayectorias,
       aes(x = as.factor(numero_embarcaciones),
           fill = as.factor(trayectoria_ordenada))) +
    geom_bar(position = "stack") +
    facet_grid(cols = vars(as.factor(numero_plataformas)),
               rows = vars(as.factor(porcentaje_anp))) +
    labs(x = "Número de embarcaciones",
         y = "Conteo",
         fill = "Trayectoria") +
    theme_bw() +
    ## scale_fill_viridis(discrete = TRUE, option = "magma")
    scale_fill_ucscgb()
## scale_fill_brewer(palette = "RdYlBu")

ggplot(data_final_trayectorias,
       aes(x = as.factor(numero_embarcaciones),
           fill = as.factor(primer_umbral_obj))) +
    geom_bar(position = "stack") +
    facet_grid(cols = vars(as.factor(numero_plataformas)),
               rows = vars(as.factor(porcentaje_anp))) +
    labs(x = "Número de embarcaciones",
         y = "Conteo",
         fill = "Trayectoria") +
    theme_bw() +
    ## scale_fill_viridis(discrete = TRUE, option = "magma")
    scale_fill_ucscgb()
    ## scale_fill_brewer(palette = "RdYlBu")
