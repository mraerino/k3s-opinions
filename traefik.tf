resource "helm_release" "traefik_install" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version    = "9.12.3"

  namespace = "kube-system"

  values = [file("${path.module}/traefik-helm-values.yaml")]
}

resource "kubernetes_service" "traefik_public" {
  metadata {
    namespace = helm_release.traefik_install.namespace
    name      = "traefik-public"
    labels = {
      app = "traefik"
    }
    annotations = {
      "metallb.universe.tf/address-pool" = "public-ips"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/instance" = "traefik"
      "app.kubernetes.io/name"     = "traefik"
    }

    type             = "LoadBalancer"
    load_balancer_ip = "45.151.166.27"

    port {
      name        = "web"
      port        = 80
      target_port = "web"
    }

    port {
      name        = "websecure"
      port        = 443
      target_port = "websecure"
    }
  }
}
