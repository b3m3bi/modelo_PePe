
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
fechas_mensuales <- seq.Date(from=fecha_inicial, to = fecha_final, by="month")
dias_desde_inicio <- as.numeric(fechas_mensuales - fecha_inicial + 1)
horas_iteracion <- 24
ticks_seq <- (dias_desde_inicio - 1) * (24 / horas_iteracion)
resultado <- data.frame(fecha= fechas_mensuales, dia=dias_desde_inicio, ticks=ticks_seq)
print(resultado)

## dias en los que se deben hacer los registros
paste(" [", paste(dias_desde_inicio, collapse=" "), "] ")
## ticks en los que se deben hacer los registros
paste(" [", paste(ticks_seq, collapse=" "), "] ")

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
    "ganancia_mes_hidrocarburo",
    "captura_acumulada",
    "ganancia_acumulada",
    "gasto_gasolina_acumulada",
    "horas_en_mar_acumulada"
)

filename <- "modeloPePe_2 calibracion_pesca_03-table.csv"

data <- read.csv(paste("./calibracion/output/", filename, sep=""), skip = 6) #, col.names= col_names )

col_names <- c(names(data)[1:18], "dia", "logdate", outputs_names)
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

agg <- aggregate(do.call(cbind, data[outputs_names]) ~ dia + fecha + VELOCIDAD + HORAS_DESCANSAR_PUERTO_1 + Ks + Ms + HORAS_MAXIMAS_EN_MAR_PUERTO_1, data =data, FUN = mean)

agg$horas_mar_viaje_prom <- agg$horas_mar_mes_prom / (agg$viajes_mes / 300)
agg$viajes_semana_prom <- agg$viajes_mes * (1/300) / 4
agg$viajes_mes_prom <- agg$viajes_mes * (1/300)
agg$dist_viaje_prom <- agg$distancia_recorrida_mes_prom / (agg$viajes_mes / 300)


ref <- as.data.frame(t(data.frame(
    valores=c(300,10,1000,8,1500,15,7500),
    row.names=c("captura", "distancia","ganancia","horas","gasolina","viajes","salario"))))


## la captura por viaje * 15 viajes al mes
fig_captura <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = (capturas_mes / viajes_mes)* 1000,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$captura, linetype="dashed") +
    labs(x = "fecha",
         y = "captura promedio al mes (kg)",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_captura
ggsave("fig_captura.png")


fig_viajes <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = viajes_mes_prom,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$viajes, linetype="dashed") +
    labs(x = "fecha",
         y = "número de viajes promedio al mes",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_viajes
ggsave("fig_viajes.png")

fig_distancia <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = distancia_recorrida_mes_prom / viajes_mes_prom,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$viajes, linetype="dashed") +
    labs(x = "fecha",
         y = "distancia recorrida mes prom (km)",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_distancia
ggsave("fig_distancia.png")

## las horas mar mes prom son las horas totales promedio de un pescador al mes
fig_duracion <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = horas_mar_mes_prom / viajes_mes_prom,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$horas, linetype="dashed") +
    labs(x = "fecha",
         y = "duracion viaje (horas)",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_duracion
ggsave("fig_duracion.png")

fig_ganancia <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = ganancias_mes / viajes_mes,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$ganancia, linetype="dashed") +
    labs(x = "fecha",
         y = "ganancia por viaje (MXN)",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_ganancia
ggsave("fig_ganancia.png")

fig_gas <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = gasto_gas_mes_prom / viajes_mes_prom,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$gasolina, linetype="dashed") +
    labs(x = "fecha",
         y = "gasto en gasolina por viaje promedio (MXN)",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_gas
ggsave("fig_gas.png")

fig_salario <-
    ggplot(agg[agg$HORAS_MAXIMAS_EN_MAR_PUERTO_1 == 8,],
           aes(x = fecha,
               y = salario_mes_prom,
               shape = as.factor(VELOCIDAD),
               color = as.factor(HORAS_DESCANSAR_PUERTO_1))) +
    geom_point() +
    geom_hline(yintercept=ref$salario, linetype="dashed") +
    labs(x = "fecha",
         y = "salario promedio mensual (MXN)",
         shape = "velocidad",
         color = "horas descansar") +
    facet_grid(vars(Ms), vars(Ks))
fig_salario
ggsave("fig_salario.png")
