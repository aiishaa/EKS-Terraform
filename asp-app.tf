resource "kubernetes_namespace" "asp-app_namespace" {
  metadata {
    name = "asp-app"
  }
}

resource "kubernetes_manifest" "deployment_asp-app" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app" = "asp-app"
      }
      "name" = "asp-app"
      "namespace" = kubernetes_namespace.asp-app_namespace.metadata.0.name
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "asp-app"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "asp-app"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "MONGO_INITDB_ROOT_USERNAME"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "MONGO_INITDB_ROOT_USERNAME"
                      "name" = kubernetes_secret.mongodb_secret.metadata.0.name
                    }
                  }
                },
                {
                  "name" = "MONGO_INITDB_ROOT_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "MONGO_INITDB_ROOT_PASSWORD"
                      "name" = kubernetes_secret.mongodb_secret.metadata.0.name
                    }
                  }
                },
                {
                  "name"  = "database_url"
                  "valueFrom" = {
                    "configMapKeyRef" = {
                      "name"      = kubernetes_config_map.mongodb_config_map.metadata.0.name
                      "key"       = "database_url"
                    }
                  }
                },
                {
                  "name"  = "MSSQL_SA_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                        "name"      = kubernetes_secret.sql_secret.metadata.0.name
                        "key"       = "MSSQL_SA_PASSWORD"
                    }
                  }
                },
              ]
              "image" = "aishafathy/aspnet-application-image"
              "name" = "asp-app"
              "ports" = [
                {
                  "containerPort" = 80
                },
              ]
            },
          ]
        }
      }
    }
  }
  depends_on = [ kubernetes_secret.sql_secret, kubernetes_secret.mongodb_secret ]
}

resource "kubernetes_service" "asp-app_service" {
  metadata {
    name      = "asp-app"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_manifest.deployment_asp-app.manifest.spec.template.metadata.labels.app
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "my-ingress" {
  metadata {
    name = "my-ingress"
  }
  spec {
    rule {
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.asp-app_service.metadata.0.name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

output "my_external_ALB_ingress" {
  description = "this is the external ALB ingress dns name"
  value = kubernetes_service.asp-app_service.status.0.load_balancer.0.ingress.0.hostname
}
