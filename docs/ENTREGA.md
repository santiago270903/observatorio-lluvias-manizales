# Formato de entrega del equipo

## Tres ambientes y tres URLs

| Ambiente | URL de la aplicación | URL de la API | Estado |
|---|---|---|---|
| DEV | https://observatorio-lluvias-dev.web.app | https://observatorio-api-dev.onrender.com | Validado el 25/10/2026: pruebas de humo OK |
| QA | https://observatorio-lluvias-qa.web.app | https://observatorio-api-qa.onrender.com | Validado el 25/10/2026: pruebas de humo y de aceptación OK |
| PDN / Producción | https://observatorio-lluvias-manizales.web.app | https://observatorio-api-prod.onrender.com | Validado el 25/10/2026: aprobación manual y pruebas de humo OK |

## Sección 9 del taller

| Campo | Respuesta del equipo |
|---|---|
| Integrantes | Santiago Acosta López, Santiago Medina Varón y Julián Ocampo Millán |
| Modalidad | Aplicación base (Modalidad A) |
| Plataforma principal | Firebase Hosting para el frontend, con un pipeline en GitHub Actions. La API está en Render y la base de datos en Neon. |
| Repositorio | https://github.com/santiago270903/observatorio-lluvias-manizales |
| URL DEV | https://observatorio-lluvias-dev.web.app |
| URL QA | https://observatorio-lluvias-qa.web.app |
| URL PDN/Producción | https://observatorio-lluvias-manizales.web.app |
| API DEV / QA / PDN | https://observatorio-api-dev.onrender.com · https://observatorio-api-qa.onrender.com · https://observatorio-api-prod.onrender.com |
| Base de datos y estrategia de persistencia | Neon, un PostgreSQL administrado *serverless*. Un proyecto tiene tres ramas aisladas (`dev`, `qa` y `production`), y cada una tiene su propio *endpoint*, sus credenciales y sus datos. Cada API de Render se conecta solo a su rama, por JDBC con TLS. Las credenciales están en las variables de entorno de Render, nunca en el repositorio. Hibernate crea el esquema al iniciar. La base de datos no se expone públicamente: se valida a través de la API o de la consola de Neon. Detalle en [Arquitectura](ARQUITECTURA.md#estrategia-de-persistencia). |
| Pipeline | Workflow: https://github.com/santiago270903/observatorio-lluvias-manizales/blob/main/.github/workflows/pipeline.yml. Ejecuciones: DEV https://github.com/santiago270903/observatorio-lluvias-manizales/actions/runs/40248546705 · QA https://github.com/santiago270903/observatorio-lluvias-manizales/actions/runs/40249947009 · PDN, con aprobación, https://github.com/santiago270903/observatorio-lluvias-manizales/actions/runs/40250622140 |
| Video | Enlace de Google Drive incluido en el informe de entrega (Word) |
| Costos y limpieza | Hoy el costo es 0 USD: Firebase Spark, Render Free, Neon Free y GitHub con repositorio público, todo sin tarjeta asociada. Podrían generar cargos solo si se activan planes pagos: Firebase Blaze, instancias Starter de Render (unos 21 USD/mes por los 3 ambientes) y los planes pagos de Neon. Plan de eliminación: revocar los secretos de GitHub y la clave de la cuenta de servicio, borrar los 3 servicios de Render, borrar el proyecto de Neon y desactivar los sitios o borrar el proyecto de Firebase. Ver [costos](SERVICIOS_SEGURIDAD_COSTOS.md) y [limpieza](LIMPIEZA.md). |

## Evidencias capturadas

- Consola de Neon con las tres ramas.
- Render con los tres servicios en estado *Live*.
- Firebase Hosting con los tres sitios.
- *Environments* de GitHub, con el revisor obligatorio en `production`.
- Ejecuciones del pipeline:
  - DEV;
  - QA;
  - PDN esperando aprobación;
  - PDN aprobado y en verde;
  - resumen "Registro del despliegue".
- Prueba de aceptación en QA: se creó un registro de 12,5 mm y apareció en el resumen de QA pero no en el de DEV ni en el de PDN, lo que demuestra el aislamiento.
