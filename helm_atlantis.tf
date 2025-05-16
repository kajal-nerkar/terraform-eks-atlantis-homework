# Ensure the atlantis namespace exists
resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = "atlantis"
  }
}

# Deploy Atlantis via Helm
resource "helm_release" "atlantis" {
  name       = "atlantis"
  repository = "https://runatlantis.github.io/helm-charts"
  chart      = "atlantis"
  version    = var.atlantis_chart_version
  namespace  = kubernetes_namespace.atlantis.metadata[0].name

  # Your values.yaml for chart configuration
  values = [
    file("${path.module}/../atlantis-values.yaml")
  ]

  # Sensitive GitHub settings
  set_sensitive {
    name  = "github.token"
    value = var.github_token
  }

  set_sensitive {
    name  = "github.secret"
    value = var.github_webhook_secret
  }

  depends_on = [
    module.eks
  ]
}
