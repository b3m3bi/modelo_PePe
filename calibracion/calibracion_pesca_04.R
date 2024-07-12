setwd("/home/lggj/PARA/proyectos/PePe_ecosur/modelo_PePe/calibracion")

library(lubridate)

## se generan las listas de ticks y fechas en las que se toman
## registros (a fin de mes)
fecha_inicial = as.Date("2024-01-01")
fecha_final = as.Date("2034-01-01")
fechas_mensuales <- seq.Date(from=fecha_inicial, to=fecha_final, by="month")
dias_desde_inicio <- as.numeric(fechas_mensuales - fecha_inicial + 1)
horas_iteracion <- 24
ticks_seq <- (dias_desde_inicio - 1) * (24 / horas_iteracion)

paste(" [", paste(dias_desde_inicio, collapse = " "), "] ")
paste(" [", paste(ticks_seq, collapse = " "), "] ")


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

filename <- "modeloPePe_2 calibracion_pesca_04-table.csv"

data <- read.csv(paste("./output/", filename, sep = ""), skip = 6)

col_names <- c(names(data)[1:9],"dia","logdate", outputs_names)
names(data) <- col_names

data$fecha <- fecha_inicial + data$dia

agg <- aggregate(do.call(cbind, data[outputs_names]) ~ dia + fecha + NUMERO_EMBARCACIONES + TIPO_DE_EMBARCACIONES + Ks, data = data, FUN = mean)

# "semi-industrial (10 ton, 5 tripulantes)"
# "pequeña escala (1 ton, 3 tripulantes)"
ggplot(agg[agg$TIPO_DE_EMBARCACIONES=="pequeña escala (1 ton, 3 tripulantes)"
           ,],
       aes(x = fecha,
           y = captura_acumulada,
           color = as.factor(NUMERO_EMBARCACIONES))) +
    geom_line() +
    labs(x = "fecha",
         shape = "tipo de embarcación",
         color = "número de embarcaciones") +
    facet_grid(vars(Ks), vars(TIPO_DE_EMBARCACIONES))
