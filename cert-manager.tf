locals {
  letsencrypt_email           = "kontakt@freifunk-duesseldorf.de"
  letsencrypt_preferred_chain = "ISRG Root X1"
  acme_servers = {
    staging    = "https://acme-staging-v02.api.letsencrypt.org/directory"
    production = "https://acme-v02.api.letsencrypt.org/directory"
  }
}

resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name = "cert-manager-system"
  }
}

resource "helm_release" "cert_manager_chart" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.1.0"

  namespace = kubernetes_namespace.cert_manager_namespace.metadata.0.name

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "kubernetes_manifest" "cert_manager_issuers" {
  provider   = kubernetes-alpha
  depends_on = [helm_release.cert_manager_chart]
  for_each   = local.acme_servers

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      namespace = kubernetes_namespace.cert_manager_namespace.metadata.0.name
      name      = "letsencrypt-${each.key}"
    }
    spec = {
      acme = {
        email          = local.letsencrypt_email
        preferredChain = local.letsencrypt_preferred_chain
        privateKeySecretRef = {
          name = "cert-manager-letsencrypt-${each.key}-account-key"
        }
        server = each.value
        solvers = [
          {
            http01 = {
              ingress = {
                class = "traefik"
              }
            }
          },
        ]
      }
    }
  }
}
