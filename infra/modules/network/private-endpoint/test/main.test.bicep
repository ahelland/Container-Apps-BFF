targetScope = 'subscription'

@description('Specifies the location for resources.')
param location string = 'norwayeast'

param resourceTags object = {
  value: {
    IaC: 'Bicep'
    Environment: 'Test' 
  }
}

resource rg_pe 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-pe'
  location: location
  tags: resourceTags
}

module pe '../main.bicep' = {
  scope: rg_pe
  name: 'pe'
  params: {
    resourceTags: resourceTags
    location: location
    peName: 'private-endpoint'
    serviceConnectionId: 'foobar.id'
    serviceConnectionGroupIds: 'foobar' 
    snetId: 'subscription/vnet/snet'
  }
}
