---
title: "Análisis de sensibilidad"
output: html_document
---
Se realizaron simulaciones para identificar las trayectorias del submodelo
de pesca con un conjunto de parámetros base. Lo único que se vario en las
simulaciones es el número de embarcaiones de 10 a 200 con saltos de 10.
## Parámetros base
En las simulaciones se utilizaron los siguientes parámetros base:

| Submodelo | Parámetro | Valor |
|-|-|-|
| pesca | HORAS_DESCANSAR | 12 |
| pesca | PROB_EXPLORAR | 0.2 |
| pesca | RADIO_EXPLORAR | 3 |
| pesca | NUM_AMIGOS | 2 |
| pesca | **NUMERO_EMBARCACIONES** | varia |
| pesca | DIAS_MAXIMOS_EN_MAR | 5 |
| pesca | CAPTURABILIDAD | 0.01 |
| pesca | VELOCIDAD | 0.5 |
| pesca | CAPACIDAD_MAXIMA | 1 |
| pesca | LITROS_POR_DISTANCIA | 1 |
| pesca | LITROS_POR_HORA_PESCA | 1 |
| pesca | NUM_TRIPULANTES | 3 |
| pesca | PRECIO_BIOMASA | 10000 |
| pesca | PRECIO_LITRO_GAS | 20 |
| ecología | K | 50 |
| ecología | M | 0.001 |
| ecología | R | 0.6 |
| hidrocarburo | **NUMERO_PLATAFORMAS** | 0 |
| hidrocarburo | HODROCARBURO_INICIAL | 20000 |
| hidrocarburo | EXTRACCION_MAX_HIDROCARBURO | 10 |
| hidrocarburo | TASA_DECLINACION_HIDROCARBURO | 0.001 |
| hidrocarburo | PROB_OCURRENCIA_DERRAME | 0.025 |
| hidrocarburo | PROB_EXTENSION_DERRAME | 0.35 |
| hidrocarburo | PROB_MORTALIDAD_DERRAME | 0.5 |
| hidrocarburo | TIEMPO_DERRAMADO | 50 |
| hidrocarburo | COSTO_OPERACION_PLATAFORMA | 1000 |
| hidrocarburo | PRECIO_HIDROCARBURO | 10000 |
| hidrocarburo | RADIO_RESTRICCION | 4 |
| hidrocarburo | SUBSIDIO_MENSUAL_GASOLINA | 0 |
| tortugas | **LARGO_ZONA_PROTEGIDA** | 0 |
| tortugas | **ANCHO_ZONA_PROTEGIDA** | 0 |
| tortugas | POB_INICIAL_TORTUGAS | 150 |
| tortugas | NUM_DESCENDIENTES | 1 |
| tortugas | CAPACIDAD_CARGA | 2 |
| tortugas | PROB_MORTALIDAD_TORTUGA_PESCA | 0.008 |
| tortugas | PROB_MORTALIDAD_TORTUGA_DERRAME | 0.15 |
| mundo | HORAS_ITERACION | 24 |
| mundo | LONGITUD_CELDA | 1 |
| mundo | LONGITUD_TIERRA | 6 |
| jugabilidad | SALARIO_MIN_MENSUAL | 7000 |
| jugabilidad | MAX_MESES_CRISIS_PESCA | 12 |
| jugabilidad | PORCENTAJE_BIOMASA_CRISIS | 50 |
| jugabilidad | PORCENTAJE_BIOMASA_COLAPSO | 25 |
| jugabilidad | MAX_MESES_CRISIS_HIDROCARBURO | 12 |
| jugabilidad | PORCENTAJE_TORTUGAS_CRISIS | 50 |
| jugabilidad | PORCENTAJE_TORTUGAS_COLAPSO | 25 |







## Series de tiempo



### Captura total

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)

### Captura por viaje

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)

### Biomasa total

![plot of chunk unnamed-chunk-8](figure/unnamed-chunk-8-1.png)

