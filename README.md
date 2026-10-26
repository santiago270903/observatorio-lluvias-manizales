# Observatorio de Lluvias y Eventos de Manizales

Aplicación de demostración para el taller del Laboratorio DevOps (Universidad de Caldas). Incluye un frontend React + Vite, una API REST Spring Boot y una base de datos PostgreSQL. Está desplegada en tres ambientes aislados (DEV, QA y PDN) con un pipeline CI/CD en GitHub Actions.

**Equipo:** Santiago Acosta López, Santiago Medina Varón y Julián Ocampo Millán. **Modalidad:** A, con la aplicación base del docente.

> Los datos son ficticios y sirven únicamente para pruebas académicas. No es un sistema oficial de alertas ni debe usarse para decisiones de emergencia.

## Ambientes desplegados

| Ambiente | Rama | Aplicación (Firebase Hosting) | API (Render) | Base de datos (Neon) |
|---|---|---|---|---|
| DEV | `develop` | https://observatorio-lluvias-dev.web.app | https://observatorio-api-dev.onrender.com | rama `dev` |
| QA | `qa` | https://observatorio-lluvias-qa.web.app | https://observatorio-api-qa.onrender.com | rama `qa` |
| PDN | `main` | https://observatorio-lluvias-manizales.web.app | https://observatorio-api-prod.onrender.com | rama `production` |

Cada API expone:

- la salud del servicio en `/actuator/health`;
- el commit desplegado en `/actuator/info`;
- el resumen del día en `/api/dashboard/summary`.

Las APIs están en el plan gratuito de Render. Se suspenden tras 15 minutos sin tráfico, así que la primera petición después de una pausa puede tardar cerca de un minuto.

## Documentación

- [Arquitectura](docs/ARQUITECTURA.md): diagrama, componentes, flujos y estrategia de persistencia.
- [Servicios, seguridad y costos](docs/SERVICIOS_SEGURIDAD_COSTOS.md).
- [Desactivación y eliminación de recursos](docs/LIMPIEZA.md).
- [Formato de entrega del equipo](docs/ENTREGA.md), que corresponde a la sección 9 del taller.
- [Guion del video](docs/GUION_VIDEO.md).

## Componentes

