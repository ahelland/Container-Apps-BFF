@description('The location for the resource(s) to be deployed.')
param location string = resourceGroup().location

param bff_web_app_containerport string

param outputs_azure_container_apps_environment_default_domain string

param tenantid_value string

param app_outputs_clientid string

param app_outputs_uamiid string

param app_outputs_identifieruri string

param app_outputs_keyvaulturl string

param app_outputs_keyvaultsecret string

param outputs_azure_container_registry_managed_identity_id string

param outputs_managed_identity_client_id string

param outputs_azure_container_apps_environment_id string

param outputs_azure_container_registry_endpoint string

param bff_web_app_containerimage string

resource bff_web_app 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'bff-web-app'
  location: location
  properties: {
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: bff_web_app_containerport
        transport: 'http'
      }
      registries: [
        {
          server: outputs_azure_container_registry_endpoint
          identity: outputs_azure_container_registry_managed_identity_id
        }
      ]
    }
    environmentId: outputs_azure_container_apps_environment_id
    template: {
      containers: [
        {
          image: bff_web_app_containerimage
          name: 'bff-web-app'
          env: [
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EXCEPTION_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_EMIT_EVENT_LOG_ATTRIBUTES'
              value: 'true'
            }
            {
              name: 'OTEL_DOTNET_EXPERIMENTAL_OTLP_RETRY'
              value: 'in_memory'
            }
            {
              name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
              value: 'true'
            }
            {
              name: 'HTTP_PORTS'
              value: bff_web_app_containerport
            }
            {
              name: 'services__weatherapi__http__0'
              value: 'http://weatherapi.internal.${outputs_azure_container_apps_environment_default_domain}'
            }
            {
              name: 'services__weatherapi__https__0'
              value: 'https://weatherapi.internal.${outputs_azure_container_apps_environment_default_domain}'
            }
            {
              name: 'TenantId'
              value: tenantid_value
            }
            {
              name: 'ClientId'
              value: app_outputs_clientid
            }
            {
              name: 'UamiId'
              value: app_outputs_uamiid
            }
            {
              name: 'IdentifierUri'
              value: app_outputs_identifieruri
            }
            {
              name: 'KeyVaultUrl'
              value: app_outputs_keyvaulturl
            }
            {
              name: 'KeyVaultSecret'
              value: app_outputs_keyvaultsecret
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: outputs_managed_identity_client_id
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${outputs_azure_container_registry_managed_identity_id}': { }
    }
  }
}