terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }
}

provider "docker" {}

# Rede Docker
resource "docker_network" "analysis_network" {
  name = "analysis_network"
}

# Banco de Dados PostgreSQL
resource "docker_container" "postgres" {
  name  = "postgres_db"
  image = "postgres:15"
  env   = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}"
  ]
  ports {
    internal = 5432
    external = 5432
  }
  networks_advanced {
    name = docker_network.analysis_network.name
  }
}

# Jupyter Notebook
resource "docker_container" "jupyter" {
  name  = "jupyter_notebook"
  image = "jupyter/datascience-notebook:latest"
  env = [
    "JUPYTER_TOKEN=${var.jupyter_password}", 
    "JUPYTER_ENABLE_LAB=yes"
  ]
  ports {
    internal = 8888
    external = 8888
  }
  volumes {
    container_path = "/home/jovyan/work"
    host_path      = "C:/dev/CaioSathler/_devops/devops-uc1-aula5/notebooks"
  }
  networks_advanced {
    name = docker_network.analysis_network.name
  }
}

#Adminer
resource "docker_container" "adminer" {
  name  = "adminer"
  image = "adminer:latest"
  ports {
    internal = 8080
    external = 8080
  }
  networks_advanced {
    name = docker_network.analysis_network.name
  }
}