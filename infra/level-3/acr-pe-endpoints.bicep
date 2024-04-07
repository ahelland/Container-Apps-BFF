//Private Endpoints specifically for ACR

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

resource pe 'Microsoft.Network/privateEndpoints@2022-09-01' = {
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

@description('IP Address of root Private Endpoint')
output ip_0 string = pe.properties.customDnsConfigs[0].ipAddresses[0]
@description('IP Address of region-specific Private Endpoint')
output ip_1 string = pe.properties.customDnsConfigs[1].ipAddresses[0]
@description('FQDN (public zone) of root Private Endpoint')
output fqdn_0 string = pe.properties.customDnsConfigs[0].fqdn
@description('FQDN (public zone) of region-specific Private Endpoint')
output fqdn_1 string = pe.properties.customDnsConfigs[1].fqdn
