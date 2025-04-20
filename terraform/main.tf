variable "k8s_host" {}
variable "docker_image" {}

provider "kubernetes" {
  host = var.k8s_host
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