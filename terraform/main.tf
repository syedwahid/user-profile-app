variable "k8s_host" {}
variable "docker_image" {}

provider "kubernetes" {
  host                   = "https://${var.k8s_host}:6443"  # Use HTTPS + Port 6443
  cluster_ca_certificate = file("~/.minikube/ca.ca.crt")  # Add CA cert
  client_certificate     = file("~/.minikube/proxy-client-ca.cert")       # Client cert
  client_key             = file("~/.minikube/proxy-client-ca.key")        # Client key
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