### Numero de viajes

![plot of chunk unnamed-chunk-9](figure/unnamed-chunk-9-1.png)

### Horas en mar por viaje

![plot of chunk unnamed-chunk-10](figure/unnamed-chunk-10-1.png)

### Distancia recorrida por viaje

![plot of chunk unnamed-chunk-11](figure/unnamed-chunk-11-1.png)

### Gasto en gasolina por viaje

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12-1.png)

### Ganancia por viaje

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png)

### Salario promedio mensual

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png)

## Acumulados y finales



### Captura acumulada final

![plot of chunk unnamed-chunk-16](figure/unnamed-chunk-16-1.png)

### Biomasa final

![plot of chunk unnamed-chunk-17](figure/unnamed-chunk-17-1.png)

### Ganancia acumulada final

![plot of chunk unnamed-chunk-18](figure/unnamed-chunk-18-1.png)

### Número tortugas acumulado

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-1.png)

## Tiempos de sostenibilidad
### Tiempo pesca sostenible

![plot of chunk unnamed-chunk-20](figure/unnamed-chunk-20-1.png)

### Tiempo biomasa sostenible

![plot of chunk unnamed-chunk-21](figure/unnamed-chunk-21-1.png)

### Tiempo tortugas sostenible

![plot of chunk unnamed-chunk-22](figure/unnamed-chunk-22-1.png)

## Trayectorias representativas
Para el conjunto de parametros base se identificó que la cantidad óptima
de embarcaciones es 100. Esto se debe a que con este valor no se supera
ninguno de los umbrales de sostenibilidad y se obtienen altas capturas
y ganancias acumuladas.

A partir de estas simulaciones se pueden identificar 4 escenarios a los
que se podrían acotar las exploraciones:

1. *Sub-pesca*: con 50 embarcaciones, no se supera ningún umbral de
juego, se obtiene un alto salario mensual, pero la captura y ganancia
acumuladas son bajas.
2. *Óptimo*: con 100 embarcaciones, no se supera ningún umbral de juego,
se obtiene un salario mensual aceptable, la captura y ganancia acumuladas
son altos (más altos que con 50).
3. *Sobre-pesca límite*: con 150 embarcaciones, se superan todos los
umbrales de juego a partir de los 15 años, se obtienen las máximas capturas y ganancias acumuladas pero no son sostenibles.
4. *Sobre-pesca extrema*: con 200 embarcaciones, se superan todos los
umbrales de juego en menos de 10 años, se obteienen ganancias acumuladas
menores a con 150 pero similares a con 100.

En las siguientes gráficas se muestran las trayectorias representativas
promedio de 30 simulaciones y sus máximos y mínimos.



### Captura total

![plot of chunk unnamed-chunk-24](figure/unnamed-chunk-24-1.png)

### Captura por viaje

![plot of chunk unnamed-chunk-25](figure/unnamed-chunk-25-1.png)

### Biomasa

![plot of chunk unnamed-chunk-26](figure/unnamed-chunk-26-1.png)

### Numero viajes

![plot of chunk unnamed-chunk-27](figure/unnamed-chunk-27-1.png)

### Horas en mar por viaje

![plot of chunk unnamed-chunk-28](figure/unnamed-chunk-28-1.png)

### Distancia recorrida por viaje

![plot of chunk unnamed-chunk-29](figure/unnamed-chunk-29-1.png)

### Gasto en gasolina por viaje

![plot of chunk unnamed-chunk-30](figure/unnamed-chunk-30-1.png)

### Ganancia por viaje

![plot of chunk unnamed-chunk-31](figure/unnamed-chunk-31-1.png)

### Salario mensual promedio

![plot of chunk unnamed-chunk-32](figure/unnamed-chunk-32-1.png)

### Tortugas

![plot of chunk unnamed-chunk-33](figure/unnamed-chunk-33-1.png)

