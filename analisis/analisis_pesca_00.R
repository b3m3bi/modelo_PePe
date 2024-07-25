setwd("/home/lggj/PARA/proyectos/PePe_ecosur/modelo_PePe/analisis/")

library(ggplot2)

filename <- "mini_PePeCoGoMx analisis_pesca_00-table.csv"
data <- read.csv(paste("./data/", filename, sep = ""), skip = 6)

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
    "dias_tortugas_sostenible"
)

names(data) <- c(names(data)[1:9], nombres_salidas)

agg <- aggregate(do.call(cbind, data[nombres_salidas]) ~ meses_transcurridos + NUMERO_EMBARCACIONES, data = data, FUN = mean)

## plot_st_captura_total <-
##     ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = total_capturas_mes,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Mes",
##          y = "Captura total (ton)",
##          color = "Número de embarcaciones") +
##     theme_classic()

## plot_captura_acumulada <-
##     ggplot(data[data$meses_transcurridos ==  max(data$meses_transcurridos), ],
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = captura_acumulada)) +
##     geom_boxplot() +
##     labs(x = "Número de embarcaciones",
##          y = "Captura acumulada (ton)") +
##     theme_classic()
## plot_captura_acumulada

## plot_biomasa_final <-
##     ggplot(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = biomasa_total)) +
##     geom_boxplot() +
##     labs(x = "Numero de embarcaciones",
##          y = "Biomasa total (ton)") +
##     geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "gray", linetype = 3 ) + 
##     theme_classic()
## plot_biomasa_final

## plot_st_biomasa_total <-
##     ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = biomasa_total,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Meses",
##          y = "Biomasa total (ton)",
##          color = "Número de embarcaciones") +
##     geom_hline(yintercept = 0.25 * 40 * 40 * 50, color = "gray", linetype = 3 ) + 
##     theme_classic()
## plot_st_biomasa_total

## plot_dias_pesca_sostenible <-
##     ggplot(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = dias_pesca_sostenible)) +
##     geom_boxplot() +
##     labs(x = "Número de embarcaciones",
##          y = "Días pesca sostenible") +
##     theme_classic()
## plot_dias_pesca_sostenible

## plot_dias_biomasa_sostenible <-
##     ggplot(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = dias_biomasa_sostenible)) +
##     geom_boxplot() +
##     labs(x = "Número de embarcaciones",
##          y = "Días biomasa sostenible") +
##     theme_classic()
## plot_dias_biomasa_sostenible

## plot_total_tortugas <-
##     ggplot(data,
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = num_tortugas)) +
##     geom_boxplot() +
##     labs(x = "Número de embarcaciones",
##          y = "Número de tortugas") +
##     theme_classic() +
##     geom_hline(yintercept = 0.5 * 150, color = "gray", linetype = 3) +
##     geom_hline(yintercept = 0.25 * 150, color = "gray", linetype = 1)
## plot_total_tortugas

## plot_dias_tortugas_sostenible <-
##     ggplot(data[data$meses_transcurridos == max(data$meses_transcurridos), ],
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = dias_tortugas_sostenible)) +
##     geom_boxplot() +
##     labs(x = "Número de embarcaciones",
##          y = "Días tortugas sostenible") +
##     theme_classic()
## plot_dias_tortugas_sostenible

## plot_st_salario_mensual <-
##     ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = salario_mensual_promedio,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Meses",
##          y = "Salario mensual promedio ($ MXN)",
##          color = "Número de embarcaciones") +
##     geom_hline(yintercept =  7000, color = "gray", linetype = 1 ) + 
##     theme_classic()
## plot_st_salario_mensual

## plot_st_gasto_gas_mes <-
##      ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = total_gasto_gas_mes / num_viajes_mes ,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Meses",
##          y = "Gasto en gasolina por viaje promedio ($ MXN)",
##          color = "Número de embarcaciones") +
##     theme_classic()
## plot_st_gasto_gas_mes

## plot_ganancia_acumulada <-
##     ggplot(data[data$meses_transcurridos ==  max(data$meses_transcurridos), ],
##            aes(x = as.factor(NUMERO_EMBARCACIONES),
##                y = ganancia_acumulada)) +
##     geom_boxplot() +
##     labs(x = "Número de embarcaciones",
##          y = "Ganancia acumulada ($ MXN)") +
##     theme_classic()
## plot_ganancia_acumulada

## plot_st_num_viajes <-
##     ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = num_viajes_mes,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Meses",
##          y = "Número de viajes",
##          color = "Número de embarcaciones") +
##     theme_classic()
## plot_st_num_viajes

## plot_st_captura_viaje <-
##     ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = total_capturas_mes / num_viajes_mes,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Meses",
##          y = "Captura por viaje promedio (ton)",
##          color = "Número de embarcaciones") +
##     theme_classic()
## plot_st_captura_viaje

## plot_st_horas_en_mar_viaje <-
##     ggplot(agg,
##            aes(x = meses_transcurridos,
##                y = total_horas_en_mar_mes / num_viajes_mes,
##                color = as.factor(NUMERO_EMBARCACIONES))) +
##     geom_line() +
##     labs(x = "Meses",
##          y = "Horas en mar por viaje",
##          color = "Número de embarcaciones") +
##     theme_classic()
## plot_st_horas_en_mar_viaje

