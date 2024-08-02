library(tidyverse)
library(ggsci)

data <- read_csv("./data/mini_PePeCoGoMx analisis_00-table_merged.csv")

## combinaciones <-
##     data %>%
##     select(numero_embarcaciones,
##            numero_plataformas,
##            largo_zona_protegida) %>%
##     crossing()

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

ggsave("trayectorias.png",
       dpi = 300)
       
