resource "kubernetes_namespace" "main" {
  metadata {
    name = var.name
  }
}

resource "kubernetes_deployment" "taskcafe" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.main.metadata.0.name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.name
      }
    }
    template {
      metadata {
        labels = {
          app = var.name
        }
      }
      spec {
        init_container {
          name =  "check-psql-ready"
          image = "postgres:9.6.5"
          command = [
            "sh", "-c", "until pg_isready -h ${var.db_host} -p 5432; do echo waiting for database; sleep 2; done; "
            ]
        }
        container {
          image = var.image
          name  = "taskcafe"
          port {
            container_port = 80
          }
          env {
              name = "TASKCAFE_DATABASE_HOST"
              value = var.db_host
          }
          env {
              name = "TASKCAFE_DATABASE_USER"
              value = var.db_user
          }
          env {
              name = "TASKCAFE_DATABASE_PASSWORD"
              value = var.db_pass
          }
          env {
              name = "TASKCAFE_DATABASE_NAME"
              value = var.db_name
          }
          env {
              name = "TASKCAFE_MIGRATE"
              value = true
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web_service" {
  metadata {
    name      = var.name
    namespace = kubernetes_namespace.main.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.taskcafe.spec.0.template.0.metadata.0.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 3333
    }
  }
}

