# Guion del video (unos 9 minutos)

Cada integrante graba **un solo audio continuo** con su parte, leyendo los párrafos seguidos y haciendo una pausa de dos segundos entre párrafo y párrafo. Esas pausas marcan los cambios de escena del video.

## Cómo grabar

- **Un archivo por persona:** `1_acosta.mp3`, `2_medina.mp3` y `3_ocampo.mp3`. Sirven mp3, m4a, wav u ogg.
- **Ambiente:** un lugar silencioso, con el micrófono a un palmo de la boca y ritmo pausado.
- **Errores:** si alguien se equivoca, puede hacer una pausa y repetir la frase. Yo corto el error al editar.
- **Pronunciación:** "Neon" se dice *nión*, "Render" se dice *rénder* y "deploy hook" se dice *diplói juk*.

---

## Santiago Acosta López (1_acosta): Presentación, plataformas y arquitectura

*En pantalla: la portada del repositorio en GitHub.*

> Hola, somos Santiago Acosta López, Santiago Medina Varón y Julián Ocampo Millán, y este es nuestro taller de despliegue de aplicaciones en la nube del Laboratorio DevOps. Trabajamos en la modalidad A, con la aplicación base del profesor: el Observatorio de Lluvias y Eventos de Manizales. Es una aplicación web para registrar precipitaciones, incidentes de tráfico y deslizamientos, y ver un resumen diario. Tiene un frontend en React con Vite, una API REST en Spring Boot con Java diecisiete y una base de datos PostgreSQL. Nuestro objetivo fue publicarla en tres ambientes separados, desarrollo, QA y producción, con un pipeline que pruebe, despliegue y controle la promoción entre ambientes.

*En pantalla: la tabla "Ambientes desplegados" del README.*

> Elegimos Firebase como plataforma principal. Firebase Hosting publica el frontend, pero no ejecuta una API en Java ni una base de datos SQL, así que lo combinamos con dos servicios más. La API corre en Render, como contenedor Docker, y la base de datos es PostgreSQL administrado en Neon. Todo el código está en GitHub y el pipeline corre en GitHub Actions. Como resultado tenemos tres URLs de aplicación y tres URLs de API, una por ambiente, todas con HTTPS. Los tres servicios los usamos en su plan gratuito y sin tarjeta de crédito.

*En pantalla: el diagrama de `docs/ARQUITECTURA.md`.*

> Este es el diagrama de arquitectura. El equipo hace push a GitHub, y eso dispara GitHub Actions. El pipeline prueba el frontend y el backend; si todo pasa, despliega la API en Render y el frontend en Firebase. La clave está en el aislamiento: cada ambiente tiene su propio sitio en Firebase, su propio servicio en Render y su propia rama de base de datos en Neon. El frontend de desarrollo solo habla con la API de desarrollo, y esa API solo se conecta a la base de datos de desarrollo. Lo mismo pasa en QA y en producción. Así, un dato de prueba en QA nunca llega a producción.

---

## Santiago Medina Varón (2_medina): Infraestructura, seguridad y pipeline

*En pantalla: la consola de Neon con las tres ramas y luego Render con los tres servicios en Live.*

> Ahora la infraestructura. En Neon creamos un proyecto con tres ramas, dev, qa y production. Cada rama es una base de datos independiente, con su propio endpoint y sus propias credenciales. En Render creamos tres servicios web a partir del Dockerfile del backend: uno para desarrollo, otro para QA y otro para producción. Cada servicio tiene en sus variables de entorno la conexión a su rama de Neon. Le desactivamos el despliegue automático a Render: la API solo se actualiza cuando el pipeline lo ordena, después de pasar las pruebas.

*En pantalla: Firebase Hosting con los tres sitios y luego `firebase.json` y `.firebaserc`.*

> En Firebase usamos un solo proyecto con tres sitios de Hosting. En el archivo punto firebaserc cada sitio queda asociado a un target, dev, qa y prod, y el pipeline despliega con firebase deploy solo al target que corresponde. El frontend necesita saber a qué API llamar, así que el pipeline lo construye con la variable VITE API URL apuntando a la API de su ambiente. Del otro lado, cada API tiene configurado CORS para aceptar únicamente peticiones del dominio de su propio frontend.

*En pantalla: GitHub, Settings, Environments, y luego la tabla de seguridad de `docs/SERVICIOS_SEGURIDAD_COSTOS.md`.*

