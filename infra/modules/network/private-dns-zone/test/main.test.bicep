targetScope = 'subscription'

param location string = 'norwayeast'
param resourceTags object = {
  value: {
    IaC: 'Bicep'
    Environment: 'Test' 
  }
}

resource rg_dns 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'contoso-dns'
  location: location
  tags: resourceTags
}

module dnsZone '../main.bicep' = {
  scope: rg_dns
  name: 'dns'
  params: {
    resourceTags: resourceTags
    registrationEnabled: false
    vnetId: ''
    vnetName: ''
    zoneName: 'contoso.com'
  }
}
