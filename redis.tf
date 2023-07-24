resource "kubernetes_deployment" "redis_deployment" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "redis"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis"
        }
      }
      spec {
        container {
          image = "redis"
          name  = "redis-container"
          port {
            container_port = 6379
          }
        }
      }
    }
  }
  # depends_on = [ aws_eks_node_group.private-nodes, kubernetes_namespace.asp-app_namespace ]
}

resource "kubernetes_service" "redis_service" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.asp-app_namespace.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.redis_deployment.spec.0.template.0.metadata.0.labels.app
    }
    port {
      port        = 6379
      target_port = 6379
    }
  }
  depends_on = [ kubernetes_deployment.redis_deployment ]
}