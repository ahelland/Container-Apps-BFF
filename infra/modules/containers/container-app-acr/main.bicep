metadata name = 'Container App ACR'
metadata description = 'Container App ACR'
metadata owner = 'ahelland'

@description('Specifies the location for resources.')
param location string = resourceGroup().location
@description('Tags retrieved from parameter file.')
param resourceTags object = {}
@description('Name of container app.')
param name string
@description('The id of the container environment to deploy app to.')
param containerAppEnvironmentId string
@description('Image of container. Defaults to mcr quickstart.')
param containerImage string = 'mcr.microsoft.com/k8se/quickstart:latest'
@description('The port exposed on the target container.')
param targetPort int
@allowed([
  'Auto'
  'http'
  'http2'
  'tcp'
])
@description('Which transport protocol to expose.')
param transport string = 'Auto'
@description('Enable external ingress.')
param externalIngress bool = true
@description('Minimum number of replicas.')
param minReplicas int = 0
@description('Maximum number of replicas.')
param maxReplicas int = 10
@description('Name of container.')
param containerName string = 'simple-hello-world-container'
@description('Registry to use for pulling images from. (Assumed to be in the form contosoacr.azurecr.io)')
param containerRegistry string
@description('Id of the user-assigned managed identity to use.')
param identityName string
@description('Environment variables.')
param envVars array = []
@description('Container App Service (Redis) to bind to.')
param serviceId string?

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: identityName
}

resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: name
  location: location
  tags: resourceTags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${mi.id}':{}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    environmentId: containerAppEnvironmentId
    workloadProfileName: 'Consumption'
    configuration: {
      registries: [
        {
          identity: mi.id
          server: containerRegistry
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: externalIngress
        targetPort: targetPort
        exposedPort: 0
        transport: transport
        traffic: [
          {
            weight: 100
            latestRevision: true
          }
        ]
        allowInsecure: false
      }
    }
    template: {
      serviceBinds: (!empty(serviceId)) ? [
        {
          serviceId: serviceId
          name: 'redis'
        }
      ] : []
      containers: [
        {
          image: containerImage
          name: containerName
          env: envVars
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
      }
    }
  }
}

@description('Name of the container app.')
output name string = containerApp.name
@description('The principalId for the system managed identity of the app.')
output principalId string = containerApp.identity.principalId
