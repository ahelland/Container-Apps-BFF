metadata name = 'Container App Docker Hub'
metadata description = 'Container App Docker Hub'
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
@description('Name of container.')
param containerName string
@description('The port exposed on the target container.')
param targetPort int
@description('The port exposed on ingress.')
param exposedPort int?
@allowed([
  'http'
  'tcp'
])
@description('Which transport protocol to expose.')
param transport string = 'http'
@description('Minimum number of replicas.')
param minReplicas int = 0
@description('Maximum number of replicas.')
param maxReplicas int = 10
@description('Environment variables.')
param envVars array = []

resource containerApp 'Microsoft.App/containerApps@2023-11-02-preview' = {
  name: name
  location: location
  tags: resourceTags
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    environmentId: containerAppEnvironmentId
    workloadProfileName: 'Consumption'
    configuration: {
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: targetPort
        exposedPort: exposedPort
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
      revisionSuffix: ''
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
  identity: {
    type: 'None'
  }
}

@description('Name of the container app.')
output name string = containerApp.name
