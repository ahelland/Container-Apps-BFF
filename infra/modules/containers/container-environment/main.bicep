metadata name = 'Container App Environment'
metadata description = 'Deploys a Container Environment in Azure.'
metadata owner = 'ahelland'

@description('Name of Container Environment')
param environmentName string
@description('Location for Container Environment')
param location string
@description('Tags retrieved from parameter file.')
param resourceTags object = {}

@description('Should the Container Environment be connected to a custom virtual network? Enabling this also requires a valid value for snetId.')
param vnetInternal bool = true
@description('If vnet integration is enabled which subnet should the container environment be connected to?')
param snetId string

//Include Log Analytics in module to avoid passing clientSecret via outputs
resource loganalytics 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'log-analytics-${environmentName}'
  location: location
  tags: resourceTags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

resource containerenvironment 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: environmentName
  location: location  
  tags: resourceTags
  properties: {    
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: loganalytics.properties.customerId
        sharedKey: loganalytics.listKeys().primarySharedKey
      }
    }
    vnetConfiguration: {
      internal: vnetInternal ? true : false
      //If vnetInternal == false, snetId is assumed to be null.
      infrastructureSubnetId: snetId
    }
    peerAuthentication: {
      mtls: {
        enabled: true
      }
    }
    workloadProfiles: [
      {
        workloadProfileType: 'Consumption'
        name: 'Consumption'
      }
    ]
  }  
}

@description('The default domain of the cluster.')
output defaultDomain string = containerenvironment.properties.defaultDomain
