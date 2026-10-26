# Guion del video (8 a 10 minutos)

Recomendaciones:

- Grabar la pantalla con OBS o con la herramienta de captura de Windows (`Win + Alt + R`).
- Subir el video a YouTube como "No listado" o a Google Drive con acceso "Cualquier persona con el enlace".
- Pegar el enlace en [ENTREGA.md](ENTREGA.md).

**Antes de grabar**, abrir las tres URLs de la API para "despertar" los servicios de Render, que tardan alrededor de un minuto la primera vez.

| Min | Quién | Qué mostrar | Qué decir |
|---|---|---|---|
| 0:00 | Santiago Acosta | Portada del README | Presentar al equipo, la modalidad A, la aplicación del observatorio y la plataforma (Firebase + Render + Neon + GitHub Actions). |
| 0:45 | Santiago Acosta | El diagrama en `docs/ARQUITECTURA.md` | Explicar las tres capas y los tres ambientes aislados, y por qué Firebase solo aloja el frontend y la API va en Render. |
| 2:00 | Santiago Medina | Firebase Console (3 sitios), Render (3 servicios Live) y Neon (3 ramas) | Mostrar que cada ambiente tiene recursos separados. Mostrar las variables de Render sin revelar valores, por ejemplo con la contraseña oculta. |
| 3:30 | Santiago Medina | `pipeline.yml` y GitHub → Settings → Environments | Explicar los jobs, que un fallo detiene el despliegue, los secretos por ambiente y el revisor obligatorio en `production`. |
| 4:30 | Julián Ocampo | **En vivo:** un cambio pequeño en `develop` (por ejemplo un texto del README) y su push | Mostrar el run de DEV: pruebas, *deploy hook*, espera de la API, Firebase y smoke tests. |
| 6:00 | Julián Ocampo | PR `develop → qa`, merge y run de QA. En la app de QA, registrar una precipitación. | La prueba de aceptación: el registro aparece en QA y no en DEV ni en PDN. |
| 7:15 | Santiago Acosta | PR `qa → main` y el run esperando → **Review deployments → Approve** | La aprobación explícita, y luego el despliegue y los smoke tests de PDN. |
| 8:15 | Santiago Acosta | `/actuator/info` de PDN y el resumen "Registro del despliegue" | Explicar el registro de versión: el commit desplegado. |
| 8:45 | Santiago Medina | `docs/SERVICIOS_SEGURIDAD_COSTOS.md` y `docs/LIMPIEZA.md` | Explicar las medidas de seguridad, que el costo actual es 0 USD, qué generaría cargos y cómo se eliminan los recursos. Mencionar el rollback descrito en el README. |
| 9:30 | Todos | — | Cierre y lecciones aprendidas, por ejemplo el defecto de `test-setup.js` detectado por el pipeline. |

Si el despliegue en vivo tarda (Render construye en unos 3 a 5 minutos), se puede cortar la espera en la edición o mostrar un run previo ya terminado.
