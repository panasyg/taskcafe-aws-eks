output "url" {
  value = kubernetes_service.web_service.status.0.load_balancer.0.ingress.0.hostname
}