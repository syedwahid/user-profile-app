variable "k8s_host" {}
variable "docker_image" {}

provider "kubernetes" {
  host = "https://${var.k8s_host}:8443"  # Ensure port 8443 is included

  client_certificate     = file("/home/syedwahid/.minikube/profiles/minikube/client.crt")      # Client cert
  client_key             = file("/home/syedwahid/.minikube/profiles/minikube/client.key")       # Client key
  cluster_ca_certificate = file("/home/syedwahid/.minikube/ca.crt")                 # Add CA cert
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "user-profile-app"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "user-profile-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "user-profile-app"
        }
      }

      spec {
        container {
          name  = "app"
          image = var.docker_image
          port {
            container_port = 3000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = "user-profile-service"
  }

  spec {
    selector = {
      app = "user-profile-app"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer"
  }
}