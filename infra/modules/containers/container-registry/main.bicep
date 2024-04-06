metadata name = 'Azure Container Registry'
metadata description = 'Deploys an Azure Container Registry.'
metadata owner = 'ahelland'

@description('The location to deploy to.')
param location string

@description('Tags retrieved from parameter file.')
param resourceTags object = {}

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name for your Azure Container Registry')
param acrName string
@description('Provide a tier for your Azure Container Registry.')
param acrSku string
@description('Should the admin user be enabled (for non-managed identity access).')
param adminUserEnabled bool = false
@description('Allow anonymous pull (requires Premium SKU).')
param anonymousPullEnabled bool
@description('Managed identity type for the registry.')
param managedIdentity string
@description('Should the endpoint be publicly available?')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string

resource acrResource 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
  tags: resourceTags
  identity: {
    type: managedIdentity
  }
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    anonymousPullEnabled: anonymousPullEnabled
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('The id of the container registry.')
output id string = acrResource.id
@description('Generated name of container registry.')
output acrName string = acrResource.name
@description('Output the login server property.')
output loginServer string = acrResource.properties.loginServer
