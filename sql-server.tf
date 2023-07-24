resource "kubernetes_manifest" "deployment_sql" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "name" = "sql",
      "namespace" = kubernetes_namespace.asp-app_namespace.metadata.0.name
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "sql"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "sql"
          }
        }
        "spec" = {
          "containers" = [
            {
              "env" = [
                {
                  "name" = "ACCEPT_EULA"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "ACCEPT_EULA"
                      "name" = kubernetes_secret.sql_secret.metadata.0.name
                    }
                  }
                },
                {
                  "name" = "MSSQL_SA_PASSWORD"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "MSSQL_SA_PASSWORD"
                      "name" = kubernetes_secret.sql_secret.metadata.0.name
                    }
                  }
                },
              ]
              "image" = "mcr.microsoft.com/mssql/server"
              "name" = "sql-container"
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
  depends_on = [ kubernetes_secret.sql_secret ]
}

resource "kubernetes_service" "sql_service" {
  metadata {
    name      = "sql"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_manifest.deployment_sql.manifest.spec.template.metadata.labels.app
    }
    port {
      port        = 1433
      target_port = 1433
    }
  }
  depends_on = [ kubernetes_manifest.deployment_sql ]
}