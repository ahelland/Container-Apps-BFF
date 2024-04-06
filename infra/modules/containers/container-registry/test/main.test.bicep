targetScope = 'subscription'

param location string = 'norwayeast'

param resourceTags object = {
  value: {
    IaC: 'Bicep'
    Environment: 'Test' 
  }
}

//Azure Container Registries
resource rg_acr 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-core-acr'  
  location: location
  tags: resourceTags
}

// ACR for container images
param acrName string = 'acr${uniqueString('rg-core-acr')}'
param acrSku string = 'Standard'
param acrManagedIdentity string = 'SystemAssigned'

module acr '../main.bicep' = {
  scope: rg_acr
  name: acrName
  params: {
    resourceTags: resourceTags
    acrName: acrName
    acrSku: acrSku
    adminUserEnabled: false
    anonymousPullEnabled: false 
    location: location
    managedIdentity: acrManagedIdentity
    publicNetworkAccess: 'Disabled'
  }
}
