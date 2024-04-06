metadata name = 'Private DNS A record'
metadata description = 'Creates an A record in a private DNS zone.'
metadata owner = 'ahelland'

@description('The name of the DNS record to be created.  The name is relative to the zone, not the FQDN.')
param recordName string
@description('IP address')
param ipAddress string
@description('Name of DNS zone')
param zone string

resource dnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: zone
}

resource record 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  parent: dnsZone
  name: recordName  
  properties: {    
    ttl: 3600
    aRecords: [
      {
        ipv4Address: ipAddress
      }
    ]
  }
}