> En el repositorio no hay ninguna contraseña, token ni clave. Los secretos están en GitHub Secrets y en las variables de entorno de Render. En GitHub creamos tres environments. Cada uno guarda su propio deploy hook de Render, así que un despliegue de desarrollo no puede tocar producción. Para Firebase usamos una cuenta de servicio dedicada: el pipeline escribe su clave en un archivo temporal y lo borra al terminar. Además, la base de datos no está expuesta al público, solo las APIs se conectan a ella, por una conexión cifrada con TLS.

*En pantalla: el archivo `pipeline.yml` y luego el grafo de un run en verde.*

> Este es el pipeline. Tiene dos jobs de pruebas que corren en paralelo. El del frontend instala dependencias, ejecuta las pruebas con Vitest y construye. El del backend ejecuta las pruebas con Maven y empaqueta el jar. Si cualquiera falla, el pipeline se detiene y no despliega nada. Si pasan, el job de despliegue llama al deploy hook de Render y espera hasta que la API reporte el commit nuevo en su endpoint de info. Luego construye y publica el frontend en Firebase, y al final corre las pruebas de humo. La rama develop despliega a desarrollo, la rama qa a QA y la rama main a producción.

---

## Julián Ocampo Millán (3_ocampo): Operación, aprobación, costos y cierre

*En pantalla: el run de DEV en verde y la aplicación de desarrollo abierta.*

> Ahora vamos con la operación. Cuando hacemos push a la rama develop, el pipeline despliega automáticamente en desarrollo. Aquí se ve la ejecución en verde y la aplicación de desarrollo funcionando. Al terminar, el pipeline corre las pruebas de humo, que verifican cuatro cosas: que la API responda saludable, que consulte la base de datos, que el frontend publicado apunte a su propia API y que CORS acepte su dominio. Precisamente en este ambiente el pipeline nos detectó un defecto: las pruebas del frontend fallaban por una configuración de Vitest. Lo corregimos y volvimos a desplegar.

*En pantalla: el pull request de develop a qa, luego la app de QA con un registro de lluvia y el resumen de desarrollo en cero.*

> Para pasar a QA abrimos un pull request de develop hacia qa. El pipeline vuelve a correr las pruebas sobre el pull request, y solo con esas pruebas en verde hacemos el merge, que despliega en QA. En QA hicimos la prueba de aceptación: registramos una precipitación de doce punto cinco milímetros y apareció en el resumen de QA. Al revisar desarrollo y producción, el registro no aparece. Esto demuestra que las bases de datos de los ambientes están realmente aisladas.

*En pantalla: el run de PDN esperando aprobación, el diálogo Review deployments y luego el run en verde con la tabla "Despliegue exitoso".*

> Para llegar a producción abrimos un pull request de qa hacia main. Al hacer el merge, el pipeline prueba otra vez, pero el despliegue a producción no arranca solo: el environment production exige la aprobación de un revisor, y ni siquiera un administrador puede saltársela. El revisor aprueba con un comentario, que queda registrado. Después se despliega y se corren las pruebas de humo. Al final, el pipeline deja un registro con el ambiente, la rama, el commit, el autor y las URLs, y la API de producción muestra en su endpoint de info el commit exacto que está publicado.

*En pantalla: la sección de rollback del README, la tabla de costos y luego `docs/LIMPIEZA.md`.*

> Si una versión falla, la forma recomendada de revertirla es un git revert promovido por el mismo pipeline. En una urgencia también se puede volver a la versión anterior desde el historial de Firebase o con el botón de rollback de Render. En costos, hoy el proyecto cuesta cero dólares, porque todo está en planes gratuitos y sin tarjeta asociada. Solo generaría cargos si se activaran planes pagos, por ejemplo unos veintiún dólares al mes por las tres APIs en Render. Al terminar el curso seguiremos el procedimiento de limpieza: revocar los secretos y la clave de la cuenta de servicio, y borrar los servicios de Render, el proyecto de Neon y los sitios de Firebase.

*En pantalla: las tres aplicaciones, una al lado de la otra, y al final la portada del repositorio.*

> En resumen, tenemos la aplicación publicada en tres ambientes aislados, cada uno con su URL, su API y su base de datos. El pipeline detiene cualquier despliegue si fallan las pruebas, y para llegar a producción exige una aprobación explícita y deja registro de cada versión. Aprendimos que una plataforma de hosting sola no resuelve toda la arquitectura, que separar bien la configuración y los secretos por ambiente es lo que hace confiable la promoción, y que las pruebas automáticas atrapan defectos antes de que lleguen a producción. Todo está documentado en el repositorio. Gracias.
