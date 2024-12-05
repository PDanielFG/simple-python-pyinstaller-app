terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"  # Para Windows
}

# Crear una red de Docker para Jenkins
resource "docker_network" "jenkins_network" {
  name = "jenkins"
}

# Construir la imagen personalizada de Jenkins desde el Dockerfile
resource "docker_image" "jenkins_blueocean_image" {
  name         = "myjenkins-blueocean"
  build {
    context    = "."
    dockerfile = "Dockerfile"
  }
}
# Contenedor para Jenkins Docker-in-Docker (DIND)
resource "docker_container" "jenkins_docker" {
  name  = "jenkins-docker"
  image = "docker:dind"

  privileged = true
  restart    = "no"
  networks_advanced {
    name = docker_network.jenkins_network.name
    aliases = ["docker"]
  }

  env = [
    "DOCKER_TLS_CERTDIR=/certs"
  ]

  volumes {
    host_path      = "C:/docker/jenkins-docker-certs"  # Ruta absoluta en Windows
    container_path = "/certs/client"
  }

  volumes {
    host_path      = "C:/docker/jenkins-data"  # Ruta absoluta en Windows
    container_path = "/var/jenkins_home"
  }

  ports {
    internal = 2376
    external = 2376
  }
}

# Contenedor para Jenkins Blue Ocean
resource "docker_container" "jenkins_blueocean" {
  name  = "jenkins-blueocean"
  image = docker_image.jenkins_blueocean_image.name

  restart = "on-failure"
  networks_advanced {
    name = docker_network.jenkins_network.name
  }

  env = [
    "DOCKER_HOST=tcp://docker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1"
  ]

  volumes {
    host_path      = "C:/docker/jenkins-data"  # Ruta absoluta en Windows
    container_path = "/var/jenkins_home"
  }

  volumes {
    host_path      = "C:/docker/jenkins-docker-certs"  # Ruta absoluta en Windows
    container_path = "/certs/client"
    read_only      = true
  }

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }
}
