targetScope = 'subscription'

@description('Location for Container Environment')
param location string
@description('Tags retrieved from parameter file.')
param resourceTags object = {}

param subId string = subscription().id
param acrName string = 'acr${uniqueString(subId)}'

resource rg_cae 'Microsoft.Resources/resourceGroups@2023-07-01' existing = {
  name: 'rg-bff-cae'
}

resource containerenvironment 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = {
  scope: rg_cae
  name: 'bff-cae-01'
}

module weatherapi '../modules/containers/container-app-acr/main.bicep' = {
  scope: rg_cae
  name: 'weatherapi'
  params: {
    location: location
    resourceTags: resourceTags
    containerAppEnvironmentId: containerenvironment.id
    containerRegistry: '${acrName}.azurecr.io'
    containerImage: '${acrName}.azurecr.io/weatherapi:latest'
    targetPort: 8080
    transport: 'http'
    externalIngress: false
    containerName: 'weatherapi'
    identityName: 'bff-cae-user-mi'
    name: 'weatherapi'
    minReplicas: 1
  }
}

module bff '../modules/containers/container-app-acr/main.bicep' = {
  scope: rg_cae
  name: 'bff-web-app'
  params: {
    location: location
    resourceTags: resourceTags
    containerAppEnvironmentId: containerenvironment.id
    containerRegistry: '${acrName}.azurecr.io'
    containerImage: '${acrName}.azurecr.io/bff_web_app:latest'
    targetPort: 8080
    externalIngress: true
    containerName: 'bffwebapp'
    identityName: 'bff-cae-user-mi'
    name: 'bff-web-app'
    minReplicas: 1
    envVars: [
      { name: 'ASPNETCORE_ENVIRONMENT', value: 'Production' }
    ]
  }
}

module bffDns '../modules/network/private-dns-record-a/main.bicep' = {
  scope: rg_cae
  name: 'bffDns'
  params: {
    ipAddress: containerenvironment.properties.staticIp
    recordName: bff.outputs.name
    zone: containerenvironment.properties.defaultDomain
  }
}
