
#Configuraciones globales de terraform
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}
provider "docker" {}  #configura terraform para trabajar con docker 

# Crear una red para Jenkins
resource "docker_network" "jenkins" {
  name = "jenkins"
}

#Creación de volumenes para almacenar de manera persistente los datos de jenkins y los certificados TLS usados por docker:dind
resource "docker_volume" "jenkins_data" {
  name = "jenkins-data"
}

resource "docker_volume" "jenkins_certs" {
  name = "jenkins-docker-certs"
}


# Contenedor Docker in Docker con las intrucciones del comando docker run de la práctica
resource "docker_container" "jenkins_docker" {
  name  = "jenkins-docker"
  image = "docker:dind"
  privileged = true

  #Define la red creada arriba
  networks_advanced {
    name = docker_network.jenkins.name
    aliases = ["docker"]

  }

  #Monta el volumenes en la ruta correspondiente
  volumes {
    volume_name    = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name    = docker_volume.jenkins_certs.name
    container_path = "/certs/client"

  }

  #Expone el puerto correspondiente para el demonio docker 
  ports {
    internal = 2376
    external = 2376
  }

  env = [
    "DOCKER_TLS_CERTDIR=/certs",
  ]
}

# Contenedor Jenkins con Blue Ocean con las instrucciones y plugins del docker run de la práctica
resource "docker_container" "jenkins_blueocean" {
  name  = "jenkins-blueocean"
  image = "myjenkins-blueocean"
  restart = "on-failure"

  #indica que el contenedor se conecte a la red definida anteriormente
  networks_advanced {
    name = docker_network.jenkins.name
        aliases = ["docker"]

  }

  #expone el puerto 8080 para acceder a jenkins y trabajar
  ports {
    internal = 8080
    external = 8080
  }

  #para que se conecte con jenkins
  ports {
    internal = 50000
    external = 50000
  }

  env = [
    "DOCKER_HOST=tcp://docker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1",
  ]

  #Monta los volumenes anteriores 
  volumes {
    volume_name    = docker_volume.jenkins_data.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name    = docker_volume.jenkins_certs.name
    container_path = "/certs/client"
    read_only      = true
  }
}
