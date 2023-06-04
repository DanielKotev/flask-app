resource "kubernetes_service_account" "dns-account" {
  depends_on = [module.external_dns_irsa_role]
  metadata {
    name      = "external-dns"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "external-dns"
      "app.kubernetes.io/component" = "external-dns"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.external_dns_irsa_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "kubernetes_service_account" "cert-account" {
  depends_on = [module.cert_manager_irsa_role]
  metadata {
    name      = "cert-manager"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name" = "cert-manager"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.cert_manager_irsa_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}





resource "helm_release" "external_dns" {
  depends_on = [module.eks]
  name       = "external-dns"
  chart      = "external-dns"
  repository = "https://charts.bitnami.com/bitnami"
  version    = "6.13.2"
  namespace  = "kube-system"
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns"
  }
  set {
    name  = "sources"
    value = "{ingress}"
  }
  set {
    name  = "registry"
    value = "txt"
  }
  set {
    name  = "domainFilters"
    value = "daguaniko.com"
  }
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "txtPrefix"
    value = "prefix"
  }
  set {
    name  = "txtOwnerId"
    value = "Owner"
  }
}

resource "helm_release" "cert-manager" {
  depends_on = [module.eks]
  name       = "cert-manager"
  atomic     = true
  wait       = true
  version    = "1.11.0"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "kube-system"

  set {
    name  = "installCRDs"
    value = "true"
  }


  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "cert-manager"
  }
}

resource "helm_release" "nginx-ingress" {
  depends_on = [module.eks]
  name       = "nginx-ingress-controller"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx-ingress-controller"
  version    = "9.7.2"
  atomic     = true
  wait       = true
  namespace  = "kube-system"
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "publishService.enabled"
    value = "true"
  }
}

