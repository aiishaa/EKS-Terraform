resource "kubernetes_secret" "sql_secret" {
  metadata {
    name = "my-sql-secret"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }

  data = {
    ACCEPT_EULA = "Y"
    MSSQL_SA_PASSWORD = base64encode("password123")
  }
}

resource "kubernetes_secret" "mongodb_secret" {
  metadata {
    name = "my-mongodb-secret"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }

  data = {
    MONGO_INITDB_ROOT_USERNAME = base64encode("admin")
    MONGO_INITDB_ROOT_PASSWORD = base64encode("password123")
  }
}