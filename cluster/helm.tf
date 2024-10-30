# resource "helm_release" "ingress-nginx" {
#   namespace        = "ingress"
#   create_namespace = true
#   name             = "ingress-nginx"
#   repository       = "https://kubernetes.github.io/ingress-nginx"
#   chart            = "ingress-nginx"
#   version          = "4.11.3"
#   timeout          = 300
#   max_history      = 5
#
#   values = [
#     file("${path.root}/helm/ingress-nginx/values.yaml")
#   ]
# }

# resource "helm_release" "prometheus-stack" {
#   namespace        = "monitoring"
#   create_namespace = true
#   name             = "prometheus-stack"
#   repository       = "https://prometheus-community.github.io/helm-charts"
#   chart            = "kube-prometheus-stack"
#   version          = "65.2.0"
#   timeout          = 600
#   max_history      = 5
#
#   values = [
#     file("${path.root}/helm/prometheus-stack/values.yaml")
#   ]
# }

# resource "helm_release" "eck-operator" {
#   namespace        = "elastic-operator"
#   create_namespace = true
#   name             = "eck-operator"
#   repository       = "https://helm.elastic.co"
#   chart            = "eck-operator"
#   version          = "2.12.1"
#   timeout          = 300
#   max_history      = 5

#   values = [
#     file("${path.root}/helm/eck-operator/values.yaml")
#   ]
# }

# resource "helm_release" "eck-stack" {
#   namespace        = "logging"
#   create_namespace = true
#   name             = "eck-stack"
#   repository       = "https://helm.elastic.co"
#   chart            = "eck-stack"
#   version          = "0.10.0"
#   timeout          = 300
#   max_history      = 5

#   values = [
#     file("${path.root}/helm/eck-stack/values.yaml")
#   ]
# }