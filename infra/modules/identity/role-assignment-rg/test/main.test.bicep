targetScope = 'subscription'

param location string = 'norwayeast'

param resourceTags object = {
  value: {
    IaC: 'Bicep'
    Environment: 'Test' 
  }
}

resource rg_app 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-app'
  location: location  
  tags: resourceTags
}

module userManagedIdentity '../../user-managed-identity/main.bicep' = {
  scope: rg_app
  name: 'contoso-user-mi'
  params: {
    resourceTags: resourceTags
    location: location
    miname: 'contoso-user-mi'
  }
}

module AcrPull_Role '../main.bicep' = {
  scope: rg_app
  name: guid('AcrPull_Role-ciam')
  params: {
    principalId: userManagedIdentity.outputs.managedIdentityPrincipal
    principalType: 'ServicePrincipal'
    roleName: 'AcrPull'
  }
}