| Ruta | Contenido |
|---|---|
| `frontend/` | React + Vite: el dashboard y los formularios. |
| `backend/` | Java 17, Spring Boot 3 y Spring Data JPA. Render lo construye con su `Dockerfile`. |
| `firebase.json` y `.firebaserc` | Los tres sitios de Firebase Hosting, uno por ambiente, asociados a los targets `dev`, `qa` y `prod`. |
| `.github/workflows/pipeline.yml` | El pipeline CI/CD. |
| `scripts/wait-for-api.sh` | Espera a que Render publique en la API el commit que se está desplegando. |
| `scripts/smoke-test.sh` | Pruebas de humo de un ambiente desplegado. |
| `docker-compose.yml` | PostgreSQL, API y frontend para ejecutar en local. |
| `Jenkinsfile` y `deploy.sh.example` | La plantilla de referencia del docente. El equipo usa GitHub Actions como orquestador; ver [Arquitectura](docs/ARQUITECTURA.md#por-qué-github-actions-y-no-jenkins). |

## Pipeline CI/CD

El archivo [`.github/workflows/pipeline.yml`](.github/workflows/pipeline.yml) define el pipeline. Cada evento produce lo siguiente:

| Evento | Qué hace | Destino |
|---|---|---|
| Push a `develop` | Pruebas, build y despliegue | DEV |
| Pull request a `qa` o `main` | Solo pruebas y build, como validación previa al merge | — |
| Merge (push) a `qa` | Pruebas, build y despliegue | QA |
| Merge (push) a `main` | Pruebas, build, **aprobación manual** y despliegue | PDN |

Pasos del pipeline:

1. **Frontend:** `npm ci`, `npm test` (Vitest) y `npm run build`.
2. **Backend:** `mvn test` y `mvn package`. El jar se publica como artefacto del run.
3. **Despliegue:** solo corre si los dos jobs anteriores pasan; un fallo en compilación o pruebas detiene el pipeline.
   1. Llama al *deploy hook* de Render del ambiente.
   2. Espera hasta que `/actuator/info` reporte el commit del run.
   3. Construye el frontend con `VITE_API_URL` apuntando a la API del ambiente.
   4. Lo publica con `firebase deploy --only hosting:<target>`.
   5. Ejecuta las [pruebas de humo](scripts/smoke-test.sh).
4. **Registro:** el resumen del run guarda el ambiente, la rama, el commit, el autor y las URLs.

**Aprobación de PDN.** El ambiente `production` de GitHub tiene un revisor obligatorio (`santiago270903`) y no permite saltarse la aprobación. El job de PDN queda en espera (*Waiting*) hasta que alguien pulse **Review deployments → Approve and deploy**. El comentario de aprobación queda registrado en el run.

### Promover una versión

```bash
# 1. Trabajar en develop: el push despliega en DEV
git switch develop
git push origin develop

# 2. DEV → QA: abrir un pull request develop → qa, revisar que las pruebas pasen y hacer merge
gh pr create --base qa --head develop --title "Promover a QA"

# 3. QA → PDN: después de las pruebas de aceptación en QA, PR qa → main, merge y aprobar el despliegue
gh pr create --base main --head qa --title "Promover a PDN"
```

### Revertir una versión (rollback)

| Situación | Procedimiento |
|---|---|
| Opción recomendada para cualquier ambiente | Hacer `git revert <commit>` en la rama del ambiente o en `develop` y promoverlo. Así el pipeline vuelve a probar, desplegar y registrar la versión anterior. |
| Urgencia en el frontend | Firebase Console → Hosting → el sitio del ambiente → *Historial de versiones* → en la versión anterior, **Revertir**. Es inmediato. |
| Urgencia en la API | Render → el servicio → *Events* → en el deploy anterior, **Rollback**. |

Después de un rollback manual, la rama de Git queda adelantada respecto de lo desplegado. Se debe corregir con `git revert` para que el siguiente despliegue no reintroduzca el defecto.

### Variables y secretos (sin valores)

| Dónde | Nombre | Uso |
|---|---|---|
| GitHub → *Environments* `dev`, `qa` y `production` | `RENDER_DEPLOY_HOOK` | URL privada del *deploy hook* del servicio de Render del ambiente. |
| GitHub → *Repository secrets* | `FIREBASE_SERVICE_ACCOUNT` | JSON de la cuenta de servicio `github-deploy`. El pipeline lo escribe en un archivo temporal que borra al terminar. |
| Render, en cada servicio | `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD` | Conexión a la rama de Neon del ambiente. |
| Render, en cada servicio | `APP_CORS_ORIGINS` | Orígenes permitidos: los dominios `.web.app` y `.firebaseapp.com` del frontend del mismo ambiente. |
| Build del frontend, lo define el pipeline | `VITE_API_URL` | URL de la API del ambiente. No es secreta: queda dentro del JavaScript publicado. |

Ninguna credencial está en el repositorio.

### Defecto corregido durante el despliegue

Las pruebas del frontend fallaban con `expect is not defined`. El archivo `frontend/src/test-setup.js` importaba `@testing-library/jest-dom`, que espera un `expect` global, pero Vitest no lo define por defecto. Se cambió a `@testing-library/jest-dom/vitest`.

## Ejecutar localmente con Docker
Requisitos: Docker Desktop y Docker Compose.

```bash
docker compose up --build
```
- Frontend: http://localhost:5173
- API: http://localhost:8080/api/dashboard/summary
- Health: http://localhost:8080/actuator/health

Para detener:
```bash
docker compose down
```
Para borrar también la base de datos local:
```bash
docker compose down -v
```

## Ejecutar sin Docker
### Backend
Requisitos: Java 17+, Maven 3.9+, PostgreSQL 15+.
Configurar variables `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD` y ejecutar:
```bash
cd backend
mvn spring-boot:run
```

### Frontend
Requisitos: Node.js 20+.
```bash
cd frontend
npm install
npm run dev
```
Por defecto, Vite usa `http://localhost:8080` como API. Para otro destino, crear `frontend/.env.local`:
```env
VITE_API_URL=http://localhost:8080
```

## Funcionalidades
- Registrar precipitación en milímetros por fecha y sector.
- Consultar registros de lluvia y acumulado diario.
- Registrar incidentes de congestión vehicular.
- Registrar reportes de deslizamientos.
- Ver resumen diario: lluvia acumulada, cantidad de incidentes y deslizamientos.
- Filtrar listados por fecha.

## Unidades
Se almacena precipitación en mm. El volumen estimado en litros solo se calcula si se proporciona el área de referencia en m²:
`litros_estimados = precipitación_mm × área_m²`.
No se debe presentar el resultado como volumen real de toda Manizales sin definir el área y la metodología.

## Seguridad antes de publicar
Este repositorio es una base académica, no una solución de producción endurecida. Antes de exponerla:
- Añadir autenticación/autorización para crear, editar y eliminar reportes.
- Usar HTTPS y secretos administrados por el proveedor.
- Configurar CORS con orígenes permitidos específicos.
- Configurar backups, límites de recursos y alertas de costos.
- No abrir PostgreSQL a Internet.
