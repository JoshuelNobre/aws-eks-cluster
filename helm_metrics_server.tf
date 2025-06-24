resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "metrics-server"
  namespace  = "kube-system"

  version = "7.2.16"
  wait    = false

  set {
    name  = "apiService.create"
    value = "true"
  }

  set {
    name  = "extraArgs.kubelet-insecure-tls"
    value = ""
  }

  set {
    name  = "extraArgs.kubelet-preferred-address-types"
    value = "InternalIP"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_fargate_profile.kube-system
  ]
}
