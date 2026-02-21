# Roadmap 30/30 — Parte 1/30
# Boot Modal + modo Chat/Agente + rol/objetivo + fast mode
#
# Uso:
# 1) Copia los bloques dentro de tu app Shiny, idealmente en server().
# 2) Si ya tienes `%||%` (p. ej. de rlang/shiny), elimina la definición local.

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0) y else x
}

# 1) Reactive values (al inicio de server())
mode <- shiny::reactiveVal("agent")       # "chat" | "agent"
agent_role <- shiny::reactiveVal("")
agent_goal <- shiny::reactiveVal("")
fast_mode <- shiny::reactiveVal(TRUE)

# 2) Funciones (parte 3 sugerida)
agent_charter_q1_biz <- function(role_txt, goal_txt, mode_txt) {
  paste(
    "Eres un AGENTE ANALISTA DE DATOS CIENTÍFICO (nivel Q1 internacional) y ESTRATEGA DE NEGOCIO.",
    "",
    "MODO:", mode_txt,
    "",
    "OBJETIVO DUAL:",
    "A) Investigación Q1: análisis robustos, reproducibles, inferenciales/predictivos, con estándares publicables.",
    "B) Empresa: convertir hallazgos en decisiones, eficiencia, riesgos, oportunidades y ROI.",
    "",
    "CONDUCTA:",
    "- Mantén el hilo: memoria resumida + ventana deslizante.",
    "- Responde por pasos, con supuestos explícitos cuando falte info.",
    "- Si piden REPORTE WOW: genera resumen ejecutivo + tablas + gráficos + recomendaciones.",
    "",
    "ROL DEL AGENTE:", role_txt,
    "",
    "QUÉ DESEAMOS OBTENER:", goal_txt,
    sep = "\n"
  )
}

build_system_prompt <- function(agent_cfg) {
  mode_txt <- if ((agent_cfg$mode %||% "agent") == "chat") "Chat normal" else "Agente"
  agent_charter_q1_biz(agent_cfg$role %||% "", agent_cfg$goal %||% "", mode_txt)
}

# 3) Modal de inicio (dentro de server())
shiny::observeEvent(TRUE, {
  shiny::showModal(shiny::modalDialog(
    title = "Inicio 2050 — Configura tu modo",
    shiny::radioButtons(
      "startup_mode",
      "Modo:",
      choices = c("Chat normal" = "chat", "Agente Q1+Empresa" = "agent"),
      selected = "agent"
    ),
    shiny::textInput(
      "startup_role",
      "Qué queremos que sea (rol):",
      value = "Analista científico Q1 + Business Intelligence"
    ),
    shiny::textAreaInput(
      "startup_goal",
      "Qué deseamos obtener (objetivo/entregables):",
      height = "100px",
      value = paste0(
        "Quiero análisis avanzados (Q1) + aportaciones a la empresa, y opción de REPORTE WOW ",
        "con tablas, gráficos, conclusiones, conjeturas marcadas y recomendaciones."
      )
    ),
    shiny::checkboxInput(
      "startup_fast",
      "Modo rápido (latencia baja, no pierde el hilo)",
      value = TRUE
    ),
    footer = shiny::tagList(
      shiny::actionButton("startup_go", "Comenzar", class = "btn btn-primary")
    ),
    easyClose = FALSE
  ))
}, once = TRUE)

shiny::observeEvent(input$startup_go, {
  mode(input$startup_mode)
  agent_role(input$startup_role)
  agent_goal(input$startup_goal)
  fast_mode(isTRUE(input$startup_fast))
  shiny::removeModal()

  # crea conversación nueva con system prompt dinámico
  conv <- new_conversation(title = paste0("Chat ", format(Sys.time(), "%Y-%m-%d %H:%M")))
  conv$agent <- list(mode = mode(), role = agent_role(), goal = agent_goal(), fast = fast_mode())
  conv$messages[[1]] <- make_system_message(build_system_prompt(conv$agent))

  current(conv)
  save_conversation(conv)
  refresh_index()
  shiny::updateSelectInput(session, "conv_select", selected = conv$id)
}, ignoreInit = TRUE)
