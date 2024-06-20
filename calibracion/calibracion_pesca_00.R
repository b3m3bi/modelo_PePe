
library(lubridate)

obtener_ultimo_dia_mes <- function(fecha_inicio, fecha_final){
    ultimos_dias_ano <- yday((seq.Date(from=fecha_inicio, to=fecha_final + 1, by="month") - 1)[-1])
    ultimos_dias_total <- vector()
    indice_ultimo_dia_ano <- 12
    suma_indice <- 0
    for (i in 1:(year(fecha_final) - year(fecha_inicio))){
        ultimos_dias_total <- append(
            ultimos_dias_total,
            ultimos_dias_ano[(indice_ultimo_dia_ano - 11):indice_ultimo_dia_ano] + suma_indice)
        indice_ultimo_dia_ano <- indice_ultimo_dia_ano + 12
        suma_indice <- suma_indice + ultimos_dias_ano[indice_ultimo_dia_ano]
    }
    return(ultimos_dias_total)
}

fecha_inicial = as.Date("2024-01-01")
fecha_final = as.Date("2034-01-01")
fechas_mensuales <- seq.Date(from=fecha_inicio, to = fecha_final, by="month")
dias_desde_inicio <- as.numeric(fechas_mensuales - fecha_inicial + 1)
horas_iteracion <- 24
ticks_seq <- (dias_desde_inicio - 1) * (24 / horas_iteracion)
resultado <- data.frame(fecha= fechas_mensuales, dia=dias_desde_inicio, ticks=ticks_seq)
print(resultado)

paste(" [", paste(dias_desde_inicio, collapse=" "), "] ")

library(ggplot2)

outputs_names <- c(
    "capturas_mes",          
    "distancia_recorrida_mes_prom",
    "ganancias_mes",
    "horas_mar_mes_prom",
    "gasto_gas_mes_prom",
    "viajes_mes",
    "salario_mes_prom",
    "num_embarcaciones_viable",
    "num_embarcaciones_crisis",
    "num_embarcaciones_quiebra",
    "biomasa_0",
    "biomasa_1",
    "biomasa_2",
    "num_tortugas",
    "tiempo_pesca_sostenible",
    "tiempo_hidrocarburo_sostenible",
    "tiempo_biomasa_sostenible",
    "tiempo_tortugas_sostenible",
    "num_derrames",
    "produccion_mes_hidrocarburo",
    "produccion_total_hidrocarburo",
    "ganancia_mes_hidrocarburo"
)

filename <- "modeloPePe_2 calibracion_pesca_02-table.csv"

data <- read.csv(paste("./calibracion/output/", filename, sep=""), skip = 6) #, col.names= col_names )

col_names <- c(names(data)[1:18], "dia", outputs_names)
names(data) <- col_names

fecha_inicio <- as.Date("2024-01-01")
fecha_final <- as.Date("2034-01-01")
data$fecha <- fecha_inicio + data$dia

## ggplot(data,
##        aes(x = dia,
##            y = biomasa_0,
##            colour = as.factor(HORAS_DESCANSAR_PUERTO_1),
##            ## size = VELOCIDAD
##            )
##        ) +
##     geom_point() +
##     facet_grid(vars(VELOCIDAD), vars(Ks))

agg <- aggregate(do.call(cbind, data[outputs_names]) ~ dia + fecha + VELOCIDAD + HORAS_DESCANSAR_PUERTO_1 + Ks + HORAS_MAXIMAS_EN_MAR_PUERTO_1 + PRECIOS_KILO_BIOMASA, data =data, FUN = mean)

agg$horas_mar_viaje_prom <- agg$horas_mar_mes_prom / (agg$viajes_mes / 300)
## agg$viajes_semana_prom <- agg$viajes_mes * (1/300) 

ggplot(agg,
       aes(x = fecha,
           y = viajes_mes,
           shape = as.factor(HORAS_DESCANSAR_PUERTO_1),
           color = as.factor(HORAS_MAXIMAS_EN_MAR_PUERTO_1)
           )
       ) +
    geom_point() +
    facet_grid(vars(VELOCIDAD), vars(Ks))
