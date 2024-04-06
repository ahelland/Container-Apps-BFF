metadata name = 'Private Endpoint'
metadata description = 'Private Endpoint'
metadata owner = 'ahelland'

@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('Tags retrieved from parameter file.')
param resourceTags object = {}
@description('Name of the Private Endpoint.')
param peName string
@description('String array - "foo, bar"')
param serviceConnectionGroupIds string
@description('Subnet to attach private endpoint to.')
param snetId string?
@description('The connection id for the private link service.')
param serviceConnectionId string

resource pe 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: peName
  location: location
  tags: resourceTags
  properties: {
    manualPrivateLinkServiceConnections: []
    ipConfigurations: []
    subnet: {
      id: snetId
    }
    privateLinkServiceConnections: [
      {
         name: peName
         properties: {
          privateLinkServiceId: serviceConnectionId
          groupIds: [serviceConnectionGroupIds]
         }        
      }
    ]
  }
}

@description('IP Address of Private Endpoint')
output ip string = pe.properties.customDnsConfigs[0].ipAddresses[0]
@description('FQDN (public zone) of Private Endpoint')
output fqdn string = pe.properties.customDnsConfigs[0].fqdn
