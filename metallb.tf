resource "kubernetes_namespace" "metallb_namespace" {
  metadata {
    name = "metallb-system"
  }
}

resource "helm_release" "metallb_chart" {
  name       = "metallb"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metallb"
  version    = "2.0.4"

  namespace = kubernetes_namespace.metallb_namespace.metadata.0.name

  set {
    name  = "configInline"
    value = file("${path.module}/metallb-config.yaml")
  }
}
