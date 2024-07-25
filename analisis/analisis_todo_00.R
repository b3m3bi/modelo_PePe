library(tidyverse)
library(janitor)

rutas_archivos <- c("data/mini_PePeCoGoMx analisis_todo_00-table.csv",
                    "data/mini_PePeCoGoMx analisis_todo_00_part_1-table.csv",
                    "data/mini_PePeCoGoMx analisis_todo_00_part_2-table.csv")

raw_data <- read_csv(rutas_archivos, skip = 6, id = "file")

raw_data <-
    raw_data |>
    janitor::clean_names()

# Se revisa para ver donde están los duplicados
raw_data %>%
    count(numero_embarcaciones,
          numero_plataformas,
          largo_zona_protegida,
          sort = TRUE) %>%
    print(n = 10)

# Se quitan los duplicados
data <- raw_data %>%
    filter(!(
        file == "data/mini_PePeCoGoMx analisis_todo_00-table.csv" &
        numero_embarcaciones == 125 &
        numero_plataformas == 5
    ))

data %>%
    count(numero_embarcaciones,
          numero_plataformas,
          largo_zona_protegida,
          sort = TRUE) %>%
    print(n = 200)

write_csv(data, "data/mini_PePeCoGoMx analisis_00-table_merged.csv")

