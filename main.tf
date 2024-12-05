terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.0"
    }
  }
}

# Proveedor Docker
provider "docker" {
  host = "unix:///var/run/docker.sock" # Ruta al socket de Docker
}

# Red Docker
resource "docker_network" "jenkins_network" {
  name = "jenkins" # Nombre de la red
}

# Imagen Docker in Docker (DinD)
resource "docker_image" "dind" {
  name = "docker:dind" # Imagen oficial de DinD
}

# Imagen personalizada de Jenkins
resource "docker_image" "jenkins" {
  name = "myjenkins-blueocean" # Nombre de la imagen personalizada

  # Construcción de la imagen personalizada
  build {
    context    = "./jenkins"      # Carpeta donde está el Dockerfile
    dockerfile = "Dockerfile"     # Nombre del Dockerfile
  }
}

# Contenedor Docker in Docker (DinD)
resource "docker_container" "dind" {
  name  = "jenkins-docker"
  image = docker_image.dind.latest # Imagen creada anteriormente

  privileged = true # Permite al contenedor usar características avanzadas

  networks_advanced {
    name    = docker_network.jenkins_network.name # Conecta a la red
    aliases = ["docker"]                          # Alias en la red
  }

  # Variables de entorno
  env = [
    "DOCKER_TLS_CERTDIR=/certs"
  ]

  # Montaje de volúmenes
  volumes {
    host_path      = "jenkins-docker-certs"
    container_path = "/certs/client"
  }
  volumes {
    host_path      = "jenkins-data"
    container_path = "/var/jenkins_home"
  }

  # Puertos expuestos
  ports {
    internal = 2376 # Puerto interno
    external = 2376 # Puerto expuesto
  }
}

# Contenedor Jenkins personalizado
resource "docker_container" "jenkins" {
  name  = "jenkins-blueocean"
  image = docker_image.jenkins.latest # Imagen personalizada de Jenkins

  restart = "on-failure" # Reinicia si falla

  networks_advanced {
    name = docker_network.jenkins_network.name # Conecta a la red
  }

  # Variables de entorno
  env = [
    "DOCKER_HOST=tcp://docker:2376",       # Dirección del demonio Docker
    "DOCKER_CERT_PATH=/certs/client",      # Ruta de los certificados
    "DOCKER_TLS_VERIFY=1"                  # Activa verificación TLS
  ]

  # Montaje de volúmenes
  volumes {
    host_path      = "jenkins-data"
    container_path = "/var/jenkins_home"
  }
  volumes {
    host_path      = "jenkins-docker-certs"
    container_path = "/certs/client:ro" # Solo lectura
  }

  # Puertos expuestos
  ports {
    internal = 8080 # Puerto interno HTTP
    external = 8080 # Puerto expuesto HTTP
  }
  ports {
    internal = 50000 # Puerto interno para agentes Jenkins
    external = 50000 # Puerto expuesto para agentes Jenkins
  }
}
