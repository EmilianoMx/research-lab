# EPOGOB-IA | CFA + SEM + LPA (Pipeline reproducible)

Este proyecto contiene un pipeline completo para análisis psicométrico y configuracional de la escala **EPOGOB-IA** usando R.

## Qué incluye
- **CFA (WLSMV):** confirmación factorial de 6 dimensiones (24 ítems, Likert 1–5)
- **SEM (WLSMV):** modelo causal de 2º orden (**IA → Gobernanza → Bienestar**)
- **LPA:** perfiles latentes sobre dimensiones promedio (1–3 clases) + ANOVA
- Exportación automática de resultados a Excel y gráfico de perfiles

## Estructura
- `EPOGOB_pipeline.R`: script principal reproducible.

## Entrada esperada
- Archivo **Excel original** exportado de Google Forms (respuestas), o CSV UTF-8-BOM.
- El script detecta automáticamente las 24 columnas Likert 1–5 y las renombra a:
  - `IA_AI1..4`, `IA_TE1..4`, `GOV_CD1..4`, `GOV_TO1..4`, `WB_SL1..4`, `WB_EC1..4`

## Salida
Se crea automáticamente una carpeta junto al archivo de entrada:

`./Resultados_EPOGOB/`

Incluye:
- `EPOGOB-IA_respuestas_limpias_codigos.xlsx`
- `EPOGOB_Reporte_SEM_LPA.xlsx`
- `LPA_plot_profiles_K{best_k}.png`

## Requisitos
- R (>= 4.2 recomendado)
- Paquetes: `tidyverse`, `readxl`, `lavaan`, `semTools`, `psych`, `tidyLPA`, `mclust`, `openxlsx`

El script instala automáticamente paquetes faltantes.

## Ejecución
1. Abrir R/RStudio.
2. Ejecutar `EPOGOB_pipeline.R`.
3. Seleccionar el archivo original en el explorador (`file.choose()`).

## Notas metodológicas
- Estimador CFA/SEM: **WLSMV** (ítems ordinales Likert)
- Se aplica un **boundary solution** en `IA_AI2 ~~ 0*IA_AI2` para manejar Heywood case leve.

## Autor
Gustavo Emiliano Mascareño Beltrán
