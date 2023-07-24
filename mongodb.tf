resource "kubernetes_manifest" "deployment_mongodb" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "mongodb",
      "namespace" = kubernetes_namespace.asp-app_namespace.metadata.0.name
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "mongodb"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "mongodb"
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
              ]
              "image" = "mongo:latest"
              "name" = "mongodb"
              "ports" = [
                {
                  "containerPort" = 27017
                },
              ]
            },
          ]
        }
      }
    }
  }
  depends_on = [ kubernetes_secret.mongodb_secret ]
}

resource "kubernetes_manifest" "mongodb_service" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Service"
    "metadata" = {
      "name" = "mongodb-service"
      "namespace" = kubernetes_namespace.asp-app_namespace.metadata.0.name
    }
    "spec" = {
      "ports" = [
        {
          "port" = 27017
          "protocol" = "TCP"
          "targetPort" = 27017
        },
      ]
      "selector" = {
        "app" = "mongodb"
      }
    }
  }
}

# data "kubernetes_manifest" "mongodb_service" {
#   name = kubernetes_manifest.mongodb_service.manifest.0.metadata.0.name
# }