# resource "kubernetes_config_map" "sql_config_map" {
#   metadata {
#     name = "sql-config-map"
#   }

#   data = {
#     database_name = "sql-database"
#     database_url = data.kubernetes_service.kubernetes_sql.name
#   }
# }

resource "kubernetes_config_map" "mongodb_config_map" {
  metadata {
    name = "mongo-config-map"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }

  data = {
    database_name = "mogodb-database"
    database_url = kubernetes_manifest.mongodb_service.manifest.metadata.name
  }
}

# resource "kubernetes_config_map" "redis_config_map" {
#   metadata {
#     name = "redis-config-map"
#   }

#   data = {
#     database_name = "redis-database"
#     database_url = data.kubernetes_service.kubernetes_redis.name
#   }
# }