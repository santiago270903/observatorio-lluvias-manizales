# Desactivación y eliminación de recursos

Este procedimiento se ejecuta cuando el taller esté calificado. Se sigue en este orden para que ningún componente quede apuntando a otro que ya no existe y para revocar primero las credenciales.

## 1. Detener el pipeline y revocar credenciales

1. **GitHub → Settings → Actions → General.** Seleccionar *Disable actions*, o borrar `.github/workflows/pipeline.yml`.
2. **GitHub → Settings → Environments.** Eliminar `dev`, `qa` y `production`. Esto borra también los secretos `RENDER_DEPLOY_HOOK`.
3. **GitHub → Settings → Secrets and variables → Actions.** Eliminar `FIREBASE_SERVICE_ACCOUNT`.
4. **Google Cloud Console → IAM y administración → Cuentas de servicio.** En el proyecto `observatorio-lluvias-manizales`, abrir `github-deploy` → *Claves*, borrar la clave y luego eliminar la cuenta de servicio.

## 2. API (Render)

1. En cada servicio (`observatorio-api-dev`, `observatorio-api-qa` y `observatorio-api-prod`), ir a **Settings → Delete Web Service** y confirmar con el nombre. Al borrar el servicio se invalida su *deploy hook*.
2. Opcional: en **Account Settings → Git providers**, revocar el acceso de Render a GitHub, si se dio.

Si solo se quiere **desactivar** sin borrar, usar **Settings → Suspend Web Service**.

## 3. Base de datos (Neon)

1. Si se quieren conservar datos, exportarlos primero:

   ```bash
   pg_dump "<cadena de conexión de la rama>" > backup.sql
   ```

2. Ir a **Neon Console → proyecto `observatorio-lluvias` → Settings → Delete project**. Esto elimina las tres ramas, sus *endpoints* y sus credenciales.

## 4. Frontend (Firebase)

Hay dos opciones:

- **Solo desactivar.** Ejecutar `firebase hosting:disable --site <sitio> --project observatorio-lluvias-manizales` para cada sitio (`observatorio-lluvias-dev`, `observatorio-lluvias-qa` y `observatorio-lluvias-manizales`). Las URLs responden "Site Not Found" y el contenido se puede volver a publicar después.
- **Eliminar todo.** En **Firebase Console → Configuración del proyecto → General → Borrar proyecto**. Google mantiene el proyecto 30 días en estado pendiente de eliminación y después lo borra definitivamente, junto con los sitios y la cuenta de servicio.

## 5. Repositorio

- Archivar el repositorio en **GitHub → Settings → Archive this repository** si se quiere conservar como evidencia; queda en solo lectura.
- O eliminarlo en **Settings → Delete this repository**.

## 6. Local

```bash
docker compose down -v        # contenedores y volumen de PostgreSQL local
firebase logout               # cierra la sesión de la CLI
```

## Verificación final

- [ ] Las seis URLs públicas ya no responden o muestran "Site Not Found".
- [ ] Render no lista servicios en el *dashboard*.
- [ ] Neon no lista el proyecto.
- [ ] La cuenta de servicio `github-deploy` ya no existe, o el proyecto de Firebase está en eliminación.
- [ ] No quedan secretos en GitHub.
