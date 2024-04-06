metadata name = 'Private DNS Zone'
metadata description = 'A module for generating an empty Private DNS Zone.'
metadata owner = 'ahelland'

@description('Tags retrieved from parameter file.')
param resourceTags object = {}

@description('The name of the DNS zone to be created.  Must have at least 2 segments, e.g. hostname.org')
param zoneName string

@description('Enable auto-registration for virtual network.')
param registrationEnabled bool
@description('The name of vnet to connect the zone to (for naming of link). Null if registrationEnabled is false.')
param vnetName string?
@description('Vnet to link up with. Null if registrationEnabled is false.')
param vnetId string?

resource zone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: zoneName
  location: 'global'
  tags: resourceTags
  
  resource vnet 'virtualNetworkLinks@2020-06-01' = if (!empty(vnetName)) {
    name: '${vnetName}-link'
    location: 'global'
    properties: {
      registrationEnabled: registrationEnabled
      virtualNetwork: {
        id: vnetId
      }
    }    
  }
}
