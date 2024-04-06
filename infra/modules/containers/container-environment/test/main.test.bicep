targetScope = 'subscription'

param location string = 'norwayeast'
param resourceTags object = {
  value: {
    IaC: 'Bicep'
    Environment: 'Test' 
  }
}

resource rg_cae 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'contoso-cae'
  location: location
  tags: resourceTags
}

module cae '../main.bicep' = {
  scope: rg_cae
  name: 'cae-01'
  params: {
    location: location
    environmentName: 'cae-01'
    snetId: '/subscriptions/subscriptionId/resourceGroups/rg-vnet/providers/Microsoft.Network/virtualNetworks/core-vnet-weu/subnets/cae'
  }
}
