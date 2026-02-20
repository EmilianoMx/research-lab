# Datos necesarios para agrupar código por proyecto de investigación

Si quieres subir más pipelines como este y mantener todo ordenado por proyecto, estos son los datos mínimos que necesito por cada nuevo proyecto.

## 1) Identificación del proyecto
- **Nombre corto del proyecto:** ej. `EPOGOB-IA`
- **Título formal:** nombre académico completo
- **Estado:** borrador / en análisis / publicado
- **Persona responsable:** nombre + ORCID (si aplica)

## 2) Objetivo científico
- **Pregunta de investigación** (1–3 líneas)
- **Hipótesis principales**
- **Tipo de estudio:** transversal, longitudinal, experimental, etc.

## 3) Datos de entrada
- **Formato(s) de entrada:** `.xlsx`, `.csv`, etc.
- **Diccionario mínimo de variables:**
  - nombre columna original
  - tipo (Likert, numérica, categórica)
  - rango esperado (ej. 1–5)
- **Criterios de calidad de entrada:** mínimos de N, faltantes máximos permitidos

## 4) Pipeline analítico
- **Script principal** (ruta y nombre)
- **Orden de análisis** (ej. limpieza → CFA → SEM → LPA)
- **Parámetros críticos** (estimador, número de clases, criterios de selección)

## 5) Salidas esperadas
- **Archivos de salida** (nombres exactos)
- **Métricas clave que se reportan** (CFI/TLI/RMSEA/SRMR, BIC, etc.)
- **Carpeta de resultados** estándar

## 6) Reproducibilidad
- **Versión de R**
- **Paquetes y versión recomendada**
- **Comando de ejecución paso a paso** para usuarios no programadores

## 7) Gobernanza y trazabilidad
- **Licencia de uso de datos/código**
- **Restricciones éticas o privacidad**
- **Cómo citar el proyecto**

---

## Plantilla rápida para nuevos proyectos

Copia y completa:

```text
Proyecto:
Título formal:
Responsable:
Estado:

Pregunta:
Hipótesis:
Tipo de estudio:

Entradas (formatos):
Variables clave:
Reglas de calidad:

Script principal:
Pipeline:
Parámetros críticos:

Salidas esperadas:
Métricas clave:
Carpeta de resultados:

R versión:
Paquetes:
Ejecución paso a paso:

Ética/privacidad:
Citación:
```
