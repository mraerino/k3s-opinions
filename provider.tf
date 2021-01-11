locals {
  config_context = "ffddorf-k3s2"
}

provider "kubernetes" {
  config_context = local.config_context
}

provider "kubernetes-alpha" {
  config_path    = "~/.kube/config"
  config_context = local.config_context

  server_side_planning = true
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = local.config_context
  }
}
