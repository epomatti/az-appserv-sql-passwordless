output "docker_container_service_principal_object_id" {
  value = azuread_service_principal.docker_containers.object_id
}

output "docker_container_service_principal_id" {
  value = azuread_service_principal.docker_containers.id
}

output "docker_container_client_id" {
  value = azuread_application.docker_containers.client_id
}

output "docker_container_app_password" {
  value = azuread_service_principal_password.docker_containers.value
}
