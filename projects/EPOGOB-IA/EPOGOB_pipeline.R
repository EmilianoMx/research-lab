# ============================================================
# EPOGOB-IA | Pipeline reproducible (CFA + SEM + LPA + Reporte)
# Autor: Gustavo Emiliano Mascareño Beltrán
# Fecha: 2026-02-20
# ============================================================

rm(list = ls())

# 0) Paquetes
pkgs <- c("tidyverse", "readxl", "lavaan", "semTools", "psych", "tidyLPA", "mclust", "openxlsx")
to_install <- pkgs[!pkgs %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) install.packages(to_install)
invisible(lapply(pkgs, library, character.only = TRUE))

# 1) Elegir archivo
cat("📂 Selecciona el EXCEL ORIGINAL del Forms (respuestas)...\n")
file_path <- file.choose()
cat("✅ Archivo seleccionado:\n", file_path, "\n\n")

if (grepl("\\.xlsx$", file_path, ignore.case = TRUE)) {
  raw <- readxl::read_xlsx(file_path, sheet = 1)
} else if (grepl("\\.csv$", file_path, ignore.case = TRUE)) {
  raw <- read.csv(file_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
} else {
  stop("Formato no soportado. Usa .xlsx o .csv")
}

# 2) Carpeta de resultados
base_dir <- dirname(normalizePath(file_path, winslash = "/", mustWork = FALSE))
results_dir <- file.path(base_dir, "Resultados_EPOGOB")
if (!dir.exists(results_dir)) dir.create(results_dir, recursive = TRUE)
cat("📁 Carpeta de resultados:\n", results_dir, "\n\n")

# 3) Detectar Likert 1-5 y mapear a códigos
raw_num <- raw
raw_num[] <- lapply(raw_num, function(x) suppressWarnings(as.numeric(as.character(x))))

is_likert_col <- function(v) {
  v <- v[!is.na(v)]
  if (length(v) < 5) return(FALSE)
  all(v %in% 1:5)
}

likert_cols <- names(raw)[sapply(raw_num, is_likert_col)]

if (length(likert_cols) < 24) {
  stop(paste0(
    "❌ Detecté solo ", length(likert_cols),
    " columnas tipo Likert (1-5). Deben ser al menos 24.\n",
    "Revisa que sea el Forms correcto y que los ítems sean numéricos 1–5."
  ))
}

item_cols <- likert_cols[1:24]

codes <- c(
  paste0("IA_AI", 1:4),
  paste0("IA_TE", 1:4),
  paste0("GOV_CD", 1:4),
  paste0("GOV_TO", 1:4),
  paste0("WB_SL", 1:4),
  paste0("WB_EC", 1:4)
)

demo_candidates <- c(
  "Marca temporal", "Edad:",
  "Género: si la persona se reconoce como hombre, mujer u otra opción.",
  "Nivel máximo de estudios ", "Departamento/Área de Trabajo:", "Horario Laboral:",
  "Nombre de la empresa: (Opcional y anonimo)", "Años trabajando en esta empresa:"
)
demo_cols <- intersect(demo_candidates, names(raw))

data <- raw %>%
  select(all_of(demo_cols), all_of(item_cols)) %>%
  rename(!!!setNames(item_cols, codes))

data[codes] <- lapply(data[codes], function(x) as.numeric(as.character(x)))

data <- data %>%
  mutate(
    IA_AI = rowMeans(across(all_of(paste0("IA_AI", 1:4))), na.rm = TRUE),
    IA_TE = rowMeans(across(all_of(paste0("IA_TE", 1:4))), na.rm = TRUE),
    GOV_CD = rowMeans(across(all_of(paste0("GOV_CD", 1:4))), na.rm = TRUE),
    GOV_TO = rowMeans(across(all_of(paste0("GOV_TO", 1:4))), na.rm = TRUE),
    WB_SL = rowMeans(across(all_of(paste0("WB_SL", 1:4))), na.rm = TRUE),
    WB_EC = rowMeans(across(all_of(paste0("WB_EC", 1:4))), na.rm = TRUE)
  )

clean_xlsx <- file.path(results_dir, "EPOGOB-IA_respuestas_limpias_codigos.xlsx")
openxlsx::write.xlsx(data, clean_xlsx, overwrite = TRUE)

qa <- list(
  n = nrow(data),
  faltantes_items = sum(is.na(as.matrix(data[codes]))),
  faltantes_por_item = sort(colSums(is.na(data[codes])), decreasing = TRUE),
  min_item = suppressWarnings(min(as.matrix(data[codes]), na.rm = TRUE)),
  max_item = suppressWarnings(max(as.matrix(data[codes]), na.rm = TRUE))
)

cat("✅ Archivo limpio guardado en:\n", clean_xlsx, "\n")
cat("🔎 QA rápido:\n")
print(qa)
cat("\n")

ordered_items <- codes

# A) CFA
cfa_model_6f <- '
  F_IA_AI  =~ IA_AI1 + IA_AI2 + IA_AI3 + IA_AI4
  F_IA_TE  =~ IA_TE1 + IA_TE2 + IA_TE3 + IA_TE4
  F_GOV_CD =~ GOV_CD1 + GOV_CD2 + GOV_CD3 + GOV_CD4
  F_GOV_TO =~ GOV_TO1 + GOV_TO2 + GOV_TO3 + GOV_TO4
  F_WB_SL  =~ WB_SL1 + WB_SL2 + WB_SL3 + WB_SL4
  F_WB_EC  =~ WB_EC1 + WB_EC2 + WB_EC3 + WB_EC4

  IA_AI2 ~~ 0*IA_AI2
'

fit_cfa <- cfa(model = cfa_model_6f, data = data, ordered = ordered_items, estimator = "WLSMV")

cfa_fit <- fitMeasures(fit_cfa, c("cfi", "tli", "rmsea", "srmr"))
cfa_loadings <- parameterEstimates(fit_cfa, standardized = TRUE) %>%
  filter(op == "=~") %>%
  select(lhs, rhs, est, se, z, pvalue, std.all)

cfa_reliab <- tryCatch(reliability(fit_cfa), error = function(e) e)

lambda_std <- inspect(fit_cfa, "std")$lambda
psi_std <- inspect(fit_cfa, "std")$psi

# B) SEM
sem_model <- '
  F_IA_AI  =~ IA_AI1 + IA_AI2 + IA_AI3 + IA_AI4
  F_IA_TE  =~ IA_TE1 + IA_TE2 + IA_TE3 + IA_TE4
  F_GOV_CD =~ GOV_CD1 + GOV_CD2 + GOV_CD3 + GOV_CD4
  F_GOV_TO =~ GOV_TO1 + GOV_TO2 + GOV_TO3 + GOV_TO4
  F_WB_SL  =~ WB_SL1 + WB_SL2 + WB_SL3 + WB_SL4
  F_WB_EC  =~ WB_EC1 + WB_EC2 + WB_EC3 + WB_EC4

  IA  =~ 1*F_IA_AI + F_IA_TE
  GOV =~ 1*F_GOV_CD + F_GOV_TO
  WB  =~ 1*F_WB_SL + F_WB_EC

  GOV ~ a*IA
  WB  ~ b*GOV + cprime*IA

  indirect := a*b
  total    := cprime + (a*b)

  IA_AI2 ~~ 0*IA_AI2
'

fit_sem <- sem(model = sem_model, data = data, ordered = ordered_items, estimator = "WLSMV")

sem_fit <- fitMeasures(fit_sem, c("cfi", "tli", "rmsea", "srmr"))
sem_paths <- parameterEstimates(fit_sem, standardized = TRUE) %>%
  filter(op %in% c("~", ":=")) %>%
  select(lhs, op, rhs, est, se, z, pvalue, std.all)

# C) LPA
lpa_vars <- data %>%
  select(all_of(c("IA_AI", "IA_TE", "GOV_CD", "GOV_TO", "WB_SL", "WB_EC"))) %>%
  drop_na()

lpa_scaled <- as.data.frame(scale(lpa_vars))

lpa_results <- estimate_profiles(lpa_scaled, 1:3)
lpa_fit <- get_fit(lpa_results)

best_k <- lpa_fit %>% arrange(BIC) %>% slice(1) %>% pull(Classes)
best_lpa <- lpa_results[[best_k]]

lpa_assign <- get_data(best_lpa) %>%
  rename(Profile = Class) %>%
  mutate(Profile = as.integer(Profile))

lpa_join <- lpa_vars %>% mutate(Profile = lpa_assign$Profile)

profile_sizes <- lpa_join %>%
  count(Profile, name = "n") %>%
  mutate(pct = n / sum(n) * 100) %>%
  arrange(Profile)

profile_means <- lpa_join %>%
  group_by(Profile) %>%
  summarise(
    n = n(),
    IA_AI = mean(IA_AI, na.rm = TRUE),
    IA_TE = mean(IA_TE, na.rm = TRUE),
    GOV_CD = mean(GOV_CD, na.rm = TRUE),
    GOV_TO = mean(GOV_TO, na.rm = TRUE),
    WB_SL = mean(WB_SL, na.rm = TRUE),
    WB_EC = mean(WB_EC, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(Profile)

anova_WB_SL <- summary(aov(WB_SL ~ factor(Profile), data = lpa_join))
anova_WB_EC <- summary(aov(WB_EC ~ factor(Profile), data = lpa_join))

plot_path <- file.path(results_dir, paste0("LPA_plot_profiles_K", best_k, ".png"))
png(plot_path, width = 1400, height = 900)
plot_profiles(best_lpa)
dev.off()

# D) Exportar reporte
out_report <- file.path(results_dir, "EPOGOB_Reporte_SEM_LPA.xlsx")
wb <- createWorkbook()

addWorksheet(wb, "QA")
writeData(wb, "QA", data.frame(
  Metric = c("n", "faltantes_items", "min_item", "max_item"),
  Value = c(qa$n, qa$faltantes_items, qa$min_item, qa$max_item)
))

addWorksheet(wb, "QA_missing_by_item")
writeData(wb, "QA_missing_by_item",
  data.frame(Item = names(qa$faltantes_por_item), Missing = as.integer(qa$faltantes_por_item))
)

addWorksheet(wb, "CFA_Fit")
writeData(wb, "CFA_Fit", data.frame(Metric = names(cfa_fit), Value = as.numeric(cfa_fit)))

addWorksheet(wb, "CFA_Loadings")
writeData(wb, "CFA_Loadings", cfa_loadings)

addWorksheet(wb, "CFA_Lambda_std")
writeData(wb, "CFA_Lambda_std", as.data.frame(lambda_std), rowNames = TRUE)

addWorksheet(wb, "CFA_Psi_std")
writeData(wb, "CFA_Psi_std", as.data.frame(psi_std), rowNames = TRUE)

addWorksheet(wb, "CFA_Reliability")
if (inherits(cfa_reliab, "error")) {
  writeData(wb, "CFA_Reliability", data.frame(Error = cfa_reliab$message))
} else {
  writeData(wb, "CFA_Reliability", data.frame(Output = capture.output(print(cfa_reliab))))
}

addWorksheet(wb, "SEM_Fit")
writeData(wb, "SEM_Fit", data.frame(Metric = names(sem_fit), Value = as.numeric(sem_fit)))

addWorksheet(wb, "SEM_Paths_Effects")
writeData(wb, "SEM_Paths_Effects", sem_paths)

addWorksheet(wb, "LPA_Fit")
writeData(wb, "LPA_Fit", lpa_fit)

addWorksheet(wb, "LPA_ProfileSizes")
writeData(wb, "LPA_ProfileSizes", profile_sizes)

addWorksheet(wb, "LPA_ProfileMeans")
writeData(wb, "LPA_ProfileMeans", profile_means)

addWorksheet(wb, "ANOVA")
writeData(wb, "ANOVA", data.frame(
  Test = c("ANOVA_WB_SL", "ANOVA_WB_EC"),
  Output = c(
    paste(capture.output(anova_WB_SL), collapse = "\n"),
    paste(capture.output(anova_WB_EC), collapse = "\n")
  )
))

saveWorkbook(wb, out_report, overwrite = TRUE)

# E) Final
cat("\n================== RESULTADOS ==================\n")
cat("✅ CFA Fit:\n")
print(cfa_fit)
cat("\n✅ SEM Fit:\n")
print(sem_fit)
cat("\n✅ LPA mejor K por BIC:", best_k, "\n\n")
cat("📄 Reporte guardado en:\n", out_report, "\n")
cat("🖼️ Plot LPA guardado en:\n", plot_path, "\n")
cat("✅ Archivo limpio guardado en:\n", clean_xlsx, "\n")
cat("================================================\n")
