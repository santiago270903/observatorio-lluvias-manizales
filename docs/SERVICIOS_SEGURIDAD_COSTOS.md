# Servicios, seguridad y costos

## Servicios utilizados

| Servicio | Uso | Plan | Recursos creados |
|---|---|---|---|
| GitHub | Repositorio y GitHub Actions (CI/CD) | Free, repositorio público | El repositorio, tres *Environments* y los secretos. |
| Firebase Hosting | Frontend estático con HTTPS y CDN | Spark, sin tarjeta | El proyecto `observatorio-lluvias-manizales` y tres sitios. |
| Google Cloud IAM | Autenticación del pipeline ante Firebase | Sin costo | La cuenta de servicio `github-deploy` y una clave JSON. |
| Render | API Spring Boot en contenedor Docker | Free, sin tarjeta | Tres Web Services: `observatorio-api-dev`, `-qa` y `-prod`. |
| Neon | PostgreSQL administrado | Free, sin tarjeta | El proyecto `observatorio-lluvias` con las ramas `production`, `qa` y `dev`. |

## Configuración de seguridad

| Aspecto | Medida aplicada |
|---|---|
| Secretos fuera del código | No hay contraseñas, *tokens*, claves ni *deploy hooks* en el repositorio. Viven en *GitHub Secrets* y en las variables de entorno de Render, y el pipeline los enmascara en los logs. |
| Secretos por ambiente | Cada *Environment* de GitHub tiene su propio `RENDER_DEPLOY_HOOK`, así que un job de DEV no puede desplegar PDN. |
| Credencial de Firebase en CI | Es una cuenta de servicio dedicada (`github-deploy`). Su JSON se escribe en un archivo temporal del runner y se borra al terminar el paso (`trap`). |
| Aprobación de producción | El *Environment* `production` exige un revisor y no permite que un administrador se salte la regla. Solo la rama `main` despliega a PDN. |
| Despliegue solo desde el pipeline | Render tiene *Auto-Deploy* apagado, así que un push no publica la API sin pasar antes las pruebas. |
| HTTPS | Firebase Hosting y Render sirven solo por HTTPS con certificados administrados. La conexión de la API a Neon usa TLS. |
| CORS | Cada API acepta únicamente los dominios de su propio frontend (`APP_CORS_ORIGINS`). La de DEV también acepta `http://localhost:5173` para desarrollo local. |
| Base de datos privada | Neon solo se usa desde las APIs. Las credenciales son distintas por rama y la URL de la base de datos no se publica. |
| Superficie de Actuator | Solo se exponen `health` e `info`; `info` muestra únicamente el commit desplegado. |
| Pendiente (fuera del alcance) | **Autenticación de la API.** Cualquiera puede crear o eliminar registros. En un sistema real se añadiría autenticación, por ejemplo Firebase Auth con JWT validado en Spring Security. |
| Pendiente (fuera del alcance) | **Mínimo privilegio en Firebase.** La cuenta `github-deploy` tiene el rol *Administrador de Firebase*; bastaría con *Administrador de Firebase Hosting*. |

## Costos potenciales

Hoy el costo es **0 USD**: todos los servicios están en planes gratuitos y ninguno tiene una tarjeta asociada, así que no pueden generar cobros automáticos. La siguiente tabla indica qué podría generar cargos si el proyecto creciera o si alguien activara un plan pago.

| Servicio | Límite del plan gratuito | Qué pasa al superarlo | Costo si se pasa a plan pago (referencia) |
|---|---|---|---|
| Firebase Hosting (Spark) | 10 GB de almacenamiento y unos 360 MB/día de transferencia | El sitio deja de servir hasta el siguiente ciclo; no hay cobro. | Plan Blaze, pago por uso: se cobra el almacenamiento y la transferencia que excedan la cuota gratuita. Requiere tarjeta. |
| Render (Free) | 750 horas de instancia al mes por cuenta; el servicio se suspende tras 15 minutos sin tráfico | Los servicios quedan suspendidos hasta el siguiente mes; no hay cobro. | Instancia Starter, unos 7 USD/mes por servicio, es decir, unos 21 USD/mes por los tres ambientes. |
| Neon (Free) | 0,5 GB de almacenamiento por proyecto y horas de cómputo limitadas; el cómputo se suspende tras 5 minutos inactivo | La base de datos deja de aceptar escrituras o se suspende el cómputo; no hay cobro. | Planes pagos por uso, desde unos pocos USD al mes según cómputo y almacenamiento. |
| GitHub Actions | Ilimitado en repositorios públicos | — | Solo hay costo si el repositorio fuera privado y superara los minutos incluidos. |
| Cuenta de servicio de Google Cloud | — | — | Sin costo. El riesgo no es económico: es la exposición de la clave. Por eso se elimina al terminar. |

Los precios son de referencia y pueden cambiar; deben verificarse en las páginas de precios de cada proveedor antes de activar un plan pago. Las medidas de control de costos son estas:

- no asociar tarjetas;
- mantener *Auto-Deploy* apagado, para que no haya builds innecesarios en Render;
- usar caché de dependencias en el pipeline;
- seguir el [procedimiento de limpieza](LIMPIEZA.md) al terminar el curso.
