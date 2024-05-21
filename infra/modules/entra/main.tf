data "azuread_client_config" "current" {}

resource "azuread_application" "docker_containers" {
  display_name = "docker-containers"
  # identifier_uris = ["api://example-app"]
  identifier_uris = ["docker-containers"]
  owners          = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "docker_containers" {
  client_id                    = azuread_application.docker_containers.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "docker_containers" {
  service_principal_id = azuread_service_principal.docker_containers.object_id
}
