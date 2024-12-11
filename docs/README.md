# Entregable 3. Terraform, SCV, Jenkins.

- Una vez hacemos Fork al repositorio correspondiente, clonamos el repositorio remoto a un nuestro repositorio local (directorio/carpeta) con el comando:
 __git clone \<url del repositorio remoto\>__

- Creamos la rama main usando el siguiente comando de git bash: __git branch main__ y nos situamos en ella para trabajar con el comando: 
__git checkout main__ para actualizar los cambios en el repositorio remoto los publicamos directamente con el comando: __git push origin main__

- Con el Dockerfile, situado en la carpeta docs, construímos la imagen de jenkins personalizada para que trabaje con Docker, instalacion de plugins de jenkins.
Esto lo haremos con el comando: __docker build -t myjenkins-blueocean .__

- Creación del archivo de configuraión terraform, que creará y levantará los contenedores de Docker. Un contenedor para trabajar con Jenkins, y otro contenedor Docker in Docker, para lanzar nuestros despliegues. 
Este archivo de configuración se encuentra en la carpeta docs, y para ejecutarlo realizaremos los siguientes comandos:
__terraform init__
__terraform plan__
__terraform apply__
Estos comandos nos levantará los dos contenedores en la misma red.

- Podemos acceder a localhost:8080 y terminar con la instalación de Jenkins.

- Una vez tenemos Jenkins instalado correctamente y con la sesión iniciada, clickamos en __Nueva tarea__ en la parte superior izquierda de la pantalla.
Creamos el pipeline con el nombre que corresponda clickamos en continuar, nos desplazamos hacia abajo de la pagina siguiente a la parte que dice "Pipeline".
Pulsamos en "Definition" y seleccionamos la opción "Pipeline script from SCM", ahora clickamos sobre "SCM" y seleccionamos "Git", a continuación en "Repository url" ponemos el url de nuestro repositorio que hicimos Fork anteriormente.
Especificamos la rama main en "Branch Specifier" y por último configuramos donde tenemos alojado nuestro Jenkinsfile en el repositorio, en nuestro caso en la carpeta docs, pondremos en "Script Path" lo siguiente: "docs/Jenkinsfile". Esto lo que hará es leer el archivo Jenkinsfile situado en el repositorio remoto, dicho archivo tiene la configuración del pipeline.

- Una vez configurado el pipieline lo iniciamos, si nos fijamos en los logs mientras se ejecuta, descargará el artefacto Python correspondiente. 

- Para comprobar si todo esta correcto, pulsamos sobre el pipeline en el panel de control de Jenkins, al ver el estado del pipeline veremos el artefacto anteriormente mencionado.
